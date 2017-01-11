function! vimcastle#stories#main#index#begin(state) abort
	let a:state.scene = vimcastle#scene#load('main', 'plains')
	let a:state.player = vimcastle#character#create('Player', 'You', 60, vimcastle#stories#main#plains#weapons#get().rnd()())
endfunction
