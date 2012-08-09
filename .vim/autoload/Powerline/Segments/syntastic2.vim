let g:Powerline#Segments#syntastic2#segments = Pl#Segment#Init(['syntastic2',
	\ (exists('g:loaded_syntastic_plugin') && g:loaded_syntastic_plugin == 1),
	\
	\ Pl#Segment#Create('errors', '%{Powerline#Functions#syntastic2#GetErrors()}', Pl#Segment#Modes('!N'))
\ ])
