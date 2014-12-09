require 'moonscript'

import unpack from table


class Profile
  new: (title, screens, config) =>
    @title = title
    @screens = screens
    @config = config

  isActive: =>
    for screen in *hs.screen.allScreens()
      if hs.fnutils.contains(@screens, screen\id!) then return true
    return false

  activateFor: (appname) =>
    app = hs.appfinder.appFromName(appname)
    if not app then return {}
    actions = @config[appname]
    windows = app\allWindows!
    for action in *actions
      for win in *windows do action\perform(win)
    return windows

  activate: =>
    hs.alert.show("Arranging #{@title}", 1)
    processed = [w for appname, _ in pairs(@config) for w in *@activateFor(appname)]

    -- Apply actions to all remaining windows
    actions = @config["_"]
    if not actions then return
    
    windows = [w for w in *hs.window.allWindows! when not hs.fnutils.contains(processed, w)]
    for action in *actions
      for win in *windows do action\perform(win)


{
  :Profile
}
