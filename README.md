fzf-ripgrep.vim
===============

A [fzf][fzf] + [ripgrep][rg] wrapper for vim ---
things you can do more with [fzf][fzf] and [ripgrep][rg] and (neo)vim.

[fzf.vim][fzf.vim] is a great plugin which integrates [fzf][fzf] into vim.
One of its great feature is `fzf#vim#grep`, or the `:Rg` command, but we should have a full-featured [ripgrep][rg] integration for fzf+vim.
This plugin adds [a bunch of batteries](#features) so that you can instantly jump to everywhere [ripgrep][rg] would suggest.


Features
--------

- [x] Always comes with fzf preview (toggle with `?`)
- [x] FZF matchs file contents only, not file names
- [x] <!-- Completion and --> cword expansion in vim commands (e.g. `*` for `<cword>`, `:Rg*`)
- [x] Aware of [NERDTree][nerdtree] and [NERDTreeTabs][nerdtree-tabs]: do not mess up them
- [x] Send the ripgrep result to the quickfix window (`<C-Q>`)
- [ ] Interactive, bidirectional communication between fzf and vim through RPC
- [ ] Support many flags (e.g., `-t`, `-u`) as the command-line `rg` does

Usage
-----

### Commands

| Command           | List                                                                    |
| ---               | ---                                                                     |
| `:Rg`             | Perform [rg][rg] search                                                 |

### Keybindings

- `CTRL-Q`: Send the current search result to the quickfix window.
- Common [fzf][fzf] key-bindings:
  - `CTRL-T` (new tab), `CTRL-X` (split), `CTRL-V` (vsplit)
  - `?` to toggle preview

### Advanced: as a vim function

TBD

<!--
- filetype (-t <type>)
- directory to perform ripgrep search
-->


### Installation

```vim
Plug 'wookayin/fzf-ripgrep.vim'
```


License
-------

The MIT License (c) 2020 Jongwook Choi (@wookayin)

[fzf]:            https://github.com/junegunn/fzf
[fzf.vim]:        https://github.com/junegunn/fzf.vim
[rg]:             https://github.com/BurntSushi/ripgrep
[nerdtree]:       https://github.com/scrooloose/nerdtree
[nerdtree-tabs]:  https://github.com/jistr/vim-nerdtree-tabs
