local Usbcdc = {}

function Usbcdc:init(device)
  self.vstruct = require("vstruct")
  if device == "" then
    device = "/dev/ttyACM0"
  end
  os.execute('stty -F ' .. device .. ' 115200 raw -iexten -echo -echoe -echok -echoctl')
  self.tty = io.open(device, "w")
  self.tty:setvbuf("no"); 

  print("Usbcdc rgbw backend initialized.")
end

-- FIXME In RGBW mode we are overloading every other pixel to carry W data
function Usbcdc:set_pixels(pixels) 
  local buf = self.vstruct.write("3*u1", nil, pixels[1])
  local buf2
  local buf3
  if #pixels == 2 then
    buf2 = self.vstruct.write("3*u1", nil, pixels[2])
    buf3 = self.vstruct.write("u1", nil, {0})
  elseif #pixels == 3 then
    buf2 = self.vstruct.write("3*u1", nil, pixels[2])
    buf3 = self.vstruct.write("u1", nil, {pixels[3][1]})
  else
    buf2 = self.vstruct.write("3*u1", nil, {0,0,0})
    buf3 = self.vstruct.write("u1", nil, {0})
  end
  self.tty:write(buf .. buf2 .. buf3)
  self.tty:flush()
end

return Usbcdc
