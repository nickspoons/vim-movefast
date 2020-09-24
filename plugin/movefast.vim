if exists('g:movefast_loaded') | finish | endif
let g:movefast_loaded = 1

nnoremap <silent> <Plug>(movefast_buffer_prev) :call movefast#movement#buffer#Prev(0)<CR>
nnoremap <silent> <Plug>(movefast_buffer_global_prev) :call movefast#movement#buffer#Prev(1)<CR>

nnoremap <silent> <Plug>(movefast_scroll_down) :call movefast#movement#scroll#Down()<CR>
nnoremap <silent> <Plug>(movefast_scroll_up) :call movefast#movement#scroll#Up()<CR>
nnoremap <silent> <Plug>(movefast_scroll_left) :call movefast#movement#scroll#Left()<CR>
nnoremap <silent> <Plug>(movefast_scroll_right) :call movefast#movement#scroll#Right()<CR>

nnoremap <silent> <Plug>(movefast_tab_prev) :call movefast#movement#tab#Prev()<CR>
nnoremap <silent> <Plug>(movefast_tab_next) :call movefast#movement#tab#Next()<CR>

augroup MoveFastBufferHistory
  autocmd!
  autocmd BufWinEnter * call movefast#movement#buffer#AddToHistory()
augroup END

" vim:et:sw=2:sts=2
