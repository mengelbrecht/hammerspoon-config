require 'moonscript'
import floor from math

pushToScreen = (win, screen) ->
  screen = screen or win\screen!
  if screen == win\screen! then return
  
  fullscreenChange = win\isFullScreen!
  if fullscreenChange then
    id = win\id!
    win\toggleFullscreen!
    os.execute('sleep 3')
    win = hs.window.windowForID(id)

  win\moveToScreen(screen)

  if fullscreenChange then win\toggleFullscreen!


-- handle fixed-size windows which may exceed the screen
ensureWindowIsInScreenBounds = (win) ->
  winFrame = win\frame!
  screenFrame = win\screen!\frame!
  exceedX = winFrame.x + winFrame.w > screenFrame.x + screenFrame.w
  exceedY = winFrame.y + winFrame.h > screenFrame.y + screenFrame.h
  {x: x, y: y} = winFrame
  if exceedX then x = (screenFrame.x + screenFrame.w) - winFrame.w
  if exceedY then y = (screenFrame.y + screenFrame.h) - winFrame.h
  if exceedX or exceedY then win\setTopLeft({x: x, y: y})


round = (num) -> floor(num + 0.5)


{
  :pushToScreen, :ensureWindowIsInScreenBounds, :round
}

