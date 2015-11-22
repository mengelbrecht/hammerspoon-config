Profile = {}
Profile.__index = Profile

local profiles = {}

function Profile.new(title, screens, modifiers, config, shortcuts)
  local m = setmetatable({}, Profile)
  m.title = title
  m.screens = screens
  m.config = config
  m.shortcuts = shortcuts
  m.active = false
  m.hotkeys = {}
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
  if not actions then return end

  for _, action in pairs(actions) do
    local mainWindow = app:mainWindow()
    for _, win in pairs(app:allWindows()) do
      if win:isStandard() then action(win) end
      if mainWindow and win:id() == mainWindow:id() then mainWindow = nil end
    end

    if mainWindow then action(mainWindow) end
  end
end

function Profile:isActive()
  return self.active
end

function Profile:isDesignated()
  return hs.fnutils.some(hs.screen.allScreens(), function(screen) return hs.fnutils.contains(self.screens, screen:id()) end)
end

function Profile:deactivate()
  self:_disableHotkeys()
  self.active = false
end

function Profile:activate()
  local activeProfile = Profile.active()
  if activeProfile and activeProfile ~= self then activeProfile:deactivate() end

  if activeProfile ~= self then self:_enableHotkeys() end
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

----------------------------------------------------------------------------------------------------

return Profile
