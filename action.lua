require 'utils'

Action = {}
Action.__index = Action

function Action.Close()
  return function(win) if win then win:close() end end
end

function Action.Maximize()
  return function(win) if win then win:maximize() end end
end

function Action.FullScreen()
  return function(Win) if win then win:setFullScreen(true) end end
end

function Action.Snap()
  return function(win) if win and not utils.isFullScreen(win) then hs.grid.snap(win) end end
end

function Action.MoveToScreen(screenIndex)
  return function(win) if win then utils.pushToScreen(win, hs.screen.allScreens()[screenIndex]) end end
end

function Action.MoveToNextScreen()
  return function(win) if win then utils.pushToScreen(win, win:screen():next()) end end
end

function Action.MoveToPreviousScreen()
  return function(win) if win then utils.pushToScreen(win, win:screen():previous()) end end
end

function Action.MoveToUnit(x, y, w, h)
  return function(win)
    if win and not utils.isFullScreen(win) then
      win:moveToUnit({x = x, y = y, w = w, h = h}):ensureIsInScreenBounds()
    end
  end
end

----------------------------------------------------------------------------------------------------

return Action
