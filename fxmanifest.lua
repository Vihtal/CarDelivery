fx_version 'adamant'

game 'gta5'

description 'ESX Vehicle Spawner'

author 'Hyp3R'

server_script { 
	'@mysql-async/lib/MySQL.lua',
}

server_scripts {
	'@es_extended/locale.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua'
}

server_script "config.lua"
client_script "config.lua"


dependencies {
	'es_extended'
}
