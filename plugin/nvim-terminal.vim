if exists('g:loaded_nvim_terminal')
  finish
endif
let g:loaded_nvim_terminal = 1

" Source the main plugin file
execute 'source' . expand('<sfile>:p:h') . '/nvim-terminal.vim'

" Set default values for user options
if !exists('g:nvim_terminal_background_color')
  let g:nvim_terminal_background_color = '#171b21'
endif
if !exists('g:nvim_terminal_small_height')
  let g:nvim_terminal_small_height = 10
endif
if !exists('g:nvim_terminal_large_height')
  let g:nvim_terminal_large_height = 50
endif

" Set default keybindings
nnoremap <A-t> :call nvim_terminal#TermToggle(g:nvim_terminal_small_height)<CR>
tnoremap <A-t> <C-\><C-n>:call nvim_terminal#TermToggle(g:nvim_terminal_small_height)<CR>
nnoremap <A-z> :call nvim_terminal#TermToggle(g:nvim_terminal_large_height)<CR>
tnoremap <A-z> <C-\><C-n>:call nvim_terminal#TermToggle(g:nvim_terminal_large_height)<CR>
