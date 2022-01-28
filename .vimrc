" Get vundle from here:
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" Copy this .vimrc and run :PluginInstall the very first time.
" Also run :GoInstallBinaries once vim-go is installed

set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
if ($OS == 'Windows_NT')
        set shellslash
        set rtp+=~/vimfiles/bundle/Vundle.vim
else
        set rtp+=~/.vim/bundle/Vundle.vim
endif

call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'vim-scripts/indentpython.vim'
Plugin 'scrooloose/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-markdown'
Plugin 'klen/python-mode'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'mhinz/vim-startify'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'junegunn/fzf'
Plugin 'vimwiki/vimwiki'
Plugin 'sheerun/vim-polyglot'
Plugin 'fatih/vim-go'
Plugin 'andymass/vim-matchup'
Plugin 'preservim/nerdcommenter'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'psf/black'
Plugin 'ryanoasis/vim-devicons'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" tagbar at F8
nmap <F8> :TagbarToggle<CR>

" my favourite font
set guifont=Hack\ 10

" markdown mode for .page files
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.page set filetype=markdown

set nofoldenable    " disable folding

" python settings
let g:pymode_options = 1 " default pymode settings
let g:pymode_rope_refix = '<C-c>'
let g:pymode_rope_refix = '<C-c>'
au BufRead,BufNewFile *.py,*.pyw set tabstop=4
au BufRead,BufNewFile *.py,*.pyw set softtabstop=4
au BufRead,BufNewFile *.py,*.pyw set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw set textwidth=79
au BufRead,BufNewFile *.py,*.pyw set expandtab
au BufRead,BufNewFile *.py,*.pyw set autoindent
" au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
" au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /\s\+$/
au         BufNewFile *.py,*.pyw set fileformat=unix
au BufRead,BufNewFile *.py,*.pyw let b:comment_leader = '#'
" au BufWritePre *.py execute ':Black'

" General settings
set tabstop=4       	" number of visual spaces per TAB
set softtabstop=4	" number of spaces in tab when editing
set expandtab       	" tabs are spaces
set wildignore=*.o,*~,*.pyc
set encoding=utf-8

let python_highlight_all=1
syntax on
set background=light
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree
set ignorecase
" set paste
set nohlsearch
set incsearch
nmap <F3> a<C-R>=strftime("%A %Y%m%d")<CR><Esc>
imap <F3> <C-R>=strftime("%A %Y%m%d")<CR>
:set pastetoggle=<f5>
set laststatus=2 "airline needs this
let g:airline#extensions#tabline#enabled = 1
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|pyc)$'

" OS Specific settings
if ($OS == 'Windows_NT')
        set background=dark
		"colorscheme solarized
        "vimwiki settings
        let g:vimwiki_list = [{'path': '~\OneDrive\Documents\GitHub\arunsrin.mkdocs\home',
                              \ 'syntax': 'markdown', 'ext': '.md'}]
else
        "vimwiki settings
        let g:vimwiki_list = [{'path': '~/code/arunsrin.mkdocs/home',
                              \ 'syntax': 'markdown', 'ext': '.md'}]
        " use exuberant-ctags instead of emacs' ctags
        let g:gutentags_ctags_executable='/usr/bin/ctags'
endif

" folding for large json files
" Toggle fold: za
" Open fold: zo
" Close fold: zc
" open all: zR
" close all: zM
" more at :help fold-commands
autocmd BufRead,BufNewFile *.json
         \ setlocal filetype=json | syntax on | setlocal foldmethod=syntax


" map : to ;
" from https://www.twilio.com/blog/5-quality-of-life-vim-tricks-for-your-vimrc
nnoremap <leader>; ;
map ; :

" reformat and fix imports on save
let g:go_fmt_command = "goimports"

" ctags: reference: https://stackoverflow.com/a/741486
" look for a `tags` file from $CWD and go upward one folder until you find one
set tags=./tags;$HOME

" Bind NerdTree pane to Ctrl+o
map <C-o> :NERDTreeToggle<CR>

" nerdcommenter:
" \cc: comment: simple
" \cu: uncomment

set termguicolors

