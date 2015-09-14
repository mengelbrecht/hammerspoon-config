require 'action'
require 'hotkey_modal'
require 'profile'

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------

hs.window.animationDuration = 0.15
hs.grid.setMargins({0, 0})
hs.grid.setGrid({6, 4})
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

Profile.new('Home', {69671680}, {
  ["Atom"]          = {Action.MoveToScreen(1), Action.Maximize()},
  ["Google Chrome"] = {Action.MoveToScreen(2), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["iTunes"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Mail"]          = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Reeder"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Safari"]        = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["SourceTree"]    = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.0, 0.7, 1.0)},
  ["Terminal"]      = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.5, 1.0, 0.5), Action.PositionBottomRight()},
  ["TextMate"]      = {Action.MoveToScreen(1), Action.MoveToUnit(0.5, 0.0, 0.5, 1.0)},
  ["Xcode"]         = {Action.MoveToScreen(1), Action.Maximize()},
  ["_"]             = {Action.Snap()}
})

----------------------------------------------------------------------------------------------------

Profile.new('Work', {2077750397, 188898833, 188898834, 188898835, 188898836, 188915586}, {
  ["Atom"]              = {Action.MoveToScreen(1), Action.Maximize()},
  ["Dash"]              = {Action.MoveToScreen(2), Action.MoveToUnit(0.0, 0.0, 0.5, 1.0)},
  ["Google Chrome"]     = {Action.MoveToScreen(2), Action.Maximize()},
  ["iTunes"]            = {Action.Close()},
  ["Parallels Desktop"] = {Action.MoveToScreen(2), Action.FullScreen()},
  ["Safari"]            = {Action.MoveToScreen(2), Action.Maximize()},
  ["SourceTree"]        = {Action.MoveToScreen(1), Action.Maximize()},
  ["Terminal"]          = {Action.MoveToScreen(1), Action.MoveToUnit(0.0, 0.5, 1.0, 0.5), Action.PositionBottomRight()},
  ["TextMate"]          = {Action.MoveToScreen(2), Action.MoveToUnit(0.5, 0.0, 0.5, 1.0)},
  ["Tower"]             = {Action.MoveToScreen(1), Action.Maximize()},
  ["Xcode"]             = {Action.MoveToScreen(1), Action.Maximize()},
  ["_"]                 = {Action.Snap()}
})

----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------

local mash = {'ctrl', 'alt'}

function focusedWin() return hs.window.focusedWindow() end

hs.hotkey.bind(mash, 'UP',    function() Action.Maximize()(focusedWin()) end)
hs.hotkey.bind(mash, 'DOWN',  function() Action.MoveToNextScreen()(focusedWin()) end)
hs.hotkey.bind(mash, 'LEFT',  function() Action.MoveToUnit(0.0, 0.0, 0.5, 1.0)(focusedWin()) end)
hs.hotkey.bind(mash, 'RIGHT', function() Action.MoveToUnit(0.5, 0.0, 0.5, 1.0)(focusedWin()) end)
hs.hotkey.bind(mash, 'SPACE', function() utils.snapAll() end)
hs.hotkey.bind(mash, 'H',     function() hs.hints.windowHints() end)
hs.hotkey.bind(mash, 'G',     function() hs.grid.toggleShow() end)
hs.hotkey.bind(mash, '^',     function() Profile.activateActiveProfile() end)

local position = HotkeyModal.new('Position', mash, '1')
position:bind({}, 'UP',     function() Action.PositionBottomLeft()(focusedWin()) end)
position:bind({}, 'DOWN',   function() Action.PositionBottomRight()(focusedWin()) end)
position:bind({}, 'LEFT',   function() Action.PositionTopLeft()(focusedWin()) end)
position:bind({}, 'RIGHT',  function() Action.PositionTopRight()(focusedWin()) end)
position:bind({}, 'RETURN', function() position:exit() end)

local resize = HotkeyModal.new('Resize', mash, '2')
resize:bind({}, 'UP',     function() hs.grid.resizeWindowShorter() end)
resize:bind({}, 'DOWN',   function() hs.grid.resizeWindowTaller() end)
resize:bind({}, 'LEFT',   function() hs.grid.resizeWindowThinner() end)
resize:bind({}, 'RIGHT',  function() hs.grid.resizeWindowWider() end)
resize:bind({}, 'RETURN', function() resize:exit() end)

local move = HotkeyModal.new('Move', mash, '3')
move:bind({}, 'UP',     function() hs.grid.pushWindowUp() end)
move:bind({}, 'DOWN',   function() hs.grid.pushWindowDown() end)
move:bind({}, 'LEFT',   function() hs.grid.pushWindowLeft() end)
move:bind({}, 'RIGHT',  function() hs.grid.pushWindowRight() end)
move:bind({}, 'RETURN', function() move:exit() end)

local appShortcuts = {
  ['a'] = 'Atom',
  ['c'] = 'Google Chrome',
  ['d'] = 'Dash',
  ['e'] = 'TextMate',
  ['f'] = 'Finder',
  ['g'] = 'Tower',
  ['m'] = 'iTunes',
  ['p'] = 'Parallels Desktop',
  ['t'] = 'Terminal',
  ['x'] = 'Xcode',
}

for shortcut, appName in pairs(appShortcuts) do
  hs.hotkey.bind({'alt', 'cmd'}, shortcut, function() hs.application.launchOrFocus(appName) end)
end

----------------------------------------------------------------------------------------------------
-- Watcher
----------------------------------------------------------------------------------------------------

function appEvent(appName, event) if event == hs.application.watcher.launched then Profile.activateForApp(appName) end end
function pathEvent(files) hs.reload() end
function screenEvent() Profile.activateActiveProfile() end

hs.application.watcher.new(appEvent):start()
hs.pathwatcher.new(hs.configdir, pathEvent):start()
hs.screen.watcher.new(screenEvent):start()

screenEvent()
