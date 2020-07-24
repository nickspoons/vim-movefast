let s:save_cpo = &cpoptions
set cpoptions&vim

function! movefast#utils#Execute(dict, key) abort
  if !has_key(a:dict, a:key)
    return
  endif
  if type(a:dict[a:key]) == v:t_func
    call a:dict[a:key]()
  elseif type(a:dict[a:key]) == v:t_string
    execute a:dict[a:key]
  endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:et:sw=2:sts=2
