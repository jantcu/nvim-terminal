if exists('g:loaded_nvim_terminal')
  finish
endif
let g:loaded_nvim_terminal = 1

" Source the main plugin file
execute 'source' . expand('<sfile>:p:h') . '/../nvim-terminal.vim'
