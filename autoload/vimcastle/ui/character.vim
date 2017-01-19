function! vimcastle#ui#character#draw(screen, state) abort
	call vimcastle#ui#common#drawtitle(a:screen, "Character")
	call append(line('$'), '')

	call append(line('$'), '* Name: ' . a:state.player.name.long)
	call append(line('$'), '* Health: ' . a:state.player.health.current . '/' . a:state.player.health.max)
	call append(line('$'), '')

	call vimcastle#ui#common#drawbindings(a:state.nav)
endfunction
