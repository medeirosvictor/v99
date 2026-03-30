--- GitHub Copilot CLI provider for 99.
--- Uses the `copilot` CLI in non-interactive mode (-p flag).
--- Passes the prompt via stdin to avoid Windows CreateProcess mangling
--- of long strings with XML tags, newlines, and special characters.
---
--- The model defaults to whatever the user has configured in their
--- Copilot CLI (~/.copilot/config.json, COPILOT_MODEL env, or the
--- CLI's built-in default). Set opts.model in v99.setup() to override.
---
--- Usage:
---   v99.setup({ provider = require("v99.providers.copilot") })

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

local CopilotProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- Build the command for non-interactive copilot.
--- The prompt itself is NOT included here — it is piped via stdin
--- in make_request() to avoid Windows argv mangling.
--- @param context _99.Prompt
--- @return string[]
function CopilotProvider:_build_command(_, context)
  local cmd = {
    "copilot",
    "-p", "-",       -- read prompt from stdin
    "-s",            -- silent: suppress stats, output only the response
    "--allow-all",   -- skip all permission prompts
    "--no-ask-user", -- prevent the agent from pausing to ask for input
  }

  if context.model and context.model ~= "" then
    table.insert(cmd, "--model")
    table.insert(cmd, context.model)
  end

  return cmd
end

--- @return string
function CopilotProvider:_get_provider_name()
  return "CopilotProvider"
end

--- @return string
function CopilotProvider:_get_default_model()
  -- Empty string = use copilot CLI's own configured default.
  -- Set opts.model in v99.setup() to override.
  return ""
end

--- Hardcoded model list from the Copilot CLI docs.
--- The CLI has no programmatic way to list available models.
function CopilotProvider.fetch_models(callback)
  callback({
    "claude-opus-4.5",
    "claude-sonnet-4.5",
    "claude-haiku-4.5",
    "gpt-5.2",
    "gpt-5.3-codex",
  }, nil)
end

--- Override make_request to pass the prompt via stdin instead of as an
--- argv argument. On Windows, long strings with XML tags and newlines
--- get mangled by CreateProcess when passed as argv — stdin handles
--- them correctly.
--- @param query string
--- @param context _99.Prompt
--- @param observer _99.Providers.Observer
function CopilotProvider:make_request(query, context, observer)
  observer.on_start()

  local logger = context.logger:set_area(self:_get_provider_name())
  local command = self:_build_command(nil, context)
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

return CopilotProvider
