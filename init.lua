-- ========================================================================== --
-- 1. BASIC SETTINGS (The "Vim" stuff)
-- ========================================================================== --

-- Work arounds

-- Set leader key to Space (Must happen before plugins!)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI and Behavior
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers (great for jumping)
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.ignorecase = true     -- Case insensitive searching...
vim.opt.smartcase = true      -- ...unless I use a capital letter
vim.opt.termguicolors = true  -- Better colors (standard for modern terminals)
vim.opt.tabstop = 4           -- 1 tab = 4 spaces
vim.opt.shiftwidth = 4        -- Indent size
vim.opt.expandtab = true      -- Convert tabs to spaces

-- ========================================================================== --
-- 2. PLUGIN MANAGER (Lazy.nvim)
-- ========================================================================== --

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP Configuration & Plugins
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- Autocompletion (The YCM Replacement)
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip", -- Snippet engine

  -- Rust specific enhancements
  "simrat39/rust-tools.nvim",

  -- Fuzzy Finder (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    --tag = 'v0.2.1', --Gemini gave me an old as shit version which broke with Arch having the latest neovim. Instead of using the latest version v0.2.1 instead just let it find the latest
    dependencies = {
	    'nvim-lua/plenary.nvim',
	    'nvim-treesitter/nvim-treesitter',
    },
  },

  -- Session Manager (Persistence)
  {
    "folke/persistence.nvim",
    event = "BufReadPre", 
    opts = {} -- Uses default settings
  },

  -- A nice colorscheme (Optional, but Neovim looks better with one!)
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

-- Telescope ignore files in build
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "build/.*",
        },
    },
})


-- Load the colorscheme
vim.cmd.colorscheme("catppuccin-mocha")

-- 3. KEYMAPS (The "Leader" shortcuts)

-- General
vim.keymap.set("n", "<F4>", "<cmd>tabm -1<CR>", { desc = "Move current tab to the left" })
vim.keymap.set("n", "<F5>", "<cmd>tabfirst<CR>", { desc = "Jump to first tab" })
vim.keymap.set("n", "<F6>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<F7>", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<F8>", "<cmd>tablast<CR>", { desc = "Jump to last tab" })
vim.keymap.set("n", "<F9>", "<cmd>tabm +1<CR>", { desc = "Move current tab to the right" })

-- Window/Buffer management
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>s", ":split<CR>", { desc = "Horizontal split" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to window left of current" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window down of current" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window up of current" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to window right of current" })


vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Back to File Explorer" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Floating diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Telescope (Search)
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Search Text (Grep)' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })

vim.keymap.set('n', '<leader>j', ":Telescope jumplist<CR>", { desc = 'Show jump history window' })

-- Resume last search (Very useful if you accidentally closed a results window)
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Resume last Telescope' })

-- Persistence (Sessions)
local persistence = require("persistence")
-- Restore session for current directory
vim.keymap.set("n", "<leader>qs", function() persistence.load() end, { desc = "Restore Session" })
-- Restore last session (even if in different directory)
vim.keymap.set("n", "<leader>ql", function() persistence.load({ last = true }) end, { desc = "Restore Last Session" })
-- Stop saving session on exit
vim.keymap.set("n", "<leader>qd", function() persistence.stop() end, { desc = "Don't Save Session" })

-- 4. Mason Setup (Install clangd and rust-analyzer here)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "rust_analyzer" }
})

-- 5. Completion Setup (YCM-like behavior)
local cmp = require'cmp'
cmp.setup({
  snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(), -- Open completion menu
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
    ['<C-e'] = cmp.mapping.abort(), -- Close menu
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  })
})

-- 6. Language Server Setup
local lspconfig = require('lspconfig')

-- Debug LSP problems by uncommenting this
--vim.lsp.set_log_level("debug")


vim.lsp.config('*', {
	capabilities = require('cmp_nvim_lsp').default_capabilities()
})


-- C/C++ Setup
vim.lsp.config('clangd', {
})

-- Rust Setup (Using rust-tools for better integration)
-- require('rust-tools').setup({})
vim.lsp.config('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			checkOnSave = true,
            check = { command = "clippy" },
		},
	},
})

vim.lsp.config('ron-lsp', {
	cmd = { "ron-lsp" },
	filetypes = { "ron" },
	root_markers = { ".git", "Cargo.toml" },
})

-- Restart the lsp while debugging ron-lsp
vim.api.nvim_create_user_command('LspRestart', function()
  -- Stop the client for the current buffer
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in pairs(clients) do
    if client.name == 'ron-lsp' then -- Replace with your actual client name
      client.stop()
      vim.notify('Stopped ' .. client.name, vim.log.levels.INFO)
    end
  end

  -- Force re-attachment by triggering the FileType event
  vim.cmd('edit')
end, {})

vim.lsp.enable({ 'clangd', 'rust_analyzer', 'ron-lsp' })

-- Setup telescope shortcuts to only work when an lsp is attached
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local builtin = require('telescope.builtin')
    local opts = { buffer = ev.buf }

    -- LSP Navigation via Telescope
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts) -- Goto Definition (.c function body)
    vim.keymap.set('n', 'gD', function()
        builtin.lsp_definitions({jump_type = "never", reuse_win = false, loclist = true, lsp_handler = vim.lsp.handlers["textDocument/declaration"]}) -- Goto Declaration (.h header typically)
    end, { desc = "Goto Declaration (.h header typically)" })
    vim.keymap.set('n', 'gr', builtin.lsp_references, opts) -- Goto References
    vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts) 
    vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, opts) -- Goto Type Definition
    
    -- Search Symbols in current file (Great for long C files)
    vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, opts)
    -- Search Symbols in whole project (Great for Rust crates)
    vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, opts)

    -- Standard LSP actions (Telescope not needed/best here)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    
    -- Format key
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

