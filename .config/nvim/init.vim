
" General {

set virtualedit=onemore             " Allow for cursor beyond last character
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator
" }

" Vim UI {

set colorcolumn=80

set cmdheight=2                 " Better display for messages

set noshowmode                  " Disable the current mode because we have lightline

set linespace=0                 " No extra spaces between rows
set number                      " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
" }

" Formatting {
set nowrap                      " Do not wrap long lines
set softtabstop=4               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
" }

call plug#begin('~/.vim/plugged')

Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'

Plug 'hrsh7th/nvim-compe'

Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'itchyny/lightline.vim'

Plug 'preservim/nerdtree'
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'hashivim/vim-terraform'
" Plug 'APZelos/blamer.nvim'
Plug 'Chiel92/vim-autoformat'

Plug 'chemzqm/vim-jsx-improve'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
call plug#end()

lua require("lsp")

" nvim compe
set completeopt=menuone,noselect
" let g:compe.enabled = v:true

let g:blamer_enabled = 1

" Golang {
autocmd FileType go setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd BufWritePre *.go lua goimports(1000)
autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)
" let g:go_def_mode='gopls'
" let g:go_info_mode='gopls'
" let g:go_fmt_command = 'goimports'
" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_types = 1
" let g:go_highlight_extra_types = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_structs = 1
" let g:go_highlight_interfaces = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_generate_tags = 1
" let g:go_auto_sameids = 1

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
" }

" Formatting {
"au BufWrite * :Autoformat
au BufNewFile,BufRead Jenkinsfile setf groovy
" Format prior to save
"

