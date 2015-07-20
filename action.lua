require 'utils'

Action = {}
Action.__index = Action

----------------------------------------------------------------------------------------------------

Action.Close = {}
Action.Close.__index = Action.Close

function Action.Close.new()
  return setmetatable({}, Action.Close)
end

function Action.Close:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then win:close() end
end

----------------------------------------------------------------------------------------------------

Action.Maximize = {}
Action.Maximize.__index = Action.Maximize

function Action.Maximize.new()
  return setmetatable({}, Action.Maximize)
end

function Action.Maximize:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then win:maximize() end
end

----------------------------------------------------------------------------------------------------

Action.FullScreen = {}
Action.FullScreen.__index = Action.FullScreen

function Action.FullScreen.new()
  return setmetatable({}, Action.FullScreen)
end

function Action.FullScreen:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then win:setFullScreen(true) end
end

----------------------------------------------------------------------------------------------------

Action.Snap = {}
Action.Snap.__index = Action.Snap

function Action.Snap.new(grid)
  local m = setmetatable({}, Action.Snap)
  m.grid = grid
  return m
end

function Action.Snap:perform(win)
  local win = win or hs.window.focusedWindow()
  if win and not utils.isFullScreen(win) then self.grid:snap(win) end
end

----------------------------------------------------------------------------------------------------

Action.MoveToScreen = {}
Action.MoveToScreen.__index = Action.MoveToScreen

function Action.MoveToScreen.new(screenIndex)
  local m = setmetatable({}, Action.MoveToScreen)
  m.screenIndex = screenIndex
  return m
end

function Action.MoveToScreen:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then utils.pushToScreen(win, hs.screen.allScreens()[self.screenIndex]) end
end

----------------------------------------------------------------------------------------------------

Action.MoveToNextScreen = {}
Action.MoveToNextScreen.__index = Action.MoveToNextScreen

function Action.MoveToNextScreen.new()
  return setmetatable({}, Action.MoveToNextScreen)
end

function Action.MoveToNextScreen:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then utils.pushToScreen(win, win:screen():next()) end
end

----------------------------------------------------------------------------------------------------

Action.MoveToPreviousScreen = {}
Action.MoveToPreviousScreen.__index = Action.MoveToPreviousScreen

function Action.MoveToPreviousScreen.new()
  return setmetatable({}, Action.MoveToPreviousScreen)
end

function Action.MoveToPreviousScreen:perform(win)
  local win = win or hs.window.focusedWindow()
  if win then utils.pushToScreen(win, win:screen():previous()) end
end

----------------------------------------------------------------------------------------------------

Action.MoveToUnit = {}
Action.MoveToUnit.__index = Action.MoveToUnit

function Action.MoveToUnit.new(x, y, w, h)
  local m = setmetatable({}, Action.MoveToUnit)
  m.unit = {x = x, y = y, w = w, h = h}
  return m
end

function Action.MoveToUnit:perform(win)
  local win = win or hs.window.focusedWindow()
  if win and not utils.isFullScreen(win) then
    win:moveToUnit(self.unit):ensureIsInScreenBounds()
  end
end

----------------------------------------------------------------------------------------------------

return Action
