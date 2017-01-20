
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                                   PLUGINS                                   "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()




"***************** VUNDLE *****************"

" Vundle itself
Plugin 'gmarik/Vundle.vim' 



"**************** UTILITY *****************"

" Better status bar
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Easy commenting
Plugin 'scrooloose/nerdcommenter'

" Git gestion
"Plugin 'tpope/vim-fugitive'

" Add and change surrounding brackets
Plugin 'tpope/vim-surround'

" Brackets automatisation
Plugin 'Raimondi/delimitMate'

" XMate-like folder navigation
Plugin 'scrooloose/nerdtree'

"Doxygen
Plugin 'DoxygenToolkit.vim'

"Markdown
"Plugin 'suan/vim-instant-markdown'




"************ SNIPPETS GESTION ************"

" Snippets Engine
Plugin 'vim-scripts/UltiSnips'

" Snippets Library
Plugin 'honza/vim-snippets'



"********* LANGUAGE COMPATIBILITY *********"

" Prolog
"Plugin 'adimit/prolog.vim'

"Scala
"Plugin 'derekwyatt/vim-scala'

" Coq
"Plugin 'the-lambda-church/coquille'



"************ SYNTAX ANALYSERS ************"

" Syntax checker and error reporter
Plugin 'scrooloose/syntastic'

" Syntax analisis for ocaml
"Plugin 'the-lambda-church/merlin'



"******** SHELL AND INTERPRETERS  *********"

"Plugin 'Shougo/vimproc'

"Plugin 'Shougo/vimshell.vim'





call vundle#end()
filetype plugin indent on
syntax on
set t_Co=256




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                           GLOBAL CONFIGURATION                              "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set autoindent                  " Set auto indentation
set backspace=indent,eol,start  " Allow backspacing
set cinoptions+=j1,J1           " Set the c-indenting file
set cmdheight=1                 " Set the height of the command bar
set cursorline                  " Highlight the current line
set encoding=utf-8              " Set utf-8 as standard encoding
set expandtab                   " Replace tabs with spaces
set fileformats=unix
set ff=unix                     " Set unix as the standard file type
set hidden                      " Set buffers non deleted when abandoned
set hlsearch                    " Set highlight search results
set ignorecase                  " Ignore case for search
set laststatus=2                " Always show the status line
set lazyredraw                  " No redraw he interface when not utile
set list                        " Print spacing characters
set listchars=tab:\ \ ,trail:·
set magic                       " Better regex
set mouse=a                     " Disable mouse
set nobackup                    " Disable backup
set nofoldenable                " Disable Folding
set noswapfile                  " Disable Swap Files
set number                      " Display line number
set preserveindent              " Preserv local indentation
set ruler                       " Display the cursor position
set relativenumber              " Line number is relative to the position
set showcmd                     " Display the current command
set showmatch                   " Show corresponding bracket
set shiftround                  " Indent with a multiple au shiftwidth
set shiftwidth=4                " Set width indentation
set showbreak=↪                 " Set the breaking line symbol
set si
set softtabstop=4               " Set tabulations width
set smartindent                 " Smart indentation
set smarttab                    " Smart tabulations
set spelllang=fr,en             " Spell languages
set tabstop=4                   " Set tabulations width
set textwidth=79                " Line longer than 79 columns will be broken
set title                       " Show title
set ttyfast
set wildignore=*~,*.swp,*.class " Ignore
set wildignore+=*.o
set shell=/bin/zsh              " Set the shell used when executing commands in vim




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                                FUNCTIONS                                    "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" GUI-Settings
if has("gui_running")
    set guifont=Inconsoloata\ for\ Powerline:h12
    let g:Powerline_symbols = 'fancy'
    set fillchars+=stl:\ ,stlnc:\

    if has("mac")
        set transparency=5
    endif
endif


" Set new indentation
function! Indentation(n)
  execute "set tabstop=".a:n
  execute "set softtabstop=".a:n
  execute "set shiftwidth=".a:n
endfunction



" Auto Commands
if has("autocmd")
    au FileType ocaml       call Indentation(2)
    au BufRead,BufNewFile *.pro set filetype=prolog

    "CursorLine only in active window
    augroup CursorLineOnlyInActiveWindow
      autocmd!
      autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
      autocmd WinLeave * setlocal nocursorline
    augroup END

endif

" Reveals the actual word's syntaxique group
nmap <C-S-T> :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                                   MAPPING                                   "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"*********** MAPLEADER SETTING ***********"

" Set space to be the map leader
let mapleader=" "

"*************** NERD TREE ****************"

nmap <leader>nt :NERDTree<CR>
nmap <leader>nc :NERDTreeClose<CR>


"******** BUFFER TABS & WINDOW GESTION *********"

" Move to the next buffer
nmap <leader>bn :bnext<CR>

" Move to the previous buffer
nmap <leader>bp :bprevious<CR>

" Close the current buffer and move to the previous one
nmap <leader>bq :bp <BAR> bd #<CR>

" Close the current buffer, the current window
" and move to the previous one
nmap <leader>bQ :bp <BAR> bd #<CR> :q<CR>

" Move to the next buffer
nmap <leader>to :tab split<CR>

" Move to the next buffer
nmap <leader>tn :tabnext<CR>

" Move to the previous buffer
nmap <leader>tp :tabprevious<CR>

" Close the current buffer and move to the previous one
nmap <leader>tq :tabclose<CR>

" Close the current buffer, the current window
" and move to the previous one
nmap <leader>bQ :bp <BAR> bd #<CR> :q<CR>

" Show only the current buffer
nmap <leader>wo :only<CR>

" Move to the next window
nmap <leader>wn <C-w><C-w>

" Move to bottom window
nnoremap <C-J> <C-W>j

" Move to upper window
nnoremap <C-K> <C-W>k

" Move to right-side window
nnoremap <C-L> <C-W>l

" Move to left-side window
nnoremap <C-H> <C-W>h



"*********** EASY LINE EDITION ***********"

" Select all the document
nmap <leader>va gg<S-v>G

" Copy-up the line
nmap <C-a> yykp

" Copy-down the line
nmap <C-v> yyp

" Move-up the line
nmap <C-p> ddkkp

" Move-down the line
nmap <C-n> ddp

" Replace current word and enter in insert mode
nmap <leader>r bdei

" Insert a line-jump
nmap <CR> o<ESC>

" Insert a line-jump after the cursor
nmap <leader><CR> O<ESC>



"************* INTERPRETER **************"

" Open the VimShell Intera­ctive window
"nmap <leader>io :VimShellInteractive<CR><ESC><C-w><C-w>

" Interpret the current paragraph
"nmap <leader>ip vip:VimShellSendString<CR>

" Interpret the current line
"nmap <leader>il vip:VimShellSendString<CR>


"************** FUCGITIVE ***************"

"nnoremap <space>ga :Git add %:p<CR><CR>
"nnoremap <space>gs :Gstatus<CR>
"nnoremap <space>gc :Gcommit -a<CR>
"nnoremap <space>gt :Gcommit -v -q %:p<CR>
"nnoremap <space>gd :Gdiff<CR>
"nnoremap <space>ge :Gedit<CR>
"nnoremap <space>gr :Gread<CR>
"nnoremap <space>gw :Gwrite<CR><CR>
"nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>
"nnoremap <space>gm :Gmove<Space>
"nnoremap <space>gb :Git branch<Space>
"nnoremap <space>go :Git checkout<Space>
"nnoremap <space>gps :Dispatch! git push<CR>
"nnoremap <space>gpl :Dispatch! git pull<CR>
"nnoremap <leader>gg :!git log --pretty=format:"\%h - \%cn; \%cr : \%s" --graph<CR>
"nnoremap <space>gps :Git push<Space>
"nnoremap <space>gpl :Git pull<Space>



"*************** MERLIN ****************"

" Explains the type of an expression
" Show only the current buffer
"nmap <leader>wo :only<CR>

" Move to the next window
"nmap <leader>wn <C-w><C-w>

" Move to bottom window
"nnoremap <C-J> <C-W>j

" Move to upper window
"nnoremap <C-K> <C-W>k

" Move to right-side window
"nnoremap <C-L> <C-W>l

" Move to left-side window
"nnoremap <C-H> <C-W>h

"*********** COQ ***********"

"map <leader>ql :CoqLaunch<CR>
"map <leader>qn :CoqNext<CR>
"map <leader>qu :CoqUndo<CR>
"map <leader>qc :CoqToCursor<CR>
"map <leader>qq :CoqKill<CR>


"*************** OTHERS ****************"

nnoremap <leader><leader> :nohlsearch<CR>

" Refresh vim comportment in reloading .vimrc
nmap <leader>vim :source ~/.vimrc<CR>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                        INSTANT MARKDOWN CONFIGURATION                       "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"let g:instant_markdown_slow = 1



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                           ULTISNIPS CONFIGURATION                           "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:UtilSnipsExpandTrigger="<tab>"




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                           AIRLINE CONFIGURATION                             "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:airline_theme             = 'wombat'
let g:airline_enable_branch     = 1
let g:airline_enable_syntastic  = 1
let g:airline_powerline_fonts   = 1
let g:airline_detect_whitespace = 0

" Enable the list of tablines
let g:airline#extensions#tabline#enabled = 1

" Enable displaying buffers with a single tab
let g:airline#extensions#tabline#show_buffers = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Disable close button
let g:airline#extensions#tabline#show_close_button = 0

" Mappings to select tab/buffers
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>b1 <Plug>AirlineSelectTab1
nmap <leader>b2 <Plug>AirlineSelectTab2
nmap <leader>b3 <Plug>AirlineSelectTab3
nmap <leader>b4 <Plug>AirlineSelectTab4
nmap <leader>b5 <Plug>AirlineSelectTab5
nmap <leader>b6 <Plug>AirlineSelectTab6
nmap <leader>b7 <Plug>AirlineSelectTab7
nmap <leader>b8 <Plug>AirlineSelectTab8
nmap <leader>b9 <Plug>AirlineSelectTab9

nmap <leader>t1 1gt
nmap <leader>t2 2gt
nmap <leader>t3 3gt
nmap <leader>t4 4gt
nmap <leader>t5 5gt
nmap <leader>t6 6gt
nmap <leader>t7 7gt
nmap <leader>t8 8gt
nmap <leader>t9 9gt

"Tab numbers
let g:airline#extensions#tabline#tab_nr_type = 1



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                               DELIMITE MATE                                 "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Set the expansion of <CR> and <space>
let delimitMate_expand_space    = 1
let delimitMate_expand_cr       = 1

"Suppress simple quote completion in caml
if has("autocmd")
  au FileType ocaml let b:delimitMate_quotes = "\""
endif

"skip <CR> expansion on pop-up-menu
imap <expr> <CR> pumvisible()
                 \ ? "\<C-Y>"
                 \ : "<Plug>delimitMateCR"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                                SYNTASTIC                                    "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Check syntax on open
let g:syntastic_check_on_open = 1

let g:syntastic_ocaml_checkers = ['merlin']


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                               COMPLETION                                    "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"*************** MERLIN ****************"

let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"






"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                             "
"                               COLOR-SCHEME                                  "
"                                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

colorscheme Termina


