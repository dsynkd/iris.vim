let s:compose = function('iris#utils#compose')
let s:editor = has('nvim') ? 'neovim' : 'vim8'
let s:path = resolve(expand('<sfile>:h:h:h') . '/server.py')

function! iris#api#path()
  return s:path
endfunction

" -------------------------------------------------------------------- # Login #

function! iris#api#login()

  if !exists("g:iris_name")
    echohl ErrorMsg | echo "iris_name is not set!"
    return 1
  elseif !exists("g:iris_email")
    echohl ErrorMsg | echo "iris_email is not set!"
    return 1
  elseif !exists("g:iris_imap_host")
    echohl ErrorMsg | echo "iris_imap_host is not set!"
    return 1
  elseif !exists("g:iris_imap_host")
    echohl ErrorMsg | echo "iris_smtp_host is not set!"
    return 1
  endif

  let g:iris_imap_user = get(g:, 'iris_imap_user', g:iris_email)
  let g:iris_imap_port  = get(g:, 'iris_imap_port', 993)
  let g:iris_smtp_user = get(g:, 'iris_smtp_user', g:iris_email)
  let g:iris_smtp_port  = get(g:, 'iris_smtp_port', 587)

  execute 'call iris#api#' . s:editor . '#start()'

  redraw | echo
  if !exists("g:iris_imap_pass")
    let prompt = 'IMAP password:' . "\n> "
    let g:iris_imap_pass = s:compose('iris#utils#trim', 'inputsecret')(prompt)
  endif

  redraw | echo
  if !exists("g:iris_smtp_pass")
    let prompt = 'SMTP password (empty=same as IMAP):' . "\n> "
    let g:iris_smtp_pass = s:compose('iris#utils#trim', 'inputsecret')(prompt)
  endif

  call iris#utils#log('logging in...')
  call iris#api#send({
    \'type': 'login',
    \'imap-host': g:iris_imap_host,
    \'imap-port': g:iris_imap_port,
    \'imap-user': g:iris_imap_user,
    \'imap-pass': g:iris_imap_pass,
    \'smtp-host': g:iris_smtp_host,
    \'smtp-port': g:iris_smtp_port,
    \'smtp-user': g:iris_smtp_user,
    \'smtp-pass': empty(g:iris_smtp_pass) ? g:iris_imap_pass : g:iris_smtp_pass,
  \})
endfunction

" --------------------------------------------------------------------- # Send #

function! iris#api#send(data)
  execute 'call iris#api#' . s:editor . '#send(a:data)'
endfunction

" -------------------------------------------------------------- # Handle data #

function! iris#api#handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return iris#utils#elog('server: ' . string(data.error))
  endif

  if data.type == 'login'
    call iris#db#write('folders', data.folders)
    call iris#utils#log('logged in!')

  elseif data.type == 'select-folder'
    call iris#db#write('folder', data.folder)
    call iris#db#write('seq', data.seq)
    call iris#db#write('emails', data.emails)
    call iris#email#ui#list()
    call iris#utils#log('folder changed!')

  elseif data.type == 'fetch-emails'
    call iris#db#write('emails', data.emails)
    call iris#email#ui#list()
    redraw | echo

  elseif data.type == 'fetch-email'
    call iris#email#ui#preview(data.email, data.format)
    call iris#utils#log('email previewed!')

  elseif data.type == 'send-email'
    call iris#db#write('draft', [])
    call iris#utils#log('email sent!')
  endif
endfunction

" ------------------------------------------------------------- # Handle close #

function! iris#api#handle_close()
  call iris#utils#elog('server: connection lost')
endfunction
