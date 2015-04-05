all: opc_server

opc_server: src/main.lua src/backends/*.lua
	lua utils/pack.lua src > opc_server.lua
	cd utils/LuaMinify && bash LuaMinify.sh ../../opc_server.lua ../../opc_server_min.lua
	echo '#!/usr/bin/env lua' > opc_server
	echo '_arg = arg' >> opc_server
	cat opc_server_min.lua >> opc_server
	chmod +x opc_server

clean:
	rm -f opc_server opc_server.lua opc_server_min.lua
