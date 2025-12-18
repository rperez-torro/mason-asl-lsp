# ASL Language Server Quick Fix

## ⚠️ Important Setup Note

Since this plugin references a GitHub repository that was just created, you need to install it through your plugin manager first.

## Quick Setup Steps:

1. **The syntax error in lspconfig.lua has been fixed**

2. **Install the plugin**:

   ```
   # In Neovim
   :Lazy sync
   ```

3. **Enable the Mason plugin**:

   - Edit: `~/.config/nvim/lua/custom/plugins/mason-asl-lsp.lua`
   - Replace `return {}` with the commented plugin config
   - Restart Neovim

4. **Install the core server**:
   ```bash
   cd ~/code/lsp/asl-lsp-server
   npm install && npm run install-global
   ```

## What Was Fixed:

- ❌ **Before**: `unexpected symbol near '}'` error in lspconfig.lua:277
- ✅ **After**: Clean syntax, Neovim starts without errors

The plugin is temporarily disabled until you install it through Lazy.nvim to avoid startup errors.
