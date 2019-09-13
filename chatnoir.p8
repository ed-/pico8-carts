pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--chatnoir
--slumberheart

-- demake of gamedesign.jp's
-- "chat noir"

function _init()
  difficulty = "normal"
  show_distances = false
  player_turns = 1
  board = boardclass:new()
  board:init()
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
  board:init()
end

-->8
--board
boardclass = class:new{
  spaces = {},
  rc = {},
  crsr = nil,
  cat = nil,
  player_turns = 0,
  result = nil,
  timeout = 120,
}

function boardclass:init()
  self.spaces = {}
  self.rc = {}
  for row=0,10 do
    self.rc[row] = {}
    for col=0,10 do
      z = spaceclass:new{row=row, col=col}
      add(self.spaces, z)
      self.rc[row][col] = z
    end
  end
  self.crsr = cursorclass:new()
  self.cat = catclass:new()
  self.player_turns = 0
  self.result = nil
  self.timeout = 60

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
  
  if self.result == true then
      print("you win", 50, 120, 11)
  elseif self.result == false then
      print("i win", 52, 120, 11)
  else
    if self.player_turns == 0 then
      print("wait", 54, 120, 6)
    else
      print("your turn", 44, 120, 6)
    end
  end
  if self.result != nil then
    if self.timeout > 0 then
      self.timeout -= 1
    else
      self:init()
    end
  end
end

function boardclass:space_at(r, c)
  if self.rc[r] == nil then
    return nil
  end
  return self.rc[r][c]  
end

function boardclass:neighbors(r, c)
  local ns = {
    self:space_at(r, c - 1),
    self:space_at(r, c + 1),
    self:space_at(r - 1, c),
    self:space_at(r + 1, c),
  }
  if r % 2 == 0 then
    add(ns, self:space_at(r - 1, c - 1))
    add(ns, self:space_at(r + 1, c - 1))
  else
    add(ns, self:space_at(r - 1, c + 1))
    add(ns, self:space_at(r + 1, c + 1))
  end
  local rn = {}
  for n in all(ns) do
    if n != nil then
      if n.distance != nil then
        add(rn, n)
      end
    end
  end
  return rn
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
  row = 5,
  col = 5,
  x = -8,
  y = 60,
  chosen = true,
}

function catclass:update()
  --[[ a cat can only choose
  a new space if it's its turn
  and it hasn't already chosen
  --]]
  if board.player_turns == 0 and not self.chosen then
    self:choose()
  end

  --[[ a cat will always move
  toward its chosen space
  --]]
  self:move()

  --[[ if the cat moves to its
  chosen space then it's done
  moving, so it's back to the
  player's turn again.
  --]]
  self:think()
end

function catclass:draw()
  if self.chosen then
    local cx, cy = rc2xy(self.row, self.col)
    spr(5, cx, cy)
  end
  if board.player_turns == 0 then
    spr(3, self.x, self.y)
  else
    spr(4, self.x, self.y)
  end
end

function catclass:choose()
  if board.result != nil then
    return
  end
  
  chosen = nil
  ns = board:neighbors(self.row, self.col)

  for n in all(board:neighbors(self.row, self.col)) do
    if chosen == nil then
      chosen = n
    end
    if n.distance < chosen.distance then
      chosen = n
    end
  end

  if chosen != nil then
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
end

function catclass:think()
  rx, ry = rc2xy(self.row, self.col)
  if self.x == rx and self.y == ry then
    self.chosen = false
    local space = board:space_at(self.row, self.col)
    if space.distance == nil then
      board.result = true
    elseif space.distance == 0 then
      board.result = false
    end
    if board.player_turns == 0 then
      board.player_turns = player_turns
    end
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
  
  self.col = self.col % 11
  self.row = self.row % 11
  self.x, self.y = rc2xy(self.row, self.col)
  self.space = board:space_at(self.row, self.col)

  if btnp(4) or btnp(5) then
    self:choose()
  end
  
end

function cursorclass:draw()
  spr(0, self.x, self.y)
end

function cursorclass:choose()
  if board.result != nil then
    return
  end
  if board.player_turns > 0 then
    if not self.space.blocking then
      self.space.blocking = true
      board:calc_distances()
      board.player_turns -= 1
    end
  end
end
__gfx__
0002200077777777777777770500005005000050000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200200777bb77777733777051005e1051005e100c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200002077bbbb777733337705515ee105515ee10c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000
200000027bbbbbb7733333370555555105555551c000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
200000027bbbbbb7733333371b55b55115555551c000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0200002077bbbb777733337753553555515115550c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200200777bb7777773377715e5555115e5555100c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002200077777777777777770125511001255110000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
