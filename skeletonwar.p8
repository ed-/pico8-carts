pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- skeletonwar
-- slumberheart

--[[

if your grave doesnt say "rest
in peace" on it you are
automatically drafted into the
skeleton war

- @dril

]]

function _init()
  cls()
  _mode = 0
  _frame = 0
  _game = game:new()
  _game:reset()
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
    draw(game)
  else
  end
end
function update(something)
  something:update()
end

function draw(something)
  something:draw()
end
-->8
-- game
game = {
  actors = {},
  players = {},
}

function game:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end

function game:reset()
  add(self.players, warrior:new{})

  for i=1,#self.players do
    add(self.actors, self.players[i])
  end
  for i=1,0 do
    add(self.actors, skeleton:new{
      x=flr(rnd(120)),
      y=flr(rnd(120)),})
  end
end
 
function game:update()
  foreach(self.actors, update)
end

function game:draw()
  foreach(self.actors, draw)
end
-->8
--actor
actor = {
  dx = 0,
  dy = 0,
  maxd = 1,
  x = 0,
  y = 0,
  sprites = {0},
  state = 1,
  facingleft = false,
  faction = nil,
  clock = 0,
  hp = 1,
}
--[[ actor states
1 move
2 move alternate
3 attack

--]]

function actor:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end

function actor:update()
  if _frame % 15 == 0 then
    self.clock += 1
  end
  self:act()
end

function actor:act()
  local _player = game.players[1]
  local dx = self.x - _player.x
  local dy = self.y - _player.y
  local d = sqrt((dx * dx) + (dy * dy))
  local oldd = self.maxd
  if d < 6 then 
    self:act_close(dx, dy)
  elseif d < 30 then
    self.maxd *= 2
    self:act_mid(dx, dy)
  elseif d < 80 then
    self:act_mid(dx, dy)
  else
    self:act_far(dx, dy)
  end
  self.maxd = oldd
end

function actor:act_close(dx, dy)
  self:stand()
end

function actor:act_mid(dx, dy)
  self:stand()
  dx += flr(rnd(5)) - 2
  dy += flr(rnd(5)) - 2
  if dx < 0 then
    self:right()
  elseif dx > 0 then
    self:left()
  end
  if dy < 0 then
    self:down()
  elseif dy > 0 then
    self:up()
  end
  self:move()
end

function actor:act_far(dx, dy)
  local lr = flr(rnd(3)) - 1
  local ud = flr(rnd(3)) - 1
  self:stand()
  if lr < 0 then
    self:left()
  elseif lr > 0 then
    self:right()
  end
  if ud < 0 then
    self:up()
  elseif ud > 0 then
    self:down()
  end
  self:move()
end

function actor:move()
  if self.dx > self.maxd then
    self.dx = self.maxd
  end
  if self.dx < 0 - self.maxd then
    self.dx = 0 - self.maxd
  end
  self.x += self.dx
  if self.x >= 120 then
    self.x = 120
  end
  if self.x < 0 then
    self.x = 0
  end

  if self.dy > self.maxd then
    self.dy = self.maxd
  end
  if self.dy < 0 - self.maxd then
    self.dy = 0 - self.maxd
  end 
  self.y += self.dy
  if self.y >= 120 then
    self.y = 120
  end
  if self.y < 0 then
    self.y = 0
  end
end

function actor:left()
  self.dx = 0 - self.maxd
  self.facingleft = true
end

function actor:right()
  self.dx = self.maxd
  self.facingleft = false
end

function actor:up()
  self.dy = 0 - self.maxd
end

function actor:down()
  self.dy = self.maxd
end

function actor:stand()
  self.dx = 0
  self.dy = 0
end

function actor:draw()
  local sprite = self.sprites[self.state]    
  spr(sprite, self.x, self.y, 1, 1, self.facingleft)
end
-->8
-- warrior
warrior = actor:new{
  faction = "player",
  sprites = {1, 2},
  maxd = 4,
  hp = 4,
  slashing = 0
}

function warrior:update()
  local do_decay = true
  if btn(0) then
    self:left()
    do_decay = false
  end
  if btn(1) then
    self:right()
    do_decay = false
  end
  if btn(2) then
    self:up()
    do_decay = false
  end
  if btn(3) then
    self:down()
    do_decay = false
  end
  
  self.slashing = max(0, self.slashing - 1)
  if self.slashing <= 0 and btnp(4) then
    self.slashing = 5
  end
  self.state = 1
  if self.slashing > 0 then
    self.state = 2
  end
    
  if do_decay then
    if self.dx < 0 then
      self.dx += 1
    elseif self.dx > 0 then
      self.dx -= 1
    end
    if self.dy < 0 then
      self.dy += 1
    elseif self.dy > 0 then
      self.dy -= 1
    end
  end
  self:move()
end

function warrior:left()
  self.dx -= 1
  self.facingleft = true
end

function warrior:right()
  self.dx += 1
  self.facingleft = false
end

function warrior:up()
  self.dy -= 1
end

function warrior:down()
  self.dy += 1
end
    
function warrior:move()
  self.lastx = self.x
  self.lasty = self.y
  actor.move(self)
end

function warrior:draw()
  actor.draw(self)
  local slash = self.slashing
  if slash > 0 then
    local s = 7
    if slash < 5 then
      s = 9
    end
    if slash < 3 then
      s = 11
    end
    spr(s, self.x - 4, self.y - 4, 2, 2, self.facingleft, false)
  end
  --actor.draw(self)
end
-->8
--skeleton
skeleton = actor:new{
  sprites = {17},
  faction = "skeleton",
}
__gfx__
0000000000660000000660000000000000000000000000000ccc00000000007ccc000000000000cccc000000000000cccc000000000000cccc00000000000000
00000000066660600066660000000000000000000056650000ccc00000000077cccc00000000cccccccc00000000cccccccc00000000cccccccc000000000000
007007000526206000526200000000000000000000077000000ccc0000000007ccccc000000cccccccccc000000cccccccccc000000cccccccccc00000000000
0007700005fff070005fff00000000000000000000022000000cccc000000007cccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000000000
00077000541145f50541145f0000000000000000002e98007cccccc000000007000cccc00cc00cccccccccc00cc00cccccccccc00cc00cc00cccccc000000000
00700700f1161050f5116100000000000000000002e98880077cccc00000000770000cc00000000cccccccc00000000cccccccc00000000000ccccc000000000
00000000044440000044440000000000000000000088880000077cc000000000700000c00000000ccccccccc0000000ccccccccc0000000000cccccc00000000
000000000500500000500500000000000000000000000000000007c0000000007000000000000000cccccccc00000000cccccccc0000000000cccccc00000000
000000000006600000660000000000000000000000000000000000000000000000000000000000007777777c00000000cccccccc000000000000cccc00000000
000000000067770006777060000000000000000000000000000000000000000000000000000000077777777700000007cccccccc0000000700cccccc00000000
000000000068780006878060000000000000000000000000000000000000000000000000000000000000000000000077ccccccc00000007700ccccc000000000
00000000000777000077706000000000000000000005500000000000000000000000000000000000000000000000077cccccccc00000077cc0ccccc000000000
0000000006566560656656700000000000000000005666000000000000000000000000000000000000000000000077cccccccc00000077cccccccc0000000000
0000000007ddad707ddad060000000000000000000526200000000000000000000000000000000000000000000077cccccccc00000077cccccccc00000000000
0000000000555500055550000000000000000000000666000000000000000000000000000000000000000000000000cccccc0000000000cccccc000000000000
00000000006006000600600000000000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000ccc00000000000000
00660040006600000066000000660000006600000066000000660000006600404066040000a0a000006600000000000000000000000000000000000000000000
0677700406777040067770600677700006777000067770000677700006777040467774000aaaa000067770600000000000000000000000000000000000000000
06878004068780400687806006878000068780000687800006878000068780400687800006878000068780660000000000000000000000000000000000000000
00777004007770400077706000777000007770000077222200777000007770400077700000777000007770060000000000000000000000000000000000000000
3bbbb3741cccc17065665670cccccc0022222200444422d24444447099dd997052222500111111005555557d0000000000000000000000000000000000000000
7dd6d0047ccac0407ddad0607dd6dc70711d147071192d2d71191400799990407cccc700677c7660d76d67000000000000000000000000000000000000000000
0bbbb0040cccc040055550000cccc0002444420046662222466664000444404001cc105046666400566665000000000000000000000000000000000000000000
05005040c5cc504006006000c5cc5c00250052004500522045005400050050400500500645445400550055000000000000000000000000000000000000000000
000000000000330004000000000000000000000000000000a094090000000000a094090000000000000000000000000000000000000000000000000000000000
000000000003abb00440bb0000000000000000000066660094666640006666009466664000000000000000000000000000000000000000000000000000000000
00000000003bbb80444bbbb000000000000000000667776046677760066777604667776000000000000000000000000000000000000000000000000000000000
00011000003bb008445b4b4000000000000000000677777606777776067787760677977600000000000000000000000000000000000000000000000000000000
001dd100003b000044c5bbb000000000000000000067878604679796006777760467777600000000000000000000000000000000000000000000000000000000
01dccd10000b0000040555c000022020000000000006767000967670000676700096767000000000000000000000000000000000000000000000000000000000
0dc8c8d03003b00004030300002222c2000ff0000000606000006060000060600000606000000000000000000000000000000000000000000000000000000000
dccccccd033b00000000000042f22f000ff00f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
