require 'moonscript'

import min, max from math
utils = require 'utils'


class Grid
  new: (width=6, height=6) =>
    @width = width
    @height = height

  get: (win) =>
    winFrame = win\frame!
    screenFrame = win\screen!\frame!
    {ratioWidth, ratioHeight} = {screenFrame.w / @width, screenFrame.h / @height}
    {
      x: utils.round((winFrame.x - screenFrame.x) / ratioWidth),
      y: utils.round((winFrame.y - screenFrame.y) / ratioHeight),
      w: max(1, utils.round(winFrame.w / ratioWidth)),
      h: max(1, utils.round(winFrame.h / ratioHeight)),
    }

  set: (win, grid) =>
    screenFrame = win\screen!\frame!
    {ratioWidth, ratioHeight} = {screenFrame.w / @width, screenFrame.h / @height}
    newFrame = {
      x: (grid.x * ratioWidth) + screenFrame.x,
      y: (grid.y * ratioHeight) + screenFrame.y,
      w: grid.w * ratioWidth,
      h: grid.h * ratioHeight,
    }

    win\setFrame(newFrame)
    utils.ensureWindowIsInScreenBounds(win)

  adjustWindow: (win, fn) =>
    win = win or hs.window.focusedWindow!
    grid = @get(win)
    for k, v in pairs(fn(grid)) do grid[k] = v
    @set(win, grid)

  snap: (win=hs.window.focusedWindow!) => if win\isStandard! then @set(win, @get(win), win\screen!)
  snapAll: => for win in *hs.window.visibleWindows! do @snap(win)

  resizeWider: (win=nil) => @adjustWindow(win, (f) -> {w: min(f.w + 1.0, @width - f.x)})
  resizeThinner: (win=nil) => @adjustWindow(win, (f) -> {w: max(f.w - 1.0, 1.0)})
  resizeShorter: (win=nil) => @adjustWindow(win, (f) -> {y: f.y, h: max(f.h - 1.0, 1.0)})
  resizeTaller: (win=nil) => @adjustWindow(win, (f) -> {y: f.y, h: min(f.h + 1.0, @height - f.y)})

  moveUp: (win=nil) => @adjustWindow(win, (f) -> {y: max(0.0, f.y - 1.0)})
  moveDown: (win=nil) => @adjustWindow(win, (f) -> {y: min(@height - f.h, f.y + 1.0)})
  moveLeft: (win=nil) => @adjustWindow(win, (f) -> {x: max(0.0, f.x - 1.0)})
  moveRight: (win=nil) => @adjustWindow(win, (f) -> {x: min(@width - f.w, f.x + 1.0)})

  positionTopLeft: (win=nil) => @adjustWindow(win, (f) -> {x: 0.0, y: 0.0})
  positionBottomLeft: (win=nil) => @adjustWindow(win, (f) -> {x: 0.0, y: @height - f.h})
  positionTopRight: (win=nil) => @adjustWindow(win, (f) -> {x: @width - f.w, y: 0.0})
  positionBottomRight: (win=nil) => @adjustWindow(win, (f) -> {x: @width - f.w, y: @height - f.h})


{
  :Grid
}
