# v99

A wrapper around [ThePrimeagen/99](https://github.com/ThePrimeagen/99) that provides:
- Custom provider adapters (pi, ollama, etc.)
- Pin to specific 99 commits for stability
- Easy configuration

## Installation

```lua
-- Using lazy.nvim
{ "medeirosvictor/v99", dependencies = { "ThePrimeagen/99" } }
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

### Pinning v99 Itself

To pin v99 to a specific version, specify the commit/branch in your config:

```lua
{ "medeirosvictor/v99", commit = "abc123f" }
```

### Pinning 99 Dependency

If 99 upstream breaks, you can lock it to a known-working commit. Edit `lua/v99/init.lua` and set:

```lua
local PINNED_COMMIT = "abc123f"  -- your known-good commit
```

Then manually checkout that commit in the 99 plugin directory:

```bash
# Find where lazy.nvim installed 99
cd ~/.local/share/nvim/lazy/ThePrimeagen/99
git checkout abc123f
```

To find a good commit to pin to, check the [99 commits](https://github.com/ThePrimeagen/99/commits/master) and note one that works for you.

### Recovery Workflow

If 99 updates and breaks your workflow:

1. Identify the breaking change (check `/tmp/<project>.99.debug` logs)
2. Find a working commit: `git log --oneline` in the 99 plugin directory
3. Pin with `PINNED_COMMIT` in v99
4. Optionally, open an issue on 99

## License

MIT
