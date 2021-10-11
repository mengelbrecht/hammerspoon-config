----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.consoleOnTop(true)
hs.dockIcon(false)
hs.menuIcon(false)
hs.uploadCrashData(false)

hs.window.animationDuration = 0

local log = hs.logger.new('init', 'debug')

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

----------------------------------------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------------------------------------

menu = hs.menubar.new()
menu:setMenu({
  { title = 'Hammerspoon ' .. hs.processInfo.version, disabled = true },
  { title = '-' },
  { title = 'Reload', fn = hs.reload },
  { title = 'Console...', fn = hs.openConsole },
  { title = '-' },
  { title = 'Quit', fn = function() hs.application.get(hs.processInfo.processID):kill() end }
})

----------------------------------------------------------------------------------------------------
-- Moonlander Detection
----------------------------------------------------------------------------------------------------

function isDeviceMoonlander(device) 
  return device.productName == "Moonlander Mark I" 
end

function moonlanderDetected(connected)
  if connected then
    hs.keycodes.setLayout("U.S.")
    menu:setIcon(hs.configdir .. '/assets/statusicon_on.tiff')
  else
    hs.keycodes.setLayout("German")
    menu:setIcon(hs.configdir .. '/assets/statusicon_off.tiff')
  end
end

function searchMoonlander()
  local usbDevices = hs.usb.attachedDevices()
  local moonlanderConnected = hs.fnutils.find(usbDevices, isDeviceMoonlander) ~= nil
  
  moonlanderDetected(moonlanderConnected)  
end

searchMoonlander()

usbWatcher = hs.usb.watcher.new(function(event)
  if event.productName == "Moonlander Mark I" then
    moonlanderDetected(event.eventType == "added")
  end
end):start()

caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.systemDidWake then
    searchMoonlander()
  end
end):start()

----------------------------------------------------------------------------------------------------
-- Shortcuts
----------------------------------------------------------------------------------------------------

local hyperModifier = {"cmd", "shift", "ctrl", "alt"}
local windowModifier = {"ctrl", "alt"}

function maximizeCurrentWindow() 
  hs.window.focusedWindow():maximize() 
end

function moveCurrentWindowToNextScreen()
  local win = hs.window.focusedWindow()
  win:moveToScreen(win:screen():next())
end

function moveCurrentWindowToLeftHalf()
  local win = hs.window.focusedWindow()
  local screenFrame = win:screen():frame()
  win:setFrame(hs.geometry.rect(screenFrame.x, screenFrame.y, screenFrame.w / 2, screenFrame.h))
end

function moveCurrentWindowToRightHalf()
  local win = hs.window.focusedWindow()
  local screenFrame = win:screen():frame()
  win:setFrame(hs.geometry.rect(screenFrame.x + screenFrame.w / 2, screenFrame.y, screenFrame.w / 2, screenFrame.h))
end

function moveMouseToWindowCenter()
  local windowCenter = hs.window.frontmostWindow():frame().center
  hs.mouse.absolutePosition(windowCenter)
end

function moveMouseToUpperLeft()
  local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
  hs.mouse.absolutePosition(hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h / 4))
end

function moveMouseToUpperRight()
  local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
  hs.mouse.absolutePosition(hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h / 4))
end

function moveMouseToLowerLeft()
  local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
  hs.mouse.absolutePosition(hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h * 3 / 4))
end

function moveMouseToLowerRight()
  local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
  hs.mouse.absolutePosition(hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h * 3 / 4))
end

hs.hotkey.bind(hyperModifier, "[", moveMouseToWindowCenter)
hs.hotkey.bind(hyperModifier, "m", moveMouseToUpperLeft)
hs.hotkey.bind(hyperModifier, "o", moveMouseToUpperRight)
hs.hotkey.bind(hyperModifier, "up", moveMouseToLowerLeft)
hs.hotkey.bind(hyperModifier, "down", moveMouseToLowerRight)
hs.hotkey.bind(hyperModifier, "delete", function() hs.caffeinate.lockScreen() end)
hs.hotkey.bind(hyperModifier, "a", function() hs.application.launchOrFocusByBundleID("com.apple.ActivityMonitor") end)
hs.hotkey.bind(hyperModifier, "c", function() hs.application.launchOrFocusByBundleID("com.apple.Safari") end)
hs.hotkey.bind(hyperModifier, "d", function() hs.application.launchOrFocusByBundleID("com.microsoft.VSCode") end)
hs.hotkey.bind(hyperModifier, "f", function() hs.application.launchOrFocusByBundleID("com.apple.finder") end)
hs.hotkey.bind(hyperModifier, "g", function() hs.application.launchOrFocusByBundleID("com.fournova.Tower3") end)
hs.hotkey.bind(hyperModifier, "p", function() hs.application.launchOrFocusByBundleID("com.postmanlabs.mac") end)
hs.hotkey.bind(hyperModifier, "r", function() hs.application.launchOrFocusByBundleID("com.reederapp.5.macOS") end)
hs.hotkey.bind(hyperModifier, "s", function() hs.application.launchOrFocusByBundleID("com.markmcguill.strongbox.mac") end)
hs.hotkey.bind(hyperModifier, "t", function() hs.application.launchOrFocusByBundleID("com.googlecode.iterm2") end)
hs.hotkey.bind(hyperModifier, "v", function() hs.application.launchOrFocusByBundleID("com.microsoft.Outlook") end)
hs.hotkey.bind(hyperModifier, "w", function() hs.application.launchOrFocusByBundleID("com.jetbrains.intellij") end)
hs.hotkey.bind(hyperModifier, "x", function() hs.application.launchOrFocusByBundleID("com.microsoft.Teams") end)
hs.hotkey.bind({'cmd'}, "\\", function()
  local application = hs.application.frontmostApplication()
  if (application:bundleID() == "com.markmcguill.strongbox.mac") then
    application:hide()
  else
    hs.application.launchOrFocusByBundleID("com.markmcguill.strongbox.mac")
  end
end)
