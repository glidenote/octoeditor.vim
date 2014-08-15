" autoload/octoeditor.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.0.3
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

if !exists('g:octopress_post_suffix')
  let g:octopress_post_suffix = "markdown"
endif

if !exists('g:octopress_post_date')
  let g:octopress_post_date = "%Y-%m-%d %H:%M"
endif

if !exists('g:octopress_published')
  let g:octopress_published = 1
endif

if !exists('g:octopress_comments')
  let g:octopress_comments = 1
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

if !exists('g:octopress_unite_source')
  let g:octopress_unite_source = "file"
endif

if !exists('g:octopress_unite_option')
  let g:octopress_unite_option = ""
endif

if !exists('g:octopress_bundle_exec')
  let g:octopress_bundle_exec = 0
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
" functions for completing tags and categories
fun! octoeditor#completeTagsCategories(ArgLead, CmdLine, CursorPos) abort
  " tags & categories
  " this globpath will return full path
  return split(fnamemodify(globpath(g:octopress_path . "/public/blog/categories", a:ArgLead . "*"), ":t"), "\n")
endfun

function! octoeditor#list()
  if get(g:, 'octopress_vimfiler', 0) != 0
    exe "VimFiler" s:escarg(g:octopress_path) . "/source/_posts"
  elseif get(g:, 'octopress_unite', 0) != 0
    exe "Unite" g:octopress_unite_source.':'.s:escarg(g:octopress_path) ."/source/_posts" g:octopress_unite_option
  else
    exe "e" s:escarg(g:octopress_path) . "/source/_posts"
  endif
endfunction

function octoeditor#generate()
  if get(g:, 'octopress_bundle_exec', 0) != 0
    exe "!cd " s:escarg(g:octopress_path) . " && bundle exec rake generate "
  else
    exe "!cd " s:escarg(g:octopress_path) . " && rake generate "
  endif
endfunction

function octoeditor#deploy()
  exe "set noswapfile"
  if get(g:, 'octopress_bundle_exec', 0) != 0
    exe "!cd " s:escarg(g:octopress_path) . " && bundle exec rake gen_deploy "
  else
    exe "!cd " s:escarg(g:octopress_path) . " && rake gen_deploy "
  endif
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
      exe "Vimgrep -r" s:escarg(word) s:escarg(g:octopress_path . "/source/_posts/*")
    else
      exe "vimgrep" s:escarg(word) s:escarg(g:octopress_path . "/source/_posts/*")
    endif
    if get(g:, 'octopress_auto_open_results', 1) == 1
      copen
    endif
  catch
    redraw | echohl ErrorMsg | echo v:exception | echohl None
  endtry
endfunction

function! octoeditor#new(title)
  let items = {
  \ 'title': a:title,
  \ 'date':  localtime(),
  \ 'published': [],
  \ 'comments': [],
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

  if get(g:, 'octopress_published', 0) !=0
    let items['published'] = 'true'
  else
    let items['published'] = 'false'
  endif

  if get(g:, 'octopress_comments', 0) != 0
    let items['comments'] = 'true'
  else
    let items['comments'] = 'false'
  endif

  if get(g:, 'octopress_prompt_tags', 0) != 0
    let items['tags'] = join(split(input("Post tags: ", "", "customlist,octoeditor#completeTagsCategories"), '\s'), ' ')
  endif

  if get(g:, 'octopress_prompt_categories', 0) != 0
    let items['categories'] = join(split(input("Post categories: ", "", "customlist,octoeditor#completeTagsCategories"), '\s'), ' ')
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
  let old_undolevels = &undolevels
  set undolevels=-1
  call append(0, s:apply_template(template, items))
  let &undolevels = old_undolevels
  set nomodified

endfunction

function! octoeditor#fileup(file)
  let file = a:file
  if file == ''
    let file = input("UploadFile: ", "", "file")
  endif

  let file_name  = fnamemodify(file, ':t')
  let image_dir  = s:escarg("/images/" . strftime("%Y/%m/%d/"))
  let file_path  = s:escarg(g:octopress_path . "/source") . image_dir
  if !isdirectory(file_path)
    call mkdir(file_path, 'p')
  endif
  silent exe "!cp " . file . " " . file_path . file_name
  let img_tag = '\![{{title}}]({{src}})'
  let img_tag = substitute(img_tag, '{{title}}', file_name, '')
  let img_tag = substitute(img_tag, '{{src}}', image_dir . file_name, '')
  exe "read !echo '" . img_tag . "'"
  redraw!
endfunction

let s:default_template = [
\ '---' ,
\ 'layout: post',
\ 'title: "{{_title_}}"',
\ 'published: {{_published_}}',
\ 'date: {{_date_}}',
\ 'comments: {{_comments_}}',
\ 'tags: {{_tags_}}',
\ 'categories: {{_categories_}}',
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
