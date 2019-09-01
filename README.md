# lightline-mru

Config example:
```
let g:lightline = {
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'mru_files', 'cocstatus' ] ]
\ },
\ 'component_function': {
\   'cocstatus': 'coc#status'
\ },
\ 'component_expand': {
\   'mru_files': 'lightline#mru#files'
\ },
\ 'component_type': {
\   'mru_files': 'tabsel'
\ }
\ }

autocmd BufWinEnter,BufWritePost,TextChanged,TextChangedI * call lightline#update()
```
