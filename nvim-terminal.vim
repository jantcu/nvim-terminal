if exists('g:loaded_nvim_terminal')
  finish
endif
let g:loaded_nvim_terminal = 1

" Initialize required variables
let g:main_win = 0
let g:term_win = 0
let g:term_height = 0

" Source the main plugin functions
execute 'source' . expand('<sfile>:p:h') . '/autoload/NvimTerminal.vim'

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
nnoremap <A-t> :call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height)<CR>
tnoremap <A-t> <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height)<CR>
nnoremap <A-z> :call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height)<CR>
tnoremap <A-z> <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height)<CR>

augroup AdjustScrolling
    autocmd!
    autocmd WinEnter,CursorMoved,CursorMovedI * if win_getid() == g:main_win | call NvimTerminal#AdjustMainWindowScrolling() | endif
augroup END
