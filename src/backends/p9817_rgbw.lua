local P9817_rgbw = {}

-- In RGBW mode we are overloading every other pixel to carry W data
function P9817_rgbw:init(device)
  self.vstruct = require("vstruct")
  if device == "" then
    device = "/dev/ttyACM0"
  end
  self.tty = io.open(device, "w")
  self.tty:setvbuf("no"); 

  print("P9817_rgbw backend initialized.")
end

function P9817_rgbw:set_pixels(pixels) 
  local buf = self.vstruct.write(#pixels .. "*{ 3*u1 }", nil, pixels)
  self.tty:write(buf)
  self.tty:flush()
end

return P9817_rgbw
