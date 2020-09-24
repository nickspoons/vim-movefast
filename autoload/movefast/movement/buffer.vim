let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

let g:movefast_buffer_history = get(g:, 'movefast_buffer_history', [])

function! movefast#movement#buffer#AddToHistory() abort
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
  if a:direction ==# s:options.directions[0]
    let idx = idx == 0 ? 0 : idx - 1
  elseif a:direction ==# s:options.directions[1]
    let idx = idx == len(buffers) - 1 ? len(buffers) - 1 : idx + 1
  endif
  let s:buffer_navigating = 1
  execute 'buffer' buffers[idx]
  redraw
endfunction

function! s:FastBufferComplete() abort
  let s:buffer_navigating = 0
  " Move the newly selected buffer to the top of the list
  call movefast#movement#buffer#AddToHistory()
  if len(w:movefast_buffer_history) > 1
    " Set the previous top of the list as the alternate buffer
    let @# = w:movefast_buffer_history[-2]
  endif
  call movefast#utils#Execute(s:user, 'oncomplete')
endfunction

function! s:FastBufferInit(global) abort
  " Legal buftypes for fast-buffer switching
  let bts = ['', 'help']
  " Filter movefast_buffer_history in both scopes - do not use copy() here
  for scope in [g:, w:]
    call filter(get(scope, 'movefast_buffer_history', []),
    \ 'bufexists(v:val) && index(bts, getbufvar(v:val, "&buftype")) >= 0')
  endfor
  let scope = a:global ? g: : w:
  if len(get(scope, 'movefast_buffer_history', [])) < 2 | return | endif
  if a:global
    " Ensure that current buffer is at the top of the global history stack
    " before beginning
    call movefast#movement#buffer#AddToHistory()
  endif
  let s:options = {
  \ 'directions': ['h', 'l'],
  \ 'cancel': ['j', 'k'],
  \ 'title': (a:global ? 'Global ' : '') . 'FastBuffering…',
  \ 'next': function('s:FastBuffer', [scope])
  \}
  let s:user = {}
  let optionsName = a:global ? 'movefast_buffer_global' : 'movefast_buffer'
  if has_key(get(g:, optionsName, {}), 'oncomplete')
    " Back up user-defined 'oncomplete' action, to be executed after
    " s:FastBufferComplete()
    let s:user.oncomplete = get(g:, optionsName).oncomplete
  endif
  call extend(s:options, get(g:, optionsName, {}))
  let s:options.oncomplete = function('s:FastBufferComplete')
  let direction = s:options.directions[0]
  call movefast#Init(direction, s:options)
endfunction

function! movefast#movement#buffer#Prev(global) abort
  call s:FastBufferInit(a:global)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
