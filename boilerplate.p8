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
  
  game.buttons = {}
  
  add(game.buttons, new_button(0, "⬅️", 8 *  4, 8 * 8))
  add(game.buttons, new_button(1, "➡️", 8 *  6, 8 * 8))
  add(game.buttons, new_button(2, "⬆️", 8 *  5, 8 * 7))
  add(game.buttons, new_button(3, "⬇️", 8 *  5, 8 * 9))
  add(game.buttons, new_button(4, "🅾️", 8 *  9, 8 * 8))
  add(game.buttons, new_button(5, "❎", 8 * 11, 8 * 8))
    
  game.update = function(self)
    foreach(game.buttons, update)
  end

  game.draw = function(self)
    foreach(game.buttons, draw)
  end
  
  return game
end
-->8
-- button

function new_button(key, label, x, y)
  button = {}
  
  button.key = key
  button.label = label
  button.labelcolor = 5
  button.x = x
  button.y = y
  
  button.update = function(self)
    if btn(self.key) then
      self.labelcolor = 7
    else
      self.labelcolor = 5
    end
  end
  
  button.draw = function(self)
    print(self.label, self.x, self.y, self.labelcolor)
  end
  
  return button
end
