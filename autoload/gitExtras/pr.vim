let s:pr_buffer = -1
let s:pr_root = ""

function! s:openPRBuffer(title, body, ...)
  if s:pr_buffer == -1
    let s:pr_root = getcwd()
    new
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal filetype=markdown
    setlocal noswapfile
    let s:pr_buffer = bufnr('%')
    file PR
    call appendbufline(s:pr_buffer, 0, a:title)
    let l:foundTemplate = 0
    for l:path in a:000
      let l:template = getcwd() . "/" . path
      if filereadable(l:template)
        execute '2read ' . l:template
        let l:foundTemplate = 1
        break
      endif
    endfor
    if l:foundTemplate == 0
      call appendbufline(s:pr_buffer, 2, a:body)
    endif
    $ " move to end of buffer
  else
    execute 'sbuffer ' . s:pr_buffer
  endif
endfunction

function! gitExtras#pr#create()
  let l:result = system('git log -1 --pretty=%B')
  if v:shell_error == 0
    let l:title = trim(l:result)
  else
    let l:title = "PR Title"
  endif
  call s:openPRBuffer(
          \ l:title,
          \ "PR Description",
          \ "pull_request_template.md",
          \ "PULL_REQUEST_TEMPLATE.md",
          \ "docs/PULL_REQUEST_TEMPLATE.md",
          \ "docs/pull_request_template.md",
          \ ".github/pull_request_template.md",
          \ ".github/PULL_REQUEST_TEMPLATE.md")
endfunction

function! s:resetPrBuffer()
  if s:pr_buffer > -1
    execute 'bwipeout ' . s:pr_buffer
    let s:pr_buffer = -1
  endif
endfunction()

function! gitExtras#pr#cancel()
  call s:resetPrBuffer()
endfunction()

function! gitExtras#pr#submit()
  if s:pr_buffer > -1
    execute 'buffer ' . s:pr_buffer
    execute 'lcd ' . s:pr_root

    let l:buffer = join(getline(1, '$'), "\n")
    let l:result = system('hub pull-request --push --message "' . l:buffer .'"')

    if v:shell_error == 0
      let l:pos = matchstrpos(l:result, "https://github.com/")[1]
      let l:link = trim(strpart(l:result, l:pos))
      echo(l:link . " created!")
    else
      echoerr(l:result)
    endif
    call s:resetPrBuffer()
  else
    echoerr("No PR Buffer open")
  endif
endfunction
