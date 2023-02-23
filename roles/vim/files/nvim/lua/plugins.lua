local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'wbthomason/packer.nvim', -- Package manage self

    -- plenary (lua functions)
    'nvim-lua/plenary.nvim',

    -- icons
    'nvim-tree/nvim-web-devicons',

    -- theme
    'ellisonleao/gruvbox.nvim',

    -- which-key
    'folke/which-key.nvim',

    -- file tree
    'nvim-tree/nvim-tree.lua',

    -- buffer line
    { 'akinsho/bufferline.nvim', tag = 'v3.3.0' },

    -- lua line
    'nvim-lualine/lualine.nvim',

    -- telescope
    { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    },
    'nvim-telescope/telescope.nvim',

    -- undo tree
    'mbbill/undotree',

    -- vim fugitive
    'tpope/vim-fugitive',

    -- gitsigns for blame and other things
    'lewis6991/gitsigns.nvim',

    -- Codeium Autocompletion
    'Exafunction/codeium.vim',




    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dependencies = { { 'nvim-treesitter' }, },
    },
    'nvim-treesitter/playground',



    -- LSP
    {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    },
    -- DAP (debugger)
    -- 'mfussenegger/nvim-dap',
    -- "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
    -- lsp_signature
    'ray-x/lsp_signature.nvim',
    -- trouble
    'folke/trouble.nvim',
    -- null-ls
    'jose-elias-alvarez/null-ls.nvim',
    -- status updates for LSP
    'j-hui/fidget.nvim',
    -- Outline
    'simrat39/symbols-outline.nvim',

    -- Autocompletion
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'hrsh7th/nvim-cmp',
    -- Autocompletion snippets
    { "L3MON4D3/LuaSnip",        tag = "v1.2.1" },
    "rafamadriz/friendly-snippets",
})
