fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal "yes"
lua54 'yes'

name 'tempest_emoji'
author 'TempestVMP (Tempest V)'
description 'Emoji menu on player head'
discord 'https://discord.gg/VJMtfknBx2'
version '1.0'

server_script 'server.lua'
client_scripts { 'config.lua', 'client.lua' }

ui_page "web/index.html"
files {
    'web/index.html',
    'web/app.js',
    'web/style.css',
    'web/images/*.png',
}
