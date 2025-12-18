# Mason ASL LSP

A **zero-configuration** plugin for seamless ASL Language Server integration with **Neovim 0.11+**.

## ⚠️ Requirements

- **Neovim 0.11+** - Uses the modern native LSP API
- **asl-lsp-server** - The actual language server binary

## ✨ True Zero Configuration

Just add the plugin - **no server configuration needed!**

```lua
{
  "rperez-torro/mason-asl-lsp",
  config = function()
    require("mason-asl-lsp").setup()
  end,
}
```

**That's it!** ✨

## Installation

### Step 1: Verify Neovim Version

```bash
nvim --version
# Ensure you have v0.11.0 or newer
```

### Step 2: Install the ASL Language Server

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/asl-lsp-server.git
cd asl-lsp-server
npm install && npm run install-global

# Verify installation
asl-lsp-server --version
```

### Step 3: Add Plugin to Neovim

#### Using lazy.nvim (Recommended)

```lua
{
  "rperez-torro/mason-asl-lsp",
  config = function()
    require("mason-asl-lsp").setup()
  end,
}
```

#### Using packer.nvim

```lua
use {
  "YOUR_GITHUB_USERNAME/mason-asl-lsp",
  config = function()
    require("mason-asl-lsp").setup()
  end,
}
```

### Step 4: Done! ✅

Restart Neovim and open any `.asl.json` or `.asl.yaml` file. The LSP will start automatically!

## 🎯 What You Get

- **✅ Modern LSP Integration** - Uses Neovim 0.11+ native `vim.lsp.config()` API
- **✅ Automatic LSP registration** - No need for nvim-lspconfig or complex setup
- **✅ File pattern detection** - Automatically detects `.asl.json`, `.asl.yaml`, `.asl.yml`, `.asl` files
- **✅ Zero dependencies** - No Mason or lspconfig required
- **✅ Smart capabilities** - Auto-integrates with nvim-cmp if available
- **✅ Installation check** - Use `:AslLspCheck` to verify server installation
- **✅ Manual control** - Use `:AslLspEnable` to manually start the server

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

  -- Override root directory detection patterns
  root_markers = { '.asl', '.git', 'package.json' },

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

**Note**: With `auto_setup = false`, you'll need to manually call `:AslLspEnable` to start the server.

## 🛠 Troubleshooting

### Check Installation & Configuration

```vim
:AslLspCheck
```

### Enable Server Manually

```vim
:AslLspEnable
```

### Common Issues

| Issue                   | Solution                                                                                                                                             |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Requires Neovim 0.11+" | Upgrade Neovim to version 0.11 or newer                                                                                                              |
| LSP not starting        | Run `:AslLspCheck` to verify server installation                                                                                                     |
| No completions          | Ensure file extension is `.asl.json` or `.asl.yaml`                                                                                                  |
| Server not found        | Install server: `git clone https://github.com/YOUR_GITHUB_USERNAME/asl-lsp-server.git && cd asl-lsp-server && npm install && npm run install-global` |
| Config not registered   | Restart Neovim after plugin installation                                                                                                             |

### Verify LSP Status

```vim
:LspInfo
```

Should show `asl_lsp` attached to ASL files without warnings.

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

- **[asl-lsp-server](https://github.com/YOUR_GITHUB_USERNAME/asl-lsp-server)** - Core ASL Language Server
- **[amazon-states-language-service](https://github.com/aws/amazon-states-language-service)** - Official AWS ASL library

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
