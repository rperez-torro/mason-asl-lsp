# Mason ASL LSP

A **zero-configuration** Mason plugin for seamless ASL Language Server integration with Neovim.

## ✨ True Zero Configuration

Just add the plugin - **no server configuration needed!**

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

**That's it!** ✨

## Installation

### Step 1: Install the ASL Language Server

```bash
git clone https://github.com/rperez-torro/asl-lsp-server.git
cd asl-lsp-server
npm install && npm run install-global

# Verify installation
asl-lsp-server --version
```

### Step 2: Add Plugin to Neovim

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

### Step 3: Done! ✅

Restart Neovim and open any `.asl.json` or `.asl.yaml` file. The LSP will start automatically!

## 🎯 What You Get

- **✅ Automatic LSP registration** - No need to add `asl_lsp = {}` to your servers table
- **✅ File pattern detection** - Automatically detects `.asl.json`, `.asl.yaml`, `.asl.yml`, `.asl` files
- **✅ Mason integration** - Prevents registry conflicts automatically
- **✅ Smart capabilities** - Auto-integrates with nvim-cmp if available
- **✅ Installation check** - Use `:AslLspCheck` to verify server installation

## 🚀 Features

### Real-time Validation

- ASL syntax validation using official AWS rules
- Error highlighting and diagnostics

### Smart Completion

- State types: `Pass`, `Task`, `Choice`, `Wait`, `Succeed`, `Fail`, `Parallel`, `Map`
- State properties: `InputPath`, `OutputPath`, `Parameters`, etc.
- JSONPath expressions for input/output paths

### Multi-format Support

- **JSON format**: `.asl.json` files
- **YAML format**: `.asl.yaml`, `.asl.yml` files
- **Fallback**: `.asl` files (treated as JSON)

## 🔧 Advanced Configuration (Optional)

Want to customize the setup? You can pass options:

```lua
require("mason-asl-lsp").setup({
  -- Override default command
  cmd = { "asl-lsp-server", "--stdio" },

  -- Override filetypes
  filetypes = { "json", "yaml" },

  -- Override root directory detection
  root_dir = require('lspconfig.util').root_pattern('.asl', '.git', 'package.json'),

  -- Override LSP settings
  settings = {
    asl = {
      validate = true,
      completion = {
        snippets = true,
        stateNames = true
      }
    }
  },

  -- Disable automatic file detection
  auto_detect = false,

  -- Disable automatic server setup (if you want manual control)
  auto_setup = false,
})
```

**Note**: With `auto_setup = false`, you'll need to manually add `asl_lsp = {}` to your servers table.

## 🛠 Troubleshooting

### Check Installation

```vim
:AslLspCheck
```

### Common Issues

| Issue            | Solution                                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| LSP not starting | Run `:AslLspCheck` to verify server installation                                                                                             |
| No completions   | Ensure file extension is `.asl.json` or `.asl.yaml`                                                                                          |
| Mason errors     | Plugin automatically prevents registry conflicts                                                                                             |
| Server not found | Install server: `git clone https://github.com/rperez-torro/asl-lsp-server.git && cd asl-lsp-server && npm install && npm run install-global` |

### Verify LSP Status

```vim
:LspInfo
```

Should show `asl_lsp` attached to ASL files.

## 📁 Supported File Patterns

The plugin automatically activates for:

- `*.asl.json` - JSON format ASL files
- `*.asl.yaml` - YAML format ASL files
- `*.asl.yml` - YAML format ASL files
- `*.asl` - JSON format ASL files (fallback)

## 📖 Example ASL Files

### JSON Format (.asl.json)

```json
{
  "Comment": "Hello World Example",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
```

### YAML Format (.asl.yaml)

```yaml
Comment: "Hello World Example"
StartAt: HelloWorld
States:
  HelloWorld:
    Type: Pass
    Result: "Hello World!"
    End: true
```

## 🔗 Related Projects

- **[asl-lsp-server](https://github.com/rperez-torro/asl-lsp-server)** - Core ASL Language Server
- **[amazon-states-language-service](https://github.com/aws/amazon-states-language-service)** - Official AWS ASL library

## 📋 Why This Plugin?

**Before**: Complex manual setup with 50+ lines of configuration  
**After**: Zero-configuration - just add the plugin!

This plugin eliminates the need for:

- ❌ Manual server registration with lspconfig
- ❌ Mason exclusion filters
- ❌ File detection autocmds
- ❌ Capability setup
- ❌ Adding servers to your configuration table

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different Neovim configurations
5. Submit a pull request

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

## ❤️ Acknowledgments

Built on top of the official [Amazon States Language Service](https://github.com/aws/amazon-states-language-service) by AWS.
