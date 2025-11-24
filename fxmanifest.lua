fx_version 'cerulean'
games {'gta5'}
lua54 'yes'
version '1.0.0'
author 'Kanoboot'
description 'Een utils scripts voor alle jobs en andere belangrijke functies'


shared_scripts {
    '@ox_core/lib/init.lua',
    'config.lua'
}

client_scripts {
    'bridge/client.lua',
    'client/**.lua',
    'shared/c-config.lua'
}

server_scripts {
    'bridge/server.lua',
    'server/**.lua',
    'shared/s-config.lua'
}

