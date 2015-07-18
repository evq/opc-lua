local Usbcdc = {}
-- This is a hacky two pixel rgbw device :)

function Usbcdc:init(device)
  self.vstruct = require("vstruct")
  dev1 = "/dev/ttyACM0"
  dev2 = "/dev/ttyACM1"
  os.execute('stty -F ' .. dev1 .. ' 115200 raw -iexten -echo -echoe -echok -echoctl')
  os.execute('stty -F ' .. dev2 .. ' 115200 raw -iexten -echo -echoe -echok -echoctl')
  self.tty1 = io.open(dev1, "w")
  self.tty1:setvbuf("no"); 
  self.tty2 = io.open(dev2, "w")
  self.tty2:setvbuf("no"); 

  print("Usbcdc tube backend initialized.")
end

-- FIXME In RGBW mode we are overloading every other pixel to carry W data
function Usbcdc:set_pixels(pixels) 
  local buf = self.vstruct.write("3*u1", nil, pixels[1])
  local buf2 = self.vstruct.write("u1", nil, {pixels[2][1]})
  self.tty1:write(buf .. buf2)
  self.tty1:flush()
  buf = self.vstruct.write("3*u1", nil, pixels[3])
  buf2 = self.vstruct.write("u1", nil, {pixels[4][1]})
  self.tty2:write(buf .. buf2)
  self.tty2:flush()
end

return Usbcdc
