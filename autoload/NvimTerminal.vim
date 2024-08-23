function! NvimTerminal#SaveTerminals()
    let l:save_data = []
    if exists("g:term_buf")
        for i in range(len(g:term_buf))
            let l:buf = g:term_buf[i]
            if bufexists(l:buf)
                let l:term_info = {
                    \ 'name': get(g:nvim_terminal_custom_names, i, 'Terminal'),
                    \ 'cwd': getbufvar(l:buf, 'term_cwd', getcwd()),
                    \ 'cmd': NvimTerminal#GetTerminalCommand(l:buf)
                \ }
                call add(l:save_data, l:term_info)
            endif
        endfor
    endif
    let l:save_file = getcwd() . '/.nvim_terminals.json'
    call writefile([json_encode(l:save_data)], l:save_file)
    startinsert!
endfunction

function! NvimTerminal#GetTerminalCommand(buf)
    let l:chan_id = getbufvar(a:buf, '&channel')
    if l:chan_id > 0
        let l:job_id = jobpid(l:chan_id)
        if l:job_id > 0
            let l:cmd = system('ps -o command= -p ' . l:job_id)
            return trim(l:cmd)
        endif
    endif
    return ''
endfunction

function! NvimTerminal#LoadTerminals()
    let l:save_file = getcwd() . '/.nvim_terminals.json'
    if filereadable(l:save_file)
        let l:save_data = json_decode(readfile(l:save_file)[0])
        for l:term_info in l:save_data
            " Create a new buffer
            let buf = nvim_create_buf(v:false, v:true)
            call add(g:term_buf, buf)
            let g:current_term = len(g:term_buf) - 1

            " Set the custom name
            let g:nvim_terminal_custom_names[g:current_term] = l:term_info.name

            " Store the working directory
            call setbufvar(buf, 'term_cwd', l:term_info.cwd)

            " Store the command
            call setbufvar(buf, 'term_cmd', l:term_info.cmd)
        endfor
        call NvimTerminal#ShowStatusLine()
    endif
endfunction

function! NvimTerminal#AddTerminal()
    if g:term_height > 0
        " Create a new buffer
        let buf = nvim_create_buf(v:false, v:true)
        call add(g:term_buf, buf)
        let g:current_term = len(g:term_buf) - 1

        " Initialize custom name for the new terminal
        let g:nvim_terminal_custom_names[g:current_term] = 'Terminal'

        " Switch to the new buffer
        call nvim_win_set_buf(g:term_win, buf)

        " Store the current working directory
        let cwd = getcwd()
        call setbufvar(buf, 'term_cwd', cwd)

        " Open terminal in the new buffer
        let cmd = $SHELL
        call termopen(cmd, {"cwd": cwd, "detach": 0})

        " Store the command
        call setbufvar(buf, 'term_cmd', cmd)

        " Set background color
        call setwinvar(g:term_win, '&winhl', 'Normal:NvimTerminalBackgroundColor')

        " Set buffer options
        setlocal nobuflisted
        setlocal nohidden

        " Update status line
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

        " Remove custom name for the closed terminal
        if has_key(g:nvim_terminal_custom_names, g:current_term)
            call remove(g:nvim_terminal_custom_names, g:current_term)
        endif

        " Close the current terminal buffer
        execute 'bdelete! ' . current_buf

        " Adjust the custom names dictionary
        let new_names = {}
        let index = 0
        for [key, value] in items(g:nvim_terminal_custom_names)
            if key > g:current_term
                let new_names[index] = value
            elseif key < g:current_term
                let new_names[key] = value
            endif
            let index += 1
        endfor
        let g:nvim_terminal_custom_names = new_names

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
            let g:term_win = win_getid()

            " Set window options
            call setwinvar(win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
            call setwinvar(win, '&number', 0)
            call setwinvar(win, '&relativenumber', 0)
            call setwinvar(win, '&signcolumn', 'no')

            startinsert!
        else
            " If there are no more terminal buffers, close the terminal window
            let g:term_buf = []
            let g:term_height = 0
            let g:term_win = 0
            let g:nvim_terminal_custom_names = {}
            call win_gotoid(g:main_win)
        endif
        call NvimTerminal#ShowStatusLine()
    endif
endfunction

function! NvimTerminal#NextTerminal()
    if g:term_height > 0 && !empty(g:term_buf)
        let g:current_term = (g:current_term + 1) % len(g:term_buf)
        call NvimTerminal#SetupTerminalWindow()
    endif
endfunction

function! NvimTerminal#PrevTerminal()
    if g:term_height > 0 && !empty(g:term_buf)
        let g:current_term = (g:current_term - 1 + len(g:term_buf)) % len(g:term_buf)
        call NvimTerminal#SetupTerminalWindow()
    endif
endfunction

function! NvimTerminal#SetupTerminalWindow()
    let buf = g:term_buf[g:current_term]
    call nvim_win_set_buf(g:term_win, buf)
    call setwinvar(g:term_win, '&winhl', 'Normal:NvimTerminalBackgroundColor')
    call NvimTerminal#ShowStatusLine()
    
    " Check if the buffer is a terminal buffer
    if getbufvar(buf, '&buftype') == 'terminal'
        " If it's a terminal buffer, enter terminal mode
        startinsert
    else
        " If it's not a terminal buffer, create a new terminal
        call termopen($SHELL, {"detach": 0})
        startinsert
    endif
endfunction

function! NvimTerminal#UpdateStatusLine()
    if g:term_height > 0 && !empty(g:term_buf)
        let term_name = get(g:nvim_terminal_custom_names, g:current_term, 'Terminal')
        let status = ' ' . term_name . ' ' . (g:current_term + 1) . '/' . len(g:term_buf) . ' '
        let fillchar = '─'
        let fill = repeat(fillchar, &columns - len(status))
        return fill . status
    endif
    return ''
endfunction

function! NvimTerminal#SetCustomStatus()
    if g:term_height > 0 && !empty(g:term_buf)
        try
            let custom_name = input('Enter name for Terminal ' . (g:current_term + 1) . ': ')
            if !empty(custom_name)
                let g:nvim_terminal_custom_names[g:current_term] = custom_name
            elseif has_key(g:nvim_terminal_custom_names, g:current_term)
                echohl WarningMsg
                echo "Cancelled name change"
                echohl None
            else
                call remove(g:nvim_terminal_custom_names, g:current_term)
            endif
            call NvimTerminal#ShowStatusLine()
        catch /^Vim:Interrupt$/
            " This catches the Ctrl-C interrupt
            echohl WarningMsg
            echo "Cancelled name change"
            echohl None
        endtry
    else
        echo "No active terminal."
    endif
    startinsert!
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
    if win_gotoid(g:term_win) && !empty(g:term_buf)
        " Entered a terminal window
        if a:height == g:term_height
            " Toggling terminal with same height (close terminal)
            let g:term_height = 0
            let g:term_win = 0
            hide
        else
            " Toggling terminal with different height (expand/contract terminal)
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
            startinsert!
        endif
    else
        " Terminal doesn't exist yet so we need to create it
        let g:main_win = win_getid()  " Remember the main window ID
        let g:term_height = a:height
        if empty(g:nvim_terminal_custom_names)
            " Initialize custom name for the new terminal
            let g:nvim_terminal_custom_names[g:current_term] = 'Terminal'
        endif
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
        startinsert!
    endif

    call NvimTerminal#ShowStatusLine()
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
