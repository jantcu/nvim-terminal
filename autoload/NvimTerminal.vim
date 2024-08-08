function! NvimTerminal#ToggleTerminal(height)
    if win_gotoid(g:term_win)
        if a:height == g:term_height
            let g:term_height = 0
            hide
        else
            let g:term_height = a:height
            " Recreate the floating window with new size
            let buf = winbufnr(g:term_win)
            call nvim_win_close(g:term_win, v:false)
            let opts = {
                \ 'relative': 'editor',
                \ 'row': &lines - a:height,
                \ 'col': 0,
                \ 'width': &columns,
                \ 'height': a:height,
                \ 'style': 'minimal'
                \ }
            let win = nvim_open_win(buf, v:true, opts)
            let g:term_win = win_getid()
            call setwinvar(win, '&winhl', 'Normal:TerminalBackground')
            call setwinvar(win, '&number', 0)
            call setwinvar(win, '&relativenumber', 0)
            call setwinvar(win, '&signcolumn', 'no')
            startinsert!
        endif
    elseif g:term_height == 0
        let g:main_win = win_getid()  " Remember the main window ID
        let g:term_height = a:height
        " Create a floating window
        let buf = nvim_create_buf(v:false, v:true)
        let opts = {
            \ 'relative': 'editor',
            \ 'row': &lines - a:height,
            \ 'col': 0,
            \ 'width': &columns,
            \ 'height': a:height,
            \ 'style': 'minimal'
            \ }
        let win = nvim_open_win(buf, v:true, opts)
        " Set window options
        call setwinvar(win, '&winhl', 'Normal:TerminalBackground')
        call setwinvar(win, '&number', 0)
        call setwinvar(win, '&relativenumber', 0)
        call setwinvar(win, '&signcolumn', 'no')
        " Open terminal in the floating window
        call termopen($SHELL, {"detach": 0})
        let g:term_buf = bufnr("")
        let g:term_win = win_getid()
        " Set buffer options
        setlocal nobuflisted
        setlocal nohidden
        startinsert!
    endif
    call NvimTerminal#AdjustMainWindowScrolling()
endfunction

function! NvimTerminal#AdjustMainWindowScrolling()
    if g:term_height > 0
        let l:main_height = g:term_height
        call win_execute(g:main_win, 'call NvimTerminal#AdjustScrollOff(' . l:main_height . ')')
    else
        call setwinvar(g:main_win, '&scrolloff', 0)
    endif
endfunction

function! NvimTerminal#AdjustScrollOff(main_height)
    let l:total_lines = line('$')
    let l:current_line = line('.')
    let l:visible_lines = &lines - a:main_height - &cmdheight - 1

    if winline() < &lines/2
        let &l:scrolloff = 0
    else
        let &l:scrolloff = a:main_height

        " Calculate the line where we should start adjusting scroll
        let l:adjust_line = l:total_lines - g:term_height

        if l:current_line >= l:adjust_line
            let l:desired_top_line = l:total_lines - l:visible_lines + 1
            let l:current_top_line = line('w0')
            
            if l:current_top_line < l:desired_top_line
                let l:scroll_amount = l:desired_top_line - l:current_top_line
                execute 'normal! ' . l:scroll_amount . "\<C-E>"
            endif
        endif
    endif

endfunction

function! NvimTerminal#SwitchToMainWindow()
    if win_getid() == g:term_win
        call win_gotoid(g:main_win)
        call NvimTerminal#AdjustMainWindowScrolling()
    endif
endfunction

function! NvimTerminal#SwitchToTerminalWindow()
    if win_getid() == g:main_win && g:term_win != 0
        call win_gotoid(g:term_win)
        setlocal scrolloff=0
        startinsert!
    endif
endfunction

augroup AdjustScrolling
    autocmd!
    autocmd WinEnter,CursorMoved,CursorMovedI * if win_getid() == g:main_win | call NvimTerminal#AdjustMainWindowScrolling() | endif
augroup END
