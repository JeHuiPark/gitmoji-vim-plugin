let s:emojiList = []

augroup gitmoji-list
  autocmd FileType gitcommit inoremap <C-j> <C-R>=GetGitmoji()<CR>
augroup END

function! GetGitmoji()
  let records = ReadRecord()

  if len(records) < 1
    return ''
  endif
  
  let popupDatas = []

  for record in records
    if record =~ '^"'
      continue
    endif
    let cols = split(record)
    call add(popupDatas, cols[0] . ' [' . cols[1] . ']')
    call add(s:emojiList, cols[0])
  endfor
  call Popup(popupDatas)
  return ""
endfunction

function! ReadRecord()
  
  if HasLocalConfig()
    return readfile(LocalConfigPath())
  endif

  if exists("g:gitmoji_config_path")
    return GlobalConfig()
  endif

  return []
endfunction

function! HasLocalConfig()
  let systemCommand = '[ -f ' . LocalConfigPath() .  ' ] && echo 1 || echo 0'
  return system(systemCommand)
endfunction

function! LocalConfigPath()
  let localFilePath = system('echo `git rev-parse --show-toplevel`/.gitmoji')
  return substitute(localFilePath, '\n', '', '')
endfunction

function! GlobalConfig()
  return readfile(expand(g:gitmoji_config_path))
endfunction

func HandleSelected(id, indexKey)
  call complete(col('.'), [s:emojiList[a:indexKey - 1]])
endfunc

func Popup(popupDatas)
  call popup_menu(a:popupDatas, #{ callback: 'HandleSelected' })
endfunc
