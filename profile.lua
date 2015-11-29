Profile = {}
Profile.__index = Profile

local profiles = {}
local watcher = nil
local showConsoleTag = "showconsole"

function Profile.new(title, screens, modifiers, config, shortcuts)
  local m = setmetatable({}, Profile)
  m.title = title
  m.screens = screens
  m.config = config
  m.shortcuts = shortcuts
  m.active = false
  m.hotkeys = {}

  m.windowFilter = hs.window.filter.new()
    :setDefaultFilter({fullscreen=false, allowTitles=1})
    :subscribe(hs.window.filter.windowVisible, function(win, appName, event)
      local app = hs.application.find(appName)
      if app then m:arrange(app) end
    end)
    :pause()

  for key, app in pairs(shortcuts) do
    table.insert(m.hotkeys, hs.hotkey.new(modifiers, key, function() hs.application.launchOrFocus(app) end))
  end
  table.insert(profiles, m)
  return m
end

function Profile:_actionsFor(appName)
  local actions = self.config[appName]
  if actions then return actions else return self.config["_"] end
end

function Profile:_disableHotkeys()
  for _, hotkey in pairs(self.hotkeys) do hotkey:disable() end
end

function Profile:_enableHotkeys()
  for _, shortcut in pairs(self.hotkeys) do shortcut:enable() end
end

function Profile:_arrangeAll()
  for _, app in pairs(hs.application.runningApplications()) do self:arrange(app) end
end

----------------------------------------------------------------------------------------------------

function Profile:arrange(app)
  local actions = self:_actionsFor(app:title())
  local mainWindow = app:mainWindow()
  if not actions or not mainWindow or not mainWindow:isStandard() then return end

  for _, action in pairs(actions) do action(mainWindow) end
end

function Profile:isActive()
  return self.active
end

function Profile:isDesignated()
  return hs.fnutils.some(hs.screen.allScreens(), function(screen) return hs.fnutils.contains(self.screens, screen:id()) end)
end

function Profile:deactivate()
  self:_disableHotkeys()
  self.windowFilter:pause()
  self.active = false
end

function Profile:activate()
  local activeProfile = Profile.active()
  if activeProfile and activeProfile ~= self then activeProfile:deactivate() end

  if activeProfile ~= self then
    self:_enableHotkeys()
    self.windowFilter:resume()
  end
  self:_arrangeAll()
  self.active = true
end

----------------------------------------------------------------------------------------------------

function Profile.active()
  return hs.fnutils.find(profiles, function(profile) return profile:isActive() end)
end

function Profile.designated()
  return hs.fnutils.find(profiles, function(profile) return profile:isDesignated() end)
end

function Profile.detectAndChange()
  local profile = Profile.designated()
  if not profile then
      hs.notify.show("Hammerspoon", "", "unknown profile, see console for screen information", showConsoleTag)

      for _, screen in pairs(hs.screen.allScreens()) do print("found screen: " .. screen:id()) end
      return
  end
  profile:activate()
end

function Profile.watch()
  if not watcher then
    hs.notify.register(showConsoleTag, function() hs.toggleConsole() end)
    watcher = hs.screen.watcher.new(Profile.detectAndChange)
  end
  watcher:start()
  Profile.detectAndChange() -- initial detection
end

function Profile.unwatch()
  if watcher then watcher:stop() end
end

----------------------------------------------------------------------------------------------------

return Profile
