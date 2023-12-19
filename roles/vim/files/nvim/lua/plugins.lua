local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local function config(plugin)
    return require('plugin_config.' .. plugin)
end

require('lazy').setup({

    -- plenary (lua functions)
    'nvim-lua/plenary.nvim',

    -- icons
    'nvim-tree/nvim-web-devicons',

    -- theme
    {
        'ellisonleao/gruvbox.nvim',
        config = function()
            require('gruvbox').setup()
            vim.cmd [[ colorscheme gruvbox ]]
        end,
    },

    -- which-key
    {
        'folke/which-key.nvim',
        config = function()
            local wconf = config('which-key')
            require('which-key').setup(wconf.conf)
            require('which-key').register(wconf.mappings, wconf.opts)
        end,
    },

    -- file tree
    {
        'nvim-tree/nvim-tree.lua',
        config = function()
            config('nvim-tree')
        end,
    },

    -- buffer line
    {
        'akinsho/bufferline.nvim',
        tag = 'v3.3.0',
        config = function()
            require('bufferline').setup(config('bufferline'))
        end,
    },

    -- lua line
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup(config('lualine'))
        end,
    },

    -- telescope
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        config = function()
            config('telescope')
        end,
    },
    'nvim-telescope/telescope.nvim',

    -- undo tree
    'mbbill/undotree',

    -- vim fugitive
    'tpope/vim-fugitive',

    -- gitsigns for blame and other things
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            config('gitsigns')
        end,
    },



    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup(config('nvim-treesitter'))
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dependencies = { { 'nvim-treesitter' }, },
    },
    'nvim-treesitter/playground',



    -- LSP
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            {
                'ray-x/lsp_signature.nvim',
                config = function()
                    require('lsp_signature').setup()
                end
            },
            {
                'folke/trouble.nvim',
                config = function()
                    require('trouble').setup()
                end
            },
            {
                'jose-elias-alvarez/null-ls.nvim',
                config = function()
                    require('null-ls').setup()
                end
            },
            {
                'simrat39/symbols-outline.nvim',
                config = function()
                    require('symbols-outline').setup()
                end
            },
            {
                'williamboman/mason.nvim',
                dependencies = {
                    {
                        'williamboman/mason-lspconfig.nvim',
                    },
                },
                config = function()
                    require('mason').setup()
                    require('mason-lspconfig').setup({
                        ensure_installed = config('lsp').servers,
                    })
                end,
            },
        },
        config = function()
            local conf = config('lsp')
            for _, lsp in ipairs(conf.servers) do
                require('lspconfig')[lsp].setup({
                    on_attach = conf.on_attach,
                    capabilities = conf.capabilities,
                })
            end
            require('lspconfig').lua_ls.setup({
                on_attach = conf.on_attach,
                capabilities = conf.capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' } -- adding vim as a global var for lsp not to complain
                        }
                    }
                }
            })
        end,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            {
                -- snippet plugin
                'L3MON4D3/LuaSnip',
                dependencies = 'rafamadriz/friendly-snippets',
                config = function()
                    config('nvim-cmp').luasnip()
                end,
            },
            {
                'saadparwaiz1/cmp_luasnip',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
            },
        },
        config = function()
            require('cmp').setup(config('nvim-cmp').cmp)
        end,
    },

    -- Debugger
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup()
                end,
            },
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = {
                    "williamboman/mason.nvim"
                },
                config = function()
                    require("mason").setup()
                    require("mason-nvim-dap").setup({
                        ensure_installed = { "python", "delve" }
                    })
                end,
            },
        },
        {
            "rcarriga/nvim-dap-ui",
            config = function()
                require("dapui").setup()
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text",
            config = function()
                require("nvim-dap-virtual-text").setup()
            end,
        }
    },
})
