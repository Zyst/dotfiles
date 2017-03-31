" Zyst

" PLUG {{{
" Install vim-plug if it isn't installed already
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" PLUGINS
call plug#begin('~/.vim/plugged')
" Core {{{
Plug 'ctrlpvim/ctrlp.vim' " File opening shenanigans
Plug 'tpope/vim-fugitive' " Git integration, something something
Plug 'scrooloose/nerdtree'  " Adds a navigation tree
Plug 'airblade/vim-gitgutter' " Adds git changes markers
Plug 'jiangmiao/auto-pairs' " Auto closes a lot of stuff with smart behavior
Plug 'ap/vim-css-color' " Colorizes stuff
Plug 'w0rp/ale' " Runs testy thingies and warns about errors
Plug 'editorconfig/editorconfig-vim' " Grabs project-specific editor configurations
Plug 'heavenshell/vim-jsdoc' " You can add JS Docs with the JsDoc command
Plug 'valloric/youcompleteme'  " Autocomplete shimalading
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' } " Intellisense type stuff
Plug 'sbdchd/neoformat' " Does formatting for many languages
Plug 'flowtype/vim-flow', {
            \ 'autoload': {
            \     'filetypes': 'javascript'
            \ },
            \ 'build': {
            \     'mac': 'npm install -g flow-bin',
            \     'unix': 'npm install -g flow-bin'
            \ }}
Plug 'tpope/vim-surround' " Adds thingies to add sorrounding stuff like ''
Plug 'easymotion/vim-easymotion' " Lets you move around faster
" }}}

" Languages {{{
Plug 'othree/html5.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'pangloss/vim-javascript'
Plug 'herringtondarkholme/yats.vim' " TypeScript
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'
Plug 'leshill/vim-json'
" }}}

" Themes {{{
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'Zyst/onedark.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'oguzbilgic/sexy-railscasts-theme'
Plug 'mhartington/oceanic-next'
Plug 'morhetz/gruvbox'
Plug 'w0ng/vim-hybrid'
Plug 'nanotech/jellybeans.vim'
Plug 'davidklsn/vim-sialoquent'
Plug 'ajh17/Spacegray.vim'
" }}}
call plug#end()
" }}}

" PLUGINS CONFIG {{{
" Enable JSX in JS files
let g:jsx_ext_required = 0

" Enable JSDocs highlighting
let g:javascript_plugin_jsdoc = 1
" Enable NGDoc(?) highlighting
let g:javascript_plugin_ngdoc = 1
" Enable flow syntax in vim-javascript
let g:javascript_plugin_flow = 1

" Let NERDTree see dotfiles
let NERDTreeShowHidden = 1

" Editor config fix for fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
"Editor config fix for ssh remote files
let g:EditorConfig_exclude_patterns = ['scp://.*']

" Only use certain linters for JS
let g:ale_linters = {
      \  'javascript': ['eslint', 'flow'],
      \}

" Make CtrlP 'listen' to .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" neoformat: format javascript on save
autocmd BufWritePre *.js Neoformat
" Use formatprg when available
let g:neoformat_try_formatprg = 1
" Configure prettier with formatprg
autocmd FileType javascript set formatprg=prettier\ --stdin\ --parser\ flow\ --single-quote\ --trailing-comma\ es5

" Flow stuff
" Automatically closes flow error pane
let g:flow#autoclose = 1

" Easy motion
" Search for a single char
nmap <Space> <Plug>(easymotion-overwin-f2) 
" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1 
" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
" }}}

" MISC {{{
" Allows backspace to work 'normally'
set backspace=indent,eol,start

" I wanna learn to use fold aggresively, so everything is folded by default
set foldlevelstart=1
" }}}

" CLIPBOARD {{{
" Shares system clipboard
set clipboard=unnamed
" }}}

" SPACES & TABS {{{
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
" }}}

" HISTORY {{{
set undofile
set undodir=~/.vim/undo_files//
set directory=~/.vim/swap_files//
set backupdir=~/.vim/backup_files//
" }}}

" SPELLCHECKING {{{
" We spellcheck English and check markdown and text files
set spelllang=en
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd BufRead,BufNewFile *.txt setlocal spell
autocmd BufRead,BufNewFile *.markdown setlocal spell
" }}}

" THEMES {{{
" Theme accuracy stuff
syntax enable
" for vim 7
set t_Co=256
" for vim 8
if (has("termguicolors"))
  set termguicolors
endif

colorscheme onedark
" }}}

" CODE APPEARANCE {{{
" Italic comments
highlight Comment gui=italic
highlight Comment cterm=italic

" Italic HTML Args
highlight htmlArg gui=italic
highlight htmlArg cterm=italic

" Types
highlight Type gui=italic
highlight Type cterm=italic

" XML Args (For JSX)
highlight xmlAttrib gui=italic
highlight xmlAttrib cterm=italic

"JS 'this'
highlight jsthis gui=italic
highlight jsthis cterm=italic
" }}}

" EDITOR APPEARANCE {{{
" LINES
" Hightlight the current cursor line
set cursorline
" Wrap lines visually
set wrap
" Show line numbers
" set number
" Minimum number of screen lines that you would like above and below the cursor
set scrolloff=1
" this autocompletes commands with TAB
set wildmenu
" Highlights the matching item like ({[]})
set showmatch

" CURSOR CHANGE (MODE DEPENDANT)
" Change cursor shape depending on mode
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" statusline: On the Right side: File name,
set statusline=%=\ %f\ %m
" Don't show a second statusline
set noshowmode
" Vertical split color
hi vertsplit ctermfg=238 ctermbg=235
" Line Nnumber color
hi LineNr ctermfg=237
" StatusLine colors
hi StatusLine ctermfg=235 ctermbg=245 guifg=#5c6370 guibg=#262626
" StatusLine NC
hi StatusLineNC ctermfg=235 ctermbg=237
" Search appearance
hi Search ctermbg=58 ctermfg=15
" Sets the default hi to avoid overrides
hi Default ctermfg=1
" Changes the ~ sign color on empty lines
hi EndOfBuffer ctermfg=237 ctermbg=235
" Changes the background color
hi Normal guibg=#262626

" GIT GUTTER APPEARANCE
" Fix so Git Gutter looks clearer
hi clear SignColumn
hi SignColumn ctermbg=235
hi GitGutterAdd ctermbg=235 ctermfg=245
hi GitGutterChange ctermbg=235 ctermfg=245
hi GitGutterDelete ctermbg=235 ctermfg=245
hi GitGutterChangeDelete ctermbg=235 ctermfg=245
" }}}

" SEARCH {{{
" Search as you type characters
set incsearch
" Ignore case while searching
set ignorecase
" }}}

" FOLDING {{{
" Enable folding
set foldenable
" Open 10 fold levels by default
set foldlevelstart=10
" Fold based on indent level
set foldmethod=indent
" }}}

" KEY REMAPS {{{
" Disables arrow keys, habit bust
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" These make it so you can move between Vim Windows, without having to restart
" them and the like
noremap <C-h> <C-w>h 
noremap <C-j> <C-w>j 
noremap <C-k> <C-w>k 
noremap <C-l> <C-w>l
" }}}

" HOTKEYS {{{
" Toggle Nerdtree with Ctrl + B
map <C-b> :NERDTreeToggle<CR>
" Toggle the current fold
nnoremap <s-tab> za 
" }}}

" vim:foldmethod=marker:foldlevel=0
