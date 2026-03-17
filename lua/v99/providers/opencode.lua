--- OpenCode provider for 99.
--- Passes the prompt via stdin to avoid Windows CreateProcess argv mangling.
--- Uses whatever model opencode is configured with by default.
---
--- Usage:
---   v99.setup({ provider = require("v99.providers.opencode") })

local Providers = require("99.providers")

local once = (function()
  return function(fn)
    local called = false
    return function(...)
      if called then return end
      called = true
      fn(...)
    end
  end
end)()

local OpenCodeProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- @return string[]
function OpenCodeProvider._build_command()
  return { "opencode", "run" }
end

--- @return string
function OpenCodeProvider._get_provider_name()
  return "OpenCodeProvider"
end

--- @return string
function OpenCodeProvider._get_default_model()
  -- Empty string = use opencode's own configured default.
  return ""
end

--- Override make_request to pass the prompt via stdin instead of as an argv
--- argument. On Windows, long strings with XML tags and newlines get mangled
--- by CreateProcess when passed as argv — stdin handles them correctly.
--- @param query string
--- @param context _99.Prompt
--- @param observer _99.Providers.Observer
function OpenCodeProvider:make_request(query, context, observer)
  observer.on_start()

  local logger = context.logger:set_area(self:_get_provider_name())
  local command = self._build_command()
  logger:debug("make_request", "command", command)

  local once_complete = once(function(status, text)
    observer.on_complete(status, text)
  end)

  local proc = vim.system(
    command,
    {
      text = true,
      stdin = query,
      stdout = vim.schedule_wrap(function(err, data)
        if context:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if not err and data then
          observer.on_stdout(data)
        end
      end),
      stderr = vim.schedule_wrap(function(err, data)
        if context:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if not err and data then
          observer.on_stderr(data)
        end
      end),
    },
    vim.schedule_wrap(function(obj)
      if context:is_cancelled() then
        once_complete("cancelled", "")
        return
      end
      if obj.code ~= 0 then
        once_complete(
          "failed",
          string.format("process exit code: %d\n%s", obj.code, vim.inspect(obj))
        )
        logger:fatal(
          self:_get_provider_name() .. " make_query failed",
          "obj from results",
          obj
        )
      else
        vim.schedule(function()
          local ok, res = self:_retrieve_response(context)
          if ok then
            once_complete("success", res)
          else
            once_complete("failed", "unable to retrieve response from temp file")
          end
        end)
      end
    end)
  )

  context:_set_process(proc)
end

return OpenCodeProvider
