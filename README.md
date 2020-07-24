# Move Fast

This plugin provides an extensible way of navigating in a repetitive fashion using single keys.

## Built-in movements

Some movements are included in the plugin:

- Buffer: window-specific lists of buffers are maintained, allowing navigation back through the window history
- Scroll: vertical (`<C-d>`/`<C-u>`) and horizontal (`zH`/`zL`) scrolling
- Tab: move through tabs with `gt` and `gT`

No mappings are provided automatically.
Add mappings in your .vimrc to add the movefast movements you are interested in:

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

These mappings work well with the default movefast `directions` for the built-in movements.
All movefast movements are configured with an "options" dictionary (see [Movement options](#movement-options) below).
The built-in movement options can be overridden using the following variables:

| Movement          | Options variable               | Default `directions` |
|-------------------|--------------------------------|----------------------|
| Buffer history    | `g:movefast_buffer`            | `['h', 'l']`         |
| Vertical scroll   | `g:movefast_scroll`            | `['j', 'k']`         |
| Horizontal scroll | `g:movefast_scroll_horizontal` | `['h', 'l']`         |
| Tab navigation    | `g:movefast_tab`               | `['h', 'l']`         |

Here are some customization examples:

```vim
" Use 'j' and 'k' for buffer history navigation
let g:movefast_buffer = { 'directions': ['j', 'k'] }

" Use arrow keys and custom titles for scrolling, and update vim-lightline
" statusline after each movement
let g:movefast_scroll = {
\ 'directions': ["\<Down>", "\<Up>"],
\ 'title': 'Scrolling...',
\ 'onnext': function('lightline#update')
\}
let g:movefast_scroll_horizontal = {
\ 'directions': ["\<Left>", "\<Right>"],
\ 'title': 'Scrolling side-to-side...',
\ 'onnext': function('lightline#update')
\}

" Initialize buffer history navigation with `<<`/`>>`, and use `<`/`>` to
" continue
nmap << <Plug>(movefast_buffer_prev)
nmap >> <Plug>(movefast_buffer_next)
let g:movefast_buffer = { 'directions': ['<', '>'] }
```

## Movement options

An "options" dictionary is used to configure movefast movements.
Available options are:

| Option | Description | Examples |
|-|-|-|
| `directions` | An array of direction keys | `['j', 'k']` <br> `["\<Left>","\<Right>"]` |
| `title` | The text to echo while in movefast mode | `'Scrolling...'` |
| `next` | A funcref referencing the function to use to perform the movement, accepts a `direction` argument | `function('ScrollNext')` |
| `oninit` | A funcref or expression to evaluate before initialising a movement | `'let save_cursor = getcurpos()'` |
| `onnext` | A funcref or expression to evaluate after each movement `next` | `function('lightline#update')` |
| `oncomplete` | A funcref or expression to evaluate after leaving movefast mode | `'call setpos('.', save_cursor)'` |

## Custom movements

... documentation coming soon
