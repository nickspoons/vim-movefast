# Move Fast

This plugin provides an extensible way of navigating in a repetitive fashion using single keys.

Some movements are included in the plugin:

- Buffer: window-specific lists of buffers are maintained, allowing navigation back through the window history
- Scroll: vertical (`<C-d>`/`<C-u>`) and horizontal (`zH`/`zL`) scrolling
- Tab: move through tabs with `gt` and `gT`

No mappings are provided automatically.
Add mappings in your .vimrc to add the movefast navigations you are interested in:

```vim
nmap <Space>bh <Plug>(movefast_buffer_prev)
nmap <Space>bl <Plug>(movefast_buffer_next)
nmap <Space>bH <Plug>(movefast_buffer_prev_global)
nmap <Space>bL <Plug>(movefast_buffer_next_global)

nmap <Space>j <Plug>(movefast_scroll_down)
nmap <Space>k <Plug>(movefast_scroll_up)
nmap <Space>h <Plug>(movefast_scroll_left)
nmap <Space>l <Plug>(movefast_scroll_right)

nmap <Space>th <Plug>(movefast_tab_prev)
nmap <Space>tl <Plug>(movefast_tab_next)
```

These mappings work well with the default movefast "directions" for these navigations.
The directions can be customised using these variables:

```vim
" Default movefast directions
let g:movefast_buffer_prev = 'h'
let g:movefast_buffer_next = 'l'

let g:movefast_scroll_down = 'j'
let g:movefast_scroll_up = 'k'
let g:movefast_scroll_left = 'h'
let g:movefast_scroll_right = 'l'

let g:movefast_tab_prev = 'h'
let g:movefast_tab_next = 'l'
```

To use the movefast buffer navigation with `<<`/`>>` to start navigating and `<`/`>` to continue, add this to your .vimrc:

```vim
nmap << <Plug>(movefast_buffer_prev)
nmap >> <Plug>(movefast_buffer_next)
let g:movefast_buffer_prev = '<'
let g:movefast_buffer_next = '>'
```
