pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--chatnoir
--slumberheart

--remake of gamedesign.jp's "chat noir"

class = {}
function class:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end

game = class:new{
  tiles = {},
  select = {},
}

function game:update()
  for actor in all(self.tiles) do
    actor:update()
  end
  self.select:update()
end

function game:draw()
  for actor in all(self.tiles) do
    actor:draw()
  end
  self.select:draw()
end

function _init()
  _game = game:new{select=sel:new()}
  local x, y
  for row=0,10 do
    for col=0,10 do
      x, y = rc_xy(row, col)
      add(_game.tiles, tile:new{row=row, col=col, x=x, y=y})
    end
  end
  --randomize()
  calc_distances()
end

function _draw()
  cls(7)
  _game:draw()
end

function _update()
  _game:update()
  
end

function rc_xy(r, c)
  local x, y
  x, y = c * 8, r * 8
  if r % 2 == 1 then
    x += 4
  end
  return x + 16, y + 20
end

function tile_at(r, c)
  for t in all(_game.tiles) do
    if t.row == r and t.col == c then
      return t
    end
  end
end

function neighbors(r, c)
  local n = {
    tile_at(r, c - 1),
    tile_at(r, c + 1),
    tile_at(r - 1, c),
    tile_at(r + 1, c),
  }
  if r % 2 == 0 then
    add(n, tile_at(r - 1, c - 1))
    add(n, tile_at(r + 1, c - 1))
  else
    add(n, tile_at(r - 1, c + 1))
    add(n, tile_at(r + 1, c + 1))
  end

  return n
end

function randomize()
  local stopped = 0
  while stopped < 6 do
    i = flr(rnd(#_game.tiles))
    t = _game.tiles[i + 1]
    if t.r != 5 or t.c != 5 then
      if t.blocking == false then
        t.blocking = true
        stopped += 1
      end
    end
  end
end

function calc_distances()
  for t in all(_game.tiles) do
    t.distance = nil
  end
  
  local changed = 0
  repeat
    changed = 0
    for t in all(_game.tiles) do
      before = t.distance
      t:howfar()
      after = t.distance
      if before == nil then
        if after != nil then
          changed += 1
        end
      elseif after != nil then
        if after < before then
          changed += 1
        end
      end
    end
  until changed == 0    
end
-->8
--tiles
tile = class:new{
  row = 0,
  col = 0,
  x = 0,
  y = 0,
  blocking = false,
  distance = nil,
}

function tile:draw()
  local s = 1
  if self.blocking then
    s += 2
  end
  spr(s, self.x, self.y)
  local v = self.distance
  if v != nil then
    print(v, self.x + 2, self.y + 1, 3)
  end
end

function tile:update()
end

function tile:howfar()
  --if self.distance != nil then
  --  return self.distance
  --end
  if self.blocking then
    self.distance = nil
    return nil
  end
  if self.row == 0 or self.row == 10 then
    self.distance = 0
    return 0
  end
  if self.col == 0 or self.col == 10 then
    self.distance = 0
    return 0
  end
  local ns = neighbors(self.row, self.col)
  local d = nil
  for n in all(ns) do
    if n != nil then
      if n.distance != nil then
        if d == nil then
          d = n.distance + 1
        else
          d = min(d, n.distance + 1)
        end
      end
    end
  end
  if d != nil then
    self.distance = d
    return d
  end
end
-->8
--cat

-->8
--cursor
sel = class:new{
  row = 0,
  col = 0,
  x = 0,
  y = 0,
  _tile = nil,
}

function sel:draw()
  spr(18, self.x, self.y)
  local ns = neighbors(self.row, self.col)
  v = "("
  for n in all(ns) do
    if n == nil then
      v = v .. "., "
    elseif n.distance == nil then
      v = v .. ": "
    else
      v = v .. n.distance .. ", "
    end
  end
  v = v .. ")"
  print(v, 0, 0)
end

function sel:update()
  if btnp(0) then
    self.col -= 1
  end
  if btnp(1) then
    self.col += 1
  end
  if btnp(2) then
    self.row -= 1
  end
  if btnp(3) then
    self.row += 1
  end
  if btnp(4) then
    if not self._tile.blocking then
      self._tile.blocking = true
      calc_distances()
    end
  end
  
  self.col = self.col % 11
  self.row = self.row % 11
  self.x, self.y = rc_xy(self.row, self.col)
  self._tile = tile_at(self.row, self.col)

end
__gfx__
0000000077777777777bb77777777777777227770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777bb77777baab7777733777772332770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077bbbb777baaaab777333377723333270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770007bbbbbb7baaaaaab73333337233333320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770007bbbbbb7baaaaaab73333337233333320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077bbbb777baaaab777333377723333270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777bb77777baab7777733777772332770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777777bb77777777777777227770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75777757747777470002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
751775e1742774e20020020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75515ee174424ee20200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75555551744444422000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b55b551204404422000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53553555404404440200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15e5555124e444420020020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71055117720442270002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
