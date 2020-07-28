# Move Fast

Use convenient, single-key presses to perform repetitive navigation - without remapping.

Enter movefast "mode", then use e.g. `h` and `l` to move - whether you are scrolling a buffer, navigating the buffer list, browsing a diff, stepping through quickfix entries or anything else that involves repetitive commands.
The plugin contains some built-in movements but is entirely extensible - build the movefast movements you need!

## Contents

- [Anatomy of a movement](#anatomy-of-a-movement)
- [Movement options](#movement-options)
- [Built-in movements](#built-in-movements)
    - [Buffer history](#buffer-history)
    - [Built-in movement configuration](#built-in-movement-configuration)

## Anatomy of a movement

Movements consist of 3 parts:

1. Initialization of the movement mode
2. Navigation within the mode
3. Completion of the movement

A mapping is used to begin initialization.
At its simplest, the mapping can call `movefast#Init()`, passing in an initial "direction" and a minimal options dictionary containing a `'next'` callback reference:

```vim
nnoremap <silent> hl :call movefast#Init('l', { 'next': 'ChangeArg' })<CR>
nnoremap <silent> lh :call movefast#Init('h', { 'next': 'ChangeArg' })<CR>
```

As their are no other options specified in the dictionary sent to `movefast#Next()`, the default `h`/`l` directions are used in this movement.
The callback then performs the actual navigation, it could look like this:

```vim
function! ChangeArg(direction)
  if a:direction ==# 'h'
    previous
  elseif a:direction ==# 'l'
    next
  endif
  redraw
endfunction
```

With these mappings and the `ChangeArg()` callback function, `hl` or `lh` will enter a "change arg" mode and `h` and `l` will continue navigating forwards and backwards through the argument list.

Any non-direction keypress completes the the movement.

## Movement options

All movefast movements are configured with an "options" dictionary.
Available options are:

| Option       | Description                                                                               | Examples                                     |
|--------------|-------------------------------------------------------------------------------------------|----------------------------------------------|
| `directions` | An array of direction keys                                                                | `['j', 'k']` <br> `["\<Left>","\<Right>"]`   |
| `title`      | The text to echo while in movefast mode                                                   | `'Scrolling...'`                             |
| `next`       | A funcref or function name to use to perform the movement, accepts a `direction` argument | `'ScrollNext'` <br> `function('ScrollNext')` |
| `oninit`     | A funcref or expression to evaluate before initialising a movement                        | `'let save_cursor = getcurpos()'`            |
| `onnext`     | A funcref or expression to evaluate after each movement `next`                            | `function('lightline#update')`               |
| `oncomplete` | A funcref or expression to evaluate after leaving movefast mode                           | `'call setpos('.', save_cursor)'`            |

## Built-in movements

Some movements are included in the plugin:

- Scroll: vertical (`<C-d>`/`<C-u>`) and horizontal (`zH`/`zL`) scrolling
- Tab: move through tabs with `gt` and `gT`
- Buffer: move through window-specific or global buffer history

### Buffer history

The "scroll" and "tab" movements are simple movefast movements, but the buffer movement is more complicated.
The plugin maintains window-local buffer lists, allowing navigation back and forth through the window history.
On movement completion, the final buffer is moved to the top of the history list, and the buffer which initialised the movement becomes the "alternate" buffer (allowing [:h CTRL-^](http://vimhelp.appspot.com/editing.txt.html#CTRL-%5E) navigation).

Additionally, a global buffer history list is maintained, allowing navigation through _all_ normal buffers, in order of last access.

Only "normal" buffers and help buffers are included in the history - not special buffers such as quickfix buffers.

### Built-in movement configuration

No mappings are provided automatically.
Add mappings in your .vimrc to add the movefast movements you are interested in:

```vim
" Default directions: 'h'/'l'
nmap <Space>bh <Plug>(movefast_buffer_prev)
nmap <Space>bl <Plug>(movefast_buffer_next)
nmap <Space>bH <Plug>(movefast_buffer_prev_global)
nmap <Space>bL <Plug>(movefast_buffer_next_global)

" Default directions: 'j'/'k'
nmap <Space>j <Plug>(movefast_scroll_down)
nmap <Space>k <Plug>(movefast_scroll_up)

" Default directions: 'h'/'l'
nmap <Space>h <Plug>(movefast_scroll_left)
nmap <Space>l <Plug>(movefast_scroll_right)

" Default directions: 'h'/'l'
nmap <Space>th <Plug>(movefast_tab_prev)
nmap <Space>tl <Plug>(movefast_tab_next)
```

These mappings work well with the default movefast `directions` for the built-in movements.
The options (see [Movement options](#movement-options) above) for these movements can be overridden using the following variables:

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

" Initialize buffer history navigation with `oi`/`io`, and use `i`/`o` to
" continue
nmap oi <Plug>(movefast_buffer_prev)
nmap io <Plug>(movefast_buffer_next)
let g:movefast_buffer = { 'directions': ['i', 'o'] }
```
