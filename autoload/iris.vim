let s:started = 0

function! iris#start()
  if s:started == 0
    if(iris#api#login())
		return 1
	endif
    call iris#folder#api#select('INBOX')
    let s:started = 1
  else
    call iris#email#api#fetch_all()
  endif
endfunction
