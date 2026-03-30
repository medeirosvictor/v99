--- GitHub Copilot CLI provider for 99.
--- Uses the `copilot` CLI in non-interactive mode (-p flag).
---
--- The model defaults to whatever the user has configured in their
--- Copilot CLI (~/.copilot/config.json, COPILOT_MODEL env, or the
--- CLI's built-in default). Set opts.model in v99.setup() to override.
---
--- Usage:
---   v99.setup({ provider = require("v99.providers.copilot") })

local Providers = require("99.providers")

local CopilotProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- Build the command for non-interactive copilot.
--- The prompt text is passed directly as the -p argument value.
--- @param query string
--- @param context _99.Prompt
--- @return string[]
function CopilotProvider:_build_command(query, context)
  local cmd = {
    "copilot",
    "-p", query,       -- prompt text passed directly as argv
    "-s",              -- silent: suppress stats, output only the response
    "--allow-all",     -- skip all permission prompts
    "--no-ask-user",   -- prevent the agent from pausing to ask for input
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

-- No make_request override needed — BaseProvider:make_request() handles
-- process spawning, stdout/stderr routing, and _retrieve_response() correctly.

return CopilotProvider
