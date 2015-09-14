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

function Action.PositionTopLeft()
  return function(win)
    local screenFrame = win:screen():frame()
    win:setTopLeft({x = screenFrame.x, y = screenFrame.y})
  end
end

function Action.PositionBottomLeft()
  return function(win)
    local screenFrame = win:screen():frame()
    win:setTopLeft({x = screenFrame.x, y = screenFrame.y + screenFrame.h - win:size().h})
  end
end

function Action.PositionTopRight()
  return function(win)
    local screenFrame = win:screen():frame()
    win:setTopLeft({x = screenFrame.x + screenFrame.w - win:size().w, y = screenFrame.y})
  end
end

function Action.PositionBottomRight()
  return function(win)
    local screenFrame = win:screen():frame()
    win:setTopLeft({x = screenFrame.x + screenFrame.w - win:size().w, y = screenFrame.y + screenFrame.h - win:size().h})
  end
end

function Action.Resize(w, h)
  return function(win)
    local screenFrame = win:screen():frame()
    win:setSize({w = w * screenFrame.w, h = h * screenFrame.h})
  end
end

function Action.EnsureIsInScreenBounds()
  return function(win)
    win:ensureIsInScreenBounds()
  end
end

----------------------------------------------------------------------------------------------------

return Action
