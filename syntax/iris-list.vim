if exists('b:current_syntax')
  finish
endif

syntax match iris_email         /[a-zA-Z\.\_-]\+@[a-zA-Z\.\_-]\+/
syntax match iris_separator     /|/
syntax match iris_table_email   /^|.\{-}|/                    contains=iris_separator,iris_email
syntax match iris_table_subject /^|.\{-}|.\{-}|/              contains=iris_table_email,iris_separator
syntax match iris_table_date    /^|.\{-}|.\{-}|.\{-}|/        contains=iris_table_email,iris_table_subject,iris_separator
syntax match iris_table_flag    /^|.\{-}|.\{-}|.\{-}|.\{-}|$/ contains=iris_table_email,iris_table_subject,iris_table_date,iris_separator

highlight default link iris_email           Tag
highlight default link iris_separator       VertSplit
highlight default link iris_table_subject   String
highlight default link iris_table_date      Structure
highlight default link iris_table_flag      Comment

if(exists("g:iris_show_header") && g:iris_show_header)
  syntax match iris_table_head    /.*\%1l/                      contains=iris_separator
  highlight iris_table_head term=bold,underline cterm=bold,underline gui=bold,underline
endif

let b:current_syntax = 'iris-list'
