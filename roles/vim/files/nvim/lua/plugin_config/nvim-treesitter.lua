local parser_install_dir = os.getenv("HOME") .. "/.vim/treesitter-parser"

vim.opt.runtimepath:append(parser_install_dir)

require("nvim-treesitter.configs").setup({
    -- A list of parser names, or "all"
    ensure_installed = { "python", "lua", "go", "javascript", "typescript", "sql", "yaml", "json", "bash", "help" },
    sync_install = false,
    auto_install = true,
    parser_install_dir = parser_install_dir,
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
})
