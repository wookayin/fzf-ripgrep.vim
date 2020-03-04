" Copyright (c) 2020 Jongwook Choi
"
" MIT License


let s:cpo_save = &cpo
set cpo&vim


" -------------------
" Common & Utilities
" -------------------

" Utility functions brought from @junegunn/fzf.vim {{{
" https://github.com/junegunn/fzf.vim
" Copyright (c) Junegunn Choi, under MIT License
function! s:get_color(attr, ...)
  let gui = has('termguicolors') && &termguicolors
  let fam = gui ? 'gui' : 'cterm'
  let pat = gui ? '^#[a-f0-9]\+' : '^[0-9]\+$'
  for group in a:000
    let code = synIDattr(synIDtrans(hlID(group)), a:attr, fam)
    if code =~? pat
      return code
    endif
  endfor
  return ''
endfunction

let s:ansi = {'black': 30, 'red': 31, 'green': 32, 'yellow': 33, 'blue': 34, 'magenta': 35, 'cyan': 36}

function! s:csi(color, fg)
  let prefix = a:fg ? '38;' : '48;'
  if a:color[0] == '#'
    return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
  endif
  return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...)
  let fg = s:get_color('fg', a:group)
  let bg = s:get_color('bg', a:group)
  let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
        \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
  return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

for s:color_name in keys(s:ansi)
  execute "function! s:".s:color_name."(str, ...)\n"
        \ "  return s:ansi(a:str, get(a:, 1, ''), '".s:color_name."')\n"
        \ "endfunction"
endfor
" }}}


" -------------------
" Core Implementation
" -------------------

function! fzf#vim#ripgrep#rg(search_pattern, ...) abort
  " search_pattern: query to ripgrep. star(*) must have already been resolved
  let l:opts = get(a:, '1', {})
  let l:fullscreen = get(l:opts, 'fullscreen', 0)
  let l:prompt_name = get(l:opts, 'prompt_name', 'Rg')
  let l:prompt_query = get(l:opts, 'prompt_query', a:search_pattern)
  let l:rg_additional_arg = get(l:opts, 'rg_additional_arg', '')

  let fzf_opts_prompt = ['--prompt', printf(l:prompt_name.'%s> ', empty(l:prompt_query) ? '' : (' ('.l:prompt_query.')'))]
  let fzf_opts_header = ['--ansi', '--header',
        \ ':: Press '.s:magenta('?', 'Special').' to toggle preview, '
        \ . (!empty(a:search_pattern) ? s:magenta('CTRL-Q', 'Special').' to switch to quickfix' : '')
        \ .nr2char(10). '   To refresh ripgrep results rather than fuzzy-filtering, try '.s:magenta(':RG', 'Special').' instead.'
        \ ]
  let fzf_opts_contentsonly = ['--delimiter', ':', '--nth', '4..']   " fzf.vim#346
  let fzf_opts = fzf_opts_prompt + fzf_opts_header + fzf_opts_contentsonly

  " Set search path for ripgrep, if nerdtree tree/explorer is shown
  let l:target_directory = (&filetype == 'nerdtree' ? b:NERDTree.root.path._str() : '')
  let l:rg_path_args = !empty(l:target_directory) ? shellescape(l:target_directory) : ''
  if &filetype == 'nerdtree' && bufname('%') == get(t:, 'NERDTreeBufName', '')
    wincmd w   " we need to move the focus out of the pinned nerdtree buffer
  endif

  " Invoke ripgrep through fzf
  let rg_command = 'rg -i --column --line-number --no-heading --color=always '.l:rg_additional_arg.' '.shellescape(a:search_pattern).' '.l:rg_path_args
  call fzf#vim#grep(rg_command, 1,
        \ l:fullscreen ? fzf#vim#with_preview({'options': fzf_opts}, 'up:60%')
        \              : fzf#vim#with_preview({'options': fzf_opts}, 'right:50%', '?'),
        \ l:fullscreen)
  call s:fzfrg_bind_keymappings(a:search_pattern, l:rg_additional_arg)        " TODO directory???
endfunction


function! s:fzfrg_bind_keymappings(query, rg_options) abort
  " additional keymappings on the fzf window (e.g. move to quickfix)
  " Args:
  " - query: the rg pattern string (will be escaped inside)
  " - rg_options: additional flags passed to rg (passed to shell as-is)
  let t:FzfRg_last_query = a:query
  let t:FzfRg_last_options = a:rg_options
  if !empty(t:FzfRg_last_query)
    " CTRL-Q (unless query is empty) -> call rg again into the quickfix
    tnoremap <silent> <buffer> <C-q>    <C-\><C-n>:call timer_start(0, {
          \ -> ag#Ag('grep!', "-i " . shellescape(t:FzfRg_last_query) . " " . t:FzfRg_last_options)
          \ })<CR>:q<CR>
  endif
endfunction



function! fzf#vim#ripgrep#rgdef(query, ...) abort
  let l:opts = get(a:, '1', {})
  let l:fullscreen = get(l:opts, 'fullscreen', 0)
  " TODO: currently, only python is supported.
  let rgdef_type = '--type "py"'
  let rgdef_prefix = '^\s*(def|class)'
  let rgdef_pattern = rgdef_prefix.' \w*'.a:query.'\w*'

  " if the query itself starts with prefix patterns, let itself be the regex pattern
  if a:query =~ ('\v'.rgdef_prefix.'($|\s+)')
    let rgdef_pattern = '^\s*'.a:query
  endif

  return fzf#vim#ripgrep#rg(rgdef_pattern, {
        \ 'fullscreen': l:fullscreen,
        \ 'prompt_name': 'RgDef', 'prompt_query': a:query,
        \ 'rg_additional_arg': rgdef_type })
endfunction


" ------------------------------------------------------------------
let &cpo = s:cpo_save
unlet s:cpo_save
