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

local maximizeMode = true

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
    hyper = { modifier.shift, modifier.ctrl, modifier.option, modifier.cmd },
    window = { modifier.ctrl, modifier.option },
    clipboard = { modifier.ctrl, modifier.cmd }
}

local bundleID = {
    activityMonitor = "com.apple.ActivityMonitor",
    finder = "com.apple.finder",
    firefox = "org.mozilla.firefox",
    googleChrome = "com.google.Chrome",
    intellij = "com.jetbrains.intellij",
    iterm = "com.googlecode.iterm2",
    outlook = "com.microsoft.Outlook",
    reeder = "com.reederapp.5.macOS",
    safari = "com.apple.Safari",
    teams = "com.microsoft.teams",
    vsCode = "com.microsoft.VSCode",
}

local font = {
    monospace = "Iosevka Code"
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

local function moveCurentWindowToNextScreen()
    local win = hs.window.focusedWindow()
    win:moveToScreen(win:screen():next())
end

local function moveMouseToWindowCenter()
    local windowCenter = hs.window.frontmostWindow():frame().center
    hs.mouse.absolutePosition(windowCenter)
end

local function moveMouseToUpperLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 6, screenFrame.y + screenFrame.h / 6)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToUpperRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 5 / 6, screenFrame.y + screenFrame.h / 6)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToLowerLeft()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w / 6, screenFrame.y + screenFrame.h * 5 / 6)
    hs.mouse.absolutePosition(newPoint)
end

local function moveMouseToLowerRight()
    local screenFrame = (hs.window.focusedWindow():screen() or hs.screen.primaryScreen()):frame()
    local newPoint = hs.geometry.point(screenFrame.x + screenFrame.w * 5 / 6, screenFrame.y + screenFrame.h * 5 / 6)
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
            title = "Maximize Mode",
            checked = maximizeMode,
            fn = function() maximizeMode = not maximizeMode end
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
menu:setIcon(hs.configdir .. "/assets/statusicon_on.tiff")

----------------------------------------------------------------------------------------------------
-- Window Management
----------------------------------------------------------------------------------------------------

local function timedAllWindows()
    local appTimes = {}
    for _, app in ipairs(hs.application.runningApplications()) do
        local name = app:name()
        if not hs.window.filter.ignoreAlways[name] then
            local start = hs.timer.absoluteTime()
            app:allWindows()
            appTimes[name] = (appTimes[name] or 0) + hs.timer.absoluteTime() - start
        end
    end
    for appName, time in hs.fnutils.sortByKeys(appTimes) do
        local timeMillis = time / 1000 / 1000
        if timeMillis >= 50 then
            print(string.format('took %.0fms for "%s"', timeMillis, appName))
        end
    end
end

hs.window.filter.ignoreAlways = {
    ["Familie"] = true,
    ["Mail-Webinhalt"] = true,
    ["Reeder Web Content"] = true,
    ["Safari-Webinhalt"] = true,
    ["Safari-Webinhalt (im Cache)"] = true,
}

maximizeWindows = {
    "App Store",
    "Brave Browser",
    "Code",
    "Firefox",
    "Fork",
    "Fotos",
    "Google Chrome",
    "IntelliJ IDEA",
    "iTerm2",
    "Kalender",
    "Mail",
    "Microsoft Outlook",
    "Microsoft Teams",
    "Music",
    "Musik",
    "Photos",
    "Reeder",
    "Safari",
    "Spotify",
}

windowFilter = hs.window.filter.new()
windowFilter:subscribe({ hs.window.filter.windowCreated, hs.window.filter.windowFocused }, function(window)
    if maximizeMode and 
       window ~= nil and 
       window:isStandard() and 
       window:frame().h > 500 and 
       hs.fnutils.contains(maximizeWindows, window:application():name()) 
    then
        window:maximize()
    end
end)

----------------------------------------------------------------------------------------------------
-- Keyboard Shortcuts
----------------------------------------------------------------------------------------------------

hs.hotkey.bind(modifiers.window, hs.keycodes.map.left, moveCurrentWindowToLeftHalf)
hs.hotkey.bind(modifiers.window, hs.keycodes.map.right, moveCurrentWindowToRightHalf)
hs.hotkey.bind(modifiers.window, hs.keycodes.map.down, moveCurentWindowToNextScreen)
hs.hotkey.bind(modifiers.window, hs.keycodes.map.up, maximizeCurrentWindow)
hs.hotkey.bind(modifiers.window, "c", centerCurrentWindow)

hs.hotkey.bind(modifiers.hyper, "n", moveCurrentWindowToLeftHalf)
hs.hotkey.bind(modifiers.hyper, "i", moveCurrentWindowToRightHalf)
hs.hotkey.bind(modifiers.hyper, "e", moveCurentWindowToNextScreen)
hs.hotkey.bind(modifiers.hyper, "o", maximizeCurrentWindow)
hs.hotkey.bind(modifiers.hyper, "8", centerCurrentWindow)
hs.hotkey.bind(modifiers.hyper, "l", moveMouseToUpperLeft)
hs.hotkey.bind(modifiers.hyper, "p", moveMouseToUpperRight)
hs.hotkey.bind(modifiers.hyper, "r", moveMouseToLowerLeft)
hs.hotkey.bind(modifiers.hyper, "t", moveMouseToLowerRight)
hs.hotkey.bind(modifiers.hyper, "s", moveMouseToWindowCenter)
hs.hotkey.bind(modifiers.hyper, "x", function() hs.application.launchOrFocusByBundleID(bundleID.teams) end)
hs.hotkey.bind(modifiers.hyper, "u", function() hs.application.launchOrFocusByBundleID(bundleID.iterm) end)
hs.hotkey.bind(modifiers.hyper, "f", function() hs.application.launchOrFocusByBundleID(bundleID.safari) end)
hs.hotkey.bind(modifiers.hyper, "m", function() hs.application.launchOrFocusByBundleID(bundleID.intellij) end)
hs.hotkey.bind(modifiers.hyper, "a", function() hs.application.launchOrFocusByBundleID(bundleID.vsCode) end)
hs.hotkey.bind(modifiers.hyper, "h", function() hs.application.launchOrFocusByBundleID(bundleID.firefox) end)
hs.hotkey.bind(modifiers.hyper, "z", function() hs.application.launchOrFocusByBundleID(bundleID.outlook) end)

----------------------------------------------------------------------------------------------------
-- Mouse Shortcuts
----------------------------------------------------------------------------------------------------

local function handleMouse2()
    local application = hs.application.frontmostApplication()

    -- Safari: Close tab
    if application:bundleID() == bundleID.safari then
        hs.eventtap.keyStroke({ modifier.cmd }, "w")

        -- Safari Technology Preview: Close tab
    elseif application:bundleID() == bundleID.safariTechnologyPreview then
        hs.eventtap.keyStroke({ modifier.cmd }, "w")

        -- Google Chrome: Close tab
    elseif application:bundleID() == bundleID.googleChrome then
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

        -- Safari Technology Preview: Back
    elseif application:bundleID() == bundleID.safariTechnologyPreview then
        application:selectMenuItem({ "History", "Back" })

        -- Google Chrome: Back
    elseif application:bundleID() == bundleID.googleChrome then
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

        -- Safari Technology Preview: Forward
    elseif application:bundleID() == bundleID.safariTechnologyPreview then
        application:selectMenuItem({ "History", "Forward" })

        -- Google Chrome: Forward
    elseif application:bundleID() == bundleID.googleChrome then
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

----------------------------------------------------------------------------------------------------
-- Hints
----------------------------------------------------------------------------------------------------

hs.hints.fontName = font.monospace
hs.hints.fontSize = 16.0
hs.hints.showTitleThresh = 7
hs.hints.style = "vimperator"

hs.hotkey.bind(modifiers.window, hs.keycodes.map["return"], function() hs.hints.windowHints(windowFilter:getWindows()) end)
hs.hotkey.bind(modifiers.hyper, hs.keycodes.map["return"], function() hs.hints.windowHints(windowFilter:getWindows()) end)
