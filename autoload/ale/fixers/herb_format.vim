" Author: w0rp <devw0rp@gmail.com>
" Description: Integration of Herb Format with ALE.

call ale#Set('eruby_herb_format_executable', 'herb-format')
call ale#Set('eruby_herb_format_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('eruby_herb_format_options', '')

function! ale#fixers#herb_format#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'eruby_herb_format', [
    \   'node_modules/.bin/herb-format',
    \])
endfunction

function! ale#fixers#herb_format#Fix(buffer) abort
    let l:executable = ale#fixers#herb_format#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'eruby_herb_format_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . (!empty(l:options) ? ' ' . l:options : '')
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
