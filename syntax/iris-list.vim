if exists('b:current_syntax')
	finish
endif

syn match iris_email /[a-zA-Z\.\_-]\+@[a-zA-Z\.\_-]\+/
syn match iris_separator /|/
syn match iris_table_email /^|.\{-}|/ contains=iris_separator,iris_email
syn match iris_table_subject /^|.\{-}|.\{-}|/ contains=iris_table_email,iris_separator
syn match iris_table_date /^|.\{-}|.\{-}|.\{-}|/ contains=iris_table_email,iris_table_subject,iris_separator
syn match iris_table_flag /^|.\{-}|.\{-}|.\{-}|.\{-}|$/ contains=iris_table_email,iris_table_subject,iris_table_date,iris_separator

hi def link iris_email Tag
hi def link iris_separator VertSplit
hi def link iris_table_subject String
hi def link iris_table_date Structure
hi def link iris_table_flag Comment

if(exists("g:iris_show_header") && g:iris_show_header)
	syn match iris_table_head /.*\%1l/ contains=iris_separator
	hi iris_table_head term=bold,underline cterm=bold,underline gui=bold,underline
endif

let b:current_syntax = 'iris-list'
