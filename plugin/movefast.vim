if exists('g:movefast_loaded') | finish | endif
let g:movefast_loaded = 1

nnoremap <silent> <Plug>(movefast_buffer_prev) :call movefast#buffer#Prev(0)<CR>
nnoremap <silent> <Plug>(movefast_buffer_next) :call movefast#buffer#Next(0)<CR>
nnoremap <silent> <Plug>(movefast_buffer_prev_global) :call movefast#buffer#Prev(1)<CR>
nnoremap <silent> <Plug>(movefast_buffer_next_global) :call movefast#buffer#Next(1)<CR>

nnoremap <silent> <Plug>(movefast_scroll_down) :call movefast#scroll#Down()<CR>
nnoremap <silent> <Plug>(movefast_scroll_up) :call movefast#scroll#Up()<CR>
nnoremap <silent> <Plug>(movefast_scroll_left) :call movefast#scroll#Left()<CR>
nnoremap <silent> <Plug>(movefast_scroll_right) :call movefast#scroll#Right()<CR>

nnoremap <silent> <Plug>(movefast_tab_prev) :call movefast#tab#Prev()<CR>
nnoremap <silent> <Plug>(movefast_tab_next) :call movefast#tab#Next()<CR>

augroup MoveFast
  autocmd!
  autocmd BufWinEnter * call movefast#buffer#AddToHistory()
augroup END

" vim:et:sw=2:sts=2
