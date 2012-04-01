" octeditor.vim
" Maintainer:  Akira Maeda <glidenote@gmail.com>
" Version:  0.0.5
" See doc/octeditor.txt for instructions and usage.

" Code {{{1
" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if (exists("g:loaded_octeditor") && g:loaded_octeditor) || &cp
  finish
endif
let g:loaded_octeditor = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:octeditor_path')
  let g:octeditor_path = $HOME . "/octopress"
endif

command! -nargs=0 OctopressList :call octeditor#list()
command! -nargs=0 OctopressGenerate :call octeditor#generate()
command! -nargs=0 OctopressDeploy :call octeditor#gendeploy()
command! -nargs=? OctopressGrep :call octeditor#grep(<q-args>)
command! -nargs=? OctopressNew :call octeditor#new(<q-args>)

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
