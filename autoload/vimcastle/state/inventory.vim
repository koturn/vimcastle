function! vimcastle#state#inventory#enter(state) abort
	let a:state.actions.enabled = 0
	call a:state.nav.add('s', 'Character Sheet', function('s:nav_character'))
	call a:state.nav.add('b', 'Back', function('s:nav_back'))
endfunction

function! s:nav_character(state) abort
	call a:state.enter('character')
	return 1
endfunction

function! s:nav_back(state) abort
	call a:state.enter('explore')
	return 1
endfunction
