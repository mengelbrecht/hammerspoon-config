utils = {}
utils.__index = utils

function utils.positionTopLeft(win)
  local screenFrame = win:screen():frame()
  win:setTopLeft({x = screenFrame.x, y = screenFrame.y})
end

function utils.positionBottomLeft(win)
  local screenFrame = win:screen():frame()
  win:setTopLeft({x = screenFrame.x, y = screenFrame.y + screenFrame.h - win:size().h})
end

function utils.positionTopRight(win)
  local screenFrame = win:screen():frame()
  win:setTopLeft({x = screenFrame.x + screenFrame.w - win:size().w, y = screenFrame.y})
end

function utils.positionBottomRight(win)
  local screenFrame = win:screen():frame()
  win:setTopLeft({x = screenFrame.x + screenFrame.w - win:size().w, y = screenFrame.y + screenFrame.h - win:size().h})
end

function utils.snapAll()
  for _, win in pairs(hs.window.visibleWindows()) do hs.grid.snap(win) end
end

function utils.isFullScreen(win)
  if not win then return false end

  local winFrame = win:frame()
  local screen = win:screen()
  if not screen then return false end

  local screenFrame = screen:fullFrame()

  return win:isFullScreen() or
         (winFrame.x == screenFrame.x and winFrame.y == screenFrame.y and
          winFrame.w == screenFrame.w and winFrame.h == screenFrame.h)
end

function utils.pushToScreen(win, screen)
  local screen = screen or win:screen()
  if screen == win:screen() then return end

  local fullscreenChange = win:isFullScreen()
  if fullscreenChange then
    id = win:id()
    win:toggleFullScreen()
    os.execute('sleep 3')
    win = hs.window.windowForID(id)
    if not win then return end
  end

  win:moveToScreen(screen)

  if fullscreenChange then win:toggleFullScreen() end
end

----------------------------------------------------------------------------------------------------

return utils
