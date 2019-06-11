" Description: template expander with cursor placement
" Version: 2017-09-06

if exists("g:EasyTemplates_loaded") || &cp
  finish
endif
let g:EasyTemplates_loaded = 1

" options {{{
if !exists("g:EasyTemplates_open") && !exists("g:EasyTemplates_regex")
  let g:EasyTemplates_open  = '\<\+'
endif
if !exists("g:EasyTemplates_close") && !exists("g:EasyTemplates_regex")
  let g:EasyTemplates_close = '\+\>'
endif
if !exists("g:EasyTemplates_regex")
  let g:EasyTemplates_regex = '\v' . g:EasyTemplates_open . '.{-}' . g:EasyTemplates_close
endif
if !exists("g:EasyTemplates_JumpForwardTrigger")
  let g:EasyTemplates_JumpForwardTrigger = "<C-j>"
endif
if !exists("g:EasyTemplates_JumpBackwardTrigger")
  let g:EasyTemplates_JumpBackwardTrigger = "<C-k>"
endif
"============================================================================}}}

function! EasyTemplates_Jump(direction) abort
  if a:direction == 'forward'
    let search_flags_open  = ''
    let search_flags_close = 'e'
    let stopline = line("w$")
  elseif a:direction == 'backward'
    let search_flags_open  = 'be'
    let search_flags_close = 'b'
    let stopline = line("w0")
  endif

  if search( g:EasyTemplates_regex, 'W' . search_flags_open , stopline ) > 0
    execute "silent! foldopen"
    execute "normal! v"
    call search( g:EasyTemplates_regex, 'W' . search_flags_close )
    execute "normal! \<C-g>"
  endif

endfunction

noremap <silent> <Plug>EasyTemplates_JumpForward :<C-u>call EasyTemplates_Jump('forward')<CR>
noremap <silent> <Plug>EasyTemplates_JumpBackward :<C-u>call EasyTemplates_Jump('backward')<CR>

" mappings {{{
execute "nmap <silent> " . g:EasyTemplates_JumpForwardTrigger . " <Plug>EasyTemplates_JumpForward"
execute "smap <silent> " . g:EasyTemplates_JumpForwardTrigger . " <Esc><Plug>EasyTemplates_JumpForward"
execute "imap <silent> " . g:EasyTemplates_JumpForwardTrigger . " <Esc><Plug>EasyTemplates_JumpForward"
execute "nmap <silent> " . g:EasyTemplates_JumpBackwardTrigger . " <Plug>EasyTemplates_JumpBackward"
execute "smap <silent> " . g:EasyTemplates_JumpBackwardTrigger . " <Esc><Plug>EasyTemplates_JumpBackward"
execute "imap <silent> " . g:EasyTemplates_JumpBackwardTrigger . " <Esc><Plug>EasyTemplates_JumpBackward"
"============================================================================}}}
