pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--chatnoir
--slumberheart

--remake of gamedesign.jp's "chat noir"


function _init()
  difficulty = "normal"
  show_distances = false
  player_turns = 1
  board = boardclass:new()
  board:newboard()
  menuitem(1, ("mode: " .. difficulty), change_difficulty)
end

function _update()
  board:update()
end

function _draw()
  cls(7)
  board:draw()
end

class = {}
function class:new(z)
  z = z or {}
  setmetatable(z, self)
  self.__index = self
  return z
end

function rc2xy(r, c)
  local x, y
  x, y = c * 8, r * 8
  if r % 2 == 1 then
    x += 4
  end
  return x + 16, y + 20
end

function change_difficulty()
  -- normal: no markers, 1 turn
  local od = difficulty
  if od == "normal" then
    difficulty = "learn"
  end
  if od == "learn" then
    difficulty = "easy"
  end
  if od == "easy" then
    difficulty = "normal"
  end

  if difficulty == "normal" then
    show_distances = false
    player_turns = 1
  end
  if difficulty == "learn" then
    show_distances = true
    player_turns = 1
  end
  if difficulty == "easy" then
    show_distances = true
    player_turns = 2
  end
  menuitem(1, ("mode: " .. difficulty), change_difficulty)
end
-->8
--board

boardclass = class:new{
  spaces = {},
  rc = {},
  cat = nil,
  crsr = nil,
  player_turns = 0,
}

function boardclass:newboard()
  self.spaces = {}
  self.rc = {}
  self.crsr = cursorclass:new()

  self.player_turns = 0
  for row=0,10 do
    self.rc[row] = {}
    for col=0,10 do
      z = spaceclass:new{row=row, col=col}
      add(self.spaces, z)
      self.rc[row][col] = z
    end
  end
  local catspace = self:space_at(5, 5)
  self.cat = catclass:new{space=catspace}
  self:randomize()
  self:calc_distances()
end

function boardclass:update()
  for space in all(self.spaces) do
    space:update()
  end
  self.crsr:update()
  self.cat:update()
end

function boardclass:draw()
  for space in all(self.spaces) do
    space:draw()
  end
  self.crsr:draw()
  self.cat:draw()
  if self.player_turns == 0 then
    print("wait", 54, 120, 6)
  end
end

function boardclass:space_at(r, c)
  if self.rc[r] == nil then
    return nil
  end
  return self.rc[r][c]  
end

function boardclass:neighbors(r, c)
  local n = {
    self:space_at(r, c - 1),
    self:space_at(r, c + 1),
    self:space_at(r - 1, c),
    self:space_at(r + 1, c),
  }
  if r % 2 == 0 then
    add(n, self:space_at(r - 1, c - 1))
    add(n, self:space_at(r + 1, c - 1))
  else
    add(n, self:space_at(r - 1, c + 1))
    add(n, self:space_at(r + 1, c + 1))
  end

  return n
end

function boardclass:randomize()
  local changed = 0
  while changed < 6 do
    i = flr(rnd(#self.spaces))
    t = self.spaces[i + 1]
    if t.r != 5 or t.c != 5 then
      if t.blocking == false then
        t.blocking = true
        changed += 1
      end
    end
  end
end

function boardclass:calc_distances()
  for t in all(self.spaces) do
    t.distance = nil
  end  
  local changed = 0
  repeat
    changed = 0
    for space in all(self.spaces) do
      before = space.distance
      space:calc_distance()
      after = space.distance
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
--spaces
spaceclass = class:new{
  row = 0,
  col = 0,
  x = 0,
  y = 0,
  blocking = false,
  distance = nil,
}

function spaceclass:update()
  self.x, self.y = rc2xy(self.row, self.col)
end

function spaceclass:draw()
  local s = 1
  if self.blocking then
    s = 2
  end
  spr(s, self.x, self.y)
  if show_distances then
    local v = self.distance
    if v != nil then
      print(v, self.x + 2, self.y + 1, 3)
    end
  end
end

function spaceclass:calc_distance()
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
  local d = nil
  for n in all(board:neighbors(self.row, self.col)) do
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
catclass = class:new{
  space = nil,
  x = -8,
  y = 60,
}

function catclass:update()
  if board.player_turns == 0 then
    self:choose()
  end
  self:move()
end

function catclass:draw()
  local s = 3
  if self.space != nil then
    if self.space.distance == nil then
      s = 4
    end
  end
  spr(s, self.x, self.y)
end

function catclass:choose()
  if self.chosen then
    return
  end
  chosen = nil
  for n in all(board:neighbors(self.row, self.col)) do
    if n != nil then
      if chosen == nil then
        if n.distance != nil then
          chosen = nil
        end
      end
      if chosen != nil then
        if n.chosen < chosen.distance then
          chosen = n
        end
      end
    end
  end
  if chosen == nil then
    -- game over lil kitty!
    self.status = "lost"
  elseif chosen.distance == 0 then
    -- uh oh you lose!
    self.status = "won"
  else
    self.row = chosen.row
    self.col = chosen.col
    self.chosen = true
  end
end

function catclass:move()
  rx, ry = rc2xy(self.row, self.col)
  if self.x < rx then
    self.x += 1
  elseif self.x > rx then
    self.x -= 1
  end
  if self.y < ry then
    self.y += 1
  elseif self.y > ry then
    self.y -= 1
  end
  if self.x == rx and self.y == ry then
    self.chosen = false
    board.player_turns = player_turns
  end  
end
-->8
--cursor
cursorclass = class:new{
  row = 0,
  col = 0,
  x = 0,
  y = 0,
  space = nil,
}

function cursorclass:update()
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
    self:choose()
  end
  
  self.col = self.col % 11
  self.row = self.row % 11
  self.x, self.y = rc2xy(self.row, self.col)
  self.space = board:space_at(self.row, self.col)
end

function cursorclass:draw()
  spr(0, self.x, self.y)
end

function cursorclass:choose()
  if board.player_turns > 0 then
    if not self.space.blocking then
      self.space.blocking = true
      board:calc_distances()
      board.player_turns -= 1
    end
  end
end
__gfx__
00022000777777777777777705000050050000500500005000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200200777bb77777733777051005e1051005e1051005e100000000000000000000000000000000000000000000000000000000000000000000000000000000
0200002077bbbb777733337705515ee105515ee105515ee100000000000000000000000000000000000000000000000000000000000000000000000000000000
200000027bbbbbb77333333705555551055555510555555100000000000000000000000000000000000000000000000000000000000000000000000000000000
200000027bbbbbb7733333371b55b551155555511555555100000000000000000000000000000000000000000000000000000000000000000000000000000000
0200002077bbbb777733337753553555515115555151155500000000000000000000000000000000000000000000000000000000000000000000000000000000
00200200777bb7777773377715e5555115e5555115e5555100000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000777777777777777701255110012551100125511000000000000000000000000000000000000000000000000000000000000000000000000000000000
