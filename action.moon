require 'moonscript'
utils = require 'utils'


class Close
  new: () =>
  perform: (win=hs.window.focusedWindow!) => win\close!


class Maximize
  new: () =>
  perform: (win=hs.window.focusedWindow!) => win\maximize!


class FullScreen
  new: () =>
  perform: (win=hs.window.focusedWindow!) => win\setFullScreen(true)


class Snap
  new: (grid) => @grid = grid
  perform: (win=hs.window.focusedWindow!) => @grid\snap(win)


class MoveToScreen
  new: (screenIndex) => @screenIndex = screenIndex
  perform: (win=hs.window.focusedWindow!) => utils.pushToScreen(win, hs.screen.allScreens![@screenIndex])


class MoveToNextScreen
  new: () =>
  perform: (win=hs.window.focusedWindow!) => utils.pushToScreen(win, win\screen!\next!)


class MoveToPreviousScreen
  new: () =>
  perform: (win=hs.window.focusedWindow!) => utils.pushToScreen(win, win\screen!\previous!)


class MoveToUnit
  new: (unit) => @unit = unit
  perform: (win=hs.window.focusedWindow!) =>
    win\moveToUnit(@unit)
    utils.ensureWindowIsInScreenBounds(win)


{
  :Close, :Maximize, :FullScreen, :Snap,
  :MoveToScreen, :MoveToNextScreen, :MoveToPreviousScreen,
  :MoveToUnit, 
}
