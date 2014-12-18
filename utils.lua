utils = {}
utils.__index = utils

function utils.pushToScreen(win, screen)
  local screen = screen or win:screen()
  if screen == win:screen() then return end
  
  local fullscreenChange = win:isFullScreen()
  if fullscreenChange then
    id = win:id()
    win:toggleFullScreen()
    os.execute('sleep 3')
    win = hs.window.windowForID(id)
  end

  win:moveToScreen(screen)

  if fullscreenChange then win:toggleFullScreen() end
end

----------------------------------------------------------------------------------------------------

return utils
