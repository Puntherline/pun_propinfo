fx_version "cerulean"
game "gta5"

author "Puntherline"
description "The successor to pun_idgun!"
version "1.0"

ui_page "html/index.html"

files {
	"html/stylesheet.css",
	"html/javascript.js",
	"html/index.html"
}

server_scripts {
	"config.lua",
	"server/sv_main.lua"
}

client_scripts {
	"client/proplist.lua",
	"client/cl_main.lua"
}