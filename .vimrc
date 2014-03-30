" choose no compatibility width vi
set dir =~/swp,~/tmp,/var/tmp,/tmp
set nocompatible

set number
set ruler
syntax enable
set encoding=utf-8
set termencoding=utf-8
"display incomplete commands
set showcmd

" load the plugin and indent settings for the detected filetype
filetype plugin indent on


" Whitespace stuff
set nowrap
set tabstop=2
set shiftwidth=2
"#set softtabstop=2
set expandtab
"set list listchars=tab:\ \ ,trail:·
"backspace through everything in insert mode
set backspace=indent,eol,start

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Default color scheme
" Set color to 256 for complex scheme
set t_Co=256
"let g:molokai_original = 1
let g:slime_target = "tmux"
"set background=light
colorscheme hemisu
"let g:Powerline_symbols = 'unicode'
"turn powerline on in single window
set laststatus=2

let g:syntastic_warning_symbol='x'
let g:syntastic_error_symbol='x'
let g:syntastic_enable_signs=1

"newtr
let g:netrw_winsize=50
let g:netrw_liststyle=3
let g:netrw_list_hide= '.DS_Store'

" http://vimbits.com/bits/193
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

"indent guides
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=231
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=254
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My bundles here:
"
" original repos on GitHub
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdcommenter'
Bundle 'nono/vim-handlebars'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'csexton/trailertrash.vim'
Bundle 'jpalardy/vim-slime'
Bundle 'spolu/dwm.vim'
