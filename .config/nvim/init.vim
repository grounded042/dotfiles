
" General {

set virtualedit=onemore             " Allow for cursor beyond last character
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator
" }

" Use persistent history.
if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
endif
set undodir=/tmp/.vim-undo-dir
set undofile

" Vim UI {

" neovim 0.10 changed how colors work. Use only terminal ANSI colors via the
" below options.
set notermguicolors
colorscheme vim

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
set foldmethod=syntax
set foldlevelstart=99
" }

call plug#begin('~/.vim/plugged')

Plug 'neovim/nvim-lspconfig' " default lsp
Plug 'hrsh7th/nvim-cmp'      " completions
Plug 'hrsh7th/cmp-nvim-lsp'  " lsp completions
Plug 'hrsh7th/cmp-buffer'    " buffer completions
Plug 'hrsh7th/cmp-path'      " filesystem path completions

" Plug 'hrsh7th/cmp-vsnip'
" Plug 'hrsh7th/vim-vsnip'

" Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'nvim-treesitter/playground'

" Plug 'roxma/nvim-yarp'
" Plug 'roxma/vim-hug-neovim-rpc'
Plug 'itchyny/lightline.vim' " light status line

Plug 'nvim-lua/plenary.nvim' " library of lua funcs for nvim
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' } " fuzzy finder

" Plug 'junegunn/fzf', { 'do': './install --bin' }
" Plug 'junegunn/fzf.vim'
" Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'hashivim/vim-terraform'
" Plug 'APZelos/blamer.nvim'
" Plug 'Chiel92/vim-autoformat'

Plug 'chemzqm/vim-jsx-improve'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }

" copilot
Plug 'zbirenbaum/copilot.lua'
Plug 'CopilotC-Nvim/CopilotChat.nvim'

call plug#end()

lua require("init")
lua require("lsp")

set completeopt=menuone,noselect

inoremap <silent><expr> <TAB> pumvisible() ? compe#confirm('<CR>') : "\<TAB>"

" Golang {
autocmd BufWritePre *.go lua goimports()
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
au BufNewFile,BufRead Jenkinsfile setf groovy
" }

" Telescope {
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" }
