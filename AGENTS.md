# Agent Guidelines for Mason ASL LSP

## Overview

This is a **Neovim plugin for zero-config ASL (Amazon States Language) language server integration**. It provides seamless Neovim integration using the modern LSP API with the asl-lsp-server, requiring no external dependencies like Mason or lspconfig.

## Related Projects

- **[asl-lsp-server](https://github.com/rperez-torro/asl-lsp-server)** - The LSP server this plugin integrates with
- **[amazon-states-language-service](https://github.com/rperez-torro/amazon-states-language-service)** - Core ASL validation library used by the LSP server

## Plugin Architecture

### Core Design Principles

- **Zero Dependencies**: No Mason, lspconfig, or other plugin dependencies required
- **Modern LSP API**: Uses Neovim 0.11+ native `vim.lsp.config()` and `vim.lsp.enable()` APIs
- **Auto-Installation**: Automatically installs asl-lsp-server if not found
- **Minimal Configuration**: Works out of the box with sensible defaults

### File Structure

- `lua/mason-asl-lsp/init.lua` - Main plugin entry point and LSP configuration
- `README.md` - Installation and usage documentation

## Code Style Guidelines

### Lua Conventions

- **Indentation**: 2 spaces (no tabs)
- **Line Length**: 100 characters maximum
- **Quotes**: Single quotes for strings
- **Tables**: Use trailing commas for multi-line tables
- **Functions**: Prefer local functions, use descriptive names
- **Variables**: Use snake_case for variables, PascalCase for modules

### Neovim Lua Patterns

```lua
-- Proper module structure
local M = {}

-- Local helper functions
local function check_server_installed()
  return vim.fn.executable('asl-lsp-server') == 1
end

-- Public API functions
function M.setup(opts)
  opts = opts or {}
  -- Implementation
end

return M
```

### Error Handling

```lua
-- Use pcall for operations that might fail
local ok, result = pcall(vim.fn.system, command)
if not ok then
  vim.notify('Error: ' .. result, vim.log.levels.ERROR)
  return false
end
```

## Modern LSP Integration

### LSP Configuration Pattern

```lua
-- Modern Neovim 0.11+ LSP setup
vim.lsp.config('asl_lsp', {
  cmd = { 'asl-lsp-server', '--stdio' },
  filetypes = { 'json', 'yaml' },
  root_markers = { '.git', '.asl' },
  single_file_support = true,
  name = 'asl_lsp',
  on_attach = function(client, bufnr)
    -- Setup keybindings and buffer-local configuration
  end,
})

-- Enable for ASL file patterns
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'json', 'yaml' },
  callback = function(ev)
    if is_asl_file(ev.file) then
      vim.lsp.enable('asl_lsp', { bufnr = ev.buf })
    end
  end,
})
```

### File Type Detection

```lua
-- ASL file detection patterns
local asl_patterns = {
  '%.asl%.json$',
  '%.asl%.yaml$',
  '%.asl%.yml$',
  '%.asl$',
}

local function is_asl_file(filename)
  if not filename then return false end

  for _, pattern in ipairs(asl_patterns) do
    if filename:match(pattern) then
      return true
    end
  end

  return false
end
```

## Plugin Functionality

### Auto-Installation

```lua
local function install_server()
  vim.notify('Installing asl-lsp-server...', vim.log.levels.INFO)

  local install_cmd = 'npm install -g asl-lsp-server'
  local handle = vim.system(
    { 'sh', '-c', install_cmd },
    { text = true },
    function(result)
      if result.code == 0 then
        vim.notify('asl-lsp-server installed successfully!', vim.log.levels.INFO)
        setup_lsp() -- Setup LSP after successful installation
      else
        vim.notify(
          'Failed to install asl-lsp-server: ' .. result.stderr,
          vim.log.levels.ERROR
        )
      end
    end
  )
end
```

### Configuration Options

```lua
local default_config = {
  -- Server installation
  auto_install = true,
  server_cmd = { 'asl-lsp-server', '--stdio' },

  -- File patterns
  file_patterns = {
    '%.asl%.json$',
    '%.asl%.yaml$',
    '%.asl%.yml$',
    '%.asl$',
  },

  -- LSP settings
  single_file_support = true,
  root_markers = { '.git', '.asl' },

  -- Keybindings
  keybindings = {
    goto_definition = 'gd',
    hover = 'K',
    code_action = '<leader>ca',
    rename = '<leader>rn',
  },
}
```

## Neovim Integration Patterns

### Buffer-Local Setup

```lua
local function setup_buffer_keybindings(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = bufnr,
      desc = desc,
      silent = true,
    })
  end

  map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
  map('n', 'K', vim.lsp.buf.hover, 'Show hover information')
  map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code actions')
  map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
end
```

### Autocommands for File Detection

```lua
local function setup_autocommands()
  local group = vim.api.nvim_create_augroup('mason_asl_lsp', { clear = true })

  -- Enable LSP for ASL files when opened
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = group,
    callback = function(ev)
      if is_asl_file(ev.file) then
        vim.lsp.enable('asl_lsp', { bufnr = ev.buf })
      end
    end,
  })

  -- Set filetype for ASL files
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = group,
    pattern = { '*.asl.json', '*.asl.yaml', '*.asl.yml', '*.asl' },
    callback = function(ev)
      if ev.file:match('%.asl%.ya?ml$') then
        vim.bo[ev.buf].filetype = 'yaml'
      else
        vim.bo[ev.buf].filetype = 'json'
      end
    end,
  })
end
```

## Testing and Debugging

### Manual Testing

```lua
-- Test plugin functionality
local function test_plugin()
  print('Testing mason-asl-lsp plugin...')

  -- Check server availability
  local has_server = vim.fn.executable('asl-lsp-server') == 1
  print('Server available:', has_server)

  -- Check LSP config
  local configs = vim.lsp.get_clients()
  for _, client in ipairs(configs) do
    if client.name == 'asl_lsp' then
      print('LSP client active:', client.name)
      break
    end
  end
end
```

### Debug Information

```lua
local function get_debug_info()
  return {
    neovim_version = vim.version(),
    has_lsp_config = vim.lsp.config ~= nil,
    has_lsp_enable = vim.lsp.enable ~= nil,
    server_executable = vim.fn.executable('asl-lsp-server') == 1,
    active_clients = vim.tbl_map(function(client)
      return client.name
    end, vim.lsp.get_clients()),
  }
end
```

## Compatibility Considerations

### Neovim Version Support

- **Minimum**: Neovim 0.11+ (for modern LSP API)
- **Recommended**: Latest stable Neovim version
- **Breaking Change**: Uses new LSP API incompatible with older versions

### Migration from Legacy Setups

```lua
-- Help users migrate from lspconfig-based setups
local function check_legacy_setup()
  if vim.g.loaded_lspconfig then
    vim.notify(
      'Detected lspconfig. mason-asl-lsp uses native LSP APIs and does not require lspconfig.',
      vim.log.levels.WARN
    )
  end
end
```

## Configuration Examples

### Minimal Setup

```lua
-- In init.lua
require('mason-asl-lsp').setup()
```

### Custom Configuration

```lua
require('mason-asl-lsp').setup({
  auto_install = false, -- Don't auto-install server
  server_cmd = { '/custom/path/to/asl-lsp-server', '--stdio' },
  file_patterns = { '%.state%.json$' }, -- Custom file patterns
  keybindings = {
    goto_definition = '<C-]>',
    hover = 'gh',
  },
})
```

### Advanced Setup with Custom Handlers

```lua
require('mason-asl-lsp').setup({
  on_attach = function(client, bufnr)
    -- Custom on_attach logic
    print('ASL LSP attached to buffer', bufnr)

    -- Custom keybindings
    vim.keymap.set('n', '<leader>af', function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = bufnr, desc = 'Format ASL document' })
  end,

  capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities()
  ),
})
```

## Error Handling Patterns

### Graceful Degradation

```lua
local function safe_setup()
  -- Check Neovim version
  if vim.fn.has('nvim-0.11') == 0 then
    vim.notify(
      'mason-asl-lsp requires Neovim 0.11+. Current version: ' .. vim.version(),
      vim.log.levels.ERROR
    )
    return false
  end

  -- Check for modern LSP API
  if not vim.lsp.config or not vim.lsp.enable then
    vim.notify(
      'Modern LSP API not available. Please update Neovim.',
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end
```

### Server Installation Errors

```lua
local function handle_install_error(error_msg)
  local troubleshooting = {
    'Troubleshooting ASL LSP Server installation:',
    '1. Ensure Node.js and npm are installed',
    '2. Check network connectivity',
    '3. Try manual installation: npm install -g asl-lsp-server',
    '4. Check npm permissions',
  }

  vim.notify(table.concat(troubleshooting, '\n'), vim.log.levels.ERROR)
end
```

## Common Patterns

### Plugin State Management

```lua
local M = {}
local state = {
  initialized = false,
  server_installed = false,
  config = {},
}

function M.setup(opts)
  if state.initialized then
    vim.notify('mason-asl-lsp already initialized', vim.log.levels.WARN)
    return
  end

  state.config = vim.tbl_deep_extend('force', default_config, opts or {})
  state.initialized = true

  -- Continue setup...
end
```

### Lazy Loading Integration

```lua
-- Compatible with lazy.nvim plugin manager
return {
  'rperez-torro/mason-asl-lsp',
  ft = { 'json', 'yaml' }, -- Load only for relevant filetypes
  config = function()
    require('mason-asl-lsp').setup({
      -- Configuration options
    })
  end,
}
```
