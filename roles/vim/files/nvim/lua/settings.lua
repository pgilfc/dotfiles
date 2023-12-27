local opt = vim.opt


opt.termguicolors = true

opt.timeoutlen = 300      -- time milli to wait to show wich-key

opt.scrolloff = 10        -- number of screen lines above and below cursor

opt.number = true         -- line number on cursor line
opt.relativenumber = true -- relative line numbers

opt.cursorline = true     -- highlight current cursor line

opt.ignorecase = true     -- ignore case when searching
opt.smartcase = true      -- if you include mixed case in your search, assumes you want case-sensitive

-- disable netrw (vim default tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- handling indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Use just undo file (no swap[file must fit in memory] no backup)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- incremental search
vim.opt.incsearch = true

-- sign column allways on (column before line numbers)
vim.opt.signcolumn = "yes"
