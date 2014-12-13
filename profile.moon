require 'moonscript'

import unpack from table


class Profile
  new: (title, screens, config) =>
    @title = title
    @screens = screens
    @config = config

  _actionsFor: (appName) =>
    actions = @config[appName]
    if actions then actions else @config["_"]
    
  _activateForApp: (app) =>
    actions = @_actionsFor(app\title!)
    if actions then for action in *actions do for win in *app\allWindows! do action\perform(win)

  isActive: =>
    for screen in *hs.screen.allScreens()
      if hs.fnutils.contains(@screens, screen\id!) then return true
    return false

  activateFor: (appName) =>
    app = hs.appfinder.appFromName(appName)
    if app then @_activateForApp(app)

  activate: =>
    hs.alert.show("Arranging #{@title}", 1)
    for app in *hs.application.runningApplications! do @_activateForApp(app)


{
  :Profile
}
