fx_version 'bodacious'
game 'gta5'

ui_page 'nui/index.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'config/config.lua',
	'hansolo/hansolo.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'config/config.lua',
	'skywalker.lua'
}

files {
	'nui/index.html',
	'nui/jquery.js',
	'nui/css.css',
	'nui/images/*.png'
}