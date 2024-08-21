-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.shiftwidth = 4 -- number of spaces to use for autoindent
opt.tabstop = 4    -- number of spaces that a <Tab> in the file counts for
opt.softtabstop = 4

opt.scrolloff = 10 -- number of screen lines above and below cursor

---

opt.swapfile = true -- enable swap files
opt.backup = true   -- enable backup files
opt.undofile = true -- enable undo files
opt.directory = os.getenv("HOME") .. "/.vim/swapdir//"
opt.backupdir = os.getenv("HOME") .. "/.vim/backupdir//"
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

---

opt.incsearch = true -- incremental search
opt.hlsearch = true  -- highlight search results
