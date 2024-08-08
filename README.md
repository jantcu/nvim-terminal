# Neovim Terminal (nvim-terminal) Vim Plugin

This Vim plugin provides a floating terminal window that can be toggled on and off.



https://github.com/user-attachments/assets/b145d861-affb-433c-bc64-5575d319b1fb



## Installation

Use a plugin manager like Vim-Plug to install the plugin:

```vim
Plug 'Jantcu/nvim-terminal'
```

Then `:PlugInstall`

## Configuration defaults

You can override these in `~/.config/nvim/init.vim`:
- `let g:term_toggle_background_color = '#171b21'`
- `let g:term_toggle_small_height = 10`
- `let g:term_toggle_large_height = 50`
