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

" Themes
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'rakr/vim-one'
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
set scrolloff=5

" Habit bust: Using keys
" Disables arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Uncomment the one below for the one theme
" set background=light         " for the light version
colorscheme Tomorrow-Night

