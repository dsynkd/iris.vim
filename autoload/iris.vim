let s:password = ''
let s:mail = {}
let s:mails = []
let s:const = {
  \'column': ['from', 'subject', 'date', 'flags'],
  \'width': {
    \'from': 21,
    \'subject': 37,
    \'date': 16,
    \'flags': 6,
  \},
  \'label': {
    \'from': 'FROM',
    \'subject': 'SUBJECT',
    \'date': 'DATE',
    \'flags': 'FLAGS',
  \},
\}

" ----------------------------------------------------------------- # Password #

function! iris#password()
  if s:password == ''
    let s:password = inputsecret(
      \'Iris password :' .
      \"\n> "
    \)
  endif

  return s:password
endfunction

" --------------------------------------------------------------------- # Read #

function! iris#read(id)
  redraw | echo 'Fetching mail...'

  let id = a:id ? a:id : s:get_focused_mail_id()
  let s:mail = py3eval('read(' . id . ')')
  let s:mail.text = substitute(s:mail.text, '', '', 'g')

  silent! edit Iris viewer
  call append(0, split(s:mail.text, '\n'))
  normal! ddgg
  setlocal filetype=iris-viewer
endfunction

" ------------------------------------------------------------------ # Preview #

function! iris#preview()
  redraw | echo 'Previewing mail...'
  execute 'python3 preview("'. s:mail.html .'")'
endfunction

" ----------------------------------------------------------------- # Read all #

function! iris#read_all()
  redraw | echo 'Fetching mails...'

  let columns = s:const.column
  let labels  = s:const.label

  let header  = [filter(copy(s:const.label), 'index(columns, v:key) + 1')]
  let s:mails = py3eval('read_all()')

  let thead = map(copy(header), function('s:PrintHead'))
  let tbody = map(copy(s:mails), function('s:PrintBody'))

  silent! edit Iris
  call append(0, thead + tbody)
  normal! ddgg
  setlocal filetype=iris
endfunction

" ------------------------------------------------------------------ # Helpers #

function! s:PrintHead(_, header)
  return s:PrintRow(a:header)
endfunction

function! s:PrintBody(_, mail)
  return s:PrintRow(a:mail)
endfunction

function! s:PrintRow(row)
  let columns = s:const.column
  let widths  = s:const.width

  return join(map(
    \copy(columns),
    \'s:PrintProp(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

function! s:PrintProp(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction

function! s:get_focused_mail_id()
  let index = line('.') - 2
  if  index == -1 | throw 'mail-not-found' | endif

  return get(s:mails, index).id
endfunction
