require 'action'
require 'profile'

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
local mash = {'ctrl', 'alt'}

local expose = hs.expose.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}))
hs.expose.ui.minimizedStripPosition = 'left'
hs.expose.ui.showExtraKeys = true
hs.expose.ui.showThumbnails = false
hs.expose.ui.showTitles = false

hs.window.animationDuration = 0.15

hs.grid.setMargins({0, 0})
hs.grid.setGrid('6x4', nil)
hs.grid.HINTS = {
  {'f1', 'f2','f3', 'f4', 'f5', 'f6', 'f7', 'f8'},
  {'1', '2', '3', '4', '5', '6', '7', '8'},
  {'Q', 'W', 'E', 'R', 'T', 'Z', 'U', 'I'},
  {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K'},
  {'Y', 'X', 'C', 'V', 'B', 'N', 'M', ','}
}

----------------------------------------------------------------------------------------------------
-- Profiles
----------------------------------------------------------------------------------------------------

Profile.new('Home', 'eventhorizon', mash, {
  ["Atom"]          = {Action.MoveToScreen(1), Action.Maximize()},
  ["Google Chrome"] = {Action.MoveToScreen(2), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["iTunes"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["MacPass"]       = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Mail"]          = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Reeder"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Safari"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["SourceTree"]    = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Terminal"]      = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.5, 1.0, 0.5, 0), Action.PositionBottomRight()},
  ["TextMate"]      = {Action.MoveToScreen(1), Action.MoveToUnit(0.5, 0.0, 0.5, 1.0)},
  ["Xcode"]         = {Action.MoveToScreen(1), Action.Maximize()},
  ["_"]             = {Action.Snap()}
}, {
  ['a'] = 'Atom',
  ['c'] = 'Google Chrome',
  ['e'] = 'TextMate',
  ['f'] = 'Finder',
  ['g'] = 'SourceTree',
  ['i'] = 'iTunes',
  ['m'] = 'Activity Monitor',
  ['r'] = 'Reeder',
  ['s'] = 'MacPass',
  ['t'] = 'Terminal',
  ['x'] = 'Xcode',
})

----------------------------------------------------------------------------------------------------

Profile.new('Work', 'singularity', mash, {
  ["Atom"]              = {Action.MoveToScreen(1), Action.Maximize()},
  ["Dash"]              = {Action.MoveToScreen(2), Action.Maximize()},
  ["Google Chrome"]     = {Action.MoveToScreen(2), Action.Maximize()},
  ["iTerm2"]            = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.5, 1.0, 0.5, 0), Action.PositionBottomRight()},
  ["iTunes"]            = {Action.Close()},
  ["MacPass"]           = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Parallels Desktop"] = {Action.MoveToScreen(2), Action.FullScreen()},
  ["Safari"]            = {Action.MoveToScreen(2), Action.Maximize()},
  ["SourceTree"]        = {Action.MoveToScreen(1), Action.Maximize()},
  ["Terminal"]          = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.5, 1.0, 0.5, 0), Action.PositionBottomRight()},
  ["TextMate"]          = {Action.MoveToScreen(2), Action.Maximize()},
  ["Tower"]             = {Action.MoveToScreen(1), Action.Maximize()},
  ["Xcode"]             = {Action.MoveToScreen(1), Action.Maximize()},
  ["_"]                 = {Action.Snap()}
}, {
  ['a'] = 'Atom',
  ['c'] = 'Google Chrome',
  ['d'] = 'Dash',
  ['e'] = 'TextMate',
  ['f'] = 'Finder',
  ['g'] = 'Tower',
  ['i'] = 'iTunes',
  ['p'] = 'Parallels Desktop',
  ['m'] = 'Activity Monitor',
  ['s'] = 'MacPass',
  ['t'] = 'iTerm',
  ['x'] = 'Xcode',
})

Profile.watch()

----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------

function focusedWin() return hs.window.focusedWindow() end

hs.hotkey.bind(mash, 'UP',    function() Action.Maximize()(focusedWin()) end)
hs.hotkey.bind(mash, 'DOWN',  function() Action.MoveToNextScreen()(focusedWin()) end)
hs.hotkey.bind(mash, 'LEFT',  function() Action.MoveToUnit(0.0, 0.0, 0.5, 1.0)(focusedWin()) end)
hs.hotkey.bind(mash, 'RIGHT', function() Action.MoveToUnit(0.5, 0.0, 0.5, 1.0)(focusedWin()) end)
hs.hotkey.bind(mash, 'SPACE', function() Profile.detectAndChange() end)
hs.hotkey.bind(mash, '1',     function() expose:toggleShow() end)
hs.hotkey.bind(mash, '2',     function() hs.grid.toggleShow() end)
