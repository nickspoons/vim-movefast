scriptencoding utf-8

let g:movefast_buffer_history = get(g:, 'movefast_buffer_history', [])

function! movefast#buffer#AddToHistory() abort
  if get(s:, 'buffer_navigating', 0) | return | endif
  let w:movefast_buffer_history = get(w:, 'movefast_buffer_history', [])
  let bufnr = bufnr('%')
  for scope in [g:, w:]
    let idx = index(get(scope, 'movefast_buffer_history'), bufnr)
    if idx != -1
      call remove(get(scope, 'movefast_buffer_history'), idx)
    endif
    call add(get(scope, 'movefast_buffer_history'), bufnr)
  endfor
endfunction

function! s:FastBuffer(scope, direction) abort
  let buffers = get(a:scope, 'movefast_buffer_history', [])
  let idx = index(buffers, bufnr('%'))
  if a:direction ==# get(g:, 'movefast_buffer_prev', 'h')
    let idx = idx == 0 ? 0 : idx - 1
  elseif a:direction ==# get(g:, 'movefast_buffer_next', 'l')
    let idx = idx == len(buffers) - 1 ? len(buffers) - 1 : idx + 1
  endif
  let s:buffer_navigating = 1
  execute 'buffer' buffers[idx]
  redraw
endfunction

function! s:FastBufferComplete() abort
  let s:buffer_navigating = 0
  " Move the newly selected buffer to the top of the list
  call movefast#buffer#AddToHistory()
  if len(w:movefast_buffer_history) > 1
    " Set the previous top of the list as the alternate buffer
    let @# = w:movefast_buffer_history[-2]
  endif
endfunction

function! s:FastBufferInit(global, direction) abort
  " Legal buftypes for fast-buffer switching
  let bts = ['', 'help']
  " Filter movefast_buffer_history in both scopes - do not use copy() here
  for scope in [g:, w:]
    call filter(get(scope, 'movefast_buffer_history', []),
    \ 'bufexists(v:val) && index(bts, getbufvar(v:val, "&buftype")) >= 0')
  endfor
  let scope = a:global ? g: : w:
  if len(get(scope, 'movefast_buffer_history', [])) < 2 | return | endif
  call movefast#Next(a:direction, {
  \ 'directions': [
  \   get(g:, 'movefast_buffer_prev', 'h'),
  \   get(g:, 'movefast_buffer_next', 'l')
  \ ],
  \ 'title': (a:global ? 'Global ' : '') . 'FastBuffering…',
  \ 'next': function('s:FastBuffer', [scope]),
  \ 'complete': function('s:FastBufferComplete')
  \})
endfunction

function! movefast#buffer#Prev(global) abort
  call s:FastBufferInit(a:global, get(g:, 'movefast_buffer_prev', 'h'))
endfunction
function! movefast#buffer#Next(global) abort
  call s:FastBufferInit(a:global, get(g:, 'movefast_buffer_next', 'l'))
endfunction
