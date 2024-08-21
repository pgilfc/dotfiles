-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Move Lines
-- Override the default keymaps for moving lines
-- Use Alt + Shift + J/K to move lines up and down
-- Alt + j/k is already used by zellij to switch panes
map("n", "<AS-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<AS-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<AS-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<AS-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<AS-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<AS-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })
