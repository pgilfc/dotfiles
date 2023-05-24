set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" to isntall vundle
Plugin 'VundleVim/Vundle.vim'

" Autocomplete with tabs
Plugin 'ervandew/supertab'
" Snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
" Open close pairs (brackets etc)
Plugin 'raimondi/delimitmate'
" elixir autocomplete!
Plugin 'slashmili/alchemist.vim'
" Airline
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" Colors
Plugin 'flazz/vim-colorschemes'
" NERDTree
Plugin 'scrooloose/nerdtree'
" Nerdtree git
Plugin 'Xuyuanp/nerdtree-git-plugin'
" Vue sintax
Plugin 'posva/vim-vue'
" Languages
Plugin 'sheerun/vim-polyglot'
" Vim-elixir
Plugin 'elixir-editors/vim-elixir'
" ctrlp.vim
Plugin 'ctrlpvim/ctrlp.vim'
" Editorconfig
Plugin 'editorconfig/editorconfig-vim'
" git Gutter
Plugin 'airblade/vim-gitgutter'
" Mix formater
Plugin 'mhinz/vim-mix-format'
" treesitter
Plugin 'nvim-treesitter/nvim-treesitter'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

" Activate default syntax highlighting
syntax on

let g:airline#extensions#tabline#enabled = 1

nnoremap <Space> <nop>
let mapleader = "\<Space>"
noremap <leader>n :bn<CR>
noremap <leader>b :bp<CR>

let NERDTreeShowHidden=1
"map <leader>t :NERDTreeFocus<CR>
"map <leader>c :NERDTreeClose<CR>
map <leader>t :NERDTreeToggle<CR>

" Deactivate key arrows
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Add auto Mix formater
let g:mix_format_on_save = 1

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

"Switch buffers without saving
set hidden

"colorscheme molokai

set guifont=Monaco:h13

set number
set relativenumber

set tabstop=2 shiftwidth=2 expandtab

" Stops gitcommit from auto wrapping
au Filetype gitcommit call SetGitCommit()
func SetGitCommit()
    setlocal formatoptions-=tl
endfunc

" Copy to clipboard
vnoremap  <leader>y "+y

" Paste from clipboard
nnoremap <leader>p "+p