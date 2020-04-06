
" General {
filetype plugin indent on   " Automatically detect file types.
syntax on                   " Syntax highlighting

set virtualedit=onemore             " Allow for cursor beyond last character
set history=1000                    " Store a ton of history (default is 20)
"    set spell                           " Spell checking on
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator
set encoding=utf-8
" }

" Vim UI {
set cmdheight=2                 " Better display for messages

set noshowmode                  " Disable the current mode because we have lightline
set laststatus=2

set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
set number                      " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
" set wildmenu                    " Show list instead of just completing
" set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
" }

" Formatting {
set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line
set softtabstop=4               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
" }

call plug#begin('~/.vim/plugged')

Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'itchyny/lightline.vim'

Plug 'preservim/nerdtree'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'hashivim/vim-terraform'
Plug 'APZelos/blamer.nvim'
Plug 'Chiel92/vim-autoformat'
call plug#end()

let g:deoplete#enable_at_startup = 1 " Use deoplete
let g:blamer_enabled = 1

" Golang {
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' }) " use vim-go for golang autocompletion
" }

" Terraform {
let g:terraform_align = 1 " align automatically
let g:terraform_fmt_on_save = 1 " format on save
" }

" Statusline {
let g:lightline = {
			\ 'colorscheme': 'wombat',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'readonly', 'filename', 'modified', 'gitinfo' ] ]
			\ },
			\ 'component_function': {
			\   'gitinfo': 'FugitiveStatusline'
			\ },
			\ }
" }

" On Start {
autocmd VimEnter * NERDTree
" }

" Formatting {
"au BufWrite * :Autoformat
au BufNewFile,BufRead Jenkinsfile setf groovy
"

