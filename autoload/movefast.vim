let s:save_cpo = &cpoptions
set cpoptions&vim

function! movefast#Init(direction, options) abort
  call movefast#utils#Execute(a:options, 'oninit')
  call movefast#Next(a:direction, a:options)
endfunction

function! movefast#Next(direction, options) abort
  if type(a:options.next) == v:t_func
    call a:options.next(a:direction)
  else
    call function(a:options.next)(a:direction)
  endif
  call movefast#utils#Execute(a:options, 'onnext')
  if has_key(a:options, 'title')
    echohl Identifier | echo a:options.title | echohl None
  endif
  let directions = get(a:options, 'directions', ['h', 'l'])
  let c = getchar()
  let char = type(c) == v:t_number ? nr2char(c) : c
  if index(get(a:options, 'directions', ['h', 'l']), char) >= 0
    call movefast#Next(char, a:options)
  else
    echo ''
    redraw
    call movefast#utils#Execute(a:options, 'oncomplete')
  endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
