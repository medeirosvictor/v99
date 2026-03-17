--- Pi coding agent provider for 99.
--- Uses pi CLI in non-interactive mode.
---
--- Usage:
---   local v99 = require("v99")
---   v99.setup({
---     provider = require("v99.providers.pi"),
---   })

local Providers = require("99.providers")

local PiProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- @param query string
--- @param context _99.Prompt
--- @return string[]
function PiProvider:_build_command(query, context)
  local cmd = { "pi", "-p" }

  -- Add model if specified
  if context.model then
    table.insert(cmd, "--model")
    table.insert(cmd, context.model)
  end

  -- The query already contains the TEMP_FILE instruction from 99's prompt
  -- builder. Pi's write tool will create the file as instructed.
  table.insert(cmd, query)

  return cmd
end

--- @return string
function PiProvider:_get_provider_name()
  return "PiProvider"
end

--- @return string | nil
function PiProvider:_get_default_model()
  -- Return nil so pi uses its own configured default provider/model.
  -- Set opts.model in v99.setup() to override explicitly.
  return nil
end

return PiProvider
