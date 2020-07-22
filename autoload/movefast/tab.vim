scriptencoding utf-8

function s:FastTab(direction) abort
  if a:direction ==# get(g:, 'movefast_tab_prev', 'h')
    tabprev
  elseif a:direction ==# get(g:, 'movefast_tab_prev', 'l')
    tabnext
  endif
  redraw
endfunction

function! s:FastTabInit(direction) abort
  call movefast#Next(a:direction, {
  \ 'directions': [
  \   get(g:, 'movefast_tab_prev', 'h'),
  \   get(g:, 'movefast_tab_next', 'l')
  \ ],
  \ 'title': 'FastTabbing…',
  \ 'next': function('s:FastTab')
  \})
endfunction

function! movefast#tab#Prev() abort
  call s:FastTabInit(get(g:, 'movefast_tab_prev', 'h'))
endfunction
function! movefast#tab#Next() abort
  call s:FastTabInit(get(g:, 'movefast_tab_next', 'l'))
endfunction
