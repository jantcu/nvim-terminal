# Neovim Terminal (nvim-terminal) Vim Plugin

This Vim plugin provides a floating terminal window that can be toggled on and off.



https://github.com/user-attachments/assets/b145d861-affb-433c-bc64-5575d319b1fb



## Installation

Use a plugin manager like [vim-plug](https://github.com/junegunn/vim-plug) to install the plugin. Add the following to `~/.config/nvim/init.vim`:

```vim
Plug 'Jantcu/nvim-terminal'
```

Then `:PlugInstall`

## Usage

The default keyboard shortcuts are:
- Open/close small terminal: <kbd>Alt</kbd>-<kbd>t</kbd>
- Open/close large terminal: <kbd>Alt</kbd>-<kbd>z</kbd>
- Switch from terminal to main window: <kbd>Ctrl</kbd>-<kbd>w</kbd>+<kbd>k</kbd>
- Switch from main window to terminal: <kbd>Ctrl</kbd>-<kbd>w</kbd>+<kbd>j</kbd>
- Create new terminal when already in an opened terminal: <kbd>Alt</kbd>-<kbd>+</kbd>
- Remove terminal when already in an opened terminal: <kbd>Alt</kbd>-<kbd>-</kbd>
- Move to next terminal: <kbd>Alt</kbd>-<kbd>]</kbd>
- Move to previous terminal: <kbd>Alt</kbd>-<kbd>[</kbd>

## Configuration defaults

You can override these in `~/.config/nvim/init.vim`:
- `let g:nvim_terminal_toggle_small = '<A-t>'`
- `let g:nvim_terminal_toggle_large = '<A-z>'`
- `let g:nvim_terminal_background_color = '#171b21'`
- `let g:nvim_terminal_statusline_color = '#3fbbce'`
- `let g:nvim_terminal_small_height = 10`
- `let g:nvim_terminal_large_height = 50`

## Contributing

Feel free to open [issues](https://github.com/Jantcu/nvim-terminal/issues) if you have questions or run into problems, however, we likely won't be very responsive and may not fix issues. This is a project that fits the needs of our team and we just wanted to share it in case it was helpful to others in the current state that it's in. If you have bug fixes or feature requests, your best bet is to open a [PR](https://github.com/Jantcu/nvim-terminal/pulls).

## Similar projects

- https://github.com/akinsho/toggleterm.nvim
- https://github.com/rebelot/terminal.nvim
