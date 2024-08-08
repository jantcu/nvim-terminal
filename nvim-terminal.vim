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

" Define the highlight group for the terminal window
highlight NvimTerminalBackgroundColor guibg=g:nvim_terminal_background_color ctermbg=234

" Set default keybindings
nnoremap <A-t> :call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height)<CR>
tnoremap <A-t> <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height)<CR>
nnoremap <A-z> :call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height)<CR>
tnoremap <A-z> <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height)<CR>

augroup AdjustScrolling
    autocmd!
    autocmd WinEnter,CursorMoved,CursorMovedI * if win_getid() == g:main_win | call NvimTerminal#AdjustMainWindowScrolling() | endif
augroup END

" Switch to main window from terminal
tnoremap <C-w>k <C-\><C-n>:call NvimTerminal#SwitchToMainWindow()<CR>
" Switch to terminal window from main window and enter insert mode
nnoremap <C-w>j :call NvimTerminal#SwitchToTerminalWindow()<CR>
" Exit terminal mode
tnoremap <C-w><Esc> <C-\><C-n>
" Make sure Ctrl-W works in terminal mode
tnoremap <C-w> <C-\><C-n><C-w>
