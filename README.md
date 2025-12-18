# Mason ASL LSP

A Mason plugin that provides seamless integration of the ASL Language Server with Neovim's Mason package manager.

## Features

- **Zero Configuration**: Automatically registers `asl_lsp` with Mason and lspconfig
- **Smart Installation**: Handles external installation via npm
- **Seamless Integration**: Works with existing Mason + lspconfig + completion setups
- **File Detection**: Automatically detects and starts LSP for ASL files

## Installation

### Prerequisites

1. Install the ASL Language Server first:

   ```bash
   git clone https://github.com/rperez-torro/asl-lsp-server.git
   cd asl-lsp-server
   npm install && npm run install-global
   ```

2. Verify installation:
   ```bash
   asl-lsp-server --version
   # Should output: asl-lsp-server v1.0.0
   ```

### Install Mason Plugin

#### Using lazy.nvim

```lua
{
  "rperez-torro/mason-asl-lsp",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason-asl-lsp").setup()
  end,
}
```

#### Using packer.nvim

```lua
use {
  "rperez-torro/mason-asl-lsp",
  requires = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason-asl-lsp").setup()
  end,
}
```

#### Manual Installation

```bash
git clone https://github.com/rperez-torro/mason-asl-lsp.git ~/.local/share/nvim/site/pack/plugins/start/mason-asl-lsp
```

## Usage

### Basic Setup

After installation, simply add `asl_lsp` to your servers table:

```lua
local servers = {
  -- ... your other servers
  asl_lsp = {}, -- That's it! Zero configuration required
}
```

### Advanced Configuration

```lua
local servers = {
  asl_lsp = {
    settings = {
      asl = {
        validate = true,
        completion = {
          snippets = true,
          stateNames = true
        }
      }
    },
    -- Custom root directory detection
    root_dir = require('lspconfig.util').root_pattern('.asl', 'state-machines', '.git'),
  },
}
```

## What This Plugin Does

1. **Registers `asl_lsp` with lspconfig**: Makes `asl_lsp` available as a standard LSP server
2. **Excludes from Mason auto-install**: Prevents "Cannot find package asl_lsp" errors
3. **Sets up file detection**: Automatically starts ASL LSP for `.asl.json`, `.asl.yaml` files
4. **Configures filetypes**: Properly sets JSON/YAML filetypes for ASL files

## Replaces Complex Manual Setup

**Before (57+ lines of complex configuration):**

```lua
-- Manual server registration
local configs = require('lspconfig.configs')
if not configs.asl_lsp then
  configs.asl_lsp = { ... } -- 20+ lines
end

-- Mason exclusion filter
ensure_installed = vim.tbl_filter(function(server_name)
  return server_name ~= 'asl_lsp'
end, ensure_installed)

-- Manual autocmds
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  -- ... 15+ lines
})
```

**After (1 line):**

```lua
asl_lsp = {}, -- Just add to your servers table!
```

## Supported File Patterns

- `*.asl.json` - JSON format ASL files
- `*.asl.yaml` - YAML format ASL files
- `*.asl.yml` - YAML format ASL files
- `*.asl` - JSON format ASL files (fallback)

## Troubleshooting

### LSP Not Starting

1. Verify ASL server is installed: `asl-lsp-server --version`
2. Check LSP status: `:LspInfo` in Neovim
3. Verify file has correct extension (`.asl.json` or `.asl.yaml`)

### Mason Registry Errors

If you still see Mason registry errors, ensure this plugin is loaded before Mason setup:

```lua
-- Load mason-asl-lsp first
require("mason-asl-lsp").setup()

-- Then setup Mason
require("mason").setup()
require("mason-lspconfig").setup()
```

## API Reference

### `require("mason-asl-lsp").setup(opts)`

Setup the Mason ASL LSP integration.

**Parameters:**

- `opts` (table, optional): Configuration options

**Options:**

```lua
{
  -- Override default ASL server command
  cmd = { "asl-lsp-server", "--stdio" },

  -- Override default filetypes
  filetypes = { "json", "yaml" },

  -- Override root directory detection
  root_dir = function(fname)
    return require('lspconfig.util').root_pattern('.asl', '.git')(fname)
  end,

  -- Additional settings to pass to the LSP
  settings = {
    asl = {
      validate = true,
    }
  },

  -- Disable automatic file detection autocmds
  auto_detect = true,
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different Neovim configurations
5. Submit a pull request

## Related Projects

- [asl-lsp-server](https://github.com/rperez-torro/asl-lsp-server) - Core ASL Language Server
- [amazon-states-language-service](https://github.com/aws/amazon-states-language-service) - Official AWS ASL library

## License

MIT License - see [LICENSE](LICENSE) file for details.
