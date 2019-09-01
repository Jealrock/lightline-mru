" Plugin:      https://github.com/jealrockone/lightline-mru
" Description: A MRU for the lightline vim plugin.
" Maintainer:  Oleg Marakhovsky <https://github.com/jealrock>

if exists('g:loaded_lightline_mru')
  finish
endif
let g:loaded_lightline_mru = 1

call lightline#mru#init()
