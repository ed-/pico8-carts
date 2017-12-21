pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- boilerplate
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
  
  game.actors = {}
  
  add(game.actors, new_button(0, "⬅️", 8 *  4, 8 * 8))
  add(game.actors, new_button(1, "➡️", 8 *  6, 8 * 8))
  add(game.actors, new_button(2, "⬆️", 8 *  5, 8 * 7))
  add(game.actors, new_button(3, "⬇️", 8 *  5, 8 * 9))
  add(game.actors, new_button(4, "🅾️", 8 *  9, 8 * 8))
  add(game.actors, new_button(5, "❎", 8 * 11, 8 * 8))

  add(game.actors, new_cursor())
    
  game.update = function(self)
    foreach(game.actors, update)
  end

  game.draw = function(self)
    foreach(game.actors, draw)
  end
  
  return game
end
-->8
-- button

function new_button(key, label, x, y)
  z = {}
  
  z.key = key
  z.label = label
  z.labelcolor = 5
  z.x = x
  z.y = y
  
  z.update = function(self)
    if btn(self.key) then
      self.labelcolor = 7
    else
      self.labelcolor = 5
    end
  end
  
  z.draw = function(self)
    print(self.label, self.x, self.y, self.labelcolor)
  end
  
  return z
end

-->8
-- cursor
function new_cursor()
  z = {}
  
  z.x = 0
  z.y = 0
  
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
  end

  z.left = function(self)
    if (self.x > 0) then
      self.x -= 1
    end
  end

  z.right = function(self)
    if (self.x < 15) then
      self.x += 1
    end
  end

  z.up = function(self)
    if (self.y > 0) then
      self.y -= 1
    end
  end

  z.down = function(self)
    if (self.y < 15) then
      self.y += 1
    end
  end
  
  z.draw = function(self)
    spr(0, self.x * 8, self.y * 8)
  end
  
  return z
end
