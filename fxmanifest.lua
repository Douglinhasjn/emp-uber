fx_version 'bodacious'
game 'gta5'

autor 'ZIRAFLIX'
description 'Esse sistema possui o básico de todas as funcionalidades necessários para um emprego de Uber. É possível tanto chamar um Uber quanto trabalhar de Uber. Além disso, notificações são enviadas constante para os motoristas enquanto houver passageiros precisando ser atendidos. Uma pequena interface foi pensada para melhorar a experiência do usuário. Ela se dá através de um pequeno console que acompanha o motorista em todo o percurso, desde aguardar algum chamado, até a finalização da corrida. Além disso, foi preparado um arquivo de configuração, para que você possa ajustar o script da maneira que achar melhor.'
version '1.0.0'
contact 'E-mail: contato@ziraflix.com - Discord: discord.gg/ziraflix'

ui_page 'nui/darkside.html'

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
	'nui/darkside.html',
	'nui/lightsaber.js',
	'nui/theforce.css',
	'nui/images/*.png'
}