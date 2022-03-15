fx_version 'cerulean'
game 'gta5'

description 'NADRP-Garages'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@NADRP-core/shared/locale.lua',
    'locales/en.lua'   -- Choose your language from locales
}

client_script 'client/main.lua'

server_scripts {	
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'
