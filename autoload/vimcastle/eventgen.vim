let s:EventgenClass = {}

function! vimcastle#eventgen#create(name) abort
	let eventgen = copy(s:EventgenClass)
	let eventgen.name = a:name
	let eventgen.texts = []
	return eventgen
endfunction

function! s:EventgenClass.text(texts) dict abort
	call add(self.texts, type(a:texts) == 1 ? [a:texts] : a:texts)
	return self
endfunction

function! s:EventgenClass.explore(text) dict abort
	let self.action_explore_text = a:text
	return self
endfunction

function! s:EventgenClass.fight(text, monsters) dict abort
	let self.monsters = a:monsters
	let self.action_fight_text = a:text
	return self
endfunction

function! s:EventgenClass.finditem(items) dict abort
	let self.items = a:items
	return self
endfunction

function! s:EventgenClass.findequippable(equippables) dict abort
	let self.equippables = a:equippables
	return self
endfunction

function! s:EventgenClass.enterscene(text, scene) dict abort
	let self.nextscene = a:scene
	let self.action_enterscene_text = a:text
	return self
endfunction

function! s:EventgenClass.before(fn) dict abort
	call vimcastle#utils#validate(a:fn, 2)
	let self.before_fn = a:fn
	return self
endfunction

function! s:EventgenClass.effect(name, value) dict abort
	let self.effect_name = a:name
	let self.effect_value = a:value
	return self
endfunction

function! s:EventgenClass.invoke(state) dict abort
	let a:state.stats.events += 1
	let event = vimcastle#event#create()

	if(exists('self.before_fn'))
		try
			call self.before_fn(a:state)
		catch
			throw 'There was an error in before fn of ' . a:state.scene.story . '/' . a:state.scene.name . '/' . self.name . ': ' . v:exception
		endtry
	endif

	" TODO: On event instead
	if(exists('self.monsters'))
		let a:state.enemy = self.monsters.rnd().invoke()
	endif

	" TODO: On event instead
	if(exists('self.items'))
		let a:state.ground_item = self.items.rnd()
	endif

	" TODO: On event instead
	if(exists('self.equippables'))
		let a:state.ground_equippable = self.equippables.rnd().invoke()
	endif

	call a:state.clearlog()
	for lineoptions in self.texts
		let line = vimcastle#utils#oneof(lineoptions)
		call add(a:state.log, a:state.msg(line))
	endfor

	if(exists('a:state.ground_equippable'))
		call s:showequippablediff(a:state)
	endif

	if(exists('self.effect_name'))
		let effect_value = exists('self.effect_value') ? self.effect_value : 0
		execute 'call vimcastle#effects#' . self.effect_name . '(a:state, effect_value)'
	endif

	call a:state.actions().clear()

	if(exists('self.action_fight_text') && exists('a:state.enemy'))
	call a:state.actions().add('fight', 'f', self.action_fight_text . ' (level ' . a:state.enemy.level . ')')
	endif

	if(exists('self.action_enterscene_text'))
		" NOTE: Cannot use arglist in 7.4
		" call a:state.actions().add('e', self.action_enterscene_text, function('s:action_enterscene', [self.nextscene]))
		let a:state.nextscene = self.nextscene
		let sceneinfo = {}
		execute 'let sceneinfo = vimcastle#stories#' . a:state.scene.story . '#' . a:state.nextscene . '#index#info()'
		call a:state.actions().add('enterscene', 'e', self.action_enterscene_text . ' (level ' . sceneinfo.level . ')')
	endif

	if(exists('a:state.ground_item'))
		call a:state.actions().add('pickup_item', 'p', 'Pick up')
	endif

	if(exists('a:state.ground_equippable'))
		call a:state.actions().add('equip_equippable', 'e', 'Equip')
	endif

	if(exists('self.action_explore_text'))
		call a:state.actions().add('explore', 'c', self.action_explore_text)
	endif

	if(!exists('self.action_fight_text'))
		call a:state.actions().add('inventory', 'i', 'Inventory')
		call a:state.actions().add('character', 's', 'Character Sheet')
	endif

	return event
endfunction

function! s:showequippablediff(state) abort
	if(has_key(a:state.player.equipment, a:state.ground_equippable.slot))
		let current = a:state.player.equipment[a:state.ground_equippable.slot]
	else
		let current = vimcastle#equippablegen#create(a:state.ground_equippable.slot, 0, 0)
	endif

	if(a:state.ground_equippable.slot ==# 'weapon')
		call s:showequippabledmg(a:state, current, a:state.ground_equippable)
	endif
	call s:showequippablestats(a:state, current, a:state.ground_equippable)
endfunction

function! s:showequippabledmg(state, current, ground) abort
	let msg = '  * dmg: ' . s:getdiff(a:current['dmg'].min, a:ground['dmg'].min) . ' - ' . s:getdiff(a:current['dmg'].max, a:ground['dmg'].max)
	call add(a:state.log, msg)
endfunction

function! s:showequippablestats(state, current, ground) abort
	let allstats = copy(a:ground.stats)
	for curkey in keys(a:current.stats)
		if(!has_key(allstats, curkey))
			let allstats[curkey] = a:current.stats[curkey]
		endif
	endfor
	for name in sort(keys(allstats))
		let currentval = has_key(a:current.stats, name) ? a:current.stats[name] : 0
		let groundval = has_key(a:ground.stats, name) ? a:ground.stats[name] : 0
		let msg = '  * ' . name . ': ' . s:getdiff(currentval, groundval)
	call add(a:state.log, msg)
	endfor
endfunction

function! s:getdiff(current, ground) abort
	if(a:ground > a:current)
		let diff = '+' . (a:ground - a:current)
	elseif(a:ground < a:current)
		let diff = '-' . (a:current - a:ground)
	else
		let diff = '='
	endif
	return a:ground . ' (' . diff . ')'
endfunction
