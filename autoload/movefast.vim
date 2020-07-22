function! movefast#Next(direction, opts) abort
  call a:opts.next(a:direction)
  let directions = get(a:opts, 'directions', ['h', 'l'])
  if has_key(a:opts, 'title')
    echohl Identifier | echo a:opts.title | echohl None
  endif
  let c = nr2char(getchar())
  if index(directions, c) >= 0
    call movefast#Next(c, a:opts)
  else
    echo ''
    if has_key(a:opts, 'complete')
      call a:opts.complete()
    endif
    redraw
  endif
endfunction
