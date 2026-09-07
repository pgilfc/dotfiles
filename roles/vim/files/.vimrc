set nocompatible

filetype plugin indent on

" Activate default syntax highlighting
syntax on

nnoremap <Space> <nop>
let mapleader = "\<Space>"
noremap <leader>n :bn<CR>
noremap <leader>b :bp<CR>

" Deactivate key arrows
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

"Switch buffers without saving
set hidden

set number
set relativenumber

set tabstop=2 shiftwidth=2 expandtab

" Git's commit buffer inherits 't' and 'l' from the global formatoptions, which hard-wraps
" commit bodies mid-typing; strip them per-buffer.
augroup vimrc_gitcommit
  autocmd!
  autocmd FileType gitcommit setlocal formatoptions-=tl
augroup END

" Copy to clipboard
vnoremap <leader>y "+y

" Paste from clipboard
nnoremap <leader>p "+p
