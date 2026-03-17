--- Claude Code provider for 99.
--- Calls the local `claude` CLI in non-interactive mode.
--- Uses whatever model/auth the claude CLI is configured with by default.
---
--- Usage:
---   v99.setup({ provider = require("v99.providers.claude") })

local Providers = require("99.providers")

local ClaudeProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- @param query string
--- @param context _99.Prompt
--- @return string[]
function ClaudeProvider._build_command(_, query, context)
  local cmd = { "claude", "--dangerously-skip-permissions", "--print" }

  -- Only pass --model if explicitly set by the user in v99.setup()
  if context.model and context.model ~= "" then
    table.insert(cmd, "--model")
    table.insert(cmd, context.model)
  end

  -- Use @file to avoid Windows CreateProcess mangling of long prompts.
  local prompt_file = context.tmp_file .. "-prompt"
  table.insert(cmd, "@" .. prompt_file)

  return cmd
end

--- @return string
function ClaudeProvider._get_provider_name()
  return "ClaudeProvider"
end

--- @return string
function ClaudeProvider._get_default_model()
  -- Empty string = use claude CLI's own configured default.
  -- Set opts.model in v99.setup() to override.
  return ""
end

return ClaudeProvider
