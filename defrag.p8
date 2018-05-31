pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- defrag
-- slumberheart

function _init()
  cls()
  _mode = 0
  _frame = 0
  game = new_game()
end

function _update()
  _frame = (_frame + 1) % 30
  if _mode == 0 then
    update(game)
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

function new_game()

  local game = {}
  
  game.cells = {}
  for i = 1, (32 * 16) + 1 do
    add(game.cells, new_cell(i))
  end
  
  game.swap = function(self, a, b)
    local _a = self.cells[a]
    --_a.position = b
    local _b = self.cells[b]
    --_b.position = a
    self.cells[a] = _b
    self.cells[b] = _a
  end
  
  game.sswap = function(self, st, ed)
    local i = st
    local j = ed
    while i < j do
      self:swap(i, j)
      i += 1
      j -= 1
    end
  end
  
  game.shuffle = function(self)
    local m = 32 * 16 + 1
    while m > 1 do
      local i = flr(rnd(m - 1)) + 1
      m -= 1
      self:swap(i, m)
    end
  end
  
  game.actors = {}
  add(game.actors, new_cursor())
  
  game.cell_at = function(self, id)
    return self.cells[id]
  end
  
  game.find_cell = function(self, id)
    for i=1,(16*32)+1 do
      if self.cells[i] == id then
        return i
      end
    end
  end
    
  game.update = function(self)
    for i=1,16*32+1 do
      cell = game.cells[i]
      cell.position = i
      if cell.index == i then
        cell.state = cell._green
      elseif cell.index == self.actors[1].c then
        cell.state = cell._blue
      else
        cell.state = cell._red
      end
      game.cells[i] = cell
    end
    foreach(game.cells, update)
    foreach(game.actors, update)
  end

  game.draw = function(self)
    foreach(game.cells, draw)
    foreach(game.actors, draw)
  end

  game:shuffle()  
  return game
end
-->8
-- cursor
function new_cursor()
  z = {}
  
  z.x = 0
  z.y = 0
  z.c = 1
  z._max = 32 * 16
  
  z.update = function(self)
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
    local c = self.c - 1
    self.x = flr(c % 32) * 4
    self.y = flr(c / 32) * 8
    
    if btnp(4) then
      self:swapleft()
    end
    if btnp(5) then
      self:swapright()
    end
  end
  
  z.swapleft = function(self)
    game:sswap(1, self.c)
  end
  
  z.swapright = function(self)
    game:sswap(self.c, 16 * 32)
  end

  z.left = function(self)
    if (self.c > 1) then
      self.c -= 1
    end
  end

  z.right = function(self)
    if (self.c < self._max) then
      self.c += 1
    end
  end

  z.up = function(self)
    if (self.c > 32) then
      self.c -= 32
    end
  end

  z.down = function(self)
    if (self.c <= self._max - 32) then
      self.c += 32
    end
  end
  
  z.draw = function(self)
    spr(9, self.x, self.y)
    --local cell = game:cell_at(self.c)
    local cell = game:cell_at(self.c)
    local index = cell.index
    local _info = index .. " " .. self.c
    for i=-1,1 do
      for j=-1,1 do
        print(_info, 1 + i, 122 + j, 0)
      end
    end
    print(_info, 1, 122, 7)
  end
  
  return z
end
-->8
-- cell

function new_cell(id)
  local z = {}
  
  z.index = id
  z.position = id
  
  z.x = -4
  z.y = -8
  
  z._off = 10
  z._red = 11
  z._green = 12
  z._blue = 13
  
  z.state = z._green
  
  z.update = function(self)
    --[[
    if self.state == self._off then
      return
    end
    --]]
    
    local p = self.position - 1
    self.x = flr(p % 32) * 4
    self.y = flr(p / 32) * 8

    --[[
    if self.index == self.position then
      self.state = self._green
            
    elseif self.index < self.position then
      self.state = self._red
    elseif self.index > self.position then
      self.state = self._blue
    end
    --]]
  end
  
  z.draw = function(self)
    spr(self.state, self.x, self.y)
  end
  
  return z
end
__gfx__
000000000660066006607ee806607aab000000000000000000000000000000000000000077770000000000007ee800007aab0000766c00000000000000000000
00000000600560056005e8826005abb300000000000000000000000000000000000000007007000000000000e8820000abb300006cc100000000000000000000
00700700600560056005e8826005abb300000000000000000000000000000000000000007007000005500000e8820000abb300006cc100000000000000000000
00077000600560056005e8826005abb300000000000000000000000000000000000000007007000005500000e8820000abb300006cc100000000000000000000
00077000600560056005e8826005abb300000000000000000000000000000000000000007007000005500000e8820000abb300006cc100000000000000000000
00700700600560056005e8826005abb300000000000000000000000000000000000000007007000005500000e8820000abb300006cc100000000000000000000
00000000600560056005e8826005abb300000000000000000000000000000000000000007007000000000000e8820000abb300006cc100000000000000000000
0000000005500550055082210550b3310000000000000000000000000000000000000000777700000000000082210000b3310000c11000000000000000000000
000000007ee806607ee87ee87ee87aab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8826005e882e882e882abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000082210550822182218221b331000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007aab06607aab7ee87aab7aab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abb36005abb3e882abb3abb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b3300550b3318221b331b331000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
