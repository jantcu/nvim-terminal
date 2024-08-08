if exists('g:loaded_nvim-terminal')
  finish
endif
let g:loaded_nvim-terminal = 1

" Source the main plugin file
execute 'source' . expand('<sfile>:p:h') . '/nvim-terminal.vim'
