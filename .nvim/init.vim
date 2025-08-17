" plugins {{{1
" Use vim-plug for plugins. Paths are either github paths or any git URL.
" PlugClean    Remove unused directories
" PlugInstall  Install plugins
" PlugUpdate   Install or update plugins
" PlugUpgrade  Upgrade vim-plug itself
" PlugDiff     Review changes, possibly revert (X over plugin name)

if !has('nvim')
  call plug#begin('~/.vim/vim-plug')
else
  call plug#begin('~/.nvim/vim-plug')
endif

" bufexplorer for navigating buffers
" \b    open bufexplorer
Plug 'jlanzarotta/bufexplorer'
let g:bufExplorerDisableDefaultKeyMapping = 1   " disable default keys 
let g:bufExplorerShowDirectories = 0            " don't show directories as buffers
let g:bufExplorerShowRelativePath = 1           " show relative paths
let g:bufExplorerSortBy = 'mru'                 " sort most recently used
nnoremap <leader>b :ToggleBufExplorer<CR>

" CoC for completion
" <C-space>     trigger completion.
" \rn           symbol rename
" [d, ]d, \D    navigate diagnostics, show all diagnostics
" gd            go to definition, references
" K             show documentation
" <C-d>, <C-u>  scroll floating window forward/backward
" :CocInstall <extension>
" :CocUninstall <extension>
" :CocUpdate
" main configuration at :CocConfig
" find more extensions: https://www.npmjs.com/search?q=keywords%3Acoc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = ['coc-diagnostic', 'coc-html', 'coc-jedi', 'coc-json', 'coc-texlab']
if !has('nvim')
  inoremap <silent><expr> <C-@> coc#refresh()
else
  inoremap <silent><expr> <C-Space> coc#refresh()
endif
nmap <leader>rn <Plug>(coc-rename)
nmap [d <Plug>(coc-diagnostic-prev)
nmap ]d <Plug>(coc-diagnostic-next)
nnoremap <leader>D :CocDiagnostics<CR>
nmap gd <Plug>(coc-definition)
nmap gr <Plug>(coc-references)
nnoremap K :call <SID>show_documentation()<CR>
function! s:show_documentation()  " {{{
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction " }}}
nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1,5) : "\<C-d>"
inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1,5)\<cr>" : "\<Right>"
nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0,5) : "\<C-u>"
inoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0,5)\<cr>" : "\<Left>"
let g:coc_disable_startup_warning = 1   " don't bother me about the version

" Dispatch for running async compilations
" \c  save and run :Dispatch (background compile)
Plug 'tpope/vim-dispatch'
let g:dispatch_no_maps = 1       " disable default maps
let g:dispatch_no_tmux_make = 1  " prefer job support over tmux
nnoremap <leader>c :w<CR>:Dispatch<CR>

" commentary for easy commenting
" gc{motion}  comment lines that motion moves over
" gcc         comment lines
Plug 'tpope/vim-commentary'

" EasyTemplates
" <C-j>, <C-k>   select next/prev <+...+>
let g:EasyTemplates_JumpForwardTrigger = '<C-j>'
let g:EasyTemplates_JumpBackwardTrigger = '<C-k>'

" fugitive for git integration
" \gg              interactive git status
" \gr, \gS         git rebase, stash
" :Gw   write and stage file
Plug 'tpope/vim-fugitive'
nnoremap <leader>gg :Git<CR>

" fzf integration for fuzzy finding
" \f     open a file or buffer
" <C-/>  search lines in current buffer
" \<F1>  use fzf to search vim help
Plug 'junegunn/fzf', {'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
let g:fzf_layout = { 'down': '~33%' }   " fzf window in the bottom 1/3
let $FZF_DEFAULT_OPTS = '--inline-info --cycle --multi --bind=alt-enter:print-query,ctrl-space:replace-query,right:replace-query'
nnoremap <leader>f :Files<CR>
nnoremap <C-_> :BLines<CR>
nnoremap <leader><F1> :Helptags<CR>

" markdown-preview for live-preview of markdown files. Requires nodejs.
" \mv   toggle preview (set in after/ftplugin/markdown.vim)
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
let g:mkdp_auto_close = 0       " don't close the preview window when we switch buffers
" open the preview in a new firefox window
function OpenMarkdownPreview(url)
  execute "silent ! firefox --new-window " . a:url
endfunction
let g:mkdp_browserfunc = 'OpenMarkdownPreview'

" mundo to visualize the undo tree
" \u    open the undotree
Plug 'simnalamburt/vim-mundo'
let g:mundo_help = 0             " hide the help
let g:mundo_preview_bottom = 1   " put diff preview below the file
let g:mundo_right = 1            " put sidebar on the right
let g:mundo_width = 30           " make sidebar 30 wide
nnoremap <leader>u :MundoToggle<CR>

" peekaboo to show the registers when " or @ is used.
Plug 'junegunn/vim-peekaboo'
let g:peekaboo_delay = 500  " delay opening of peekaboo window

" netrw (already loaded)
let g:netrw_browsex_viewer = 'firefox -P default -new-window'  " use firefox for the browser
let g:netrw_banner = 0     " don't show directory browser banner
let g:netrw_liststyle = 3  " show directory tree in browser

" repeat for repeating plugin actions
Plug 'tpope/vim-repeat'

" SLIME for vim. SLIME is an Emacs plugin to send text to a REPL. This sends
" text to a tmux instance.
" \e    send line or visual selection
" \E    reconfigure SLIME
Plug 'jpalardy/vim-slime'
let g:slime_target = 'tmux'
let g:slime_default_config = { "socket_name": "default", "target_pane": "NAME:" }
let g:slime_python_ipython = 1    " play nice with ipython
let g:slime_no_mappings = 1
nmap <leader>e <Plug>SlimeLineSend
vmap <leader>e <Plug>SlimeRegionSend
nmap <leader>E <Plug>SlimeConfig

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
let g:vimtex_syntax_conceal_disable = 1                 " don't use conceal mode to change characters!

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

" " deoplete for completions (+jedi for python).
" " <C-n>, <C-space>   trigger autocompletion
" " extra settings after plug#end() below
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'deoplete-plugins/deoplete-jedi'   " use jedi for python
" Plug  'deathlyfrantic/deoplete-spell'   " spelling autocompletion
" let g:deoplete#enable_at_startup = 1
" " Use <C-space> to trigger completion (only works for nvim, use <C-@> for vim)
" inoremap <silent><expr> <C-space> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<C-n>" : deoplete#manual_complete()
" inoremap <silent><expr> <C-n> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<C-n>" : deoplete#manual_complete()
" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~ '\s'
" endfunction
" ...
" call deoplete#custom#option({'auto_complete': v:false })

"" gundo to visualize the undo tree
"" \u    open the undotree
"Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}
"let g:gundo_prefer_python3 = 1   " needed to work with neovim
"let g:gundo_help = 0             " hide the help
"let g:gundo_preview_bottom = 1   " put diff preview below the file
"let g:gundo_right = 1            " put sidebar on the right
"let g:gundo_width = 30           " make sidebar 30 wide
"nnoremap <leader>u :GundoToggle<CR>

" " incsearch for better incremental searching
" Plug 'haya14busa/incsearch.vim'
" let g:incsearch#magic = '\v'  " searching using normal regex
" map / <Plug>(incsearch-forward)
" map ? <Plug>(incsearch-backward)
" map g/ <Plug>(incsearch-stay)

" " jedi for nice python integration
" " C-n   start autocomplete
" " \d    go to definition
" " \g    go to assignment
" " \r    rename variable
" Plug 'davidhalter/jedi-vim', { 'for': 'python' }
" let g:jedi#popup_on_dot = 0           " don't autocomplete on dot (it's slow)
" let g:jedi#smart_auto_mappings = 1    " add import when typing from module.name
" let g:jedi#completions_enabled = 0
" let g:jedi#completions_command = '<C-n>'
" let g:jedi#goto_stubs_command = ''
" let g:jedi#usages_command = ''

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
"----------------------------------------------------------------------------}}}
call plug#end()
"---------------------------------------------------------------------------}}}1
" status line {{{1
set statusline=%t                     " <tail of the filename>
set statusline+=\ \│\ %y              " ' │ '<the filetype>
set statusline+=%m%r%h%w%q            " <modified?readonly?help?preview?quickfix?>
set statusline+=%([%{coc#status()}]%) " CoC status, uses coc plugin
set statusline+=%=                    " left/right separator
set statusline+=\ (%v,%l)             "' (<virtual column>,<line>)'
set statusline+=\ %3p%%               " ' '<percent of file current line is at>%
"---------------------------------------------------------------------------}}}1
" interface settings {{{1
colorscheme zenburn               " use zenburn
hi StatusLine guibg=#dfdfdf gui=bold  " more muted statusline bg color
set clipboard=unnamedplus         " use the clipboard (Ctrl-C) by default
set colorcolumn=+1                " color column 1 to the right of textwidth
set omnifunc+=syntaxcomplete#Complete  " use syntax completion
set complete+=k                   " also use the dictionary with completion
set completeopt+=menuone          " show a menu even if there is only one match
set completeopt+=longest          " complete up to longest common text
set foldmethod=marker             " put {{{ and }}} to indicate manual folding
set hidden                        " hide buffers instead of closing them
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
set termguicolors                 " use 24-bit colors in the terminal
set title                         " set the window title
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
set breakindent                   " on line breaks, keep indentation of first line
set nojoinspaces                  " don't put two spaces after a period
set nowrap                        " don't 'fake' wrap long lines either
"---------------------------------------------------------------------------}}}1
" file settings {{{1
set directory=.                   " store swap file in PWD, falling back to ~/tmp
set directory+=,~/tmp
set undofile                      " keep a persistent undofile
set undodir=.                     " store undo file in PWD, falling back to ~/tmp
set undodir+=,~/tmp
set fileformats+=mac              " support mac EOL chars too
set modeline                      " check files for modelines
set modelineexpr                  " allow expressions in modelines
"---------------------------------------------------------------------------}}}1
" system integration {{{1
set mouse=a                            " support the mouse in all modes
set shell=/usr/bin/zsh                 " the shell to use
set dictionary+=/usr/share/dict/words  " dictionary of words for auto-completion
set spelllang=en                       " spelling language
"---------------------------------------------------------------------------}}}1
" autocommands {{{1
" formatoptions gets overwritten by certain filetype plugins. This fixes it.
augroup FormatOptions
  autocmd!
  " l: don't wrap line if is already too long
  " j: remove comment char when joining comment lines
  autocmd FileType *
    \ setlocal formatoptions+=l |
    \ if !has('nvim') |
    \   setlocal formatoptions+=j | 
    \ endif
augroup END

augroup misc
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
" make Y work like it should
noremap Y y$
" c and C shouldn't add to the yank register
noremap c "_c
nnoremap cc "_cc
noremap C "_C
" allow repeat commands cover visual blocks
vnoremap . :normal .<CR>
" map j,k to not jump over wrapped lines
noremap j gj
noremap k gk
" map p in visual mode not to overwrite the paste register
vnoremap p pgvy
" make Q format, not enter ex mode
noremap Q gq
" disable these keys
noremap <F1> <Nop>
inoremap <F1> <Nop>
" map +, - to increment/decrement numbers
noremap + <C-a>
noremap - <C-x>
"----------------------------------------------------------------------------}}}
" mappings {{{
" " use <C-space> to initiate completion (<C-@> for vim, <C-space> for nvim)
" if !has('nvim')
"   inoremap <C-@> <C-X>
" else
"   inoremap <C-space> <C-X>
" endif
" make 'jk' go into normal mode
inoremap jk <Esc>
" use space to expand folds
nnoremap <space> za
" select in fold
nnoremap vif [zjV]zk
" next/prev buffer
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
" location list maps
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
" quickfix maps
nnoremap ]c :cnext<CR>
nnoremap [c :cprevious<CR>
" clear highlighting with <C-l>
nnoremap <C-l> :nohlsearch<Bar>diffupdate<CR><C-l>
" quickly turn on/off spell checking
nnoremap <leader>s :setlocal spell!<CR>
" make searches use standard regex
nnoremap / /\v
"----------------------------------------------------------------------------}}}
"---------------------------------------------------------------------------}}}1

" vim specific options {{{1
if !has('nvim')
  set nocompatible                " be incompatible with vi

  set autoindent                  " autoindent
  set autoread                    " automatically reload modified files
  set backspace=indent,eol,start  " backspace over everything
  set belloff=all                 " don't ring the bell!
  set display+=lastline           " display the mode on the last line
  set history=10000               " keep 1000 commands in history
  set hlsearch                    " search highlighting
  set incsearch                   " incremental search
  set laststatus=2                " put the statusline above the command line
  set nrformats-=octal            " remove 'octal' numbers from C-A, C-X increment
  set showcmd                     " show partial commands
  set smarttab                    " insert the 'correct' tab character
  set ttyfast                     " tell vim we're on a fast terminal
  set wildmenu                    " do fancy command line completion
  let &printheader=" "            " don't include a header when making ps files
endif
"----------------------------------------------------------------------------}}}1
" nvim specific options {{{1
if has('nvim')
  set inccommand=split              " show preview of command changes
endif
"----------------------------------------------------------------------------}}}1
