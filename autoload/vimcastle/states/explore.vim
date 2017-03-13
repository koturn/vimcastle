function! vimcastle#states#explore#create() abort
	let instance = {}
	let instance.enter = function('s:enter')
	let instance.action = function('s:action')
	return instance
endfunction

function! s:enter(game) abort dict
	return a:game.event.actions
endfunction

function! s:action(name, game) abort
	call a:game.event.action(a:name, a:game)
	return a:game.event.actions
endfunction

