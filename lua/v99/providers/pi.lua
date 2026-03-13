--- Pi coding agent provider for 99.
--- Uses pi CLI in non-interactive mode with appended context.
---
--- Usage:
---   local v99 = require("v99")
---   v99.setup({
---     provider = v99.providers.pi({
---       model = "claude-sonnet-4-5",  -- optional, uses default if not set
---     })
---   })
---
--- Or simply:
---   v99.setup({})  -- uses pi provider by default

local Providers = require("99.providers")

local PiProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- @param query string
--- @param context _99.Prompt
--- @return string[]
function PiProvider:_build_command(query, context)
  local cmd = { "pi", "-p" }
  
  -- Append context file if available
  if context.tmp_file then
    table.insert(cmd, "--append-system-prompt")
    table.insert(cmd, "@" .. context.tmp_file)
  end
  
  -- Add model if specified
  if context.model then
    table.insert(cmd, "--model")
    table.insert(cmd, context.model)
  end
  
  -- Add the query/prompt
  table.insert(cmd, query)
  
  return cmd
end

--- @return string
function PiProvider:_get_provider_name()
  return "PiProvider"
end

--- @return string
function PiProvider:_get_default_model()
  return "claude-sonnet-4-5"
end

return PiProvider
