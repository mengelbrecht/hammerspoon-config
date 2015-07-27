utils = {}
utils.__index = utils

function utils.snapAll()
  for _, win in pairs(hs.window.visibleWindows()) do hs.grid.snap(win) end
end

function utils.isFullScreen(win)
  if not win then return false end
  if win:isFullScreen() then return true end

  local winFrame = win:frame()
  local screen = win:screen()
  if not screen then return false end

  local screenFrame = screen:fullFrame()

  return winFrame.x == screenFrame.x and winFrame.y == screenFrame.y and
         winFrame.w == screenFrame.w and winFrame.h == screenFrame.h
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

function utils.notify(message, seconds)
  local notification = hs.notify.new(nil, {title = "Hammerspoon", subTitle = message}):send()
  hs.timer.doAfter(seconds, function()
    notification:withdraw()
    notification:release()
  end)
end

----------------------------------------------------------------------------------------------------

return utils
