function! vimcastle#stories#main#plains#load(scene) abort
	let a:scene.label = 'Plains'
	let a:scene.enter = s:event_enter()
	call a:scene.events.add('nothing', 20, s:event_nothing())
	call a:scene.events.add('encounter', 20, s:event_encounter())
	call a:scene.events.add('heal', 4, s:event_heal())
	call a:scene.events.add('forestentrance', 2, s:event_forestentrance())
endfunction

function! s:event_enter() abort
	return vimcastle#event#create()
				\.text('You pack up your stuff and you are ready to go!')
				\.explore('Start walking forward')
endfunction

function! s:event_nothing()
	return vimcastle#event#create()
				\.text('You wander aimlessly...')
				\.text('You walk around...', 'You see... nothing.')
				\.text('Nope. Nothing.')
				\.explore('Continue')
endfunction

function! s:event_heal()
	return vimcastle#event#create()
				\.text('You see a pond of fresh water. You drink for it and feel refreshed.')
				\.text('You see an abandoned house. You rest in it for a little bit.', 'You see... nothing.')
				\.text( 'You see a camp, and decide to rest for a few minutes.')
				\.effect(function('s:effect_heal'))
				\.explore('Continue')
endfunction

function! s:effect_heal(state)
	let a:state.player.health.current = a:state.player.health.max
endfunction

function! s:event_encounter(state)
	return vimcastle#event#create()
				\.text('You encounter %e!')
				\.monsters(vimcastle#stories#main#plains#monsters#get())
				\.fight('Fight!')
endfunction

function! s:event_forestentrance()
	return vimcastle#event#create()
				\.text('You face a dense forest. you see movement in the dark.')
				\.monsters(vimcastle#stories#main#plains#monsters#get())
				\.enterscene('forest', 'Enter the forest')
				\.explore('Avoid the forest for now')
endfunction
