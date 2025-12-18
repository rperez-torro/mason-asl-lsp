local M = {}

local default_config = {
  cmd = { "asl-lsp-server", "--stdio" },
  filetypes = { "json", "yaml" },
  root_dir = nil, -- Will be set to lspconfig.util.root_pattern in setup
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
}

-- Setup function to be called by users
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Get lspconfig and configs
  local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')
  if not ok_lspconfig then
    vim.notify("mason-asl-lsp: lspconfig not found", vim.log.levels.ERROR)
    return
  end
  
  local configs = require('lspconfig.configs')
  
  -- Set default root_dir if not provided
  if not opts.root_dir then
    opts.root_dir = lspconfig.util.root_pattern('.git', 'package.json', '.asl', 'state-machines')
  end
  
  -- Register asl_lsp with lspconfig if not already registered
  if not configs.asl_lsp then
    configs.asl_lsp = {
      default_config = {
        cmd = opts.cmd,
        filetypes = opts.filetypes,
        root_dir = opts.root_dir,
        settings = opts.settings,
      },
      docs = {
        description = [[
Amazon States Language (ASL) Language Server
Provides validation, completion, and diagnostics for ASL documents.

Requires asl-lsp-server to be installed globally:
  npm install -g asl-lsp-server

Or install from source:
  git clone https://github.com/rperez-torro/asl-lsp-server.git
  cd asl-lsp-server && npm install && npm run install-global
]],
        default_config = {
          root_dir = [[root_pattern('.git', 'package.json', '.asl', 'state-machines')]],
          cmd = [["asl-lsp-server", "--stdio"]],
          filetypes = [["json", "yaml"]],
        },
      },
    }
  end
  
  -- Setup file detection if enabled
  if opts.auto_detect then
    M.setup_file_detection()
  end
  
  -- Hook into Mason setup to exclude asl_lsp from auto-installation
  M.setup_mason_exclusion()
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
      
      -- Start ASL LSP
      vim.schedule(function()
        vim.cmd('LspStart asl_lsp')
      end)
    end,
  })
end

-- Setup Mason exclusion to prevent registry errors
function M.setup_mason_exclusion()
  -- Create an autocmd that runs after VimEnter to hook into Mason setup
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("mason-asl-lsp-exclusion", { clear = true }),
    callback = function()
      -- Override vim.tbl_keys to exclude asl_lsp from ensure_installed
      local original_tbl_keys = vim.tbl_keys
      vim.tbl_keys = function(t)
        local keys = original_tbl_keys(t)
        -- Filter out asl_lsp if it's in the keys
        return vim.tbl_filter(function(key)
          return key ~= 'asl_lsp'
        end, keys)
      end
      
      -- Restore original function after a delay to not interfere with other usage
      vim.defer_fn(function()
        vim.tbl_keys = original_tbl_keys
      end, 1000)
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
    local installed, message = M.check_installation()
    if installed then
      vim.notify("✅ " .. message, vim.log.levels.INFO)
    else
      vim.notify("❌ " .. message .. "\n\nInstall with:\n  git clone https://github.com/rperez-torro/asl-lsp-server.git\n  cd asl-lsp-server && npm install && npm run install-global", vim.log.levels.WARN)
    end
  end, {
    desc = "Check ASL Language Server installation status"
  })
end

-- Auto-setup commands when plugin loads
M.create_commands()

return M