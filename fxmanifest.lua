fx_version 'cerulean'
game 'gta5'

description 'vtr-gardening'
version '1.0'
author 'github.com/ventraks'

client_scripts {
    '@PolyZone/client.lua',
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'PolyZone',
    'qb-target'
}
