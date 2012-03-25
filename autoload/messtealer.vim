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

let s:save_cpoptions = &cpoptions
set cpoptions&vim




" Constants {{{1

let s:TRUE = 1
let s:FALSE = !s:TRUE
let s:PLUGIN_NAME = expand('<sfile>:t:r')

lockvar! s:TRUE s:FALSE s:PLUGIN_NAME




" Variables {{{1

let s:messtealer = {}


" Preparation of initialization. {{{2

function! s:messtealer.__init__() " {{{3
  call self.__init_options__()
  call self.__init_variables__()
endfunction

function! s:messtealer.__init_options__() " {{{3
  call s:set_default_option('default_stealers', ['print_buffer'])
endfunction

function! s:messtealer.__init_variables__() " {{{3
  call extend(self, {
        \  'default_stealers': g:messtealer_default_stealers,
        \  'stealers': self.find_stealers()
        \ })
endfunction




" Interface {{{1

function! messtealer#steal(action, ...) " {{{2
  call s:check_action(a:action)
  if a:0 > 0
    let _stealers = a:1
    if type(_stealers) != type([])
      throw s:create_exception_message('stealers - Wrong argument type.')
    elseif empty(_stealers)
      throw s:create_exception_message('stealers - Stealer at least one is required.')
    endif
  endif

  let common_action = s:messtealer.convert_common_action(a:action)
  let stealers = get(a:000, 0, s:messtealer.default_stealers)
  call s:messtealer.steal(common_action, stealers)
endfunction


function! messtealer#set_default_stealers(stealers) " {{{2
  if type(a:stealers) != type([])
    throw s:create_exception_message('stealers - Wrong argument type.')
  elseif empty(a:stealers)
    throw s:create_exception_message('stealers - Stealer at least one is required.')
  endif

  let s:messtealer.default_stealers = copy(a:stealers)
endfunction




" Core {{{1

function! s:messtealer.steal(action, stealers) " {{{2
  redir => mess
  silent! call a:action.call()
  redir END

  for stealer in a:stealers
    " TODO: Check for the existence of a function.
    call messtealer#stealers#{stealer}#steal(mess)
  endfor
endfunction


function! s:messtealer.convert_common_action(action) " {{{2
  let common_action = {}
  if type(a:action) == type('')
    let common_action._command_ = a:action
    function! common_action.call()
      silent! execute self._command_
    endfunction
  elseif type(a:action) == type(function('tr'))
    let common_action.call = a:action
  elseif type(a:action) == type({})
    let common_action = a:action
  endif

  return common_action
endfunction


function! s:messtealer.find_stealers() " {{{2
  let stealers = split(globpath(&runtimepath, 'autoload/' . s:PLUGIN_NAME . '/stealers/*.vim'), '\n')
  return map(stealers, 'fnamemodify(v:val, ":t:r")')
endfunction




" Misc {{{1

function! s:print_warning(message) " {{{2
  let messages = [s:PLUGIN_NAME . ': The warning occurred.']

  if type(a:message) == type([])
    call expand(messages, a:message)
  else
    call add(messages, a:message)
  endif

  for _ in messages
    echohl WarningMsg | echomsg _ | echohl None
  endfor
endfunction


function! s:create_exception_message(message) " {{{2
  return printf('%s: %s', s:PLUGIN_NAME, a:message)
endfunction


function! s:has_value_p(var, val) " {{{2
  if type(a:var) == type([])
    return index(a:var, a:val) >= 0
  elseif type(a:var) == type({})
    return index(values(a:var), a:val) >= 0
  endif
  throw s:create_exception_message('Variable type is incorrect.')
endfunction


function! messtealer#complete_stealers(arg_lead, cmd_line, cursor_pos) " {{{2
  let comp_list = copy(s:messtealer.stealers)
  let input_stealers = split(a:cmd_line)[1:]
  call filter(comp_list, '!s:has_value_p(input_stealers, v:val)')
  call filter(comp_list, 'v:val =~# a:arg_lead')

  return comp_list
endfunction


function! s:set_default_option(name, value) " {{{2
  if !exists('g:messtealer_' . a:name)
    let g:messtealer_{a:name} = a:value
  endif
endfunction


function! s:check_action(action) " {{{2
  if empty(filter([type(''), type({}), type(function('tr'))], 'type(a:action) == v:val'))
    throw s:create_exception_message('action - Wrong argument type.')
  elseif  type(a:action) == type('') && strlen(a:action) == 0
    throw s:create_exception_message('action - Command must be at least one character.')
  elseif type(a:action) == type({}) &&
        \                  (!has_key(a:action, 'call') || type(a:action.call) != type(function('tr')))
    throw s:create_exception_message('action - A dictionary type variable requires the variable "call".')
  endif
endfunction




" Init {{{1

call s:messtealer.__init__()




" Epilogue {{{1

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions




" __END__ {{{1
" vim: foldmethod=marker
