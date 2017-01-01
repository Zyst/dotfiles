" Install vim-plug if it isn't installed already
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" PLUGINS
call plug#begin('~/.vim/plugged')
" Core
Plug 'ctrlpvim/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'

" Languages
Plug 'othree/html5.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'pangloss/vim-javascript'
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'

" Themes
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'rakr/vim-one'
Plug 'NLKNguyen/papercolor-theme'
call plug#end()

" CLIPBOARD
" Shares system clipboard
set clipboard=unnamedplus

" LINES
" Hightlight the current cursor line
set cursorline
" Wrap lines visually
set wrap
" Show line numbers
set number
" Minimum number of screen lines that you would like above and below the cursor
set scrolloff=1

" TABS
" Allows backspace to work 'normally'
set backspace=indent,eol,start
set smarttab
" Makes tab insert spaces
set expandtab
" How many spaces we insert when pressing tab
set tabstop=2
" How many colums we use when you hit tab
set softtabstop=2
" How many columns text is indented using indent commands << >>
set shiftwidth=2
" Does nothing more than copy the indentation from the previous line, when starting a new line
set autoindent
" Smart indent automatically inserts one extra level of indentation in some cases
set smartindent

" HISTORY
set undofile
set undodir=~/.vim/undo_files//
set directory=~/.vim/swap_files//
set backupdir=~/.vim/backup_files//

" Habit bust: Using keys
" Disables arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Airline show by default
set laststatus=2
let g:airline_powerline_fonts = 1

" Uncomment the one below for the one theme
" set background=dark         " for the light version
colorscheme Tomorrow-Night

