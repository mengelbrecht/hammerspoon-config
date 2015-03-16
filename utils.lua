utils = {}
utils.__index = utils

function utils.isFullScreen(win)
  local win = win or hs.window.focusedWindow()
  if not win then return false end

  local winFrame = win:frame()
  local screenFrame = win:screen():fullFrame()

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
