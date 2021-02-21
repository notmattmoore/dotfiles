" Place this file in .vim/ftplugin to get sourced while the filetype plugin
" loads. If we override some plugin settings, also place a symlink in
" .vim/after/ftplugin.

" general vim settings {{{1
setlocal spell              " turn on spell checking

" use deoplete for completions
call deoplete#custom#var('omni', 'input_patterns', {'tex': g:vimtex#re#deoplete})
"----------------------------------------------------------------------------}}}1
" mappings {{{1
" all mappings are of the form `...
inoremap <buffer> `` ``
" greek symbol mappings {{{
inoremap <buffer> `a \alpha
inoremap <buffer> `b \beta
inoremap <buffer> `c \chi
inoremap <buffer> `d \delta
inoremap <buffer> `e \epsilon
inoremap <buffer> `f \phi
inoremap <buffer> `g \gamma
inoremap <buffer> `h \theta
inoremap <buffer> `i \iota
inoremap <buffer> `k \kappa
inoremap <buffer> `l \lambda
inoremap <buffer> `m \mu
inoremap <buffer> `n \eta
inoremap <buffer> `p \pi
inoremap <buffer> `r \rho
inoremap <buffer> `s \psi
inoremap <buffer> `S \sigma
inoremap <buffer> `t \tau
inoremap <buffer> `u \nu
inoremap <buffer> `w \omega
inoremap <buffer> `x \xi
inoremap <buffer> `z \zeta
"----------------------------------------------------------------------------}}}
" other symbol mappings {{{
inoremap <buffer> `v \join
inoremap <buffer> `^ \wedge
inoremap <buffer> `6 \partial
"----------------------------------------------------------------------------}}}
"----------------------------------------------------------------------------}}}1
" tagbar {{{1
" make tagbar work with tex and bib files (also need to add stuff to ~/.ctags)
let g:tagbar_type_tex = {
  \ 'ctagstype' : 'latex',
  \ 'kinds'     : [
    \ 's:sections',
    \ 'g:graphics:0:0',
    \ 'l:labels',
    \ 'r:refs:1:0',
    \ 'p:pagerefs:1:0'
  \ ],
  \ 'sort'    : 0
\ }
let g:tagbar_type_bib = {
  \ 'ctagstype' : 'bibtex',
  \ 'kinds'     : [
    \ 's:strings',
    \ 'e:entries',
    \ 'a:authors',
    \ 't:titles'
  \ ],
  \ 'sort'    : 0
\ }
"----------------------------------------------------------------------------}}}1
