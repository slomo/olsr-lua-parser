export LUA_PATH := $(PWD)/vstruct/?/init.lua;$(PWD)/vstruct/?.lua;$(PWD)/?.lua;/usr/share/lua/5.2/?.lua

test:
	lua test.lua
