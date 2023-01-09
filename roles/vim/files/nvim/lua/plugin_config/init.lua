-- plugin config init exists as is, solely to enable toggling plugins

local function config(plugin)
    require('plugin_config.' .. plugin)
end

config('gruvbox')
config('which-key')
config('nvim-tree')
config('bufferline')
config('lualine')
config('telescope')
config('nvim-treesitter')
config('lsp')
config('lsp-signature')
config('trouble')
config('null-ls')
config('symbols-outline')
config('nvim-cmp')
