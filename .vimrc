set mouse=a
"set background=light
set background=dark
syntax on
set backspace=indent,eol,start
set hlsearch
set noswapfile
set ruler
map <F4> :qa!<CR>
map <F3> /^-\\|^+<CR>
map <F5> :call CurtineIncSw()<CR>
map <F6> :call VimBlame()<CR>
map <2-LeftMouse> *
"map <F6> :<C-u>call gitblame#echo()<CR>

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

set nocscopeverbose
"if (!empty(glob("cscope.out")))
"  cs add cscope.out
"endif

"autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . expand("%"))

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

