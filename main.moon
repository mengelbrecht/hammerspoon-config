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

activateActiveProfile = ->
  for profile in *profiles
    if profile\isActive! then
      profile\activate!
      return
  hs.alert.show("unknown profile, see console for screen information")
  for screen in hs.screen.allScreens!
    print("unknown screen: #{screen\id!}")

----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------

modalModifiers = {'cmd', 'alt'}
arrangementModifiers = {'cmd', 'shift'}

split = HotkeyModal('Split', modalModifiers, '1')
split\bind({}, 'UP', -> Action.Maximize!\perform!)
split\bind({}, 'DOWN', -> Action.MoveToNextScreen!\perform!)
split\bind({}, 'LEFT', -> Action.MoveToUnit({x: 0.0, y: 0.0, w: 0.5, h: 1.0})\perform!)
split\bind({}, 'RIGHT', -> Action.MoveToUnit({x: 0.5, y: 0.0, w: 0.5, h: 1.0})\perform!)
split\bind({}, 'SPACE', grid1\snapAll)
split\bind({}, 'RETURN', split\exit)

position = HotkeyModal('Position', modalModifiers, '2')
position\bind({}, 'UP', grid1\positionTopRight)
position\bind({}, 'DOWN', grid1\positionBottomLeft)
position\bind({}, 'LEFT', grid1\positionTopLeft)
position\bind({}, 'RIGHT', grid1\positionBottomRight)
position\bind({}, 'RETURN', position\exit)

resize = HotkeyModal('Resize', modalModifiers, '3')
resize\bind({}, 'UP', grid1\resizeShorter)
resize\bind({}, 'DOWN', grid1\resizeTaller)
resize\bind({}, 'LEFT', grid1\resizeThinner)
resize\bind({}, 'RIGHT', grid1\resizeWider)
resize\bind({}, 'RETURN', resize\exit)

move = HotkeyModal('Move', modalModifiers, '4')
move\bind({}, 'UP', grid1\moveUp)
move\bind({}, 'DOWN', grid1\moveDown)
move\bind({}, 'LEFT', grid1\moveLeft)
move\bind({}, 'RIGHT', grid1\moveRight)
move\bind({}, 'RETURN', move\exit)

hs.hotkey.bind(arrangementModifiers, '1', -> activateActiveProfile!)
hs.hotkey.bind(arrangementModifiers, '2', -> home\activate!)
hs.hotkey.bind(arrangementModifiers, '3', -> work\activate!)

----------------------------------------------------------------------------------------------------
-- Settings and Watcher
----------------------------------------------------------------------------------------------------
hs.window.animationDuration = 0.1

hs.screen.watcher.new(-> activateActiveProfile!)\start!
hs.pathwatcher.new(hs.configdir, (files) -> hs.reload!)\start!
hs.alert.show("Hammerspoon loaded", 0.5)
