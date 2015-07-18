local Pca9685 = {}

Pca9685.I2C = require('periphery').I2C
Pca9685.DEFAULT_ADDR = 0x40
Pca9685.MODE1 = 0x00
Pca9685.MODE2 = 0x00
Pca9685.PRE_SCALE = 0xFE

Pca9685.LEDN_ON_L = function (N)
  return (0x06 + (4*N))
end
Pca9685.LEDN_ON_H = function (N) 
  return (0x07 + (4*N))
end
Pca9685.LEDN_OFF_L = function (N)
  return (0x08 + (4*N))
end
Pca9685.LEDN_OFF_H = function (N)
  return (0x09 + (4*N))
end


-- Mode 1
Pca9685.ALL_CALL = 0x01
Pca9685.SLEEP = 0x10
Pca9685.AUT_INC = 0x20
Pca9685.RESTART = 0x80

-- MOde 2
Pca9685.OUTDRV = 0x04


function Pca9685:init(device) 
  if device == "" then
    device = "/dev/i2c-0"
  end
  self.i2c = self.I2C(device)
  -- Set output mode to "totem pole" (non open drain)
  self.i2c:transfer(self.DEFAULT_ADDR, {{self.MODE2, self.OUTDRV}})

  -- Set prescaler to lowest value, for fastest pwm freq
  self.i2c:transfer(self.DEFAULT_ADDR, {{self.PRE_SCALE, 0x01}})

  self.i2c:transfer(self.DEFAULT_ADDR, {{self.MODE1, self.ALL_CALL + self.RESTART}})

  for i=0, 6, 1 do
    self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_ON_L(i), 0x00}})
    self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_ON_H(i), 0x00}})
  end

  print("pca9685 backend initialized.")
end

function Pca9685:set_pixels(pixels) 
  for j=1, 3, 1 do
    local pixel_h = math.floor((pixels[1][j]*16) / 256)
    local pixel_l = math.floor((pixels[1][j]*16) % 256)
    self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_OFF_H(j-1), pixel_h}})
    self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_OFF_L(j-1), pixel_l}})
  end
  if #pixels == 2 then
    for j=1, 3, 1 do
      local pixel_h = math.floor((pixels[2][j]*16) / 256)
      local pixel_l = math.floor((pixels[2][j]*16) % 256)
      self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_OFF_H(2+j), pixel_h}})
      self.i2c:transfer(self.DEFAULT_ADDR, {{self.LEDN_OFF_L(2+j), pixel_l}})
    end
  end
end

return Pca9685
