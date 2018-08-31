pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- boilerplate
-- slumberheart

function _init()
  cls()
  _mode = 0
  _frame = 0
  _game = game:new{}
  add(_game.actors, button:new{key=0, label="⬅️", x=8 *  4, y=8 * 10})
  add(_game.actors, button:new{key=1, label="➡️", x=8 *  6, y=8 * 10})
  add(_game.actors, button:new{key=2, label="⬆️", x=8 *  5, y=8 *  9})
  add(_game.actors, button:new{key=3, label="⬇️", x=8 *  5, y=8 * 11})
  add(_game.actors, button:new{key=4, label="🅾️", x=8 *  9, y=8 * 10})
  add(_game.actors, button:new{key=5, label="❎", x=8 * 11, y=8 * 10})
  add(_game.actors, walker:new{})
  
  enable_mouse()
  add(_game.actors, mouse:new{})
end

function _update()
  _frame = (_frame + 1) % 30
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

class = {}
function class:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end
-->8
-- game
game = class:new{
  actors = {},
}

function game:update()
  for actor in all(self.actors) do
    actor:update()
  end
end

function game:draw()
  for actor in all(self.actors) do
    actor:draw()
  end
end

-->8
-- button
button = class:new{
  key = "",
  label = "",
  labelcolor = 5,
  x = 0,
  y = 0,
}

function button:update()
  if btn(self.key) then
    self.labelcolor = 7
  else
    self.labelcolor = 5
  end
end

function button:draw()
  print(self.label, self.x, self.y, self.labelcolor)
end

-->8
-- walker
walker = class:new{
  x = 0,
  y = 0,
}

function walker:update()
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
end

function walker:draw()
  spr(0, self.x * 8, self.y * 8)
end

function walker:left()
  if (self.x > 0) then
    self.x -= 1
  end
end

function walker:right()
  if (self.x < 15) then
    self.x += 1
  end
end

function walker:up()
  if (self.y > 0) then
    self.y -= 1
  end
end

function walker:down()
  if (self.y < 15) then
    self.y += 1
  end
end
-->8
-- mouse
mouse = class:new{
  x = 0,
  y = 0,
  click = 0
}

function enable_mouse()
  poke(0x5f2d, 1)
end

function mouse:update()
  self.x = stat(32) - 2
  self.y = stat(33) - 2
  self.click = stat(34)
end

function mouse:draw()
  spr(1, self.x, self.y)
end
__gfx__
00000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700567650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
