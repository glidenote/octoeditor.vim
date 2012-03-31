" opeditor.vim
" Maintainer:  Akira Maeda <glidenote@gmail.com>
" Version:  0.0.5
" See doc/opeditor.txt for instructions and usage.

" Code {{{1
" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if (exists("g:loaded_opeditor") && g:loaded_opeditor) || &cp
  finish
endif
let g:loaded_opeditor = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:opeditor_path')
  let g:opeditor_path = $HOME . "/octopress"
endif

command! -nargs=0 OctopressList :call opeditor#list()
command! -nargs=0 OctopressGenerate :call opeditor#generate()
command! -nargs=0 OctopressDeploy :call opeditor#gendeploy()
command! -nargs=? OctopressGrep :call opeditor#grep(<q-args>)
command! -nargs=? OctopressNew :call opeditor#new(<q-args>)

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
