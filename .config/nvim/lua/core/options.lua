-- lua/core/options.lua
local opt = vim.opt

opt.number = true      -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.termguicolors = true -- Enable true color support
opt.tabstop = 4         -- Number of spaces a tab is
opt.shiftwidth = 4      -- Number of spaces to insert for indentation
opt.expandtab = true    -- Use spaces instead of tabs
opt.autoindent = true   -- Automatically indent new lines
opt.wrap = true        -- Don't wrap lines
opt.linebreak = true	-- Wrap lines at convenient points (like spaces)
opt.swapfile = false    -- Disable swap files
opt.backup = false      -- Disable backup files
opt.undofile = true     -- Enable persistent undo
opt.scrolloff = 8       -- Minimum lines to keep above and below cursor
opt.signcolumn = "yes"  -- Show sign column (for LSP diagnostics)
opt.completeopt = "menu,menuone,noselect" -- Configure completion options
opt.pumblend = 10 -- transparency of popup menu
opt.splitbelow = true -- split below
opt.splitright = true -- split right

vim.g.mapleader = " " -- Set mapleader to space
