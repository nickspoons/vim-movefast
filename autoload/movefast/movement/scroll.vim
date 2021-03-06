let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

function s:FastScroll(direction) abort
  if a:direction ==# s:options.directions[0]
    execute "normal! \<C-d>"
  elseif a:direction ==# s:options.directions[1]
    execute "normal! \<C-u>"
  endif
  redraw
endfunction

function s:FastScrollHorizontal(direction) abort
  if a:direction ==# s:options.directions[0]
    execute 'normal! zH'
  elseif a:direction ==# s:options.directions[1]
    execute 'normal! zL'
  endif
  redraw
endfunction

function! s:FastScrollInit(directionIndex) abort
  let s:options = {
  \ 'directions': ['j', 'k'],
  \ 'cancel': ['h', 'l'],
  \ 'buffer': 1,
  \ 'title': 'FastScrolling…',
  \ 'next': function('s:FastScroll')
  \}
  call extend(s:options, get(g:, 'movefast_scroll', {}))
  let direction = s:options.directions[a:directionIndex]
  call movefast#Init(direction, s:options)
endfunction

function! s:FastScrollInitHorizontal(directionIndex) abort
  let s:options = {
  \ 'directions': ['h', 'l'],
  \ 'cancel': ['j', 'k'],
  \ 'buffer': 1,
  \ 'title': 'FastScrolling…',
  \ 'next': function('s:FastScrollHorizontal')
  \}
  call extend(s:options, get(g:, 'movefast_scroll_horizontal', {}))
  let direction = s:options.directions[a:directionIndex]
  call movefast#Init(direction, s:options)
endfunction

function! movefast#movement#scroll#Down() abort
  call s:FastScrollInit(0)
endfunction
function! movefast#movement#scroll#Up() abort
  call s:FastScrollInit(1)
endfunction

function! movefast#movement#scroll#Left() abort
  call s:FastScrollInitHorizontal(0)
endfunction
function! movefast#movement#scroll#Right() abort
  call s:FastScrollInitHorizontal(1)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
