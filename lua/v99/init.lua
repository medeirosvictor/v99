--- v99 - 99 wrapper with custom providers
---
--- A wrapper around ThePrimeagen/99 that provides:
--- - Custom provider adapters (pi, ollama, etc.)
--- - Pin to specific 99 commits for stability
--- - Easy configuration
---
--- Usage:
---   { "medeirosvictor/v99", dependencies = { "ThePrimeagen/99" } }
---
--- In your config:
---   require("v99").setup({
---     provider = require("v99.providers").pi(),
---     -- ... other 99 options
---   })

local M = {}

-- ============================================================================
-- COMMIT PINNING
-- ============================================================================
-- If 99 upstream breaks, set this to a known-working commit.
-- Then manually checkout in the 99 plugin directory:
--   cd ~/.local/share/nvim/lazy/ThePrimeagen/99 && git checkout <commit>
-- ============================================================================
local PINNED_99_COMMIT = nil  -- e.g., "abc123f"

-- ============================================================================

--- @class v99.Options
--- @field provider? _99.Providers.BaseProvider
--- @field model? string
--- @field logger? _99.Logger.Options
--- @field tmp_dir? string
--- @field completion? _99.Completion
--- @field md_files? string[]
--- @field in_flight_options? _99.StatusWindow.Opts

--- Setup v99 (wrapper around 99.setup)
--- @param opts v99.Options
function M.setup(opts)
  opts = opts or {}
  
  local _99 = require("99")
  local cwd = vim.uv.cwd()
  local basename = vim.fs.basename(cwd)
  
  -- Default to PiProvider if no provider specified
  local provider = opts.provider
  if not provider then
    provider = require("v99.providers.pi")
  end
  
  -- Build 99 config
  local config = {
    provider = provider,
    logger = opts.logger or {
      level = _99.DEBUG,
      path = "/tmp/" .. basename .. ".99.debug",
      print_on_error = true,
    },
    tmp_dir = opts.tmp_dir or "./tmp",
    completion = opts.completion or {
      custom_rules = {},
      source = "native",
    },
    md_files = opts.md_files or { "AGENT.md" },
    in_flight_options = opts.in_flight_options,
  }
  
  if opts.model then
    config.model = opts.model
  end
  
  -- Initialize 99
  _99.setup(config)

  -- Actually activate the provider (99.setup only uses opts.provider for the
  -- default model name — provider_override must be set separately)
  _99.set_provider(provider)

  -- Register v99 providers into 99's picker table
  _99.Providers.PiProvider = require("v99.providers.pi")
  _99.Providers.ClaudeProvider = require("v99.providers.claude")

  -- Expose 99 API for direct access if needed
  M.api = _99
end

--- Get the providers module
M.providers = setmetatable({}, {
  __index = function(_, name)
    return require("v99.providers." .. name)
  end
})

--- Expose 99 logger levels
M.DEBUG = require("99.logger.level").DEBUG
M.INFO = require("99.logger.level").INFO
M.WARN = require("99.logger.level").WARN
M.ERROR = require("99.logger.level").ERROR
M.FATAL = require("99.logger.level").FATAL

return M
