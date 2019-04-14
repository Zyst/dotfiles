" Zyst

" DO NOT EDIT THIS FILE DIRECTLY
" This is a file generated from a literate programing source file located at
" https://github.com/Zyst/dotfiles/blob/master/vimrc.org
" You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

if !(g:os == "Windows")
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

if has('nvim')
  call plug#begin('~/.config/nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

Plug 'Zyst/egoist-one.vim'
if !(g:os == "Windows")
  Plug 'wincent/command-t', {
        \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
        \ }
else
  Plug 'ctrlpvim/ctrlp.vim'
endif
Plug 'sheerun/vim-polyglot'
Plug 'dmix/elvish.vim', { 'on_ft': ['elvish']}
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'christoomey/vim-tmux-navigator'

call plug#end()

let mapleader="\<Space>"

let maplocalleader="\\"

xnoremap <C-h> <C-w>h
xnoremap <C-j> <C-w>j
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

set nomodeline

filetype indent plugin on

set clipboard=unnamed

if g:os == "Linux"
    
endif

if g:os == "Windows"
    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
endif

if g:os == "Darwin"
    
endif

if (g:os == "Linux") || (g:os == "Darwin")
    
endif

if (has("termguicolors"))
  set termguicolors
endif

syntax on

colorscheme onedark

let g:onedark_terminal_italics=1
