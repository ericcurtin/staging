set mouse=a
"set background=light
set background=dark
set hlsearch
set noswapfile
map <F4> :qa!<CR>
"map <F5> :%!xxd<CR>
map <F5> :call CurtineIncSw()<CR>
map <2-LeftMouse> *

"ERIC - map F12 to fold code
function! <SID>OutlineToggle()
  if (!exists ("b:outline_mode"))
    let b:outline_mode=0
    let b:OldMarker=&foldmarker
  endif

  if (b:outline_mode == 0)
    let b:outline_mode=1
    set foldmethod=marker
    set foldmarker={,}
  else
    let b:outline_mode=0
    set foldmethod=marker
    let &foldmarker=b:OldMarker
  endif

  execute "normal! zv"
endfunction
command! -nargs=0 OUTLINE call s:OutlineToggle()

map <silent> <F12> :OUTLINE<CR>

cscope add cscope.out
