fx_version 'cerulean'

game 'gta5'

author 'TeamKillerPaul'
description 'Schneeball — Minispiel mit Schneeeffekten, werfbaren Schneebällen, Haltbarkeit und witterungsabhängigen Fahrzeugeffekten'
version '1.0'

client_scripts {
 'client.lua'
}

server_scripts {
 'server.lua'
}

shared_scripts {
    'config.lua'
}

dependencies {
    'ox_lib',
	'es_extended',
	'ox_inventory',
}
