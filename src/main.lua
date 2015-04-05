local cli = require("cliargs")
local copas = require("copas")

local socket = require("socket")
local vstruct = require("vstruct")

cli:set_name("opc_server")
cli:add_flag("-v, --verbose", "Verbose output")
cli:add_option("-b, --backend=BACKEND", "Hardware backend to use", "console")
cli:add_option("-d, --device=DEVICE", "Device file backend should use", "")

if _arg == nil then
  _arg = arg
end

args = cli:parse(_arg)

-- (--help)
if args == nil then
  return
end

if args.verbose then
  print("Verbose output enabled.")
end

if args.backend ~= "console" then
  backend = require("backends." .. args.backend)
  backend:init(args.device)
end

function opc_handler(client, host, port)
  while 1 do
    local buf, err = client:receive(1)
    if err ~= nil then
local socket = require("socket")
      break
    end
    local chan = vstruct.readvals("u1", buf)
    if args.verbose then
      print("target is channel " .. chan)
    end

    buf, err = client:receive(1)
    if err ~= nil then
      break
    end
    local cmd = vstruct.readvals("u1", buf)
    if args.verbose then
      print("cmd is " .. cmd)
    end

    if cmd == 0 then
      err = set_colors(client, chan)
      if err ~= nil then
        break
      end
    elseif cmd == 255 then
      err = system_exclusive(client, chan)
      if err ~= nil then
        break
      end
    end
  end
end

function set_colors(client, chan) 
    local buf, err = client:receive(2)
    if err ~= nil then
      return err
    end
    local len = vstruct.readvals(">u2", buf)
    if args.verbose then
      print("len is " .. len)
    end

    buf, err = client:receive(len)
    if err ~= nil then
      return err
    end
    local pixels = vstruct.read(len/3 .. "*{ 3*u1 }", buf)

    if args.verbose or args.backend == "console" then
      print("first pixel")
      print("R: " .. pixels[1][1])
      print("G: " .. pixels[1][2])
      print("B: " .. pixels[1][3])
    end

    if args.backend ~= "console" then
      backend:set_pixels(pixels)
    end
end

copas.addserver(
  assert(socket.bind("*",7890)),
  function(c) return opc_handler(copas.wrap(c), c:getpeername()) end
)
copas.loop()
