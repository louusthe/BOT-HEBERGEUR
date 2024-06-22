fx_version 'cerulean'

game 'gta5'
lua54 'yes'
version '1.0.0'

ui_page 'html_files/index.html'

shared_scripts { 
	'@es_extended/imports.lua',
	'@es_extended/locale.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'cfg_defibrillateur.lua',
	'sv_defibrillateur.lua'
}

client_scripts {
	'cfg_defibrillateur.lua',
	'cl_defibrillateur.lua',
}

files {
    'html_files/index.html',
    'html_files/style.css',
    'html_files/script.js',
	'html_files/defibrillateur.mp3',
}

dependencies {
    'ox_lib'
}

data_file 'DLC_ITYP_REQUEST' 'stream/defibrillateur_auto_ytyp.ytyp'