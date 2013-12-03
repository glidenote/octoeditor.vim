" octoeditor.vim
" Maintainer:  Akira Maeda <glidenote@gmail.com>
" Version:  0.0.3
" See doc/octoeditor.txt for instructions and usage.

" Code {{{1
" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if (exists("g:loaded_octoeditor") && g:loaded_octoeditor) || &cp
  finish
endif
let g:loaded_octoeditor = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:octopress_path')
  let g:octopress_path = $HOME . "/octopress"
endif

command! -nargs=0 OctopressList :call octoeditor#list()
command! -nargs=0 OctopressGenerate :call octoeditor#generate()
command! -nargs=0 OctopressDeploy :call octoeditor#deploy()
command! -nargs=? OctopressGrep :call octoeditor#grep(<q-args>)
command! -nargs=? OctopressNew :call octoeditor#new(<q-args>)
command! -nargs=? OctopressFileUp :call octoeditor#fileup(<q-args>)

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
