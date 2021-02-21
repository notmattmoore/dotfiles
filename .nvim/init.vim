" plugins {{{1
" Use vim-plug for plugins. Paths are either github paths or any git URL.
" PlugInstall  Install plugins
" PlugUpdate   Install or update plugins
" PlugClean    Remove unused directories
" PlugUpgrade  Upgrade vim-plug itself

if has('nvim')
  call plug#begin('~/.nvim/vim-plug')
else
  call plug#begin('~/.vim/vim-plug')
endif

" bufexplorer for navigating buffers
" \b    open bufexplorer
Plug 'jlanzarotta/bufexplorer'
let g:bufExplorerDisableDefaultKeyMapping = 1   " disable default keys 
let g:bufExplorerShowDirectories = 0            " don't show directories as buffers
let g:bufExplorerShowRelativePath = 1           " show relative paths
let g:bufExplorerSortBy = 'mru'                 " sort most recently used
nnoremap <leader>b :ToggleBufExplorer<CR>

" commentary for easy commenting
" gc{motion}  comment lines that motion moves over
" gcc         comment lines
Plug 'tpope/vim-commentary'

" deoplete for completions (+jedi for python). Only for neovim.
" <C-n>, <C-space>   trigger autocompletion
" extra settings after plug#end() below
if has("nvim")
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'deoplete-plugins/deoplete-jedi'   " use jedi for python
  let g:deoplete#enable_at_startup = 1
  " Use <c-space> to trigger completion (only works for nvim, use <C-@> for vim)
  inoremap <silent><expr> <C-space> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<C-n>" : deoplete#manual_complete()
  inoremap <silent><expr> <C-n> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<C-n>" : deoplete#manual_complete()
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction
endif

" EasyTemplates
" <C-j>, <C-k>   select next/prev <+...+>
let g:EasyTemplates_JumpForwardTrigger = '<C-j>'
let g:EasyTemplates_JumpBackwardTrigger = '<C-k>'

" fugitive for git integration
" \gs, \gc, \gm    interactive git status/commit/merge
" \gr, \gS         git rebase, stash
" \gg              git command line interface
" :Gw   write and stage file
Plug 'tpope/vim-fugitive', {'on': ['Gstatus', 'Gmerge', 'Grebase', 'Git']}
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gm :Gmerge <Tab>
nnoremap <leader>gr :Grebase master
nnoremap <leader>gg :Git <Tab>
nnoremap <leader>gc :Git checkout <Tab>
nnoremap <leader>gS :Git stash

" fzf integration for fuzzy finding
" <C-f>, <C-b>   open a file or buffer
" <C-/>          search lines in current bufer
" <C-F1>, <C-s>  use fzf to search vim help, snippets
Plug 'junegunn/fzf.vim'
let g:fzf_layout = { 'down': '~33%' }   " fzf window in the bottom 1/3
let $FZF_DEFAULT_OPTS = '--inline-info --cycle --bind=tab:down,shift-tab:up,alt-enter:print-query,ctrl-space:replace-query,right:replace-query'
nnoremap <C-f> :Files<CR>
nnoremap <C-b> :Buffers<CR>
nnoremap <C-_> :BLines<CR>
nnoremap <C-F1> :Helptags<CR>
nnoremap <C-S> :Snippets<CR>

" incsearch for better incremental searching
Plug 'haya14busa/incsearch.vim'
let g:incsearch#magic = '\v'  " searching using normal regex
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" mundo to visualize the undo tree
" \u    open the undotree
Plug 'simnalamburt/vim-mundo'
let g:mundo_help = 0             " hide the help
let g:mundo_preview_bottom = 1   " put diff preview below the file
let g:mundo_right = 1            " put sidebar on the right
let g:mundo_width = 30           " make sidebar 30 wide
nnoremap <leader>u :MundoToggle<CR>

" netrw (already loaded)
let g:netrw_browsex_viewer='firefox'

" repeat for repeating plugin actions
Plug 'tpope/vim-repeat'

" sneak for fast movements
" sxy, Sxy         jump to chars xy
" fx, Fx, tx, Tx   jump to char x, repeat f to keep going
" <Tab>            use next set of labels in label mode
Plug 'justinmk/vim-sneak'
let g:sneak#label = 1       " use label-mode for easy navigation
let g:sneak#s_next = 1      " keep pressing s/f to repeat sneak
let g:sneak#use_ic_scs = 1  " use smartcase
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
" nice highlighting
hi link SneakScope Cursor
augroup SneakPluginColors
  autocmd!
  autocmd ColorScheme * hi Sneak guifg=red guibg=NONE gui=underline,bold ctermfg=red ctermbg=NONE cterm=underline,bold
  autocmd ColorScheme * hi SneakLabel guifg=#1f1f1f guibg=#dcdccc gui=bold ctermfg=234 ctermbg=188 cterm=bold
augroup END

" suda for using sudo to write files
" workaround for bug https://github.com/neovim/neovim/issues/1716
" :Sudow   write a file using sudo
" :Sudoe   edit a file using sudo
Plug 'lambdalisue/suda.vim'
command! Sudow :w suda://%
command! -nargs=* Sudoe e suda://<args>

" surround for dealing with surroundings
" cs}]    change {...} to [...]
" ds]     change [...] to ...
" ysaw]   change word to [word]
Plug 'tpope/vim-surround'

" tabular for automatically aligning things into a table.
" \t    tabularize, prompting for delimiter
Plug 'godlygeek/tabular'
nnoremap <leader>t :Tabularize /
vnoremap <leader>t :Tabularize /

" tagbar for showing the tags in a sidebar
" \n    open tagbar ('navigate')
Plug 'majutsushi/tagbar', {'on': ['TagbarToggle']}
let g:tagbar_compact = 1    " make the sidebar more compact
let g:tagbar_autoclose = 1  " close after selecting a tag
nnoremap <leader>n :TagbarToggle<CR>

" ultisnips for a snippet engine
" <Tab>           expand snippet
" <S-Tab>         list all snippets (for ambiguous ones)
" <C-j>, <C-k>    go to next position in the snippet
" \S              edit the relevant snips file
Plug 'SirVer/ultisnips'
" Use snippet directory name 'snips'. Also include local snips.
let g:UltiSnipsSnippetDirectories = ['snips', getcwd().'/snips', getcwd().'/../snips']
" ultisnips trigger keys
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsListSnippets = '<S-Tab>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
nnoremap <leader>S :UltiSnipsEdit!<CR>
let g:UltiSnipsMappingsToIgnore = ['EasyTemplates']  " don't mess with Easy Templates select-mode maps!

" vimtex for latex support
Plug 'lervag/vimtex'
let g:tex_flavor = 'latex'                              " a .tex file is a latex file
let g:vimtex_view_method = 'zathura'                    " use zathura to view pdfs
let g:vimtex_compiler_latexmk = { 'continuous': 0 }     " disable continuous compilation
let g:vimtex_quickfix_mode = 2                          " quickfix window doesn't steal focus
let g:tex_conceal = ''                                  " don't use conceal mode to change characters!

" zenburn color scheme
Plug 'jnurmine/Zenburn'
let g:zenburn_high_Contrast = 1         " darker background
let g:zenburn_unified_CursorColumn = 1  " make the cursorcolumn fit in

"" old plugins {{{
"" clever-f for better f behavior
"" fx, Fx, tx, Tx   jump to char x, repeat f to keep going
"Plug 'rhysd/clever-f.vim'
"let g:clever_f_chars_match_any_signs = ';:'  " use characters ;: to match any special character
"let g:clever_f_smart_case = 1                " use smartcase
""let g:clever_f_timeout_ms = 2000             " timeout after 500ms

"" gundo to visualize the undo tree
"" \u    open the undotree
"Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}
"let g:gundo_prefer_python3 = 1   " needed to work with neovim
"let g:gundo_help = 0             " hide the help
"let g:gundo_preview_bottom = 1   " put diff preview below the file
"let g:gundo_right = 1            " put sidebar on the right
"let g:gundo_width = 30           " make sidebar 30 wide
"nnoremap <leader>u :GundoToggle<CR>

"" LaTeX-Box
"Plug 'LaTeX-Box-Team/LaTeX-Box'
"let g:tex_flavor = 'latex'    " a .tex file is a latex file
"let g:tex_conceal = ''        " don't use conceal mode to change characters!
"" has to be set *before* tex files are loaded!
"let g:LatexBox_ignore_warnings =
"      \ [ 'Package hyperref Warning'
"      \ , 'Class amsart Warning: When the draft option is used' ]
"" In ftplugin/tex.vim:
"imap <buffer> ]] <Plug>LatexCloseCurEnv
"let g:LatexBox_viewer = 'zathura'
"let g:LatexBox_quickfix = 2   " quickfix window doesn't steal focus

"" unimpaired (handy pairs of bracket maps)
"Plug 'tpope/vim-unimpaired'

"" old search settings
"set incsearch                 " incremental search
"" make searches use standard regex
"nnoremap / /\v
"cnoremap %s/ %s/\v
"----------------------------------------------------------------------------}}}
call plug#end()


" calls after plug#end() {{{2
call deoplete#custom#option({'auto_complete': v:false })
"----------------------------------------------------------------------------}}}2
"---------------------------------------------------------------------------}}}1
" status line {{{1
set statusline=%t                     " <tail of the filename>
set statusline+=\ \│\ %y              " ' │ '<the filetype>
set statusline+=%m%r%h%w%q            " <modified?readonly?help?preview?quickfix?>
set statusline+=%{MyGitStatusLine()}  " git status, uses fugitive plugin
set statusline+=%=                    " left/right separator
set statusline+=\ (%v,%l)             "' (<virtual column>,<line>)'
set statusline+=\ %3p%%               " ' '<percent of file current line is at>%

function! MyGitStatusLine(...) abort
  if !exists('b:git_dir')
    return ''
  endif
  return ' │ ' . fugitive#Statusline()
endfunction
"---------------------------------------------------------------------------}}}1
" interface settings {{{1
set termguicolors                 " use 24bit colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"  " black magic: vim-specific RGB colors
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"  " black magic: vim-specific RGB colors
colorscheme zenburn               " use zenburn
set belloff=all                   " don't ring the bell!
set clipboard=unnamedplus         " use the clipboard (Ctrl-C) by default
set colorcolumn=+1                " color column 1 to the right of textwidth
set completeopt+=menuone          " show a menu even if there is only one match
set completeopt+=longest          " complete up to longest common text
set foldmethod=marker             " put {{{ and }}} to indicate manual folding
set ignorecase                    " case insensitive searching
set list                          " show formatting marks
set listchars=tab:»·              " use '»·' for tabs
set listchars+=extends:▶          " use '▶' for line contents to the right
set listchars+=nbsp:␣             " use '␣' for non-breaking spaces
set listchars+=precedes:◀         " use '◀' for line contents to the left
set listchars+=trail:·            " use '·' for trailing spaces
set scrolloff=5                   " start scrolling 5 lines from the bottom
set sidescroll=10                 " sidescroll 10 chars at a time
set sidescrolloff=5               " start sidescrolling 5 chars from the side
set smartcase                     " if search has an upper case, don't ignore case
set splitbelow                    " open new hsplits below
set splitright                    " open new vsplits to the right
set nostartofline                 " try to keep the curson in the same column
set termguicolors                 " nice colors in the terminal
set virtualedit=block             " allow moving past EOL in visual block
set wildcharm=<Tab>               " tab triggers wildmode
set wildmode=longest:full         " on first tab, match longest common string and show menu
set wildmode+=full                " on second tab, cycle full matches
"---------------------------------------------------------------------------}}}1
" format settings {{{1
set expandtab                     " convert tabs to spaces
set shiftwidth=2                  " indent width
set softtabstop=2                 " tabs count as 2 spaces
set tabstop=2                     " tabs count as 2 spaces
set smartindent                   " try to be smart about autoindenting
set textwidth=80                  " make lines 80 characters wide
set linebreak                     " automatically break the line at textwidth
set formatoptions+=l              " don't wrap line if is already too long
set nowrap                        " don't 'fake' wrap long lines either
set nojoinspaces                  " don't put two spaces after a period
"---------------------------------------------------------------------------}}}1
" file settings {{{1
set directory=.                   " store swap file in PWD, falling back to ~/tmp
set directory+=,~/tmp
set undofile                      " keep a persistent undofile
set undodir=.                     " store undo file in PWD, falling back to ~/tmp
set undodir+=~/tmp
set fileformats+=mac              " support mac EOL chars too
set hidden                        " allow unsaved non-displayed buffers
set modeline                      " check files for modelines
"---------------------------------------------------------------------------}}}1
" system integration {{{1
set selectmode=mouse              " enter select mode when selecting text with a mouse
set shell=/usr/bin/zsh            " the shell to use
set spelllang=en
"---------------------------------------------------------------------------}}}1
" autocommands {{{1
augroup all
" delete pre-existing autocmd's (prevents nesting and recursion)
autocmd!
" When editing a file, jump to the last cursor position.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line('$') |
  \   execute "normal! g`\"" |
  \ endif
augroup END
"---------------------------------------------------------------------------}}}1
" maps {{{1
" 'fixes' {{{
" disable these keys
noremap <F1> <Nop>
inoremap <F1> <Nop>
" sometimes I hit K when I meant k
nnoremap K k
vnoremap K k
" map j,k to not jump over wrapped lines
noremap j gj
noremap k gk
" map p in visual mode not to overwrite the paste register
vnoremap <silent> p pgvy
" make Q format, not enter ex mode
noremap Q gq
" make Y work like it should
nnoremap Y y$
" map +, - to increment/decrement numbers
noremap + <C-a>
noremap - <C-x>
"----------------------------------------------------------------------------}}}
" mappings {{{
" make 'jk' go into normal mode
inoremap jk <Esc>
" use space to expand and create folds
nnoremap <space> za
vnoremap <space> zf
" next/prev buffer
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
" clear highlighting with <C-l>
nnoremap <C-l> :nohlsearch<CR><C-l>
" quickly turn on/off spell checking
nnoremap <leader>s :setlocal spell!<CR>
" use \d<movement> to delete without adding to the register
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>D "_D
"----------------------------------------------------------------------------}}}
"---------------------------------------------------------------------------}}}1

" vim specific options {{{1
if !has('nvim')
  set autoindent                  " autoindent
  set autoread                    " automatically reload modified files
  set backspace=indent,eol,start  " backspace over everything
  set display+=lastline           " display the mode on the last line
  set formatoptions+=j            " remove comment char when joining comment lines
  set hidden                      " hide buffers instead of closing them
  set history=10000               " keep 1000 commands in history
  set hlsearch                    " search highlighting
  set laststatus=2                " put the statusline above the command line
  set nocompatible                " be incompatible with vi
  set nrformats-=octal            " remove 'octal' numbers from C-A, C-X increment
  set showcmd                     " show partial commands
  set smarttab                    " insert the 'correct' tab character
  set ttyfast                     " tell vim we're on a fast terminal
  set wildmenu                    " do fancy command line completion
endif
"----------------------------------------------------------------------------}}}1
" nvim specific options {{{1
if has('nvim')
  tnoremap jk <C-\><C-n>
endif
"----------------------------------------------------------------------------}}}1
