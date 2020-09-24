# Move Fast

Use convenient, single-key presses to perform repetitive navigation - without remapping.

Enter movefast "mode", then use e.g. `h` and `l` to move - whether you are scrolling a buffer, navigating the buffer list, browsing a diff, stepping through quickfix entries or anything else that involves repetitive commands.
The plugin contains some built-in movements but is entirely extensible - build the movefast movements you need!

Examples (using the [built-in movements](#built-in-movements) below):

**Scrolling**: Instead of <kbd>Ctrl</kbd>+<kbd>d</kbd> <kbd>Ctrl</kbd>+<kbd>d</kbd> <kbd>Ctrl</kbd>+<kbd>u</kbd> <kbd>Ctrl</kbd>+<kbd>d</kbd>, use <kbd>Space</kbd><kbd>j</kbd><kbd>j</kbd><kbd>k</kbd><kbd>j</kbd>

**Tabbing**: Instead of <kbd>g</kbd><kbd>t</kbd> <kbd>g</kbd><kbd>t</kbd> <kbd>g</kbd><kbd>T</kbd> <kbd>g</kbd><kbd>t</kbd>, use <kbd>Space</kbd><kbd>t</kbd><kbd>l</kbd><kbd>l</kbd><kbd>h</kbd><kbd>l</kbd>

**Buffering**: To navigate buffer history for this window, use <kbd>Space</kbd><kbd>b</kbd><kbd>l</kbd><kbd>l</kbd><kbd>h</kbd><kbd>l</kbd>

Each of these demonstrates a mapping to enter movefast-mode and perform the first movement (<kbd>Space</kbd><kbd>j</kbd>, <kbd>Space</kbd><kbd>t</kbd><kbd>l</kbd>, <kbd>Space</kbd><kbd>b</kbd><kbd>l</kbd>), then repeated movements using <kbd>j</kbd>/<kbd>k</kbd> or <kbd>h</kbd>/<kbd>l</kbd>.

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

As there are no other options specified in the dictionary sent to `movefast#Init()`, the default `h`/`l` directions are used in this movement.
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

Any cursor movement other than a "direction" (`h`/`l`) completes the the movement.

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
| `cancel`     | An array of keys to use to complete the movement ([advanced](#Advanced-options))          | `['h', 'l']`                                 |
| `buffer`     | Flag indicating that this movement does not change buffer, allowing buffer-local mappings ([advanced](#Advanced-options)) | `1`          |
| `getchar`    | Flag forcing movefast to use [getchar()](http://vimhelp.appspot.com/eval.txt.html#getchar%28%29) to listen for movements, rather than mappings ([advanced](#Advanced-options)) | `1`               |

### Advanced options

There are 2 techniques used for reacting to movement directions: mappings and [getchar()](http://vimhelp.appspot.com/eval.txt.html#getchar%28%29).
They each have pros and cons.

By default, movements use mappings. To use `getchar` instead, use the `getchar: 1` option.

#### getchar()

After performing each movement, a [getchar()](http://vimhelp.appspot.com/eval.txt.html#getchar%28%29) call is made to listen for the next input key.
A direction key triggers another navigation, and any other key key completes the movement.

Pros:

- Any non-direction key can be used to complete a movement.

Cons:

- `getchar()` captures a keypress, meaning that it can't be used for anything else, e.g. a multi-key command or mapping. This means that a non-direction keypress is required to complete a movement **before** any multi-key commands can be input, which can be confusing. For example, after entering a movement, you may try to scroll to the top of the buffer with `gg` but the first `g` will be used to complete the motion, so Vim is left in operator-pending mode, waiting for the next key.
-  Vim remains in command-line mode, and the cursor is hidden, making it hard to keep track of where your last navigation has left you.

#### Mappings

Temporary mappings are created for the 2 directions, and removed again on movement completion.
If conflicting mappings exist, we fall back to "getchar" mode.

Detection of movement completion is more difficult with mappings, as we can't simply "listen" for any non-direction key, as we can with `getchar()`.
Instead, [CursorMoved](http://vimhelp.appspot.com/autocmd.txt.html#CursorMoved) and [InsertEnter](http://vimhelp.appspot.com/autocmd.txt.html#InsertEnter) autocmds are used to detect movement completion.
Additionally, a movement may be configured with extra "cancellation" mapping keys, using the `cancel: 1` option.
A use-case may be to allow `h` to always complete vertical scrolling, even when the cursor is on the first column (meaning `h` does not move the cursor and trigger a `CursorMoved` event).

Pros:

- A multi-key command or mapping can be used at any time.
- Vim remains in normal mode.

Cons:

- Complete existing mappings (e.g. `nnoremap l ll`) prevent a movement mapping from being made (fall back to "getchar mode").
- Partial existing mappings (e.g. `nnoremap ll 5l`) result in slow movements, as vim waits for `'timeoutlen'` before performing the navigation, in case another key of the existing mapping is entered.
- Cannot always determine when a movement is complete.

The first 2 cons may be resolved by using buffer-local mappings, as buffer mappings will override global mappings and can use the [<buffer>](http://vimhelp.appspot.com/map.txt.html#%3Amap-%3Cbuffer%3E) [<nowait>](http://vimhelp.appspot.com/map.txt.html#%3Amap-%3Cnowait%3E) modifiers.
However, buffer-local mappings will of course only work for movements which do not change buffer!
Buffer/tab/arg navigation movements cannot use buffer-local mappings, so of the 3 built-in movements, only scrolling uses buffer-local mappings.
Use the `buffer: 1` option to make a movement use buffer-local mappings.

## Built-in movements

Some movements are included in the plugin:

- Scroll: vertical (`<C-d>`/`<C-u>`) and horizontal (`zH`/`zL`) scrolling
- Tab: move through tabs with `gt` and `gT`
- Buffer: move through window-local or global buffer history

### Buffer history

The "scroll" and "tab" movements are simple movefast movements, but the buffer movement is more complicated.
The plugin maintains window-local buffer stacks, allowing navigation back and forth through the window history.
On movement completion, the final buffer is moved to the top of the history stack, and the buffer which initialised the movement becomes the "alternate" buffer (allowing [:h CTRL-^](http://vimhelp.appspot.com/editing.txt.html#CTRL-%5E) navigation).

Additionally, a global buffer history stack is maintained, allowing navigation through _all_ normal buffers, in order of last access.
Only "normal" buffers and help buffers are included in the history - not special buffers such as quickfix buffers.

Note that the buffer movement always starts from the top of the history stack, so there are no `<Plug>(movefast_buffer_next)`/`<Plug>(movefast_buffer_global_next)` maps.
It only makes sense to begin navigating _back_ through the history.

Should these history stacks be useful outside of vim-movefast, they are stored in variables `g:movefast_buffer_history` (global) and `w:movefast_buffer_history` (window).

### Built-in movement configuration

No mappings are provided automatically.
Add mappings in your .vimrc to add the movefast movements you are interested in:

```vim
" Default directions: 'h'/'l'
nmap <Space>bh <Plug>(movefast_buffer_prev)
nmap <Space>Bh <Plug>(movefast_buffer_global_prev)

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

| Movement                | Options variable               | Default `directions` |
|-------------------------|--------------------------------|----------------------|
| Buffer history (window) | `g:movefast_buffer`            | `['h', 'l']`         |
| Buffer history (global) | `g:movefast_buffer_global`     | `['h', 'l']`         |
| Vertical scroll         | `g:movefast_scroll`            | `['j', 'k']`         |
| Horizontal scroll       | `g:movefast_scroll_horizontal` | `['h', 'l']`         |
| Tab navigation          | `g:movefast_tab`               | `['h', 'l']`         |

Here are some customization examples:

```vim
" Use 'j' and 'k' for window-local buffer history navigation
let g:movefast_buffer = { 'directions': ['j', 'k'] }
" Use 'J' and 'K' for global buffer history navigation
let g:movefast_buffer_global = { 'directions': ['J', 'K'] }

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

" Initialize buffer history navigation with `oi`, and use `i`/`o` to
" continue
nmap oi <Plug>(movefast_buffer_prev)
let g:movefast_buffer = { 'directions': ['i', 'o'] }
```
