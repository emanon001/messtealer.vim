" Steal the message.
" Version: 0.0.1
" Author:  emanon001 <emanon001@gmail.com>
" License: DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE, Version 2 {{{
"     This program is free software. It comes without any warranty, to
"     the extent permitted by applicable law. You can redistribute it
"     and/or modify it under the terms of the Do What The Fuck You Want
"     To Public License, Version 2, as published by Sam Hocevar. See
"     http://sam.zoy.org/wtfpl/COPYING for more details.
" }}}

" Prologue {{{1

scriptencoding utf-8

if exists('g:loaded_messtealer')
  finish
endif

let s:save_cpoptions = &cpoptions
set cpoptions&vim




" Options {{{1

function! s:set_default_option(name, value)
  if !exists('g:messtealer#' . a:name)
    let g:messtealer#{a:name} = a:value
  endif
endfunction

call s:set_default_option('default_stealers', ['print_buffer'])




" Commands {{{1


command! -nargs=1 -complete=command MesStealer
      \ call s:steal(<q-args>)

command! -nargs=+ -complete=customlist,messtealer#complete_stealers MesStealers
      \ call messtealer#set_default_stealers(split(<q-args>))




" Misc {{{1

function! s:steal(input_command)
  let command_info = s:perse_input_command(a:input_command)
  call messtealer#steal(command_info.command, command_info.stealers)
endfunction

function! s:perse_input_command(input_command)
  let _ = split(a:input_command, '--stealers')
  let command = _[0]
  let stealers = len(_) > 1 ? split(_[1]) : []
  return {'command': command, 'stealers': stealers}
endfunction




" Epilogue {{{1

let g:loaded_messtealer = 1

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions




" __END__ {{{1
" vim: foldmethod=marker
