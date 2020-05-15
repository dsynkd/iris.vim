let s:started = 0

" -------------------------------------------------------------------- # Start #

function! iris#start()
  if s:started == 0
    if(iris#api#login())
		return 1
    call iris#folder#api#select('INBOX')
    let s:started = 1
  else
    call iris#email#api#fetch_all()
  endif
endfunction
