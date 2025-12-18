local M = {}

-- Check if we're running Neovim 0.11+ for modern LSP API support
local function has_modern_lsp_api()
  return vim.fn.has('nvim-0.11') == 1
end

local default_config = {
  cmd = { "asl-lsp-server", "--stdio" },
  filetypes = { "json", "yaml" },
  root_markers = { '.git', 'package.json', '.asl', 'state-machines' },
  settings = {
    asl = {
      validate = true,
      completion = {
        snippets = true,
        stateNames = true
      }
    }
  },
  auto_detect = true,
  auto_setup = true, -- Automatically setup the server without user config
}

-- Setup function to be called by users
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Validate Neovim version
  if not has_modern_lsp_api() then
    vim.notify(
      "mason-asl-lsp: Requires Neovim 0.11+ for modern LSP API support. " ..
      "Current version: " .. vim.version().major .. "." .. vim.version().minor,
      vim.log.levels.ERROR
    )
    return
  end
  
  -- Register asl_lsp with modern vim.lsp.config API
  local config = {
    cmd = opts.cmd,
    filetypes = opts.filetypes,
    root_markers = opts.root_markers,
    settings = opts.settings,
  }
  
  -- Register the LSP configuration using the modern API
  if not pcall(function() vim.lsp.config('asl_lsp', config) end) then
    vim.notify("mason-asl-lsp: Failed to register asl_lsp configuration", vim.log.levels.ERROR)
    return
  end
  
  -- Auto-setup the server if enabled (this makes it zero-configuration)
  if opts.auto_setup then
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    
    -- Try to get capabilities from nvim-cmp if available
    local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if ok_cmp then
      capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
    end
    
    -- Enable the server using modern API
    vim.lsp.enable('asl_lsp', {
      capabilities = capabilities,
    })
  end
  
  -- Setup file detection if enabled
  if opts.auto_detect then
    M.setup_file_detection()
  end
  
  -- Note: Mason exclusion is no longer needed with modern API
end

-- Setup file detection autocmds
function M.setup_file_detection()
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('mason-asl-lsp-attach', { clear = true }),
    pattern = { '*.asl.json', '*.asl.yaml', '*.asl.yml', '*.asl' },
    callback = function(args)
      local filename = vim.fn.expand('%:t')
      
      -- Set appropriate filetype
      if filename:match('%.asl%.json$') or filename:match('%.asl$') then
        vim.bo[args.buf].filetype = 'json'
      elseif filename:match('%.asl%.ya?ml$') then
        vim.bo[args.buf].filetype = 'yaml'
      end
      
      -- Enable ASL LSP using modern API
      vim.schedule(function()
        if has_modern_lsp_api() then
          vim.lsp.enable('asl_lsp', { bufnr = args.buf })
        else
          -- Fallback for older versions (shouldn't reach here due to version check)
          vim.cmd('LspStart asl_lsp')
        end
      end)
    end,
  })
end

-- Utility function to check if asl-lsp-server is installed
function M.check_installation()
  local handle = io.popen("which asl-lsp-server 2>/dev/null")
  if not handle then
    return false, "Could not check asl-lsp-server installation"
  end
  
  local result = handle:read("*a")
  handle:close()
  
  if result and result:match("%S") then
    -- Try to get version
    local version_handle = io.popen("asl-lsp-server --version 2>/dev/null")
    if version_handle then
      local version = version_handle:read("*a")
      version_handle:close()
      return true, "asl-lsp-server found: " .. (version:gsub("\n", ""))
    end
    return true, "asl-lsp-server found at: " .. result:gsub("\n", "")
  else
    return false, "asl-lsp-server not found in PATH"
  end
end

-- Command to check installation status
function M.create_commands()
  vim.api.nvim_create_user_command('AslLspCheck', function()
    -- Check Neovim version first
    if not has_modern_lsp_api() then
      vim.notify(
        "❌ Neovim 0.11+ required. Current: " .. vim.version().major .. "." .. vim.version().minor .. 
        "\n\nPlease upgrade Neovim to use mason-asl-lsp.",
        vim.log.levels.ERROR
      )
      return
    end
    
    -- Check server installation
    local installed, message = M.check_installation()
    if installed then
      vim.notify("✅ " .. message, vim.log.levels.INFO)
      
      -- Check if config is registered
      local config_exists = vim.lsp.config and vim.lsp.config.asl_lsp ~= nil
      if config_exists then
        vim.notify("✅ asl_lsp configuration registered with Neovim", vim.log.levels.INFO)
      else
        vim.notify("⚠️ asl_lsp configuration not found. Run require('mason-asl-lsp').setup()", vim.log.levels.WARN)
      end
    else
      vim.notify("❌ " .. message .. "\n\nInstall with:\n  git clone https://github.com/rperez-torro/asl-lsp-server.git\n  cd asl-lsp-server && npm install && npm run install-global", vim.log.levels.WARN)
    end
  end, {
    desc = "Check ASL Language Server installation status"
  })
  
  -- Command to manually enable the server
  vim.api.nvim_create_user_command('AslLspEnable', function()
    if has_modern_lsp_api() and vim.lsp.config and vim.lsp.config.asl_lsp then
      vim.lsp.enable('asl_lsp')
      vim.notify("✅ ASL Language Server enabled", vim.log.levels.INFO)
    else
      vim.notify("❌ asl_lsp not configured. Run require('mason-asl-lsp').setup() first", vim.log.levels.ERROR)
    end
  end, {
    desc = "Manually enable ASL Language Server"
  })
end

-- Auto-setup commands when plugin loads
M.create_commands()

return M