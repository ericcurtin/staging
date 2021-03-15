function! VimBlame()
  let file = expand('%')
  let line = line('.')
  let type = &filetype
  tabnew
  execute "-1r! git blame " file
  execute line
  execute "setfiletype" type
endfunction

