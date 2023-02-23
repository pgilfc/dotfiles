require('gitsigns').setup({
    signcolumn             = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl                  = true, -- Toggle with `:Gitsigns toggle_numhl`
    linehl                 = false, -- Toggle with `:Gitsigns toggle_linehl`
    current_line_blame     = true
})

vim.keymap.set('n', '<leader>gs', require('gitsigns').preview_hunk_inline, { desc = 'Preview inline [S]taging changes' })
