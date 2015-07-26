require 'utils'

Action = {}
Action.__index = Action

function Action.Close()
  return function(win) win:close() end
end

function Action.Maximize()
  return function(win) win:maximize() end
end

function Action.FullScreen()
  return function(win) win:setFullScreen(true) end
end

function Action.Snap()
  return function(win) if not utils.isFullScreen(win) then hs.grid.snap(win) end end
end

function Action.MoveToScreen(screenIndex)
  return function(win) utils.pushToScreen(win, hs.screen.allScreens()[screenIndex]) end
end

function Action.MoveToNextScreen()
  return function(win) utils.pushToScreen(win, win:screen():next()) end
end

function Action.MoveToPreviousScreen()
  return function(win) utils.pushToScreen(win, win:screen():previous()) end
end

function Action.MoveToUnit(x, y, w, h)
  return function(win)
    if not utils.isFullScreen(win) then
      win:moveToUnit({x = x, y = y, w = w, h = h}):ensureIsInScreenBounds()
    end
  end
end

----------------------------------------------------------------------------------------------------

return Action
