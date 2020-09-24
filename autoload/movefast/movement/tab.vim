let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

function s:FastTab(direction) abort
  if a:direction ==# s:options.directions[0]
    tabprev
  elseif a:direction ==# s:options.directions[1]
    tabnext
  endif
  redraw
endfunction

function! s:FastTabInit(directionIndex) abort
  let s:options = {
  \ 'directions': ['h', 'l'],
  \ 'cancel': ['j', 'k'],
  \ 'title': 'FastTabbing…',
  \ 'next': function('s:FastTab')
  \}
  call extend(s:options, get(g:, 'movefast_tab', {}))
  let direction = s:options.directions[a:directionIndex]
  call movefast#Init(direction, s:options)
endfunction

function! movefast#movement#tab#Prev() abort
  call s:FastTabInit(0)
endfunction
function! movefast#movement#tab#Next() abort
  call s:FastTabInit(1)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
