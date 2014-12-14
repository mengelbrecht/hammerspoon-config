utils = {}
utils.__index = utils

function utils.pushToScreen(win, screen)
  screen = screen or win:screen()
  if screen == win:screen() then return end
  
  fullscreenChange = win:isFullScreen()
  if fullscreenChange then
    id = win:id()
    win:toggleFullscreen()
    os.execute('sleep 3')
    win = hs.window.windowForID(id)
  end

  win:moveToScreen(screen)

  if fullscreenChange then win:toggleFullscreen() end
end

function utils.ensureWindowIsInScreenBounds(win)
  winFrame = win:frame()
  screenFrame = win:screen():frame()
  exceedX = winFrame.x + winFrame.w > screenFrame.x + screenFrame.w
  exceedY = winFrame.y + winFrame.h > screenFrame.y + screenFrame.h
  local topLeft = {x = winFrame.x, y = winFrame.y}
  if exceedX then topLeft.x = (screenFrame.x + screenFrame.w) - winFrame.w end
  if exceedY then topLeft.y = (screenFrame.y + screenFrame.h) - winFrame.h end
  if exceedX or exceedY then win:setTopLeft(topLeft) end
end

----------------------------------------------------------------------------------------------------

return utils
