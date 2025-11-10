" Author: w0rp <devw0rp@gmail.com>
" Description: Herb Lint, support for https://herb-tools.dev/

call ale#Set('eruby_herb_executable', 'herb-lint')
call ale#Set('eruby_herb_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('eruby_herb_options', '')

function! ale_linters#eruby#herb#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'eruby_herb', [
    \   'node_modules/.bin/herb-lint',
    \])
endfunction

function! ale_linters#eruby#herb#GetCommand(buffer) abort
    let l:executable = ale_linters#eruby#herb#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'eruby_herb_options')

    return ale#Escape(l:executable)
    \   . ' --format json'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' %s'
endfunction

function! ale_linters#eruby#herb#Handle(buffer, lines) abort
    if empty(a:lines)
        return []
    endif

    let l:json_line = join(a:lines, '')
    let l:parsed = ale#util#FuzzyJSONDecode(l:json_line, {})

    if empty(l:parsed) || !has_key(l:parsed, 'offenses')
        return []
    endif

    let l:offenses = l:parsed['offenses']

    if empty(l:offenses)
        return []
    endif

    let l:output = []

    for l:offense in l:offenses
        let l:item = {
        \   'lnum': l:offense['location']['start']['line'] + 0,
        \   'col': l:offense['location']['start']['column'] + 0,
        \   'text': l:offense['message'],
        \   'code': l:offense['code'],
        \}

        if l:offense['severity'] is# 'error'
            let l:item.type = 'E'
        else
            let l:item.type = 'W'
        endif

        if has_key(l:offense['location'], 'end')
        \   && has_key(l:offense['location']['end'], 'column')
            let l:item.end_col = l:offense['location']['end']['column'] + 0
        endif

        if has_key(l:offense['location'], 'end')
        \   && has_key(l:offense['location']['end'], 'line')
            let l:item.end_lnum = l:offense['location']['end']['line'] + 0
        endif

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('eruby', {
\   'name': 'herb',
\   'executable': function('ale_linters#eruby#herb#GetExecutable'),
\   'command': function('ale_linters#eruby#herb#GetCommand'),
\   'callback': function('ale_linters#eruby#herb#Handle'),
\})
