local keymap = vim.keymap

-- set leader key
-- leader key mappings reside at after/plugin/which-key.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ctrl+hjkl to switch windows (same as ctrl+w and hjkl)
keymap.set('n', '<C-h>', '<C-W>h', { desc = "window left" })
keymap.set('n', '<C-l>', '<C-W>l', { desc = "window right" })
keymap.set('n', '<C-j>', '<C-W>j', { desc = "window up" })
keymap.set('n', '<C-k>', '<C-W>k', { desc = "window down" })


-- ctrl+yo to switch buffers (same as :bn and :bp)
keymap.set('n', '<C-y>', '<Cmd>bp<Cr>', { desc = "buffer left" })
keymap.set('n', '<C-o>', '<Cmd>bn<Cr>', { desc = "buffer right" })

-- yank to the + register (system clipboard)
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "yank to clipboard" })

-- paste without adding replaced value to the register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "paste without adding to register" } )

-- delete to the void register
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "delete to void" })

-- REMAP: JK in visual mode to move selection up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- REMAP: ctrl+du to keep cursor in the midle of the screen while page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- REMAP: keep search terms in the midle while nexting
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


