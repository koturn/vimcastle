let s:originalfolder =  '~/.vimcastle'
let s:folder = s:originalfolder
let s:savefile = 'save.dat'
let s:highscoresfile = 'highscores.csv'
let s:configfile = 'config.vim'
let s:crashfile = 'crash.log'
let s:enabled = 0

" Setup {{{

function! vimcastle#io#setup() abort
	let homedir = s:homedir()
	try
		if(!isdirectory(homedir))
			call mkdir(homedir, '')
		endif
		let s:enabled = 1
	catch
		echom 'Cannot access "' . homedir . '": ' . v:exception
		let s:enabled = 0
	endtry
	return s:enabled
endfunction

" }}}

" General {{{

function! vimcastle#io#enabled() abort
	return s:enabled
endfunction

function! vimcastle#io#path(fname) abort
	return s:homedir() . '/' . a:fname
endfunction

function! s:homedir() abort
	return expand(s:folder)
endfunction

" }}}

" Config {{{

function! vimcastle#io#config() abort
	let configfile = vimcastle#io#path(s:configfile)
	if(filereadable(configfile))
		execute 'source ' . configfile
	endif
endfunction

" }}}

" Save {{{

function! vimcastle#io#hassave() abort
	if(!s:enabled)
		return 0
	endif

	return filereadable(vimcastle#io#path(s:savefile))
endfunction

function! vimcastle#io#clearsave() abort
	if(!s:enabled)
		return 0
	endif

  if(vimcastle#io#hassave())
		return delete(vimcastle#io#path(s:savefile))
  endif
endfunction

function! vimcastle#io#save(data) abort
	if(!s:enabled)
		return 0
	endif

	call writefile([string(a:data)], vimcastle#io#path(s:savefile))
endfunction

function! vimcastle#io#load() abort
	if(!s:enabled)
		throw 'io is disabled'
	endif

	let str = readfile(vimcastle#io#path(s:savefile))
	let data = {}
	execute 'let data = ' . str[0]
	return data
endfunction

" }}}

" High Scores {{{

function! vimcastle#io#hashighscores() abort
	if(!s:enabled)
		return 0
	endif

	return filereadable(vimcastle#io#path(s:highscoresfile))
endfunction

function! vimcastle#io#clearhighscores() abort
	if(!s:enabled)
		return 0
	endif

  if(vimcastle#io#hashighscores())
		return delete(vimcastle#io#path(s:highscoresfile))
  endif
endfunction

function! vimcastle#io#savehighscores(data) abort
	if(!s:enabled)
		return 0
	endif

	call writefile(a:data, vimcastle#io#path(s:highscoresfile))
endfunction

function! vimcastle#io#loadhighscores() abort
	if(!s:enabled)
		throw 'io is disabled'
	endif

	if(!vimcastle#io#hashighscores())
		return []
	endif

	return readfile(vimcastle#io#path(s:highscoresfile))
endfunction

" }}}

" Crash {{{

function! vimcastle#io#savecrashlog(game, exception, callstack) abort
	try
		let crashfile = vimcastle#io#path(s:crashfile)
		let crashdata = []
		call add(crashdata, 'Error: ' . a:exception)
		call add(crashdata, 'Game: ' . string(a:game.save()))
		call add(crashdata, 'Callstack: ')
		let crashdata += a:callstack
		call writefile(crashdata, crashfile)
	catch
		echom 'Could not save crash log: ' . v:exception
	endtry
endfunction

" }}}

" Test methods {{{

function! vimcastle#io#before(path) abort
	if(a:path ==# '')
		let s:enabled = 0
	else
		let s:folder = a:path
		call vimcastle#io#setup()
	endif
endfunction

function! vimcastle#io#after() abort
	let s:folder = s:originalfolder
	let s:enabled = 0
endfunction

" }}}
