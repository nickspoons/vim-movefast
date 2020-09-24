let s:save_cpo = &cpoptions
set cpoptions&vim

function! movefast#Init(direction, options) abort
  call s:Unmap()
  let s:options = a:options
  let s:options.buffer = get(s:options, 'buffer', 0)
  let s:options.getchar = get(s:options, 'getchar', 0)
  if !s:options.getchar
    call s:Map()
  endif
  call movefast#utils#Execute(a:options, 'oninit')
  call s:Next(a:direction)
endfunction

function! s:Complete(...) abort
  let force = a:0 && a:1
  if force || !exists('s:moving_timer')
    if !s:options.getchar
      call s:Unmap()
    endif
    echo ''
    redraw
    call movefast#utils#Execute(s:options, 'oncomplete')
  endif
endfunction

function! s:Map() abort
  if !s:ValidateMaps()
    let s:options.getchar = 1
    return
  endif
  for dir in get(s:options, 'directions', ['h', 'l'])
    execute printf(
    \ "nnoremap <silent> %s %s :call <SID>Next('%s')<CR>",
    \ s:options.buffer ? '<buffer> <nowait>' : '',
    \ dir,
    \ dir)
    call add(s:mappings, dir)
  endfor
  for dir in get(s:options, 'cancel', [])
    " Validate cancel mapping. If this fails, don't creating the mapping, but
    " invalid cancel mappings do _not_ automatically trigger getchar mode, as
    " invalid direction mappings do.
    let valid = s:options.buffer
      \ ? get(maparg(dir, 'n', 0, 1), 'buffer', 0) == 0
      \ : empty(maparg(dir, 'n'))
    if valid
      execute printf(
      \ 'nnoremap %s %s :call <SID>Complete(1)<CR>',
      \ s:options.buffer ? '<buffer> <nowait>' : '',
      \ dir)
      call add(s:mappings, dir)
    endif
  endfor
  augroup MoveFast
    autocmd!
    autocmd CursorMoved,InsertEnter * call <SID>Complete()
  augroup END
endfunction

function! s:Next(direction) abort
  if !s:options.getchar
    if exists('s:moving_timer')
      call timer_stop(s:moving_timer)
    endif
    let s:moving_timer = timer_start(0, {-> execute('unlet s:moving_timer')})
  endif
  if type(s:options.next) == v:t_func
    call s:options.next(a:direction)
  else
    call function(s:options.next)(a:direction)
  endif
  call movefast#utils#Execute(s:options, 'onnext')
  if has_key(s:options, 'title')
    echohl Identifier | echo s:options.title | echohl None
  endif
  if s:options.getchar
    call s:NextListen()
  endif
endfunction

" Listen for the next input character with getchar().
" Only used when mappings could not be used (s:options.getchar).
function! s:NextListen() abort
  let directions = get(s:options, 'directions', ['h', 'l'])
  let c = getchar()
  let char = type(c) == v:t_number ? nr2char(c) : c
  if index(get(s:options, 'directions', ['h', 'l']), char) >= 0
    call s:Next(char)
  else
    call s:Complete()
  endif
endfunction

function s:Unmap(...) abort
  for mapping in get(s:, 'mappings', [])
    try
      if s:options.buffer
        execute 'nunmap <buffer>' mapping
      else
        execute 'nunmap' mapping
      endif
    catch | endtry
  endfor
  if exists('#MoveFast')
    autocmd! MoveFast
  endif
  let s:mappings = []
endfunction

" vim-movefast works best with temporary mappings for directions.
" However, when mappings cannot be created because they conflict with existing
" mappings, fall back to using `getchar()` as an alternative.
function s:ValidateMaps() abort
  let all_valid = 1
  for dir in get(s:options, 'directions', ['h', 'l'])
    let map_valid = s:options.buffer
      \ ? get(maparg(dir, 'n', 0, 1), 'buffer', 0) == 0
      \ : empty(maparg(dir, 'n'))
    if !map_valid
      let all_valid = 0
      let s:mappingWarnings = get(s:, 'mappingWarnings', [])
      if index(s:mappingWarnings, dir) == -1
        echohl WarningMsg
        echomsg printf('Mapping exists: %s. Falling back to getchar().', dir)
        echohl None
        call add(s:mappingWarnings, dir)
      endif
    endif
  endfor
  return all_valid
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
