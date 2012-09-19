" choose no compatibility width vi
set nocompatible

set number
set ruler
syntax enable
set encoding=utf-8
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
color lettuce
call pathogen#infect()

filetype plugin indent on
"au BufWritePost *.coffee silent CoffeeMake! -b | cwindow | redraw!
" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2
"let g:syntastic_quiet_warnings=0
  let g:syntastic_javascript_checker='jshint'
  "let g:syntastic_check_on_open=1
  "newtr
  let g:netrw_winsize=40
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

set runtimepath^=~/.vim/bundle/ctrlp.vim
"indent guides
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=233
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=236
