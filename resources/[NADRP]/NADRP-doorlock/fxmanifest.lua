fx_version 'cerulean'
game 'gta5'

description 'denalifw-Doorlock'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@denalifw-core/shared/locale.lua',
    'locales/en.lua' -- Change this to your preferred language
}

server_script 'server/main.lua'

client_script 'client/main.lua'