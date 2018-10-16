" Store as ~/.vimrc (Unix) or ~/_vimrc (Windows, non-cygwin)
"Stop the god damn shift K to crash vim 
map <S-k> <Nop>
"eslint
let g:syntastic_javascript_checkers = ['eslint']
"set line wrap
set wrap
"highlight current line in current window
highlight CursorLine   cterm=NONE ctermbg=LightBlue ctermfg=white guibg=green guifg=white
highlight CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
"relative line num and no main line number
set nonumber
set relativenumber
"natural copy to system clipboard
vnoremap <C-c> "*y
set clipboard=unnamed
"leave insert mode quickly
 " leave insert mode quickly
  if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
      autocmd!
      au InsertEnter * set timeoutlen=0
      au InsertLeave * set timeoutlen=1000
    augroup END
  endif
"run JS in a new buffer
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  let isfirst = 1
  let words = []
  for word in split(a:cmdline)
    if isfirst
      let isfirst = 0  " don't change first word (shell command)
    else
      if word[0] =~ '\v[%#<]'
        let word = expand(word)
      endif
      let word = shellescape(word, 1)
    endif
    call add(words, word)
  endfor
  let expanded_cmdline = join(words)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:  ' . a:cmdline)
  call setline(2, 'Expanded to:  ' . expanded_cmdline)
  call append(line('$'), substitute(getline(2), '.', '=', 'g'))
  silent execute '$read !'. expanded_cmdline
  1
endfunction

command! -complete=file -nargs=* RunJS call s:RunShellCommand('node '.<q-args>)
"smart paste

let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
set guifont=Menlo\ Regular:h18
"set leader key
"setting for lightline
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightlineFugitive',
      \   'filename': 'LightlineFilename',
      \   'fileformat': 'LightlineFileformat',
      \   'filetype': 'LightlineFiletype',
      \   'fileencoding': 'LightlineFileencoding',
      \   'mode': 'LightlineMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

function! LightlineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightlineFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' && has_key(g:lightline, 'ctrlp_item') ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
      let branch = fugitive#head()
      return branch !=# '' ? mark.branch : ''
    endif
  catch
  endtry
  return ''
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP' && has_key(g:lightline, 'ctrlp_item')
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0
set noshowmode
"longer history
set hidden
set history=100
"some logic when indenting
filetype indent on
set nowrap
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

:let mapleader = ","
set nocompatible              " be iMproved, required
filetype off                  " required

"Follow config on https://dougblack.io/words/a-good-vimrc.html#colors
set cursorline
set wildmenu
set lazyredraw
nnoremap j gj
nnoremap k gk
nnoremap <leader>u :GundoToggle<CR>
"open ag.vim
nnoremap <leader>a :Ag
let g:ackprg = 'ag --vimgrep'
"edit vimrc and load vimrc bindings
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
"This one visually selects the blocks of char you added last time you were in Insert Mode
nnoremap gV [v`]
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"
" " The following are examples of different formats supported.
" " Keep Plugin commands between vundle#begin/end.
" " plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" " Install L9 and avoid a Naming conflict if you've already installed a
" " different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
" plugin/auto-pairs.vim 
" no spelling
set nospell
" Easier nerdtree navigation between split windows 
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" No more swap file
set noswapfile
" Fix Delete (backspace) on Mac OS X
set backspace=2
" " Indentation
" set autoindent
" filetype plugin indent on
" be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}AE
Plugin 'supertab-master'
Plugin 'vim-multiple-cursors-master'

"OcianicNext theme 
Plugin 'mhartington/oceanic-next'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin ongc

" ln -s vim /usr/local/bin/vi
"
set clipboard=unnamed

" Enable OS mouse clicking and scrolling
"
" Note for Mac OS X: Requires SIMBL and MouseTerm
"
" http://www.culater.net/software/SIMBL/SIMBL.php
" https://bitheap.org/mouseterm/
if has("mouse")
   set mouse=a
endif

set shell=bash\ -i

" " Bash-style tab completion
" set wildmode=longest,list
" set wildmenu

" Fix trailing selection on visual copy/cut
set selection=exclusive

" Keep selection on visual yank
vnoremap <silent> y ygv

" Emacs-style start of line / end of line navigation
nnoremap <silent> <C-a> ^
nnoremap <silent> <C-e> $
vnoremap <silent> <C-a> ^
vnoremap <silent> <C-e> $
inoremap <silent> <C-a> <esc>^i
inoremap <silent> <C-e> <esc>$i

" Fix Alt key in MacVIM GUI
" TODO - Fix in MacVIM terminal
if has("gui_macvim")
  set macmeta
endif

" Emacs-style start of file / end of file navigation
nnoremap <silent> <M-<> gg
nnoremap <silent> <M->> G$
vnoremap <silent> <M-<> gg
vnoremap <silent> <M->> G$
inoremap <silent> <M-<> <esc>ggi
inoremap <silent> <M->> <esc>G$i

" Do not attempt to fix style on paste
" " Normally we would just `set paste`, but this interferes with other aliases.
" nnoremap <silent> p "+p

" Disable comment continuation on paste
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Show line numbers
set number
" Show statusline
set laststatus=2

" Case-insensitive search
set ignorecase

" Highlight search results and search as character are entered
set incsearch
set hlsearch
nnoremap <silent> <Esc> :nohlsearch<Bar>:echo<CR>
"this command let you scroll without fucking up 
nnoremap <esc>^[ <esc>^[
" Default to soft tabs, 2 spaces
set expandtab
set sw=2
set sts=2
" Except Markdown
autocmd FileType mkd set sw=4
autocmd FileType mkd set sts=4

" Default to Unix LF line endings
set ffs=unix

" Folding
set foldmethod=syntax
set foldcolumn=1
set foldlevelstart=20

let g:vim_markdown_folding_disabled=1 " Markdown
let javaScript_fold=1                 " JavaScript
let perl_fold=1                       " Perl
let php_folding=1                     " PHP
let r_syntax_folding=1                " R
let ruby_fold=1                       " Ruby
let sh_fold_enabled=1                 " sh
let vimsyn_folding='af'               " Vim script
let xml_syntax_folding=1              " XML

autocmd BufRead,BufNewFile *.cql set filetype=cql

"
" Wrap window-move-cursor
"
function! s:GotoNextWindow( direction, count )
  let l:prevWinNr = winnr()
  execute a:count . 'wincmd' a:direction
  return winnr() != l:prevWinNr
endfunction

function! s:JumpWithWrap( direction, opposite )
  if ! s:GotoNextWindow(a:direction, v:count1)
    call s:GotoNextWindow(a:opposite, 999)
  endif
endfunction
"
" nnoremap <silent> <C-w>h :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
" nnoremap <silent> <C-w>j :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
" nnoremap <silent> <C-w>k :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
" nnoremap <silent> <C-w>l :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
nnoremap <silent> <C-w><Left> :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
nnoremap <silent> <C-w><Down> :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
nnoremap <silent> <C-w><Up> :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
nnoremap <silent> <C-w><Right> :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
inoremap <silent> <C-w>h <esc>:<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
inoremap <silent> <C-w>j <esc>:<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
inoremap <silent> <C-w>k <esc>:<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
inoremap <silent> <C-w>l <esc>:<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
inoremap <silent> <C-w><Left> <esc>:<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
inoremap <silent> <C-w><Down> <esc>:<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
inoremap <silent> <C-w><Up> <esc>:<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
inoremap <silent> <C-w><Right> <esc>:<C-u>call <SID>JumpWithWrap('l', 'h')<CR>

"
" vim-plug dependency manager
" https://github.com/junegunn/vim-plug
"

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vimc'
  Plugin 'itchyny/lightline.vim'
  Plug 'scrooloose/nerdcommenter'
  Plug 'mhinz/vim-startify'
  Plug 'bruno-/vim-alt-mappings'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'tomtom/tcomment_vim'
"   Workaround https://github.com/vim-airline/vim-airline/issues/1325
"   Plug 'bling/vim-airline'
"   Plug 'vim-airline/vim-airline-themes'
  Plug 'fsouza/go.vim'
  Plug 'wting/rust.vim'
  Plug 'godlygeek/tabular'
  Plug 'plasticboy/vim-markdown'
  Plug 'mtth/scratch.vim'
  Plug 'greplace.vim'
  Plug 'mcandre/Conque-Shell'
  Plug 'elubow/cql-vim'
  Plug 'scrooloose/nerdtree'
  Plug 'moll/vim-bbye'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'fatih/vim-go'
  Plug 'robbles/logstash.vim'
  Plug 'mhartington/oceanic-next'
call plug#end()

" " Enable Powerline fonts for airline
" if !has("win32") && !has("win16")
"   let g:airline_powerline_fonts = 1
"   let g:airline_theme='distinguished'
" endif

"Line search for ctrlP 
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPLastMode'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']

" Enable syntax highlighting
syntax on
" Theme
syntax enable
" for vim 7
set t_Co=256

" for vim 8
if (has("termguicolors"))
set termguicolors
endif

colorscheme OceanicNext
" Column 80 marker
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#660000
" match OverLength /\%81v.\+/

" " Currently broken due to Vim/Semicolon issues
" " Alt+; to toggle comments
" nnoremap <silent> <M-;> gc
" vnoremap <silent> <M-;> gc
" inoremap <silent> <M-;> <esc>gci

" Scratch splits the current window in half
let g:scratch_height = 0.50
" Scratch opens in Markdown format
let g:scratch_filetype = 'markdown'

" ctrlp: Apply .gitignore's
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
" ctrlp: Ignore golang vendors
set wildignore+=vendor

" Conque Allow C-w window navigation while in insert mode
let g:ConqueTerm_CWInsert = 1

" Replace shell with Conque-Shell
set nocp
cabbrev sh sh<C-\>esubstitute(getcmdline(), '^sh', 'ConqueTerm bash\ -i', '')<cr>
" " NERDTress File highlighting
" function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
"  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='.
"  a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
"   exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'.
"   a:extension .'$#'
"   endfunction
"
"   call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
"   call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
"   call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
"   call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
"   call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow',
"   '#151515')
"   call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
"   call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
"   call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
"   call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
"   call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
"   call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
"   call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
"   call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')
" Nerd tree toggle shortcut
map <C-a> :NERDTreeToggle<CR>
" Focus main window, not NERDTree
" Start NERDTree
" autocmd VimEnter * NERDTree
" Go to previous (last accessed) window.
" autocmd VimEnter * wincmd p
" augroup NERD
"   autocmd!
"   autocmd VimEnter * NERDTree
"   autocmd VimEnter * wincmd p
" augroup END


" For serious
" let NERDTreeShowHidden=1

" vim-go: Enable goimports on save
let g:go_fmt_command = "goimports"
