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
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'

" Languages
Plug 'othree/html5.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'othree/yajs.vim'
Plug 'herringtondarkholme/yats.vim'
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'

" Themes
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'rakr/vim-one'
Plug 'NLKNguyen/papercolor-theme'
Plug 'oguzbilgic/sexy-railscasts-theme'
Plug 'mhartington/oceanic-next'
Plug 'morhetz/gruvbox'
Plug 'w0ng/vim-hybrid'
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
" set number
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

" SPELLCHECKING
set spelllang=en
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd BufRead,BufNewFile *.txt setlocal spell
autocmd BufRead,BufNewFile *.markdown setlocal spell

" Habit bust: Using keys
" Disables arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Airline show by default
set laststatus=2

" THEMES
" Theme accuracy stuff
syntax enable 
" for vim 7
set t_Co=256 
" for vim 8
if (has("termguicolors"))
 set termguicolors
endif 
" Uncomment the one below for the one theme
" set background=dark         " for the light version 
colorscheme gruvbox

" CURSOR CHANGE (MODE DEPENDANT)
" Change cursor shape depending on mode, in iTerm2
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" CODE APPEARANCE
" Italic comments
highlight Comment cterm=italic 

" EDITOR APPEARANCE
" Statusline: On the Right side: File name,
set statusline=%=\ %f\ %m 
" Don't show a second statusline
set noshowmode 
" Vertical split color
hi vertsplit ctermfg=238 ctermbg=235 
" Line Nnumber color
hi LineNr ctermfg=237 
" StatusLine colors 
hi StatusLine ctermfg=235 ctermbg=245 guifg=Background guibg=#686868
" StatusLine NC
hi StatusLineNC ctermfg=235 ctermbg=237 
" Search appearance
hi Search ctermbg=58 ctermfg=15 
" Sets the default hi to avoid overrides
hi Default ctermfg=1
" Changes the ~ sign color on empty lines
hi EndOfBuffer ctermfg=237 ctermbg=235 
" Something something, vertical characters?
set fillchars=vert:\ ,stl:\ ,stlnc:\ 

" GIT GUTTER APPEARANCE
" Fix so Git Gutter looks clearer
hi clear SignColumn
hi SignColumn ctermbg=235
hi GitGutterAdd ctermbg=235 ctermfg=245
hi GitGutterChange ctermbg=235 ctermfg=245
hi GitGutterDelete ctermbg=235 ctermfg=245
hi GitGutterChangeDelete ctermbg=235 ctermfg=245 

