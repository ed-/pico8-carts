pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- defrag
-- slumberheart
function _init()
  cls()
  _mode = 0
  _frame = 0
  _shine = 1
  _size = 512
  _game = game:new{}
  _cells = cells:new{}
  _cells:init()
  add(_game.actors, _cells)
  add(_game.actors, bc:new{})
end

function _update()
  _frame = (_frame + 1) % 30
  if _frame % 5 == 0 then
    _shine += 1
    _shine = ((_shine - 1) % _size) + 1
  end
  if _mode == 0 then
    _game:update()
  else
  end
end

function _draw()
  cls()
  if _mode == 0 then
    _game:draw()
  else
  end
end


function i2xy(i)
  local j = ((i - 1) % _size) + 1
  local row = flr((j - 1) / 32)
  local col = ((j - 1) % 32)
  local x = col * 4
  local y = row * 8
  return x, y
end

class = {}
function class:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end

game = class:new{
  actors = {},
  cellarray = {},
}

function game:update()
  for actor in all(self.actors) do
    actor:update()
  end
end

function game:draw()
  --for i=1,128 do
  --  local x, y = i2xy(i)
  --  spr(16, x, y)
  --end
  for actor in all(self.actors) do
    actor:draw()
  end
end
-->8
-- cursor
bc = class:new{
  i = 1,
  width = 1,
  selected = nil,
  mode = 0,
}

function bc:update()
  if (self.mode == 0) then
    self:update_normal()
  elseif (self.mode == 1) then
    self:update_selecting()
  elseif (self.mode == 2) then
    self:update_selected()
  end
end

function bc:update_normal()
  if btnp(0) then
    self:left()
  end
  if btnp(1) then
    self:right()
  end
  if btnp(2) then
    self:up()
  end
  if btnp(3) then
    self:down()
  end
  if btnp(4) then
    self.selected = self.i
    self.mode = 1
  end
  if btnp(5) then
    self:cancel()
  end
end

function bc:update_selecting()
  if btnp(0) then
    self:narrower()
  end
  if btnp(1) then
    self:wider()
  end
  if btnp(4) then
    self.mode = 2
  end
  if btnp(5) then
    self:cancel()
  end
end

function bc:update_selected()
  if btnp(0) then
    self:left()
  end
  if btnp(1) then
    self:right()
  end
  if btnp(2) then
    self:up()
  end
  if btnp(3) then
    self:down()
  end
  if btnp(4) then
    self:swap()
  end
  if btnp(5) then
    self:cancel()
  end
end

function bc:draw()
  local x, y
  if self.selected != nil then
    if self.width == 1 then
     x, y = i2xy(self.selected)
     spr(17, x, y)
    else
      x, y = i2xy(self.selected)
      spr(18, x, y)
      x, y = i2xy(self.selected + self.width - 1)
      spr(20, x, y)
      for i=2,self.width-1 do
        x, y = i2xy(self.selected + i - 1)
        spr(19, x, y)
      end
    end
  end  
  

  for i=1,self.width do
  local x, y = i2xy(self.i + i - 1)
    spr(1, x, y)
  end
  
  --local v = _cells.z[self.i]
  --print(v, 0, 112)
end

function bc:left()
  self.i -= 1
  self.i = ((self.i - 1) % _size) + 1
end

function bc:right()
  self.i += 1
  self.i = ((self.i - 1) % _size) + 1
end

function bc:up()
  self.i -= 32
  self.i = ((self.i - 1) % _size) + 1
end

function bc:down()
  self.i += 32
  self.i = ((self.i - 1) % _size) + 1
end

function bc:wider()
  if (self.width < 32) then
    self.width += 1
  end
end

function bc:narrower()
  if (self.width > 1) then
    self.width -= 1
  end
end

function bc:swap()
  if (self.selected != nil) then
    _cells:swap(self.i, self.selected, self.width)
    self:cancel()
  end
  self:cancel()
end

function bc:cancel()
  self.selected = nil
  self.width = 1
  self.mode = 0
end
-->8
-- cells
cells = class:new{
  z = {},
}

function cells:init()
  local f = {}
  for i=1,_size do
    add(f, i)
  end
  while #f > 0 do
    local k = flr(rnd(#f + 1))
    local v = f[k]
    del(f, v)
    add(self.z, v)
  end
end

function cells:update()
end

function cells:draw()
  for i=1,#self.z do
    local x, y = i2xy(i)
    local s = 32
    local j = self.z[i]
    if i < j then
      s = 37
    elseif i > j then
      s = 41
    else
      s = 39
    end 
    if j == _shine then
      s += 1
    end
    spr(s, x, y)
  end
end

function cells:swap(from, to, width)
  local temp1 = {}
  local temp2 = {}
  for i=1,width do
    add(temp1, self.z[from + i - 1])
    add(temp2, self.z[to + i - 1])    
  end
  for i=1,width do
    self.z[to + i - 1] = temp1[i]
    self.z[from + i - 1] = temp2[i]
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000077000000777000077770000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000077000000777000077770000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000666600006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000600600006000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000600600006000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000600600006000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000600600006000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000666600006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0000ffff0000666600007777000000000000cccc000066660000bbbb000077770000cccc0000666600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c71c000067c60000b33b00007bb70000c17c00006c7600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c17c00006c760000b33b00007bb70000c71c000067c600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c11700006cc70000b33b00007bb70000711c00007cc600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c17c00006c760000b33b00007bb70000c71c000067c600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c71c000067c60000b33b00007bb70000c17c00006c7600000000000000000000000000000000000000000000
82280000e88e0000c11c00006cc6000000000000c11c00006cc60000b33b00007bb70000c11c00006cc600000000000000000000000000000000000000000000
88880000eeee0000cccc00006666000000000000cccc000066660000bbbb000077770000cccc0000666600000000000000000000000000000000000000000000
