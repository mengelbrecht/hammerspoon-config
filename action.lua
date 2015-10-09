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

function Action.MoveToUnit(x, y, w, h, duration)
  return function(win)
    if not utils.isFullScreen(win) then win:moveToUnit(hs.geometry.rect(x, y, w, h), duration) end
  end
end

function Action.MoveToUnitInScreenBounds(x, y, w, h)
  return function(win)
    if not utils.isFullScreen(win) then
      local f = win:screen():frame()
      win:setFrameInScreenBounds(hs.geometry.rect(f.x + x * f.x, f.y + y * f.h, w * f.w, h * f.h))
    end
  end
end

function Action.PositionTopLeft()
  return function(win)
    local f = win:screen():frame()
    win:setTopLeft(hs.geometry.point(f.x, f.y))
  end
end

function Action.PositionBottomLeft()
  return function(win)
    local f = win:screen():frame()
    win:setTopLeft(hs.geometry.point(f.x, f.y + f.h - win:size().h))
  end
end

function Action.PositionTopRight()
  return function(win)
    local f = win:screen():frame()
    win:setTopLeft(hs.geometry.point(f.x + f.w - win:size().w, f.y))
  end
end

function Action.PositionBottomRight()
  return function(win)
    local f = win:screen():frame()
    win:setTopLeft(hs.geometry.point(f.x + f.w - win:size().w, f.y + f.h - win:size().h))
  end
end

function Action.Resize(w, h)
  return function(win)
    local f = win:screen():frame()
    win:setSize(hs.geometry.size(w * f.w, h * f.h))
  end
end

function Action.EnsureIsInScreenBounds()
  return function(win) win:ensureIsInScreenBounds() end
end

----------------------------------------------------------------------------------------------------

return Action
