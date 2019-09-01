" Plugin:      https://github.com/jealrock/lightline-mru
" Description: A MRU for the lightline vim plugin.
" Maintainer:  Oleg Marakhovsky <https://github.com/jealrock>

scriptencoding utf-8

" Used to distinct entering file using plugin functions
let s:entered_through_plugin = 0
let s:LightlineMRU_files = []

let s:current_filename_modifier = get(g:, 'lightline#mru#current_filename_modifier', ':p:.')
let s:filename_modifier         = get(g:, 'lightline#mru#filename_modifier', ':t')
let s:max_displayed_files       = get(g:, 'lightline#mru#max_displayed_files', 4)
let s:modified                  = get(g:, 'lightline#mru#modified', ' +')
let s:read_only                 = get(g:, 'lightline#mru#read_only', ' -')

function! s:next_file()
  let s:entered_through_plugin = 1
  let l:current_index = index(s:LightlineMRU_files, expand('%:p'))

  if l:current_index == -1 || l:current_index + 1 == len(s:LightlineMRU_files)
    let l:next_index = 0
  else
    let l:next_index = l:current_index + 1
  endif

  exe 'edit ' . s:LightlineMRU_files[l:next_index]
endfunction

function! s:prev_file()
  let s:entered_through_plugin = 1
  let l:current_index = index(s:LightlineMRU_files, expand('%:p'))

  if l:current_index == -1 || l:current_index == 0
    let l:prev_index = -1
  else
    let l:prev_index = l:current_index - 1
  endif

  exe 'edit ' . s:LightlineMRU_files[l:prev_index]
endfunction

function! s:is_read_only(buffer)
    let l:modifiable = getbufvar(a:buffer, '&modifiable')
    let l:readonly = getbufvar(a:buffer, '&readonly')
    return (l:readonly || !l:modifiable) && getbufvar(a:buffer, '&filetype') !=# 'help'
endfunction

" Updates filelist
function! s:add_file(full_path)
    if s:entered_through_plugin
        let s:entered_through_plugin = 0
        return
    endif

    " Skip temporary buffers with buftype set. The buftype is set for buffers
    " used by plugins.
    if &buftype != ''
        return
    endif

    " If the filename is not already present in the MRU list and is not
    " readable then ignore it
    let idx = index(s:LightlineMRU_files, a:full_path)
    if idx == -1
        if !filereadable(a:full_path)
            " File is not readable and is not in the MRU list
            return
        endif
    endif

    " Remove the new file name from the existing MRU list (if already present)
    call filter(s:LightlineMRU_files, 'v:val !=# a:full_path')

    " Add the new file list to the beginning of the updated old file list
    call add(s:LightlineMRU_files, a:full_path)

    " Trim the list
    if len(s:LightlineMRU_files) > s:max_displayed_files
        let l:amount_to_remove = len(s:LightlineMRU_files) - s:max_displayed_files - 1
        call remove(s:LightlineMRU_files, 0, l:amount_to_remove)
    endif
endfunction

function! s:get_display_file_name(full_path, filename_modifier)
  let l:name = fnamemodify(a:full_path, a:filename_modifier)

  if s:is_read_only(a:full_path)
    let l:name .= s:read_only
  endif

  if getbufvar(a:full_path, '&mod')
    let l:name .= s:modified
  endif

  return substitute(l:name, '%', '%%', 'g')
endfunction

function! s:get_display_file_names(index_from, index_to, filename_modifier)
  let l:names = []
  for l:i in range(a:index_from, a:index_to - 1)
    call add(l:names, s:get_display_file_name(s:LightlineMRU_files[l:i], a:filename_modifier))
  endfor
  return l:names
endfunction

function! lightline#mru#init()
  augroup lightline_mru
    autocmd!
    autocmd BufEnter  * call <SID>add_file(expand('%:p'))
  augroup END
endfunction

function! lightline#mru#files()
  let l:current_index = index(s:LightlineMRU_files, expand('%:p'))

  if l:current_index == -1
    return []
  endif

  let l:before = s:get_display_file_names(0, l:current_index, s:filename_modifier)
  let l:current = s:get_display_file_name(s:LightlineMRU_files[l:current_index], s:current_filename_modifier)
  let l:after = s:get_display_file_names(l:current_index + 1, len(s:LightlineMRU_files), s:filename_modifier)

  return [l:before, l:current, l:after]
endfunction

noremap <silent> <Plug>lightline#mru#next_file() :call <SID>next_file()<CR>
noremap <silent> <Plug>lightline#mru#prev_file() :call <SID>prev_file()<CR>

call lightline#mru#init()
