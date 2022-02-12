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

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload)
configWatcher:start()

local moonlanderModeActive = false

----------------------------------------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------------------------------------

local modifier = {
    cmd = "cmd",
    shift = "shift",
    ctrl = "ctrl",
    option = "alt",
}

local modifiers = {
    hyper = { modifier.cmd, modifier.shift, modifier.ctrl, modifier.option },
    window = { modifier.ctrl, modifier.option },
    clipboard = { modifier.ctrl, modifier.cmd }
}

local bundleID = {
    activityMonitor = "com.apple.ActivityMonitor",
    finder = "com.apple.finder",
    firefox = "org.mozilla.firefox",
    intellij = "com.jetbrains.intellij",
    iterm = "com.googlecode.iterm2",
    outlook = "com.microsoft.Outlook",
    postman = "com.postmanlabs.mac",
    reeder = "com.reederapp.5.macOS",
    safari = "com.apple.Safari",
    spotify = "com.spotify.client",
    strongbox = "com.markmcguill.strongbox.mac",
    teams = "com.microsoft.teams",
    tower = "com.fournova.Tower3",
    vsCode = "com.microsoft.VSCode"
}

local usbDevice = {
    moonlander = "Moonlander Mark I"
}

local function languageIsGerman() return hs.host.locale.preferredLanguages()[1]:sub(0, 2) == "de" end

local function maximizeCurrentWindow() hs.window.focusedWindow():maximize() end

local function centerCurrentWindow() hs.window.focusedWindow():centerOnScreen() end

local function moveCurrentWindowToLeftHalf()
    local win = hs.window.focusedWindow()
    local screenFrame = win:screen():frame()
    local newFrame = hs.geometry.rect(screenFrame.x, screenFrame.y, screenFrame.w / 2, screenFrame.h)
    win:setFrame(newFrame)
end

local function moveCurrentWindowToRightHalf()
    local win = hs.window.focusedWindow()
    local screenFrame = win:screen():frame()
    local newFrame = hs.geometry.rect(screenFrame.x + screenFrame.w / 2, screenFrame.y, screenFrame.w / 2, screenFrame.h)
    win:setFrame(newFrame)
end

local function moveMouseToWindowCenter()
    local windowCenter = hs.window.frontmostWindow():frame().center
    hs.mouse.absolutePosition(windowCenter)
end

local function moveMouseToUpperLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h / 4)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToUpperRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h / 4)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToLowerLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 4, screenFrame.y + screenFrame.h * 3 / 4)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToLowerRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 3 / 4, screenFrame.y + screenFrame.h * 3 / 4)
    hs.mouse.absolutePosition(newPoint)
end

----------------------------------------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------------------------------------

local function menuItems()
    return {
        {
            title = "Hammerspoon " .. hs.processInfo.version,
            disabled = true
        },
        { title = "-" },
        {
            title = "Moonlander Mode",
            checked = moonlanderModeActive,
            fn = function() moonlanderDetected(not moonlanderModeActive) end
        },
        { title = "-" },
        {
            title = "Reload",
            fn = hs.reload
        },
        {
            title = "Console...",
            fn = hs.openConsole
        },
        { title = "-" },
        {
            title = "Quit",
            fn = function() hs.application.get(hs.processInfo.processID):kill() end
        }
    }
end

menu = hs.menubar.new()
menu:setMenu(menuItems)

----------------------------------------------------------------------------------------------------
-- Moonlander Detection
----------------------------------------------------------------------------------------------------

local moonlanderMode = {
    [false] = {
        keyboardLayout = "German",
        icon = hs.configdir .. "/assets/statusicon_off.tiff"
    },
    [true] = {
        keyboardLayout = "U.S.",
        icon = hs.configdir .. "/assets/statusicon_on.tiff"
    }
}

local function isDeviceMoonlander(device) return device.productName == usbDevice.moonlander end

function moonlanderDetected(connected)
    moonlanderModeActive = connected
    hs.keycodes.setLayout(moonlanderMode[connected].keyboardLayout)
    menu:setIcon(moonlanderMode[connected].icon)
end

local function searchMoonlander()
    local usbDevices = hs.usb.attachedDevices()
    local moonlanderConnected = hs.fnutils.find(usbDevices, isDeviceMoonlander) ~= nil

    moonlanderDetected(moonlanderConnected)
end

searchMoonlander()

usbWatcher = hs.usb.watcher.new(function(event)
    if event.productName == usbDevice.moonlander then
        moonlanderDetected(event.eventType == "added")
    end
end)
usbWatcher:start()

caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        searchMoonlander()
    end
end)
caffeinateWatcher:start()

----------------------------------------------------------------------------------------------------
-- Keyboard Shortcuts
----------------------------------------------------------------------------------------------------

hs.hotkey.bind(modifiers.window, hs.keycodes.map.left, moveCurrentWindowToLeftHalf)
hs.hotkey.bind(modifiers.window, hs.keycodes.map.right, moveCurrentWindowToRightHalf)
hs.hotkey.bind(modifiers.window, hs.keycodes.map["return"], maximizeCurrentWindow)
hs.hotkey.bind(modifiers.window, "c", centerCurrentWindow)

hs.hotkey.bind(modifiers.hyper, "[", moveMouseToWindowCenter)
hs.hotkey.bind(modifiers.hyper, "m", moveMouseToUpperLeft)
hs.hotkey.bind(modifiers.hyper, "o", moveMouseToUpperRight)
hs.hotkey.bind(modifiers.hyper, hs.keycodes.map.up, moveMouseToLowerLeft)
hs.hotkey.bind(modifiers.hyper, hs.keycodes.map.down, moveMouseToLowerRight)
hs.hotkey.bind(modifiers.hyper, hs.keycodes.map.delete, function() hs.caffeinate.lockScreen() end)
hs.hotkey.bind(modifiers.hyper, "a", function() hs.application.launchOrFocusByBundleID(bundleID.activityMonitor) end)
hs.hotkey.bind(modifiers.hyper, "c", function() hs.application.launchOrFocusByBundleID(bundleID.safari) end)
hs.hotkey.bind(modifiers.hyper, "d", function() hs.application.launchOrFocusByBundleID(bundleID.vsCode) end)
hs.hotkey.bind(modifiers.hyper, "f", function() hs.application.launchOrFocusByBundleID(bundleID.finder) end)
hs.hotkey.bind(modifiers.hyper, "g", function() hs.application.launchOrFocusByBundleID(bundleID.tower) end)
hs.hotkey.bind(modifiers.hyper, "p", function() hs.application.launchOrFocusByBundleID(bundleID.postman) end)
hs.hotkey.bind(modifiers.hyper, "r", function() hs.application.launchOrFocusByBundleID(bundleID.reeder) end)
hs.hotkey.bind(modifiers.hyper, "s", function() hs.application.launchOrFocusByBundleID(bundleID.strongbox) end)
hs.hotkey.bind(modifiers.hyper, "t", function() hs.application.launchOrFocusByBundleID(bundleID.iterm) end)
hs.hotkey.bind(modifiers.hyper, "v", function() hs.application.launchOrFocusByBundleID(bundleID.outlook) end)
hs.hotkey.bind(modifiers.hyper, "w", function() hs.application.launchOrFocusByBundleID(bundleID.intellij) end)
hs.hotkey.bind(modifiers.hyper, "x", function() hs.application.launchOrFocusByBundleID(bundleID.teams) end)
hs.hotkey.bind({ modifier.cmd }, "\\", function()
    local application = hs.application.frontmostApplication()

    if application:bundleID() == bundleID.strongbox then
        application:hide()
    else
        hs.application.launchOrFocusByBundleID(bundleID.strongbox)
    end
end)

----------------------------------------------------------------------------------------------------
-- Mouse Shortcuts
----------------------------------------------------------------------------------------------------

local function handleMouse2()
    local application = hs.application.frontmostApplication()

    -- Safari: Close tab
    if application:bundleID() == bundleID.safari then
        hs.eventtap.keyStroke({ modifier.cmd }, "w")
    
        -- Firefox: Close tab
    elseif application:bundleID() == bundleID.firefox then
        hs.eventtap.keyStroke({ modifier.cmd }, "w")

        -- Teams: End call
    elseif application:bundleID() == bundleID.teams then
        hs.eventtap.keyStroke({ modifier.cmd, modifier.shift }, "h")

        -- Spotify: Toggle play
    elseif application:bundleID() == bundleID.spotify then
        hs.eventtap.keyStroke({}, "space")
    end
end

local function handleMouse3()
    local application = hs.application.frontmostApplication()

    -- Safari: Back
    if application:bundleID() == bundleID.safari then
        if languageIsGerman() then
            application:selectMenuItem({ "Verlauf", "Zurück" })
        else
            application:selectMenuItem({ "History", "Back" })
        end
    
        -- Firefox: Back
    elseif application:bundleID() == bundleID.firefox then
        hs.eventtap.keyStroke({ modifier.cmd }, "left")

        -- Teams: Toggle mute
    elseif application:bundleID() == bundleID.teams then
        hs.eventtap.keyStroke({ modifier.cmd, modifier.shift }, "m")

        -- Spotify: Next
    elseif application:bundleID() == bundleID.spotify then
        hs.eventtap.keyStroke({ modifier.cmd }, "right")

        -- Reeder: Open in Safari
    elseif application:bundleID() == bundleID.reeder then
        hs.eventtap.keyStroke({}, "b")

        -- Other: Copy to clipboard
    else
        hs.eventtap.keyStroke({ "cmd" }, "c")
    end
end

local function handleMouse4()
    local application = hs.application.frontmostApplication()

    -- Safari: Forward
    if application:bundleID() == bundleID.safari then
        if languageIsGerman() then
            application:selectMenuItem({ "Verlauf", "Vorwärts" })
        else
            application:selectMenuItem({ "History", "Forward" })
        end
    
        -- Firefox: Forward
    elseif application:bundleID() == bundleID.firefox then
        hs.eventtap.keyStroke({ modifier.cmd }, "right")

        -- Teams: Toggle video
    elseif application:bundleID() == bundleID.teams then
        hs.eventtap.keyStroke({ modifier.cmd, modifier.shift }, "o")

        -- Spotify: Previous
    elseif application:bundleID() == bundleID.spotify then
        hs.eventtap.keyStroke({ modifier.cmd }, "left")

        -- Reeder: Mark all as read
    elseif application:bundleID() == bundleID.reeder then
        hs.eventtap.keyStroke({}, "a")

        -- Other: Paste from clipboard
    else
        hs.eventtap.keyStroke({ modifier.cmd }, "v")
    end
end

mouseTap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
    if event:getButtonState(2) then
        handleMouse2()
    elseif event:getButtonState(3) then
        handleMouse3()
    elseif event:getButtonState(4) then
        handleMouse4()
    end
    return true
end)
mouseTap:start()

----------------------------------------------------------------------------------------------------
-- Clipboard Manager
----------------------------------------------------------------------------------------------------

clipboard = require("clipboard")
clipboard:start()

hs.hotkey.bind(modifiers.clipboard, "v", function() clipboard:toggleClipboard() end)
hs.hotkey.bind(modifiers.clipboard, hs.keycodes.map.delete, function() clipboard:clearAll() end)
