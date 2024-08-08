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

## Configuration defaults

You can override these in `~/.config/nvim/init.vim`:
- `let g:nvim_terminal_background_color = '#171b21'`
- `let g:nvim_terminal_small_height = 10`
- `let g:nvim_terminal_large_height = 50`
