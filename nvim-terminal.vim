" Initialize required variables
let g:main_win = 0
let g:term_win = 0
let g:term_height = 0
let g:term_buf = []
let g:current_term = 0

" Source the main plugin functions
execute 'source' . expand('<sfile>:p:h') . '/autoload/NvimTerminal.vim'

" Set default values for user options
if !exists('g:nvim_terminal_background_color')
  let g:nvim_terminal_background_color = '#171b21'
endif
if !exists('g:nvim_terminal_statusline_color')
  let g:nvim_terminal_statusline_color = '#3fbbce'
endif
if !exists('g:nvim_terminal_small_height')
  let g:nvim_terminal_small_height = 10
endif
if !exists('g:nvim_terminal_large_height')
  let g:nvim_terminal_large_height = 50
endif
if !exists('g:nvim_terminal_toggle_small')
  let g:nvim_terminal_toggle_small = '<A-t>'
endif
if !exists('g:nvim_terminal_toggle_large')
  let g:nvim_terminal_toggle_large = '<A-z>'
endif
if !exists("g:nvim_terminal_custom_names")
  let g:nvim_terminal_custom_names = {}
endif

" Set default keybindings
execute 'nnoremap <silent> ' . g:nvim_terminal_toggle_small . ' :call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height, g:nvim_terminal_background_color, g:nvim_terminal_statusline_color)<CR>'
execute 'tnoremap <silent> ' . g:nvim_terminal_toggle_small . ' <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_small_height, g:nvim_terminal_background_color, g:nvim_terminal_statusline_color)<CR>'
execute 'nnoremap <silent> ' . g:nvim_terminal_toggle_large . ' :call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height, g:nvim_terminal_background_color, g:nvim_terminal_statusline_color)<CR>'
execute 'tnoremap <silent> ' . g:nvim_terminal_toggle_large . ' <C-\><C-n>:call NvimTerminal#ToggleTerminal(g:nvim_terminal_large_height, g:nvim_terminal_background_color, g:nvim_terminal_statusline_color)<CR>'

augroup AdjustScrolling
    autocmd!
    autocmd WinEnter,CursorMoved,CursorMovedI * if win_getid() == g:main_win | call NvimTerminal#AdjustScrollOff(0) | endif
    autocmd WinScrolled * if win_getid() == g:main_win | call NvimTerminal#AdjustScrollOff(1) | endif
augroup END

" Allow clicking into terminal with mouse
" 'a' enters terminal mode.
" 'x' removes the typed 'a'.
" 't' ensures the removal happens immediately.
autocmd BufEnter * if &buftype == 'terminal' | call feedkeys('a', 'xt') | endif

"augroup NvimTerminalPersist
"    autocmd!
"    autocmd VimLeavePre * call NvimTerminal#SaveTerminals()
"augroup END

augroup NvimTerminalRestore
    autocmd!
    autocmd VimEnter * call NvimTerminal#LoadTerminals()
augroup END

tnoremap <A-+> <C-\><C-n>:call NvimTerminal#AddTerminal()<CR>
tnoremap <A--> <C-\><C-n>:call NvimTerminal#RemoveTerminal()<CR>
tnoremap <A-.> <C-\><C-n>:call NvimTerminal#SetCustomStatus()<CR>
tnoremap <A-]> <C-\><C-n>:call NvimTerminal#NextTerminal()<CR>
tnoremap <A-[> <C-\><C-n>:call NvimTerminal#PrevTerminal()<CR>
tnoremap <A-s> <C-\><C-n>:call NvimTerminal#SaveTerminals()<CR>
" Switch to main window from terminal
tnoremap <C-w>k <C-\><C-n>:call NvimTerminal#SwitchToMainWindow()<CR>
" Switch to terminal window from main window and enter insert mode
nnoremap <C-w>j :call NvimTerminal#SwitchToTerminalWindow()<CR>
" Exit terminal mode
tnoremap <C-w><Esc> <C-\><C-n>
" Make sure Ctrl-W works in terminal mode
tnoremap <C-w> <C-\><C-n><C-w>
