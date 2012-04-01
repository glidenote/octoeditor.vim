" autoload/octoeditor.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.0.0
" Install this file as autoload/octoeditor.vim.  This file is sourced manually by
" plugin/octoeditor.vim.  It is in autoload directory to allow for future usage of
" Vim 7's autoload feature.

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if &cp || exists("g:autoloaded_octoeditor")
  finish
endif
let g:autoloaded_octoeditor= '1'

let s:cpo_save = &cpo
set cpo&vim

" Utility Functions {{{1
function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
endfunction
" }}}1

if !exists('g:octopress_path')
  let g:octopress_path = $HOME . "/octopress"
endif

if !exists('g:octopress_post_suffix')
  let g:octopress_post_suffix = "markdown"
endif

if !exists('g:octopress_post_date')
  let g:octopress_post_date = "%Y-%m-%d %H:%M"
endif

if !exists('g:octopress_title_pattern')
  let g:octopress_title_pattern = "[ '\"]"
endif

if !exists('g:octopress_prompt_tags')
  let g:octopress_prompt_tags = ""
endif

if !exists('g:octopress_prompt_categories')
  let g:octopress_prompt_categories = ""
endif

if !exists('g:octopress_template_dir_path')
  let g:octopress_template_dir_path = ""
endif

function! s:esctitle(str)
  let str = a:str
  let str = tolower(str)
  let str = substitute(str, g:octopress_title_pattern, '-', 'g')
  let str = substitute(str, '\(--\)\+', '-', 'g')
  let str = substitute(str, '\(^-\|-$\)', '', 'g')
  return str
endfunction

function! s:escarg(s)
  return escape(a:s, ' ')
endfunction

let g:octopress_path = expand(g:octopress_path, ':p')
if !isdirectory(g:octopress_path)
  call mkdir(g:octopress_path, 'p')
endif

"------------------------
" function
"------------------------
function! octoeditor#list()
  if get(g:, 'octopress_vimfiler', 0) != 0
    exe "VimFiler" s:escarg(g:octopress_path) . "/source/_posts"
  else
    exe "e" s:escarg(g:octopress_path) . "/source/_posts"
  endif
endfunction

function octoeditor#generate()
  exe "!cd " s:escarg(g:octopress_path) . " && rake generate "
endfunction

function octoeditor#deploy()
  exe "!cd " s:escarg(g:octopress_path) . " && rake gen_deploy "
endfunction

function! octoeditor#grep(word)
  let word = a:word
  if word == ''
    let word = input("OctopressGrep word: ")
  endif
  if word == ''
    return
  endif

  try
    if get(g:, 'octopress_qfixgrep', 0) != 0
      exe "Vimgrep" s:escarg(word) s:escarg(g:octopress_path . "/source/_posts/*")
    else
      exe "vimgrep" s:escarg(word) s:escarg(g:octopress_path . "/source/_posts/*")
    endif
  catch
    redraw | echohl ErrorMsg | echo v:exception | echohl None
  endtry
endfunction

function! octoeditor#new(title)
  let items = {
  \ 'title': a:title,
  \ 'date':  localtime(),
  \ 'tags':  [],
  \ 'categories':  [],
  \}

  if g:octopress_post_date != 'epoch'
    let items['date'] = strftime(g:octopress_post_date)
  endif
  if items['title'] == ''
    let items['title']= input("Post title: ", "")
  endif
  if items['title'] == ''
    return
  endif

  if get(g:, 'octopress_prompt_tags', 0) != 0
    let items['tags'] = join(split(input("Post tags: "), '\s'), ' ')
  endif

  if get(g:, 'octopress_prompt_categories', 0) != 0
    let items['categories'] = join(split(input("Post categories: "), '\s'), ' ')
  endif

  let file_name = strftime("%Y-%m-%d-") . s:esctitle(items['title']) . "." . g:octopress_post_suffix

  echo "Making that Post " . file_name
  exe (&l:modified ? "sp" : "e") s:escarg(g:octopress_path . "/source/_posts/" . file_name)

  " Post template
  let template = s:default_template
  if g:octopress_template_dir_path != ""
    let path = expand(g:octopress_template_dir_path, ":p")
    let path = path . "/" . g:octopress_post_suffix . ".txt"
    if filereadable(path)
      let template = readfile(path, 'b')
    endif
  endif
  " apply template
  let err = append(0, s:apply_template(template, items))

endfunction

let s:default_template = [
\ '---' ,
\ 'layout: post',
\ 'title: {{_title_}}',
\ 'published: true',
\ 'date: {{_date_}}',
\ 'tags: [{{_tags_}}]',
\ 'categories: [{{_categories_}}]',
\ '---',
\]

function! s:apply_template(template, items)
  let mx = '{{_\(\w\+\)_}}'
  return map(copy(a:template), "
  \  substitute(v:val, mx,
  \   '\\=has_key(a:items, submatch(1)) ? a:items[submatch(1)] : submatch(0)', 'g')
  \")
endfunction

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
