" To output the message into the buffer for the work.
" Author:  emanon001 <emanon001@gmail.com>
" License: DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE, Version 2 {{{
"     This program is free software. It comes without any warranty, to
"     the extent permitted by applicable law. You can redistribute it
"     and/or modify it under the terms of the Do What The Fuck You Want
"     To Public License, Version 2, as published by Sam Hocevar. See
"     http://sam.zoy.org/wtfpl/COPYING for more details.
" }}}

let s:BUFFER_NAME = '__message__'
let s:buffer_number = -1

function messtealer#stealers#print_buffer#steal(message)
  if bufexists(s:buffer_number)
    let winnr = bufwinnr(s:buffer_number)
    if winnr == -1
      split
      execute s:buffer_number . 'buffer'
    else
      execute winnr . 'wincmd w'
    endif

    1,$delete
  else
    new
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    silent file `=s:BUFFER_NAME`

    let s:buffer_number = bufnr('%')
  endif

  call setline(1, split(a:message, '\n'))
endfunction

" vim: foldmethod=marker
