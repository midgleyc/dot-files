if !has('nvim')
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
  set display=lastline
else
  unmap Y
  set listchars+=eol:$
  set scrolloff=5
endif

let mapleader = " "

set background=dark "default, but conflicts with NERDTree auto-open
set hidden " for coc
set autowrite " save when switching buffers, but not on :q
au WinLeave * if &buftype ==# '' || &buftype == 'acwrite' | update | endif

set number
set ignorecase
set hlsearch
set smartcase "ignore case only when the search string is lowercase
set laststatus=2 "bottom status line always on
set clipboard=unnamed
set wildmode=longest,list

"don't generate .swap
set noswapfile

set backup
if has('nvim')
  set backupdir=~/.config/nvim/backup
else
  set backupdir=~/.vim/backup
endif
if !isdirectory(&backupdir)
  call mkdir(&backupdir, 'p', 0700)
endif

if has('persistent_undo')
  if has('nvim')
    set undodir=~/.config/nvim/undo
  else
    set undodir=~/.vim/undo
  endif
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
  endif
  set undofile
endif

inoremap jk <Esc>
"don't blam clipboard
vnoremap p pgvy 
nnoremap <leader>w <C-w>
tnoremap <leader>w <C-w>

" When using `dd` in the quickfix list, remove the item from the quickfix list.
function! RemoveQFItem()
  let curqfidx = line('.') - 1
  let qfall = getqflist()
  call remove(qfall, curqfidx)
  call setqflist(qfall, 'r')
  execute curqfidx + 1 . "cfirst"
  :copen
endfunction
:command! RemoveQFItem :call RemoveQFItem()
" Use map <buffer> to only map dd in the quickfix window. Requires +localmap
autocmd FileType qf map <buffer> dd :RemoveQFItem<cr>

" language-specific test running
autocmd Filetype javascript nmap <leader>t :!clear; npx mocha %<CR>
autocmd Filetype typescript nmap <leader>t :!clear; npx mocha -r ts-node/register %<CR>

" !gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default|tr -d \')/ cursor-blink-mode off

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'junegunn/vim-plug' " plug itself

Plug 'preservim/nerdtree' " filetree
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim' " fuzzy finder

Plug 'tpope/vim-fugitive' " git

Plug 'tpope/vim-surround' " surround elt with quotes / brackets / tags
Plug 'tpope/vim-repeat' " Allow repeating ds', csaw', etc.
Plug 'tpope/vim-unimpaired' " ]q, ] , ]e and others

Plug 'justinmk/vim-sneak' " two-char jump, multiline ft

Plug 'editorconfig/editorconfig-vim', { 'commit': '7f4e4df', 'frozen': 1 } " use editconfig settings if present

Plug 'pangloss/vim-javascript' " javascript syntax highlight
Plug 'HerringtonDarkholme/yats.vim' "typescript syntax highlight

Plug 'joshdick/onedark.vim', {'branch': 'main'} " theme

Plug 'neoclide/coc.nvim', {'branch': 'release'} " langserver
call plug#end()

" NERDTree
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1

nnoremap <leader>n :NERDTreeFind<CR>
nnoremap <leader>v :NERDTreeToggleVCS<CR>:NERDTreeFind<CR>

" FZF
nmap <leader>f :Rg 
xmap <leader>f "9y :Rg 9
nmap <leader>j :FZF<CR>
nmap <leader>k :History<CR>
nmap <leader>b :Buffers<CR>

" Sneak
nmap <leader>s <Plug>Sneak_s
nmap <leader>S <Plug>Sneak_S
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" EditorConfig / Fugitive

let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Coc

let g:coc_global_extensions = ['coc-json', 'coc-html', 'coc-css', 'coc-tsserver']

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" select top option on c-space
inoremap <silent><expr> <NUL> pumvisible() ? coc#_select_confirm() : ""

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>rr <Plug>(coc-refactor)

" Formatting selected code.
xmap <leader>l  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects (Allow using if = inside function & ic = inside class )
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Disable mouse support (unless compiled with clipboard support)
if (!has("clipboard"))
 set mouse=
endif

" make some greys a little lighter
let g:onedark_color_overrides = {
\ "special_grey": {"gui": "#646c7a", "cterm": "238", "cterm16": "7"},
\ "gutter_fg_grey": {"gui": "#606a7f", "cterm": "238", "cterm16": "8"}
\}
" italics work for this terminal
let g:onedark_terminal_italics = 1
colorscheme onedark

" Theme
if (has("termguicolors"))
 set termguicolors
endif
