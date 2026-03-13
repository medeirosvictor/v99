# v99

A wrapper around [ThePrimeagen/99](https://github.com/ThePrimeagen/99) that provides:
- Custom provider adapters (pi, ollama, etc.)
- Pin to specific 99 commits for stability
- Easy configuration

## Installation

```lua
-- Using lazy.nvim
{ "victor/v99", dependencies = { "ThePrimeagen/99" } }
```

## Usage

```lua
-- Basic setup (uses pi provider by default)
require("v99").setup({})

-- With custom options
require("v99").setup({
  -- Use pi provider (default)
  provider = require("v99.providers").pi,
  
  -- Or use a different provider
  -- provider = require("99.providers").OpenCodeProvider,
  -- provider = require("99.providers").ClaudeCodeProvider,
  
  model = "claude-sonnet-4-5",
  logger = {
    level = require("v99").DEBUG,
    path = "/tmp/myproject.99.debug",
    print_on_error = true,
  },
  tmp_dir = "./tmp",
  completion = {
    custom_rules = { "scratch/custom_rules/" },
    source = "native",
  },
  md_files = { "AGENT.md" },
})

-- Keymaps
vim.keymap.set("v", "<leader>9v", function() require("v99").api.visual() end)
vim.keymap.set("n", "<leader>9x", function() require("v99").api.stop_all_requests() end)
vim.keymap.set("n", "<leader>9s", function() require("v99").api.search() end)
```

## Providers

### Pi Provider (default)

Uses the `pi` CLI for AI coding assistance.

```lua
provider = require("v99.providers.pi")
```

## API

The wrapped 99 API is available via `require("v99").api`:

- `api.visual()` - Send visual selection to AI
- `api.search()` - Search across project
- `api.vibe()` - Start a vibe session
- `api.stop_all_requests()` - Cancel all requests
- `api.open()` - View previous interactions
- `api.view_logs()` - View debug logs
- `api.clear_previous_requests()` - Clear history

## Commit Pinning

To pin to a specific 99 commit for stability, edit `lua/v99/init.lua` and set:

```lua
local PINNED_COMMIT = "abc123f"
```

Then manually checkout that commit in the 99 plugin directory when updates break your workflow.

## License

MIT
