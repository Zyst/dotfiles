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
Plug 'sheerun/vim-polyglot'
Plug 'dmix/elvish.vim', { 'on_ft': ['elvish']}

call plug#end()

if g:os == "Darwin"
    nnoremap <leader>t :term <CR>
    echo "mac lol"
endif

if g:os == "Linux"
    nnoremap <leader>t :term <CR>
    echo "linux"
endif

if g:os == "Windows"
    nnoremap <leader>t :term "C:\Program Files\Git\bin\bash.exe" <CR>
    echo "windows"
endif

if (has("termguicolors"))
  set termguicolors
endif

syntax on

colorscheme onedark

let g:onedark_terminal_italics=1
