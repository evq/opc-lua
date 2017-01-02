local Lwdev = {}

function Lwdev:init(device)
  self.littlewire = require("littlewire")

  local littlewire_devices = self.littlewire.search()

  print("Found ", #littlewire_devices, " littlewire devices.\n")

  self.lw_dev = self.littlewire.connect()

  print("Connected to first device.")
  print("FW Version: ", self.littlewire.readFirmwareVersion(self.lw_dev), "\n")

  self.littlewire.quadPWM_state(self.lw_dev, 1)

  print("Littlewire rgbw backend initialized.")
end

-- FIXME In RGBW mode we are overloading every other pixel to carry W data
function Lwdev:set_pixels(pixels) 
  local w
  if #pixels == 2 then
    w = pixels[2][1]
  else
    w = 0
  end
  self.littlewire.quadPWM_write(self.lw_dev, pixels[1][1], pixels[1][2], pixels[1][3], w)
end

return Lwdev
