" =============================================================================
" File:          autoload/ctrlp/ag.vim
" Description:   Example extension for ctrlp.vim
" =============================================================================

if exists('g:loaded_ctrlp_ag') && g:loaded_ctrlp_ag
  finish
endif
let g:loaded_ctrlp_ag = 1


call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#ag#init(s:crbufnr)',
  \ 'accept': 'ctrlp#ag#accept',
  \ 'lname': 'ag',
  \ 'sname': 'ag',
  \ 'type': 'tabe',
  \ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

""  cal add(g:ctrlp_ext_vars, {
""    \ 'init': 'ctrlp#line#init(s:crbufnr)',
""    \ 'accept': 'ctrlp#line#accept',
""    \ 'lname': 'lines',
""    \ 'sname': 'lns',
""    \ 'type': 'tabe',
""    \ })

" Utilities {{{1
function! s:syntax()
  if !ctrlp#nosy()
    cal ctrlp#hicheck('CtrlPBufName', 'Directory')
    cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    sy match CtrlPBufName '\t|\zs[^|]\+\ze|\d\+:\d\+|$'
    sy match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
  endif
endfunction


function! ctrlp#ag#init(bufnr)
let [lines, bufnr] = [[], exists('s:bufnr') ? s:bufnr : a:bufnr]
let bufs = exists('s:lnmode') && s:lnmode ? ctrlp#buffers('id') : [bufnr]
for bufnr in bufs
  let [lfb, bufn] = [getbufline(bufnr, 1, '$'), bufname(bufnr)]
  if lfb == [] && bufn != ''
    let lfb = ctrlp#utils#readfile(fnamemodify(bufn, ':p'))
  endif
      cal map(lfb, 'tr(v:val, ''	'', '' '')')
  let [linenr, len_lfb] = [1, len(lfb)]
  let buft = bufn == '' ? '[No Name]' : fnamemodify(bufn, ':t')
  while linenr <= len_lfb
    let lfb[linenr - 1] .= '	|'.buft.'|'.bufnr.':'.linenr.'|'
    let linenr += 1
  endwhile
  cal extend(lines, filter(lfb, 'v:val !~ ''^\s*\t|[^|]\+|\d\+:\d\+|$'''))
endfor
cal s:syntax()
return lines
endfunction


function! ctrlp#ag#accept(mode, str)
  let info = matchlist(a:str, '\t|[^|]\+|\(\d\+\):\(\d\+\)|$')
  let bufnr = str2nr(get(info, 1))
  if bufnr
    cal ctrlp#acceptfile(a:mode, bufnr, get(info, 2))
  endif
endfunction




function! ctrlp#ag#cmd(mode, ...)
  let s:lnmode = a:mode
  if a:0 && !empty(a:1)
    let s:lnmode = 0
    let bname = a:1 =~# '^%$\|^#\d*$' ? expand(a:1) : a:1
    let s:bufnr = bufnr('^'.fnamemodify(bname, ':p').'$')
  endif
    retu s:id
endfunction
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
