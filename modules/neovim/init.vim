" General
set virtualedit=onemore
set iskeyword-=.
set iskeyword-=#
set iskeyword-=-

" Use persistent history
if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
endif
set undodir=/tmp/.vim-undo-dir
set undofile

" Vim UI
set notermguicolors
colorscheme vim
set colorcolumn=80
set cmdheight=2
set noshowmode
set linespace=0
set number
set showmatch
set winminheight=0
set ignorecase
set hlsearch
set incsearch
set smartcase
set whichwrap=b,s,h,l,<,>,[,]
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
set t_Co=256

" Formatting
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set nowrap
set nojoinspaces
set splitright
set splitbelow
set foldmethod=syntax
set foldlevelstart=99

set completeopt=menuone,noselect
inoremap <silent><expr> <TAB> pumvisible() ? compe#confirm('<CR>') : "\<TAB>"

" Terraform
let g:terraform_align = 1
let g:terraform_fmt_on_save = 1

" Statusline
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

" Formatting
au BufNewFile,BufRead Jenkinsfile setf groovy

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>