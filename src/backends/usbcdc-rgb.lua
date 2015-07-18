local Usbcdc = {}

function Usbcdc:init(device)
  self.vstruct = require("vstruct")
  if device == "" then
    device = "/dev/ttyACM0"
  end
  os.execute('stty -F ' .. device .. ' 115200 raw -iexten -echo -echoe -echok -echoctl')
  self.tty = io.open(device, "w")
  self.tty:setvbuf("no"); 

  print("Usbcdc backend initialized.")
end

function Usbcdc:set_pixels(pixels) 
  local buf = self.vstruct.write(#pixels .. "*{ 3*u1 }", nil, pixels)
  self.tty:write(buf)
  self.tty:flush()
end

return Usbcdc
