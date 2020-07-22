let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

function s:FastScroll(direction) abort
  if a:direction ==# get(g:, 'movefast_scroll_down', 'j')
    execute "normal! \<C-d>"
  elseif a:direction ==# get(g:, 'movefast_scroll_up', 'k')
    execute "normal! \<C-u>"
  endif
  redraw
endfunction

function s:FastScrollHorizontal(direction) abort
  if a:direction ==# get(g:, 'movefast_scroll_left', 'h')
    execute 'normal! zH'
  elseif a:direction ==# get(g:, 'movefast_scroll_right', 'l')
    execute 'normal! zL'
  endif
  redraw
endfunction

function! s:FastScrollInit(direction) abort
  call movefast#Next(a:direction, {
  \ 'directions': [
  \   get(g:, 'movefast_scroll_down', 'j'),
  \   get(g:, 'movefast_scroll_up', 'k')
  \ ],
  \ 'title': 'FastScrolling…',
  \ 'next': function('s:FastScroll')
  \})
endfunction

function! s:FastScrollInitHorizontal(direction) abort
  call movefast#Next(a:direction, {
  \ 'directions': [
  \   get(g:, 'movefast_scroll_left', 'h'),
  \   get(g:, 'movefast_scroll_right', 'l')
  \ ],
  \ 'title': 'FastScrolling…',
  \ 'next': function('s:FastScrollHorizontal')
  \})
endfunction

function! movefast#scroll#Down() abort
  call s:FastScrollInit(get(g:, 'movefast_scroll_down', 'j'))
endfunction
function! movefast#scroll#Up() abort
  call s:FastScrollInit(get(g:, 'movefast_scroll_up', 'k'))
endfunction

function! movefast#scroll#Left() abort
  call s:FastScrollInitHorizontal(get(g:, 'movefast_scroll_left', 'h'))
endfunction
function! movefast#scroll#Right() abort
  call s:FastScrollInitHorizontal(get(g:, 'movefast_scroll_right', 'l'))
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
