function! NvimTerminal#AddTerminal()
    if g:term_height > 0
        " Create a new buffer
        let buf = nvim_create_buf(v:false, v:true)
        call add(g:term_buf, buf)
        let g:current_term = len(g:term_buf) - 1

        " Switch to the new buffer
        call nvim_win_set_buf(g:term_win, buf)
        
        " Open terminal in the new buffer
        call termopen($SHELL, {"detach": 0})

        " Set background color
        call setwinvar(g:term_win, '&winhl', 'Normal:NvimTerminalBackgroundColor')

        " Set buffer options
        setlocal nobuflisted
        setlocal nohidden

        " Update status line
        "call setwinvar(g:term_win, '&statusline', '%!NvimTerminal#UpdateStatusLine()')
        call NvimTerminal#ShowStatusLine()

        startinsert!
    else
        echo "Terminal is not open. Open it first with Alt-t (or whatever your custom keymap is)."
    endif
endfunction

function! NvimTerminal#RemoveTerminal()
    if g:term_height > 0 && !empty(g:term_buf)
        " Store the current terminal buffer
        let current_buf = g:term_buf[g:current_term]

        " Remove the current terminal buffer from the list
        call remove(g:term_buf, g:current_term)

        " Close the current terminal buffer
        execute 'bdelete! ' . current_buf

        if !empty(g:term_buf)
            " Switch to the previous terminal buffer
            let g:current_term = (g:current_term - 1 + len(g:term_buf)) % len(g:term_buf)

            " Create a new floating window with the correct size and position
            let opts = {
                \ 'relative': 'editor',
                \ 'row': &lines - g:term_height,
                \ 'col': 0,
                \ 'width': &columns,
                \ 'height': g:term_height,
                \ 'style': 'minimal'
                \ }
            let win = nvim_open_win(g:term_buf[g:current_term], v:true, opts)
            let g:term_win = win_getid(win)

            " Set window options
            call setwinvar(win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
            call setwinvar(win, '&number', 0)
            call setwinvar(win, '&relativenumber', 0)
            call setwinvar(win, '&signcolumn', 'no')

            call NvimTerminal#ShowStatusLine()
            startinsert!
        else
            " If there are no more terminal buffers, close the terminal window
            let g:term_buf = []
            let g:term_height = 0
            let g:term_win = 0
            call win_gotoid(g:main_win)
            call NvimTerminal#ShowStatusLine()
        endif
        call NvimTerminal#ShowStatusLine()
    endif
endfunction

function! NvimTerminal#NextTerminal()
    if g:term_height > 0 && !empty(g:term_buf)
        let g:current_term = (g:current_term + 1) % len(g:term_buf)
        call nvim_win_set_buf(g:term_win, g:term_buf[g:current_term])
        "call setwinvar(g:term_win, '&statusline', '%!NvimTerminal#UpdateStatusLine()')
        call NvimTerminal#ShowStatusLine()
        startinsert!
    endif
endfunction

function! NvimTerminal#PrevTerminal()
    if g:term_height > 0 && !empty(g:term_buf)
        let g:current_term = (g:current_term - 1 + len(g:term_buf)) % len(g:term_buf)
        call nvim_win_set_buf(g:term_win, g:term_buf[g:current_term])
        "call setwinvar(g:term_win, '&statusline', '%!NvimTerminal#UpdateStatusLine()')
        call NvimTerminal#ShowStatusLine()
        startinsert!
    endif
endfunction

function! NvimTerminal#UpdateStatusLine()
    if g:term_height > 0 && !empty(g:term_buf)
        let status = ' Terminal ' . (g:current_term + 1) . '/' . len(g:term_buf) . ' '
        let fillchar = '─'
        let fill = repeat(fillchar, &columns - len(status))
        return fill . status
    endif
    return ''
endfunction

function! NvimTerminal#ShowStatusLine()
    if g:term_height > 0 && !empty(g:term_buf)
        if exists('g:term_status_win')
            " Update the contents of the existing status line window
            let status_buf = nvim_win_get_buf(g:term_status_win)
            call nvim_buf_set_lines(status_buf, 0, -1, v:true, [NvimTerminal#UpdateStatusLine()])
            let opts = {
                \ 'relative': 'editor',
                \ 'row': &lines - g:term_height - 2,
                \ 'col': 0,
                \ 'width': &columns,
                \ 'height': 1,
                \ 'style': 'minimal'
                \ }
            call nvim_win_set_config(g:term_status_win, opts)
        else
            " Create a new buffer for the status line
            let status_buf = nvim_create_buf(v:false, v:true)
            call nvim_buf_set_lines(status_buf, 0, -1, v:true, [NvimTerminal#UpdateStatusLine()])

            " Create a new window for the status line
            let opts = {
                \ 'relative': 'editor',
                \ 'row': &lines - g:term_height - 2,
                \ 'col': 0,
                \ 'width': &columns,
                \ 'height': 1,
                \ 'style': 'minimal'
                \ }
            let status_win = nvim_open_win(status_buf, v:false, opts)

            " Set window options
            call setwinvar(status_win, '&number', 0)
            call setwinvar(status_win, '&relativenumber', 0)
            call setwinvar(status_win, '&signcolumn', 'no')
            call setwinvar(status_win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
            call setwinvar(status_win, '&winhighlight', 'Normal:NvimTerminalStatusLineColor')

            " Store the status window ID
            let g:term_status_win = status_win
        endif
    else
        " Remove the status line if there are no terminals
        if exists('g:term_status_win')
            call nvim_win_close(g:term_status_win, v:true)
            unlet g:term_status_win
        endif
    endif
endfunction

function! NvimTerminal#ToggleTerminal(height, background_color, statusline_color)
    execute 'highlight NvimTerminalBackgroundColor guibg=' . a:background_color . ' ctermbg=234'
    execute 'highlight NvimTerminalStatusLineColor guifg=' . a:statusline_color . ' ctermbg=234'
    if win_gotoid(g:term_win)
        if a:height == g:term_height
            let g:term_height = 0
            hide
        else
            let g:term_height = a:height
            " Recreate the floating window with new size
            let buf = g:term_buf[g:current_term]
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
            call setwinvar(win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
            call setwinvar(win, '&number', 0)
            call setwinvar(win, '&relativenumber', 0)
            call setwinvar(win, '&signcolumn', 'no')
            call NvimTerminal#ShowStatusLine()
            startinsert!
        endif
    elseif g:term_height == 0
        let g:main_win = win_getid()  " Remember the main window ID
        let g:term_height = a:height
        " Create a floating window
        if empty(g:term_buf)
            let buf = nvim_create_buf(v:false, v:true)
            call add(g:term_buf, buf)
        else
            let buf = g:term_buf[g:current_term]
        endif
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
        call setwinvar(win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
        call setwinvar(win, '&number', 0)
        call setwinvar(win, '&relativenumber', 0)
        call setwinvar(win, '&signcolumn', 'no')
        " Open terminal in the floating window if it's a new buffer
        if bufname(buf) == ''
            call termopen($SHELL, {"detach": 0})
        endif
        let g:term_win = win_getid()
        " Set buffer options
        setlocal nobuflisted
        setlocal nohidden
        "call NvimTerminal#ShowStatusLine()
        startinsert!
    endif

    if g:term_height > 0
        call NvimTerminal#ShowStatusLine()
    else
        if exists('g:term_status_win')
            call nvim_win_close(g:term_status_win, v:true)
            unlet g:term_status_win
        endif
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
            let l:desired_top_line = l:total_lines - l:visible_lines + 2
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
