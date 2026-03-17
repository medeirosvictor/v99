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
  if context.model and context.model ~= "" then
    table.insert(cmd, "--model")
    table.insert(cmd, context.model)
  end

  -- Use @file instead of inlining the prompt as an argv element.
  -- On Windows, vim.system passes long strings with special characters
  -- (<>, quotes, newlines) through CreateProcess which mangles them.
  -- The prompt is already saved to context.tmp_file .. "-prompt" by 99
  -- before make_request is called. Pi's @file syntax reads it cleanly.
  local prompt_file = context.tmp_file .. "-prompt"
  table.insert(cmd, "@" .. prompt_file)

  return cmd
end

--- @return string
function PiProvider:_get_provider_name()
  return "PiProvider"
end

--- @return string
function PiProvider:_get_default_model()
  -- Empty string = use pi's own configured default.
  -- Set opts.model in v99.setup() to override.
  return ""
end

return PiProvider
