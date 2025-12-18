# GitHub Copilot Instructions for Mason ASL LSP

## Project Context

You are working on a **Neovim plugin for zero-config ASL (Amazon States Language) language server integration**. This plugin uses modern Neovim 0.11+ LSP APIs to provide seamless integration with the asl-lsp-server without requiring external dependencies like Mason or lspconfig.

## Language & Technology Stack

- **Primary Language**: Lua (Neovim plugin development)
- **Target Platform**: Neovim 0.11+ with modern LSP API
- **Integration**: Native `vim.lsp.config()` and `vim.lsp.enable()` APIs
- **Dependencies**: Zero external plugin dependencies (self-contained)

## Code Style & Formatting

- **Indentation**: 2 spaces (no tabs)
- **Quotes**: Single quotes for strings
- **Line Length**: 100 characters maximum
- **Tables**: Use trailing commas for multi-line tables
- **Variables**: snake_case for variables, PascalCase for modules
- **Functions**: Descriptive names, prefer local functions

## Neovim Plugin Patterns

### Module Structure

```lua
-- Standard Neovim plugin module pattern
local M = {}

-- Private state and configuration
local state = {
  initialized = false,
  config = {},
}

local default_config = {
  auto_install = true,
  server_cmd = { 'asl-lsp-server', '--stdio' },
  file_patterns = { '%.asl%.json$', '%.asl%.ya?ml$', '%.asl$' },
}

-- Public setup function
function M.setup(opts)
  opts = vim.tbl_deep_extend('force', default_config, opts or {})
  state.config = opts
  state.initialized = true

  -- Plugin initialization logic
  setup_lsp_config()
  setup_autocommands()
end

return M
```

### Error Handling

```lua
-- Use pcall for operations that might fail
local function safe_operation(func, error_msg)
  local ok, result = pcall(func)
  if not ok then
    vim.notify(error_msg .. ': ' .. result, vim.log.levels.ERROR)
    return false
  end
  return result
end

-- Check Neovim version compatibility
local function check_compatibility()
  if vim.fn.has('nvim-0.11') == 0 then
    vim.notify(
      'mason-asl-lsp requires Neovim 0.11+. Current: ' .. vim.version(),
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end
```

## Modern LSP Integration

### LSP Configuration Pattern (Neovim 0.11+)

```lua
-- Use modern vim.lsp.config() instead of lspconfig
local function setup_lsp_config()
  vim.lsp.config('asl_lsp', {
    cmd = state.config.server_cmd,
    filetypes = { 'json', 'yaml' },
    root_markers = { '.git', '.asl' },
    single_file_support = true,
    name = 'asl_lsp',

    on_attach = function(client, bufnr)
      setup_buffer_keybindings(bufnr)

      if state.config.on_attach then
        state.config.on_attach(client, bufnr)
      end
    end,

    capabilities = state.config.capabilities or vim.lsp.protocol.make_client_capabilities(),
  })
end
```

### Automatic LSP Enabling

```lua
-- Enable LSP automatically for ASL files
local function setup_autocommands()
  local group = vim.api.nvim_create_augroup('mason_asl_lsp', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = group,
    callback = function(ev)
      if is_asl_file(ev.file) then
        vim.lsp.enable('asl_lsp', { bufnr = ev.buf })
      end
    end,
  })
end
```

### File Type Detection

```lua
-- ASL file pattern matching
local function is_asl_file(filename)
  if not filename then
    return false
  end

  for _, pattern in ipairs(state.config.file_patterns) do
    if filename:match(pattern) then
      return true
    end
  end

  return false
end

-- Set appropriate filetype for ASL files
local function setup_filetype_detection()
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
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

## Server Management

### Auto-Installation

```lua
local function check_server_installed()
  return vim.fn.executable('asl-lsp-server') == 1
end

local function install_server()
  if not state.config.auto_install then
    vim.notify(
      'asl-lsp-server not found and auto_install is disabled',
      vim.log.levels.WARN
    )
    return
  end

  vim.notify('Installing asl-lsp-server...', vim.log.levels.INFO)

  local install_cmd = 'npm install -g asl-lsp-server'

  vim.system(
    { 'sh', '-c', install_cmd },
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify('asl-lsp-server installed successfully!', vim.log.levels.INFO)
          -- Re-attempt LSP setup after installation
          setup_lsp_config()
        else
          vim.notify(
            'Failed to install asl-lsp-server: ' .. (result.stderr or 'Unknown error'),
            vim.log.levels.ERROR
          )
        end
      end)
    end
  )
end
```

### Server Health Check

```lua
local function check_server_health()
  if not check_server_installed() then
    return {
      status = 'error',
      message = 'asl-lsp-server executable not found'
    }
  end

  -- Test server startup
  local handle = vim.system(
    { 'asl-lsp-server', '--version' },
    { text = true, timeout = 5000 }
  )

  local result = handle:wait()

  if result.code == 0 then
    return {
      status = 'ok',
      version = vim.trim(result.stdout or ''),
      message = 'Server is healthy'
    }
  else
    return {
      status = 'error',
      message = 'Server failed to start: ' .. (result.stderr or 'Unknown error')
    }
  end
end
```

## Buffer-Local Configuration

### Keybinding Setup

```lua
local function setup_buffer_keybindings(bufnr)
  local keybindings = state.config.keybindings or {}

  local function map(mode, lhs, rhs, desc)
    if lhs then
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        desc = 'ASL LSP: ' .. desc,
        silent = true,
      })
    end
  end

  map('n', keybindings.goto_definition or 'gd', vim.lsp.buf.definition, 'Go to definition')
  map('n', keybindings.hover or 'K', vim.lsp.buf.hover, 'Show hover information')
  map('n', keybindings.code_action or '<leader>ca', vim.lsp.buf.code_action, 'Code actions')
  map('n', keybindings.rename or '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  map('n', keybindings.references or 'gr', vim.lsp.buf.references, 'Find references')
end
```

### Buffer-Local Commands

```lua
local function setup_buffer_commands(bufnr)
  -- ASL-specific commands for the buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'ASLValidate', function()
    vim.lsp.buf.code_action({
      filter = function(action)
        return action.kind and action.kind:match('quickfix')
      end,
      apply = true,
    })
  end, { desc = 'Validate ASL document and apply fixes' })

  vim.api.nvim_buf_create_user_command(bufnr, 'ASLFormat', function()
    vim.lsp.buf.format({
      async = true,
      filter = function(client)
        return client.name == 'asl_lsp'
      end,
    })
  end, { desc = 'Format ASL document' })
end
```

## Configuration Validation

### Option Validation

```lua
local function validate_config(config)
  local errors = {}

  -- Validate server command
  if config.server_cmd then
    if type(config.server_cmd) ~= 'table' then
      table.insert(errors, 'server_cmd must be a table')
    elseif #config.server_cmd == 0 then
      table.insert(errors, 'server_cmd cannot be empty')
    end
  end

  -- Validate file patterns
  if config.file_patterns then
    if type(config.file_patterns) ~= 'table' then
      table.insert(errors, 'file_patterns must be a table')
    end
  end

  -- Validate keybindings
  if config.keybindings then
    if type(config.keybindings) ~= 'table' then
      table.insert(errors, 'keybindings must be a table')
    end
  end

  if #errors > 0 then
    vim.notify(
      'Configuration errors:\n' .. table.concat(errors, '\n'),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end
```

## Debugging and Diagnostics

### Debug Information

```lua
function M.debug_info()
  local info = {
    neovim_version = tostring(vim.version()),
    plugin_initialized = state.initialized,
    server_installed = check_server_installed(),
    lsp_api_available = {
      config = vim.lsp.config ~= nil,
      enable = vim.lsp.enable ~= nil,
    },
    active_clients = {},
    config = vim.deepcopy(state.config),
  }

  -- Get active LSP clients
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.name == 'asl_lsp' then
      table.insert(info.active_clients, {
        name = client.name,
        id = client.id,
        attached_buffers = client.attached_buffers,
      })
    end
  end

  print(vim.inspect(info))
  return info
end

-- Health check function for :checkhealth
function M.check_health()
  local health = vim.health or require('health')

  health.start('mason-asl-lsp')

  -- Check Neovim version
  if vim.fn.has('nvim-0.11') == 1 then
    health.ok('Neovim version >= 0.11')
  else
    health.error('Neovim 0.11+ required, current: ' .. vim.version())
  end

  -- Check LSP API
  if vim.lsp.config and vim.lsp.enable then
    health.ok('Modern LSP API available')
  else
    health.error('Modern LSP API not available')
  end

  -- Check server installation
  local server_health = check_server_health()
  if server_health.status == 'ok' then
    health.ok('asl-lsp-server: ' .. server_health.version)
  else
    health.error('asl-lsp-server: ' .. server_health.message)
  end
end
```

## Testing Patterns

### Manual Testing Functions

```lua
local function test_asl_file_detection()
  local test_files = {
    'test.asl.json',
    'state-machine.asl.yaml',
    'workflow.asl.yml',
    'simple.asl',
    'not-asl.json',
  }

  for _, file in ipairs(test_files) do
    local is_asl = is_asl_file(file)
    print(string.format('%s: %s', file, is_asl and 'ASL' or 'Not ASL'))
  end
end

local function test_lsp_integration()
  -- Create a temporary buffer with ASL content
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    '{',
    '  "StartAt": "Hello",',
    '  "States": {',
    '    "Hello": {',
    '      "Type": "Pass",',
    '      "End": true',
    '    }',
    '  }',
    '}',
  })

  -- Set buffer name to trigger ASL detection
  vim.api.nvim_buf_set_name(bufnr, 'test.asl.json')

  -- Enable LSP for this buffer
  vim.lsp.enable('asl_lsp', { bufnr = bufnr })

  print('Test buffer created with ASL content')
  return bufnr
end
```

## Common Pitfalls to Avoid

1. **Legacy API Usage** - Don't use `require('lspconfig')`, use `vim.lsp.config()`
2. **Version Compatibility** - Always check for Neovim 0.11+ before using modern APIs
3. **Blocking Operations** - Use `vim.system()` with callbacks for async operations
4. **Resource Cleanup** - Properly clean up autocommands and keybindings
5. **Error Propagation** - Handle errors gracefully and provide helpful messages

## Plugin Manager Integration

### Lazy.nvim Configuration

```lua
-- Example plugin spec for lazy.nvim
return {
  'rperez-torro/mason-asl-lsp',
  ft = { 'json', 'yaml' },
  config = function()
    require('mason-asl-lsp').setup({
      auto_install = true,
      keybindings = {
        hover = 'gh',
        goto_definition = '<C-]>',
      },
    })
  end,
}
```

### Packer.nvim Configuration

```lua
use {
  'rperez-torro/mason-asl-lsp',
  config = function()
    require('mason-asl-lsp').setup()
  end,
  ft = { 'json', 'yaml' },
}
```

When implementing new features, always consider Neovim version compatibility, proper error handling, and integration with the modern LSP ecosystem. The plugin should remain dependency-free and work out of the box with minimal configuration.
