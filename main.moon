require 'moonscript'

import HotkeyModal from require 'hotkey_modal'
import Grid from require 'grid'
import Profile from require 'profile'
Action = require 'action'


----------------------------------------------------------------------------------------------------
-- Profiles
----------------------------------------------------------------------------------------------------
grid1 = Grid(6, 6)

homeScreens = {69671680}
homeConfig = {
  "iTunes":     {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.7, h: 1.0})}
  "Mail":       {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.7, h: 1.0})}
  "Safari":     {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.7, h: 1.0})}
  "SourceTree": {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.7, h: 1.0})}
  "Spotify":    {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.8, h: 1.0})}
  "Terminal":   {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.5, y: 0.5, w: 0.5, h: 0.5})}
  "TextMate":   {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.5, y: 0.0, w: 0.5, h: 1.0})}
  "Xcode":      {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.7, h: 1.0})}
  "_":          {Action.Snap(grid1)}
}

home = Profile('Home', homeScreens, homeConfig)

----------------------------------------------------------------------------------------------------

workScreens = {188898833, 188898834}
workConfig = {
  "Dash":              {Action.MoveToScreen(2), Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.5, h: 1.0})}
  "iTunes":            {Action.Close!}
  "Parallels Desktop": {Action.MoveToScreen(2), Action.FullScreen!}
  "Safari":            {Action.MoveToScreen(2), Action.MoveToUnit({x: 0.0, y: 0.0, w: 1.0, h: 1.0})}
  "SourceTree":        {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 1.0, h: 1.0})}
  "Terminal":          {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.5, y: 0.5, w: 0.5, h: 0.5})}
  "TextMate":          {Action.MoveToScreen(2), Action.MoveToUnit({x: 0.5, y: 0.0, w: 0.5, h: 1.0})}
  "Xcode":             {Action.MoveToScreen(1), Action.MoveToUnit({x: 0.0, y: 0.0, w: 1.0, h: 1.0})}
  "_":                 {Action.Snap(grid1)}
}

work = Profile('Work', workScreens, workConfig)

----------------------------------------------------------------------------------------------------

profiles = {home, work}

activeProfile = ->
  for profile in *profiles
    if profile\isActive! then return profile
  return nil

checkKnownProfile = ->
  if activeProfile! == nil
    hs.alert.show("unknown profile, see console for screen information", 3)
    for screen in *hs.screen.allScreens!
      print("unknown screen: #{screen\id!}")

activateActiveProfile = ->
  profile = activeProfile!
  if profile then profile\activate!

launchOrFocusApp = (appName) -> hs.application.launchOrFocus(appName)
 
launchOrActivateApp = (appName) ->
  wasAlreadyRunning = hs.appfinder.appFromName(appName) != nil
  hs.application.launchOrFocus(appName)
  if wasAlreadyRunning then
    profile = activeProfile!
    if profile then profile\activateFor(appName)
   
----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------

splitModifiers = {'ctrl', 'alt', 'cmd'}
modalModifiers = {'cmd', 'alt'}
arrangementModifiers = {'cmd', 'shift'}

hs.hotkey.bind(splitModifiers, 'UP', Action.Maximize!\perform)
hs.hotkey.bind(splitModifiers, 'DOWN', Action.MoveToNextScreen!\perform)
hs.hotkey.bind(splitModifiers, 'LEFT', Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.5, h: 1.0})\perform)
hs.hotkey.bind(splitModifiers, 'RIGHT', Action.MoveToUnit({x: 0.5, y: 0.0, w: 0.5, h: 1.0})\perform)
hs.hotkey.bind(splitModifiers, 'SPACE', grid1\snapAll)

position = HotkeyModal('Position', modalModifiers, '1')
position\bind({}, 'UP', grid1\positionTopRight)
position\bind({}, 'DOWN', grid1\positionBottomLeft)
position\bind({}, 'LEFT', grid1\positionTopLeft)
position\bind({}, 'RIGHT', grid1\positionBottomRight)
position\bind({}, 'RETURN', position\exit)

resize = HotkeyModal('Resize', modalModifiers, '2')
resize\bind({}, 'UP', grid1\resizeShorter)
resize\bind({}, 'DOWN', grid1\resizeTaller)
resize\bind({}, 'LEFT', grid1\resizeThinner)
resize\bind({}, 'RIGHT', grid1\resizeWider)
resize\bind({}, 'RETURN', resize\exit)

move = HotkeyModal('Move', modalModifiers, '3')
move\bind({}, 'UP', grid1\moveUp)
move\bind({}, 'DOWN', grid1\moveDown)
move\bind({}, 'LEFT', grid1\moveLeft)
move\bind({}, 'RIGHT', grid1\moveRight)
move\bind({}, 'RETURN', move\exit)

appShortcuts = {
  'd': 'Dash'
  'e': 'TextMate'
  'f': 'Finder'
  'g': 'SourceTree'
  'i': 'iTunes'
  'm': 'Mail'
  'p': 'Parallels Desktop'
  's': 'Safari'
  't': 'Terminal'
  'x': 'Xcode'
}
for shortcut, appName in pairs(appShortcuts)
  hs.hotkey.bind(modalModifiers, shortcut, -> launchOrFocusApp(appName))
  hs.hotkey.bind(splitModifiers, shortcut, -> launchOrActivateApp(appName))

hs.hotkey.bind(arrangementModifiers, '1', -> activateActiveProfile!)
hs.hotkey.bind(arrangementModifiers, '2', -> home\activate!)
hs.hotkey.bind(arrangementModifiers, '3', -> work\activate!)

----------------------------------------------------------------------------------------------------
-- Settings and Watcher
----------------------------------------------------------------------------------------------------
hs.window.animationDuration = 0.1

hs.screen.watcher.new(-> activateActiveProfile!)\start!
hs.pathwatcher.new(hs.configdir, (files) -> hs.reload!)\start!
hs.alert.show("Hammerspoon loaded", 1)

checkKnownProfile!
