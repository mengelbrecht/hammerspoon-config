require 'action'
require 'profile'

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
local mash = {'ctrl', 'alt'}

hs.window.animationDuration = 0.15
local animationDelay = hs.window.animationDuration + 0.06

expose = hs.expose.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}),{
  backgroundColor                 = {0.03, 0.03, 0.03, 0.75},
  closeModeBackgroundColor        = {0.7, 0.1, 0.1, 0.75},
  highlightColor                  = {0.6, 0.3, 0.0, 0.75},
  minimizeModeBackgroundColor     = {0.1, 0.2, 0.3, 0.75},
  nonVisibleStripBackgroundColor  = {0.03, 0.1, 0.15, 0.75},
  nonVisibleStripPosition         = 'left',
  otherSpacesStripBackgroundColor = {0.1, 0.1, 0.1, 0.75},
  otherSpacesStripWidth           = 0.15,
  showThumbnails                  = false,
  showTitles                      = false
})

hs.grid.setMargins({0, 0})
hs.grid.setGrid('6x4', nil)
hs.grid.HINTS = {
  {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8'},
  {'1',  '2',  '3',  '4',  '5',  '6',  '7',  '8'},
  {'Q',  'W',  'E',  'R',  'T',  'Z',  'U',  'I'},
  {'A',  'S',  'D',  'F',  'G',  'H',  'J',  'K'},
  {'Y',  'X',  'C',  'V',  'B',  'N',  'M',  ','}
}

----------------------------------------------------------------------------------------------------
-- Profiles
----------------------------------------------------------------------------------------------------

Profile.new('eventhorizon', mash, {
  ["Atom"]          = {Action.Grid(0, 0, 1, 1, 1)},
  ["Google Chrome"] = {Action.Grid(0, 0, 2/3, 1, 2)},
  ["iTerm2"]        = {Action.Grid(0, 1/2, 1, 1/2, 1)},
  ["iTunes"]        = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["MacPass"]       = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["Mail"]          = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["Reeder"]        = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["Safari"]        = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["SourceTree"]    = {Action.Grid(0, 0, 2/3, 1, 1)},
  ["Terminal"]      = {Action.Grid(0, 1/2, 1, 1/2, 1), Action.DoAfter(animationDelay, Action.PositionBottomRight())},
  ["TextMate"]      = {Action.Grid(1/2, 0, 1/2, 1, 1)},
  ["Xcode"]         = {Action.Grid(0, 0, 1, 1, 1)},
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


Profile.new('singularity', mash, {
  ["Atom"]              = {Action.MoveToScreen(1), Action.Maximize()},
  ["Dash"]              = {Action.MoveToScreen(2), Action.Maximize()},
  ["Google Chrome"]     = {Action.MoveToScreen(2), Action.Maximize()},
  ["iTerm2"]            = {Action.MoveToScreen(1), Action.Maximize()},
  ["iTunes"]            = {Action.MoveToScreen(2), Action.Maximize()},
  ["MacPass"]           = {Action.MoveToScreen(2), Action.Maximize()},
  ["MacVim"]            = {Action.MoveToScreen(1), Action.Maximize()},
  ["Neovim"]            = {Action.MoveToScreen(1), Action.Maximize()},
  ["Parallels Desktop"] = {Action.MoveToScreen(2), Action.Maximize()},
  ["Reeder"]            = {Action.MoveToScreen(2), Action.Maximize()},
  ["Safari"]            = {Action.MoveToScreen(2), Action.Maximize()},
  ["SourceTree"]        = {Action.MoveToScreen(2), Action.Maximize()},
  ["Terminal"]          = {Action.MoveToScreen(1), Action.Maximize()},
  ["Tower"]             = {Action.MoveToScreen(2), Action.Maximize()},
  ["Xcode"]             = {Action.MoveToScreen(1), Action.Maximize()},
  ["_"]                 = {Action.Snap()}
}, {
  ['b'] = 'Safari',
  ['d'] = 'Dash',
  ['e'] = 'MacVim',
  ['f'] = 'Finder',
  ['g'] = 'Tower',
  ['i'] = 'iTunes',
  ['m'] = 'Activity Monitor',
  ['p'] = 'Parallels Desktop',
  ['r'] = 'Reeder',
  ['s'] = 'MacPass',
  ['t'] = 'iTerm',
  ['x'] = 'Xcode',
})

Profile.watch()

----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------

hs.hotkey.bind(mash, 'UP',    function() Action.Grid(0, 0, 1, 1)(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, 'DOWN',  function() Action.MoveToNextScreen()(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, 'LEFT',  function() Action.Grid(0, 0, 1/2, 1)(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, 'RIGHT', function() Action.Grid(1/2, 0, 1/2, 1)(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, 'SPACE', function() Profile.detectAndChange() end)
hs.hotkey.bind(mash, '1',     function() expose:toggleShow() end)
hs.hotkey.bind(mash, '2',     function() hs.grid.toggleShow() end)
