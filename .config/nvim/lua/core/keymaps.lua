-- lua/core/keymaps.lua
local map = vim.keymap.set

-- Normal mode keymaps
map("n", "<leader>w", ":w<CR>", { desc = "Save current buffer" })
map("n", "<leader>q", ":q<CR>", { desc = "Close current buffer" })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>pv", ":Ex<CR>", { desc = "Open current directory in netrw" })
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>b", ":Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Visual mode keymaps
map("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("v", "<leader>d", '"+d', { desc = "Delete to system clipboard" })

-- Terminal mode keymaps
map("t", "<C-w>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
