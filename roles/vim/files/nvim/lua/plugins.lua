local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Package manage self

    -- plenary (lua functions)
    use 'nvim-lua/plenary.nvim'

    -- icons
    use 'nvim-tree/nvim-web-devicons'

    -- theme
    use 'ellisonleao/gruvbox.nvim'

    -- which-key
    use 'folke/which-key.nvim'

    -- file tree
    use 'nvim-tree/nvim-tree.lua'

    -- buffer line
    use { 'akinsho/bufferline.nvim', tag = 'v3.*' }

    -- lua line
    use 'nvim-lualine/lualine.nvim'

    -- telescope
    use { 'nvim-telescope/telescope-fzf-native.nvim',
        run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    }
    use 'nvim-telescope/telescope.nvim'

    -- undo tree
    use 'mbbill/undotree'

    -- vim fugitive
    use 'tpope/vim-fugitive'

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use {
        'nvim-treesitter/nvim-treesitter-textobjects',
        after = 'nvim-treesitter',
    }
    use 'nvim-treesitter/playground'



    -- LSP
    use {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    }
    -- DAP (debugger)
    -- use 'mfussenegger/nvim-dap'
    -- lsp_signature
    use 'ray-x/lsp_signature.nvim'
    -- trouble
    use 'folke/trouble.nvim'
    -- null-ls
    use 'jose-elias-alvarez/null-ls.nvim'
    -- status updates for LSP
    use 'j-hui/fidget.nvim'
    -- Outline
    use 'simrat39/symbols-outline.nvim'

    -- Autocompletion
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/nvim-cmp'
    -- Autocompletion snippets
    use({ "L3MON4D3/LuaSnip", tag = "v1.*" })
    use "rafamadriz/friendly-snippets"


    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
