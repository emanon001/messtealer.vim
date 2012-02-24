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
  call self.__init_variables__()
  call self.__init_accessor__()
endfunction

function! s:messtealer.__init_variables__() " {{{3
  let self._variables_ = {
        \  'default_stealers': g:messtealer#default_stealers,
        \  'cache_stealers': self.get_stealers()
        \ }
endfunction

function! s:messtealer.__init_accessor__() " {{{3
  " default_stealers
  call self._define_accessor('accessor', 'default_stealers')

  " cache_stealers
  call self._define_accessor('accessor', 'cache_stealers')
endfunction




" Interface {{{1

function! messtealer#steal(action, ...) " {{{2
  if type(a:action) == '' && strlen(a:action) == 0
    call s:print_error('Comand must be at least one character.')
    return
  elseif type(a:action) == type({}) &&
        \                  (!has_key(a:action, 'action') || type(a:action.call) != type(function('tr')))
    call s:print_error('A dictionary type variable requires the variable "call".')
    return
  elseif type(a:action) == type([])
    call s:print_error('Variable type is incorrect.')
    return
  endif

  let common_action = s:messtealer.convert_common_action(a:action)
  let stealers = (exists('a:1') && !empty(a:1)) ? a:1 : s:messtealer.get_default_stealers()
  call s:messtealer.steal(common_action, stealers)
endfunction


function! messtealer#set_default_stealers(stealers) " {{{2
  call s:messtealer.set_default_stealers(a:stealers)
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


function! s:messtealer.get_stealers() " {{{2
  let stealers = split(globpath(&runtimepath, 'autoload/' . s:PLUGIN_NAME . '/stealers/*.vim'), '\n')
  return map(stealers, 'fnamemodify(v:val, ":t:r")')
endfunction




" Misc {{{1

function! s:print_error(message) " {{{2
  let messages = [s:PLUGIN_NAME . ': The error occurred.']

  if type(a:message) == type([])
    call expand(messages, a:message)
  else
    call add(messages, a:message)
  endif

  for _ in messages
    echohl WarningMsg | echomsg _ | echohl None
  endfor
endfunction


function! s:has_value_p(var, val) " {{{2
  let _ = copy(a:var)
  if type(_) == type({}) || type(_) == type([])
    return !empty(filter(_, 'v:val == a:val'))
  endif
  throw s:print_error('Variable type is incorrect.')
endfunction


function! messtealer#complete_stealers(arg_lead, cmd_line, cursor_pos) " {{{2
  let comp_list = copy(s:messtealer.get_cache_stealers())
  let input_stealers = split(a:cmd_line)[1:]
  call filter(comp_list, '!s:has_value_p(input_stealers, v:val)')
  call filter(comp_list, 'v:val =~# a:arg_lead')

  return comp_list
endfunction


" Variable operation of messtealer. {{{2

function! s:messtealer._get_value(property, ...) " {{{3
  let ctx = exists('a:1') ? a:1 : self._variables_
  return get(ctx, a:property)
endfunction

function! s:messtealer._set_value(property, value, ...) " {{{3
  let ctx = exists('a:1') ? a:1 : self._variables_
  let ctx[a:property] = a:value
endfunction

function! s:messtealer._define_accessor(type, property, ...) " {{{3
  let optional_args = exists('a:1') ? copy(a:1) : {}
  let optional_args_default_values = {
        \  'is_pred': s:FALSE,
        \  'ctx': ''
        \ }
  let options = extend(copy(optional_args_default_values), optional_args)

  if a:type ==# 'accessor'
    call self.__define_getter(a:property, options)
    call self.__define_setter(a:property, options)
  elseif a:type ==# 'getter'
    call self.__define_getter(a:property, options)
  elseif a:type ==# 'setter'
    call self.__define_setter(a:property, options)
  endif
endfunction

function! s:messtealer.__define_getter(property, options) " {{{3
  execute printf("function! s:messtealer.%s()\n
        \   return self._get_value(%s%s)\n
        \ endfunction",
        \
        \ a:options.is_pred ? substitute(a:property, '^is_\(.*\)$', '\1_p', '') : 'get_' . a:property,
        \ "'" . a:property . "'",
        \ a:options.ctx != '' ? ', ' . a:options.ctx : '')
endfunction

function! s:messtealer.__define_setter(property, options) " {{{3
  execute printf("function! s:messtealer.set_%s(value)\n
        \   return self._set_value(%sa:value%s)\n
        \ endfunction",
        \
        \ a:property,
        \ "'" . a:property . "', ",
        \ a:options.ctx != '' ? ', ' . a:options.ctx : '')
endfunction




" Init {{{1

call s:messtealer.__init__()




" Epilogue {{{1

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions




" __END__ {{{1
" vim: foldmethod=marker
