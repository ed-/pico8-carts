pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- wang tile puzzle
-- -

-- eleven tiles, four colors
-- fill in the region with the
-- tiles provided
-- if you get in a pinch you can
-- use the stone block

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
end

function _update()
  frame = (frame + 1) % 30
  game:update()
end

function _draw()
  game:draw()
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
    if (frame % 5 == 0) self.cloud_offset = (self.cloud_offset + 1) % 16
    self.board:update()
    self.tileset:update()
  end

  game.draw = function(self)
    cls()
    self:draw_clouds()
    self.board:draw()
    self.tileset:draw()
  end

  return game
end
-->8
--board
function new_board()
  local board = {}
  board.b_cursor = new_b_cursor()

  for x=0,6 do
    for y=0,5 do
      mset( x * 2,       y * 2,      44)
      mset((x * 2) + 1,  y * 2,      45)
      mset( x * 2,      (y * 2) + 1, 60)
      mset((x * 2) + 1, (y * 2) + 1, 61)
    end
  end

  board.update = function(self)
    self.b_cursor:update()
  end

  board.draw = function(self)
    palt(0, 0)
    map(0, 0, 8, 8, 14, 12)
    palt()
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

  tileset.update = function(self)
    if (btnp(0)) self:add_tile()
    self.t_cursor:update()
  end

  tileset.draw = function(self)
    palt(0, false)
    for i=1,#self.tiles do
      local t = self.tiles[i]
      spr(t.id, (i * 16) - 16, 112, 2, 2)
    end
    palt()
    self.t_cursor:draw()
  end

  return tileset
end
-->8
--tile
function new_tile()
  local tile = {}
  alltiles = {2, 4, 6, 8, 10, 12, 14, 32, 34, 36, 38}
  tile.id = flr(rnd(#alltiles - 1) + 1)

  return tile
end

function new_stoneblock()
  local sb = new_tile()
  sb.id = 40
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
    if (self.x > 6) self.x = 6
  end

  bc.up = function(self)
    self.y -= 1
    if (self.y < 0) self.y = 0
  end

  bc.down = function(self)
    self.y += 1
    if (self.y > 5) self.y = 5
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
    local x = (16 * self.x) + 8
    local y = (16 * self.y) + 8
    spr(46, x, y, 2, 2, 1)
    pal()
  end

  return bc
end

function new_t_cursor()
  local tc = {}
  tc.i = 0

  tc.left = function(self)
    self.i -= 1
    if (self.i < 0) self.i = 0
  end

  tc.right = function(self)
    self.i += 1
    if (self.i > 7) self.i = 7
  end

  tc.update = function(self)
    if (selected != "tileset") return
    if (btnp(0))self:left()
    if (btnp(1))self:right()
  end

  tc.draw = function(self)
    if (selected != "tileset") pal(7, 8)
    spr(46, self.i * 16, 112, 2, 2, 1)
    pal()
  end

  return tc
end
-->8
--garbage
function z_init()
cursorx = 0
cursory = 0
xmax = 6
ymax = 5
pcursor = 0
alltiles = {2, 4, 6, 8, 10, 12, 14, 32, 34, 36, 38}
cooldown = 0
cooldownmax = 5
cursorswap = 0
game = new_game()
end

__gfx__
000000000000000006666666666666660ccc11111c11111006666666666666600ffffffffffffff0cccc11111c111111fffffffffffffff90666666666666660
0000000000000000b066666666666166b01cc111cc111106b06666666666610bc0ffffff9fffff0cc11cc111cc11111cffffffff9ffffffff06666666666610b
0070070000000000bb06666666661516bb01c1ccccc11016bb066666666610bb110ffffffffff01c1111c1ccccc1111cff9fffffffffffffff066666666610bb
0007700000000000bbb0666666161116bbb0ccc111cc0116bbb0666666160bbb1110ffffffff01cc1111ccc111cc11ccfffffffffffffffffff0666666160bbb
0007700000000000bbbb066666666666bbbb0c1111106666bbbb06666660bbbb111109fffff0cccc1111cc111111ccccfff999ffffff9ffffff906666660bbbb
0070070000000000bbbbb06616666666bbbbb01111066666bbbbb066160b3bbb1111c09fff01cccc1111c1111111ccccff9fff9fffffffffff9ff066160b3bbb
0000000000000000bbbbbb0151666666bbbbbb0110666666bbbbbb0150bb3b3b1111c109f0111c1c1111c11111111c1cf9fffff9fff9fffff9ffff0150bb3b3b
0000000000000000bbbbbbb011666666bbbbbbb001666666bbbbbbb00bbb3bbbc11cc11001111c11c11cc11111111c11f9ffffffffffff9ff9fffff00bbb3bbb
0000000000000000bbbbbbb066666166bbbbbbb006666166bbbbbbbbbbbbbbbb1cc1cc100111c1111cc1cc100111c111fffffff00ffffffffffffff00bbbbbbb
00000000000000003bbbbb06666661163bbbbb01106661163bbbbbbbbbbbbbbbcc111c066011c111cc111c0f9011c111ffffff0660ffffffffffff0110bbbbbb
0000000000000000b3b3b06666666666b3b3b0c111066666b3b3bbbbbbbbbbbbcc111066660ccc1ccc1110ffff0ccc1cffff9066660fffffffff90c1110bbbbb
0000000000000000b3bb066661166666b3bb0cccccc06666b3bbbbbbb3bbbbbbc111066661101cccc1110fff99901ccc9fff06666110ffff9fff0cccccc0bbbb
0000000000000000bbb0166616516666bbb0cc11ccc10666bbbbbbbbbb3bbbbbc11016661651011cc110fff9fff9011cfff0166616510ffffff0cc11ccc10bbb
0000000000000000bb06666615551666bb01c1111cc11066bbbbbbbbbb3bb3bbcc06666615551011cc0ffffffffff011ff0666661555109fff01c1111cc110bb
0000000000000000b066666111516666b0ccc1111c111106bbbbbb333b3bbbbbc066666111516601c0ffffffff9fff01f06666611151660ff0ccc1111c11110b
000000000000000006666666661666660ccc11111c111110bbbbbbbbbbbbbbbb06666666661666600fffff9ffffffff006666666661666600ccc11111c111110
0ccc11111c1111100ccc11111c1111100bbbbbbbbbbbbbbb06666666666666600000000000000000202020202020202056555656565556560777700000077770
601cc111cc11110f601cc111cc11110660bbbbbbbbbbbbbbb06666666666610f0655555555555550000200020002000255655565556555657000070000700007
6601c1ccccc110ff6601c1ccccc110166603bbb3bbbbbbbbbb066666666610ff0567676767676750202020202020202055565656555656567077700000077707
6660ccc111cc0fff6660ccc111cc011666603b3bbbbbbbbbbbb0666666160fff0576777777777550020002000200020065556555655565557070000000000707
66610c1111109fff66610c111110666666610b3bb3bbbbbbbbbb066666609fff0567677777775500202020202020202056565556565655567070000000000707
66165011110fffff66165011110666666616503bbbbb3bbbbbbbb066160fffff0577705555655050000200020002000255655565556555650700000000000070
6615510110f9ffff66155101106666666615510bbbbb3b3bbbbbbb0150f9ffff0567757777655500202020202020202056565655565656550000000000000000
611116600fffff9f611116600166666661111660bbbb3bbbbbbbbbb00fffff9f0577757777655050020002000200020065556555655565550000000000000000
666666600fffffff6666666006666166666666600bbbbbbbbbbbbbb00fffffff0567757777655500202020202020202056555656565556560000000000000000
6666660110ffffff6666660f906661166666660110bbbbbb3bbbbb0660ffffff0577757777655050000200020002000255655565556555650000000000000000
666610c1110fffff666610ffff066666666610c1110bbbbbb3b3b066660fffff0567766666655500202020202020202055565656555656560700000000000070
16610cccccc0ffff16610fff9990666616610cccccc0bbbbb3bb06666110ffff0577555555565050020002000200020065556555655565557070000000000707
6660cc11ccc10fff6660fff9fff906666660cc11ccc10bbbbbb0166616510fff0565555555556500202020202020202056565556565655567070000000000707
6601c1111cc1109f660ffffffffff0666601c1111cc110bbbb0666661555109f0555505050505650000200020002000255655565556555657077700000077707
60ccc1111c11110f60ffffffff9fff0660ccc1111c11110bb06666611151660f0555050505050560202020202020202056565655565656557000070000700007
0ccc11111c1111100fffff9ffffffff00ccc11111c11111006666666661666600000000000000000020002000200020065556555655565550777700000077770
bbbbbbbbbbbbbbbbcccc11111c111111fffffffffffffff9666666666662666623332232323332336666666666666666cc7cc777777777775665566566666555
bbbbbbbbbbbbbbbbc11cc111cc11111cffffffff9fffffff666666666662666633b323333b333b33666666666666616677777c77ccc7777c6666655666666665
bb33bbb3bbbbbbbb1111c1ccccc1111cff9fffffffffffff66626666662b2666b3b3b3333b333b336616666666661516777777cc777c77776666665666666665
bbbb3b3bbbbbbbbb1111ccc111cc11ccffffffffffffffff66626666662b3266b3b3b3333b333b336666666666161116777777c777777c776666665666666665
bbbb3b3bb3bbbbbb1111cc111111ccccfff999ffffff9fff662b266662b33322b3b3b33b3b333b3b66611666666666667777777777777c775666655556666655
bbbbbb3bbbbb3bbb1111c1111111ccccff9fff9fffffffff662b326622b32226b3b3b33b3b3b3b3b661651661666666677777ccc777777cc6555566665665566
bbbbbbbbbbbb3b3b1111c11111111c1cf9fffff9fff9ffff62b33322662b3266b332b3323b3b233b66155161516666667777c777cc7777c76665666666556666
bbbbbbbbbbbb3bbbc11cc11111111c11f9ffffffffffff9f22b3222662b333222233222332211221611116611166666677cc777777c777776665666666656666
bbbbbbbbbbbbbbbb1cc1cc111111c111ffffffffffffffff662b3266222b22261cc1cc111111c11166666666666661667c77c77777c777776665666666656666
3bbbbbbbbbbbbbbbcc111c111111c111ffffffff9fffffff62b33322662b3266cc111c111111c1116666666666666116c7777777777777776665566666655666
b3b3bbbbbbbbbbbbcc111cc111cccc1cffff9fffffffffff222b222662b33222cc111cc111cccc1c6666166666666666c77777777777cc776656655566566555
b3bbbbbbb3bbbbbbc1111ccccccc1ccc9fffffff999fffff662b3266222b2226c1111ccccccc1ccc1661166661166666c7777777777c77c75566666655666666
bbbbbbbbbb3bbbbbc111cc11ccc1111cfff9fff9fff99fff62b3322266622666c111cc11ccc1111c66611666165166667c77777777c7777c6566666665666666
bbbbbbbbbb3bb3bbcc11c1111cc11111ffffffffffffff9f222b222666622666cc11c1111cc1111166666666155516667c77777777c777776566666665666666
bbbbbb333b3bbbbbccccc1111c111111ffffffffff9fffff6662266666622266ccccc1111c111111666666611151666677cc77c777c777776566666665566666
bbbbbbbbbbbbbbbbcccc11111c111111ffffff9fffffffff6662226666666666cccc11111c1111116666666666166666c777cc77777c777c6556666656655666
