pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- haowang
-- slumberheart

--[[
 eleven tiles, four colors
 fill in the region with the
 tiles provided
 stone blocks match every color
]]

-- sprite flags
-- uu ll rr dd
-- 00 grass
-- 01 stone
-- 10 water
-- 11 sand

function _init()
  game = new_game() 
  selected = "board"
  frame = 0
  --zz = new_tile()
end

function _update()
  frame = (frame + 1) % 30
  game:update()
end

function _draw()
  game:draw()
  --zz:draw(0, 0)
end
-->8
-- game
function new_game()
  local game = {}
  game.board = new_board()
  game.tileset = new_tileset()
  game.tileset:add_stoneblock()
  for i=1,7 do
    game.tileset:add_tile()
  end
  game.cloud_offset = 0
  game.draw_clouds = function(self)
    for y=-1,7 do
      for x=0,7 do
        spr(76, x * 16, (y * 16) + self.cloud_offset, 2, 2)
      end
    end
  end
  game.update = function(self)
    if btn(5) then
      selected = "tileset"
    else
      selected = "board"
    end
    if btnp(4) then
      t = self.tileset:pop()
      self.board:put(t)
    end
    if (frame % 15 == 20) self.cloud_offset = (self.cloud_offset + 1) % 16
    self.board:update()
    self.tileset:update()
  end
  game.draw = function(self)
    cls()
    self:draw_clouds()
    self.board:draw()
    --self.tileset:draw()
  end
  return game
end
-->8
--board
function new_board()
  local board = {}
  board.row = 0
  board.col = 0
  board.b_cursor = new_b_cursor()
  for x=0,6 do
    for y=0,5 do
      --mset( x * 2,       y * 2,      44)
      --mset((x * 2) + 1,  y * 2,      45)
      --mset( x * 2,      (y * 2) + 1, 60)
      --mset((x * 2) + 1, (y * 2) + 1, 61)
      mset( x * 2,       y * 2,      0)
      mset((x * 2) + 1,  y * 2,      0)
      mset( x * 2,      (y * 2) + 1, 0)
      mset((x * 2) + 1, (y * 2) + 1, 0)

      mset((x * 2) + 16,  y * 2,      0)
      mset((x * 2) + 17,  y * 2,      0)
      mset((x * 2) + 16, (y * 2) + 1, 0)
      mset((x * 2) + 17, (y * 2) + 1, 0)

    end
  end
  board.can_place = function(self, t)
    return true
  end
  board.put = function(self, t)
    if (not self:can_place(t)) return
    local r = self.row * 2
    local c = self.col * 2
    local tt = t.id
    -- set horiz tiles in horiz board
    -- set vert tiles in vert board
    --mset( r * 2,       c * 2,      tt)
    --mset((r * 2) + 1,  c * 2,      tt + 1)
    --mset( r * 2,      (c * 2) + 1, tt + 16)
    --mset((r * 2) + 1, (c * 2) + 1, tt + 17)
    mset(r,     c, t.top + 16)
    mset(r + 1, c, t.top + 17)
    mset(r,     c + 1, t.bottom + 0)
    mset(r + 1, c + 1, t.bottom + 1)

    mset(r + 16, c,     t.left +  1)
    mset(r + 16, c + 1, t.left + 17)
    mset(r + 17, c,     t.right + 0)
    mset(r + 17, c + 1, t.right + 16)

  end
  board.update = function(self)
    self.b_cursor:update()
    self.row = self.b_cursor.x
    self.col = self.b_cursor.y
  end
  board.draw = function(self)
    palt(15, true)
    palt(0, false)
    map(0, 0, 0, 0, 16, 16)
    map(16, 0, 0, 0, 16, 16)
    self.b_cursor:draw()
  end
  return board
end
-->8
--tileset
function new_tileset()
  local tileset = {}
  tileset.t_cursor = new_t_cursor()
  tileset.tiles = {}
  tileset.i = 1
  tileset.add_tile = function(self)
    local t = new_tile()
    if flr(rnd(40)) == 0 then
      add(self.tiles, new_stoneblock())
    else
      add(self.tiles, new_tile())
    end
  end
  tileset.add_stoneblock = function(self)
    add(self.tiles, new_stoneblock())
  end
  tileset.pop = function(self)
    t = self.tiles[self.i]
    del(self.tiles, t)
    self:add_tile()
    return t
  end
  tileset.update = function(self)
    self.t_cursor:update()
    self.i = self.t_cursor.i
    self.t = self.tiles[i]
  end
  tileset.draw = function(self)
    for i=1,#self.tiles do
      local t = self.tiles[i]
      spr(t.id, (i * 16) - 16, 112, 2, 2)
    end
    self.t_cursor:draw()
  end
  return tileset
end
-->8
--tile
--[[
-- the 11 tiles
-- top, left, rite, down
   rgrr bgrb rggg ybbr bbby
   yyyr rygb bryb brry grgb
   rgyr  
]]

--
gems = {96, 98, 100, 102}
-- ruby, topaz, emerald, sapphire
   
function new_tile()
  local tile = {}
  alltiles = {2, 4, 6, 8, 10, 12, 14, 32, 34, 36, 38}
  local t = alltiles[flr(rnd(#alltiles - 1) + 1)]
  tile.id = t
  tile.sprites = {t, t + 1, t + 16, t + 17}
  tile.top    = gems[flr(rnd(#gems) + 1)]
  tile.left   = gems[flr(rnd(#gems) + 1)]
  tile.right  = gems[flr(rnd(#gems) + 1)]
  tile.bottom = gems[flr(rnd(#gems) + 1)]
  --[[
  tile.top    = 96
  tile.left   = 98
  tile.right  = 100
  tile.bottom = 102
  ]]
  
  tile.draw = function(self, x, y)
    palt(0, false)
    palt(15, true)
    spr(tile.top + 16, x,     y,     2, 1)
    spr(tile.left + 1, x,     y,     1, 2)
    spr(tile.right,    x + 8, y,     1, 2)
    spr(tile.bottom,   x,     y + 8, 2, 1)
    palt()
  end
  
  return tile
end
function new_stoneblock()
  local sb = new_tile()
  sb.id = 40
  sb.sprites = {40, 41, 56, 57}
  return sb
end

-->8
--cursors
function new_b_cursor()
  local bc = {}
  bc.x = 0
  bc.y = 0
  bc.left = function(self)
    self.x -= 1
    if (self.x < 0) self.x = 0
  end
  bc.right = function(self)
    self.x += 1
    if (self.x > 7) self.x = 7
  end
  bc.up = function(self)
    self.y -= 1
    if (self.y < 0) self.y = 0
  end
  bc.down = function(self)
    self.y += 1
    if (self.y > 7) self.y = 7
  end
  bc.update = function(self)
    if (selected != "board") return
    if (btnp(0))self:left()
    if (btnp(1))self:right()
    if (btnp(2))self:up()
    if (btnp(3))self:down()
  end
  bc.draw = function(self)
    if (selected != "board") pal(7, 8)
    local x = (16 * self.x)
    local y = (16 * self.y)
    palt(15, true)
    palt(0, false)
    spr(46, x, y, 2, 2, 1)
    pal()
  end
  return bc
end
function new_t_cursor()
  local tc = {}
  tc.i = 1
  tc.left = function(self)
    self.i -= 1
    if (self.i < 1) self.i = 1
  end
  tc.right = function(self)
    self.i += 1
    if (self.i > 8) self.i = 8
  end
  tc.update = function(self)
    if (selected != "tileset") return
    if (btnp(0))self:left()
    if (btnp(1))self:right()
  end
  tc.draw = function(self)
    if (selected != "tileset") pal(7, 8)
    spr(46, (self.i * 16) - 16, 112, 2, 2, 1)
    pal()
  end
  return tc
end
__gfx__
000000000000000066602888888e066666011cccccc6606666602888888e066666604999999a066666011cccccc6606666604999999a066666602888888e0666
00000000000000006666028888e06666666011cccc6606666666028888e066666660449999aa0666666011cccc6606666660449999aa06666666028888e06666
0070070000000000066660288e0666660666011cc6606666066660288e066660066604499aa066600666011cc6606660666604499aa06666666660288e066660
0007700000000000a0666602e0666666a066601166066666a0666602e066660360666044aa066601606660116606660100666044aa06660000666602e0666603
0007700000000000ba06666006666006ba06660160666006ba0666600666603b66066600006660116606660160666011aa06660000666044aa0666600666603b
0070070000000000ba006666666602e0ba006660066602e0ba0066666666003bc66066666666011cc66066600666011c9aa06666666604499aa066666666003b
0000000000000000a03a06666660288ea03a06666660288ea03a066666603a03cc660666666011cccc660666666011cc99aa06666660449999aa066666603a03
000000000000000003bba0666660288803bba0666660288803bba0666603bba0ccc6606666011cccccc6606666011ccc999a066666604999999a06666603bba0
000000000000000003bba0666660288803bba0666660288803bba0666603bba0ccc6606666011cccccc6606666011ccc999a066666604999999a06666603bba0
0000000000000000a03a066666660288a03a066666660288a03a066666603a03cc660666666011cccc660666666011cc99aa06666660449999aa066666603a03
0000000000000000ba00666666666028ba00666006666028ba0066600666003bc66066666666011cc66066666666011c9aa06666666604499aa066600666003b
0000000000000000ba06666666666602ba06660160666602ba066603a066603b66066666666660116606660000666011aa06666666666044aa0666016066603b
0000000000000000a066600660066660a066601166066660a066603bba066603606660066006660160666044aa06660100666006600666000066601166066603
0000000000000000066602e002e066660666011cc66066660666003bba006660066602e002e06660066604499aa06660666602e002e066666666011cc6606660
00000000000000006660288e288e0666666011cccc66066666603a03a03a06666660288e288e06666660449999aa06666660288e288e0666666011cccc660666
000000000000000066602888888e066666011cccccc660666603bba003bba06666602888888e066666604999999a066666602888888e066666011cccccc66066
66011cccccc6606666011cccccc660666603bba003bba06666602888888e0666000000000000000020202020202020205655565656555656f7777ffffff7777f
666011cccc660666666011cccc66066666603a03a03a06666666028888e066660655555555555550000200020002000255655565556555657ffff7ffff7ffff7
6666011cc66066666666011cc66066666666003bba006660066660288e0666660567676767676750202020202020202055565656555656567f777ffffff777f7
666660116606660066666011660666666666603bba066603a0666602e06666000576777777777550020002000200020065556555655565557f7ffffffffff7f7
6006660160666044600666016066600660066603a066603bba066660066660440567677777775500202020202020202056565556565655567f7ffffffffff7f7
02e066600666044902e06660066602e002e066600666003bba00666666660449057770555565505000020002000200025565556555655565f7ffffffffffff7f
288e066666604499288e06666660288e288e066666603a03a03a066666604499056775777765550020202020202020205656565556565655ffffffffffffffff
888e066666604999888e066666602888888e06666603bba003bba06666604999057775777765505002000200020002006555655565556555ffffffffffffffff
888e066666604999888e066666602888888e06666603bba003bba06666604999056775777765550020202020202020205655565656555656ffffffffffffffff
88e066666660449988e066666666028888e0666666603a03a03a066666604499057775777765505000020002000200025565556555655565ffffffffffffffff
8e066660066604498e066666666660288e0666600666003bba00666666660449056776666665550020202020202020205556565655565656f7ffffffffffff7f
e066660160666044e066660000666602e06666016066603bba066666666660440577555555565050020002000200020065556555655565557f7ffffffffff7f7
066660116606660006666044aa0666600666601166066603a0666006600666000565555555556500202020202020202056565556565655567f7ffffffffff7f7
6666011cc6606666666604499aa066666666011cc6606660066602e002e066660555505050505650000200020002000255655565556555657f777ffffff777f7
666011cccc6606666660449999aa0666666011cccc6606666660288e288e06660555050505050560202020202020202056565655565656557ffff7ffff7ffff7
66011cccccc6606666604999999a066666011cccccc6606666602888888e0666000000000000000002000200020002006555655565556555f7777ffffff7777f
bbbbbbbbbbbbbbbbcccc11111c111111fffffffffffffff966666666666266662333223232333233666666666666666600000000000000005665566566666555
bbbbbbbbbbbbbbbbc11cc111cc11111cffffffff9fffffff666666666662666633b323333b333b33666666666666616600000000000000006666655666666665
bb33bbb3bbbbbbbb1111c1ccccc1111cff9fffffffffffff66626666662b2666b3b3b3333b333b33661666666666151600000000000000006666665666666665
bbbb3b3bbbbbbbbb1111ccc111cc11ccffffffffffffffff66626666662b3266b3b3b3333b333b33666666666616111600000000000000006666665666666665
bbbb3b3bb3bbbbbb1111cc111111ccccfff999ffffff9fff662b266662b33322b3b3b33b3b333b3b666116666666666600000000000000005666655556666655
bbbbbb3bbbbb3bbb1111c1111111ccccff9fff9fffffffff662b326622b32226b3b3b33b3b3b3b3b661651661666666600000000000000006555566665665566
bbbbbbbbbbbb3b3b1111c11111111c1cf9fffff9fff9ffff62b33322662b3266b332b3323b3b233b661551615166666600000005500000006665666666556666
bbbbbbbbbbbb3bbbc11cc11111111c11f9ffffffffffff9f22b3222662b333222233222332211221611116611166666600000056650000006665666666656666
bbbbbbbbbbbbbbbb1cc1cc111111c111ffffffffffffffff662b3266222b22261cc1cc111111c111666666666666616600000056650000006665666666656666
3bbbbbbbbbbbbbbbcc111c111111c111ffffffff9fffffff62b33322662b3266cc111c111111c111666666666666611600000005500000006665566666655666
b3b3bbbbbbbbbbbbcc111cc111cccc1cffff9fffffffffff222b222662b33222cc111cc111cccc1c666616666666666600000000000000006656655566566555
b3bbbbbbb3bbbbbbc1111ccccccc1ccc9fffffff999fffff662b3266222b2226c1111ccccccc1ccc166116666116666600000000000000005566666655666666
bbbbbbbbbb3bbbbbc111cc11ccc1111cfff9fff9fff99fff62b3322266622666c111cc11ccc1111c666116661651666600000000000000006566666665666666
bbbbbbbbbb3bb3bbcc11c1111cc11111ffffffffffffff9f222b222666622666cc11c1111cc11111666666661555166600000000000000006566666665666666
bbbbbb333b3bbbbbccccc1111c111111ffffffffff9fffff6662266666622266ccccc1111c111111666666611151666600000000000000006566666665566666
bbbbbbbbbbbbbbbbcccc11111c111111ffffff9fffffffff6662226666666666cccc11111c111111666666666616666600000000000000006556666656655666
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000
fffffffffffffffffffffffffffffffffffffff00ffffffffffffff00fffffffffffffffffffffff000000000000000000000000000000000000000000000000
ffffffffffffffffffffff0000ffffffffffff03a0ffffffffffff0160ffffffffffffffffffffff000000000000000000000000000000000000000000000000
fffff00ff00ffffffffff044aa0ffffffffff03bba0ffffffffff011660ffffffffff000000fffff000000000000000000000000000000000000000000000000
ffff02e002e0ffffffff04499aa0ffffffff003bba00ffffffff011cc660ffffffff06666660ffff000000000000000000000000000000000000000000000000
fff0288e288e0ffffff0449999aa0ffffff03a03a03a0ffffff011cccc660fffffff06666660ffff000000000000000000000000000000000000000000000000
fff02888888e0ffffff04999999a0fffff03bba003bba0ffff011cccccc660ffffff06666660ffff000000000000000000000000000000000000000000000000
fff02888888e0ffffff04999999a0fffff03bba003bba0ffff011cccccc660ffffff06666660ffff000000000000000000000000000000000000000000000000
ffff028888e0fffffff0449999aa0ffffff03a03a03a0ffffff011cccc660fffffff06666660ffff000000000000000000000000000000000000000000000000
fffff0288e0fffffffff04499aa0ffffffff003bba00ffffffff011cc660ffffffff06666660ffff000000000000000000000000000000000000000000000000
ffffff02e0fffffffffff044aa0ffffffffff03bba0ffffffffff011660ffffffffff000000fffff000000000000000000000000000000000000000000000000
fffffff00fffffffffffff0000ffffffffffff03a0ffffffffffff0160ffffffffffffffffffffff000000000000000000000000000000000000000000000000
fffffffffffffffffffffffffffffffffffffff00ffffffffffffff00fffffffffffffffffffffff000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000
__gff__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010202080810101b1b00000000000001010202080810101b1b000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
