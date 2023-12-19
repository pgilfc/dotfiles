return {
    -- A list of parser names, or "all"
    ensure_installed = { "c", "python", "lua", "go", "javascript", "typescript", "sql", "yaml", "json", "bash" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
}
