if !has('nvim')
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
  set display=lastline
else
  silent! nunmap Y
  set mouse=nv " allow copying to + register from normal mode
               " but allow pasting using right-click from outside WSL without clipboard-wsl
  set listchars+=eol:$
  set scrolloff=5
  augroup vimStartup
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

  augroup END
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
set clipboard=unnamed,unnamedplus
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

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>l  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <leader>rr <Plug>(coc-refactor)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

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

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Disable mouse support (unless compiled with clipboard support)
if !has("clipboard")
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
