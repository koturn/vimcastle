function! vimcastle#stories#main#intro#items#get() abort
	let repo = vimcastle#repository#create()

  call repo.add(1, {'label': 'Travel cookies (+10)', 'effect': 'heal', 'value': 10})
  call repo.add(3, {'label': 'Small healing potion (+30)', 'effect': 'heal', 'value': 30})

	return repo
endfunction
