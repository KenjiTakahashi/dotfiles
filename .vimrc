" Karol 'Kenji Takahashi' Wozniak © 2012 

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off
"
" vundle
" Added (almost) on top, so vim can properly see color schemes
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Bundle "gmarik/vundle"
Bundle 'kien/ctrlp.vim'
Bundle 'lettuce.vim'
Bundle 'w0ng/vim-hybrid'
Bundle 'Syntastic'
Bundle 'The-NERD-Commenter'
Bundle 'The-NERD-tree'
Bundle 'surround.vim'
Bundle 'easytags.vim'
Bundle 'vim-coffee-script'
Bundle 'tpope/vim-markdown'
Bundle 'SirVer/ultisnips'
Bundle 'Gist.vim'
Bundle 'jade.vim'
Bundle 'vim-stylus'
Bundle 'EasyDigraph.vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'b4winckler/vim-objc'
Bundle 'tpope/vim-fugitive'
Bundle 'YankRing.vim'
Bundle 'sjl/gundo.vim'

set t_Co=256
let g:hybrid_use_Xresources=1
colorscheme hybrid

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set encoding=utf-8

set tabstop=4
set shiftwidth=4
set softtabstop=4
set completeopt=menu,preview
set expandtab
autocmd FileType jade set sw=4
autocmd FileType stylus set sw=4
autocmd BufNewFile,BufRead *.m set filetype=objc

let g:Tb_MapWindowNavVim=1
let g:Tb_MapWindowNavArrows=1
let mapleader = ","

" no blink, even in GUI
set guicursor=a:blinkon0

set number
set pastetoggle=<F2>

"NERDTree
let g:NERDTreeWinSize = 32
let g:NERDTreeWinPos = "left"
let g:NERDTreeAutoCenter = 0
let g:NERDTreeHighlightCursorLine = 0
nmap <F11> :NERDTreeToggle<bar>wincmd p<CR>

"buffers
noremap gt :bnext<CR>
noremap gT :bprev<CR>
noremap gc :bn<bar>bd # <CR>

"CtrlP
let g:ctrlp_match_window_reversed=0
let g:ctrlp_max_height=20
let g:ctrlp_dotfiles=0
let g:ctrlp_switch_buffer=0
let g:ctrlp_extensions=['buffertag']
let g:ctrlp_map='mf'
nmap <silent> mb :CtrlPBuffer<CR>
nmap <silent> mt :CtrlPBufTagAll<CR>
nmap <silent> mr :CtrlPMRU<CR>
set wildignore+=*~
set wildignore+=node_modules
set wildignore+=build
set wildignore+=dist
set wildignore+=*.o

"YankRing
let g:yankring_window_height=20
let g:yankring_history_file='.yankring_history'
noremap <silent> yr :YRShow<CR>

"gundo
nnoremap go :GundoToggle<CR>

"insert coding to python/ruby files
au BufNewFile *.py put! ='# -*- coding: utf-8 -*-'
au BufNewFile *.rb put! ='# coding: utf-8'

"adding timestamp
nnoremap ts "=strftime("%d %B %Y, %R")<CR>P

map <F1> <Esc>
imap <F1> <Esc>

let g:syntastic_enabled_balloons=0

let g:EasyDigraph_imap='<C-b>'

set laststatus=2
let g:Powerline_mode_n='n'
let g:Powerline_mode_i='i'
let g:Powerline_mode_R='r'
let g:Powerline_mode_v='v'
let g:Powerline_mode_V='v⋅l'
let g:Powerline_mode_cv='v⋅b'
let g:Powerline_mode_s='s'
let g:Powerline_mode_S='s⋅l'
let g:Powerline_mode_cs='s⋅b'
let g:Powerline_theme='kenji'
let g:Powerline_stl_path_style='relative'
let g:Powerline_symbols_override={'LINE': ''}
