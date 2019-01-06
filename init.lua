require("hs.ipc")
local log = hs.logger.new('init', 'debug')

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------

hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.consoleOnTop(true)
hs.dockIcon(false)
hs.menuIcon(false)
hs.uploadCrashData(false)

expose = hs.expose.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}), {
  backgroundColor                 = {0.03, 0.03, 0.03, 0.75},
  closeModeBackgroundColor        = {0.7, 0.1, 0.1, 0.75},
  highlightColor                  = {0.6, 0.3, 0.0, 0.75},
  minimizeModeBackgroundColor     = {0.1, 0.2, 0.3, 0.75},
  minimizeModeModifier            = 'ctrl',
  nonVisibleStripBackgroundColor  = {0.03, 0.1, 0.15, 0.75},
  nonVisibleStripPosition         = 'left',
  otherSpacesStripBackgroundColor = {0.1, 0.1, 0.1, 0.75},
  otherSpacesStripWidth           = 0.15,
  showThumbnails                  = false,
  showTitles                      = false
})

switcher = hs.window.switcher.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}), {
  backgroundColor                 = {0.03, 0.03, 0.03, 0.75},
  highlightColor                  = {0.6, 0.3, 0.0, 0.75},
  showThumbnails                  = false,
  showSelectedTitle               = false,
  showTitles                      = false
})

hs.grid.setMargins({0, 0})
hs.grid.setGrid('6x4')
hs.grid.HINTS = {
  {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8'},
  {'1',  '2',  '3',  '4',  '5',  '6',  '7',  '8'},
  {'Q',  'W',  'F',  'P',  'B',  'J',  'L',  'U'},
  {'A',  'R',  'S',  'T',  'G',  'K',  'N',  'E'},
  {'X',  'C',  'D',  'V',  'Z',  'M',  'H',  ','}
}
hs.grid.ui.showExtraKeys = false

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

----------------------------------------------------------------------------------------------------
-- Colehack Mode
----------------------------------------------------------------------------------------------------

colehackActive = false
colehackActiveBeforeLogout = false

function selectKarabinerProfile(profile)
  hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile '" .. profile .. "'")
end

function selectLayout(layout)
  local tries = 1
  local maxTries = 5
  while tries <= maxTries do
    if hs.keycodes.setLayout(layout) then return end
    hs.timer.usleep(100 * 1000)
    tries = tries + 1
  end
end

function activateColehack()
  selectLayout('U.S.')
  selectKarabinerProfile('Colehack')
  colehackActive = true
  updateMenu()
end

function deactivateColehack()
  selectLayout('German')
  selectKarabinerProfile('German')
  colehackActive = false
  updateMenu()
end

function toggleColehack()
  if colehackActive then deactivateColehack() else activateColehack() end
end

colehackCaffeinateWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.screensDidLock or event == hs.caffeinate.watcher.sessionDidResignActive or event == hs.caffeinate.watcher.systemWillPowerOff then
    colehackActiveBeforeLogout = colehackActive
    deactivateColehack()
  end
  if (event == hs.caffeinate.watcher.screensDidUnlock or event == hs.caffeinate.watcher.sessionDidBecomeActive) and colehackActiveBeforeLogout then
      activateColehack()
  end
  return false
end):start()

----------------------------------------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------------------------------------

function updateMenu()
  menu:setIcon(hs.configdir .. '/assets/statusicon_' .. (colehackActive and 'on' or 'off') .. '.tiff')
  menu:setMenu({
       { title = 'Hammerspoon ' .. hs.processInfo.version, disabled = true },
       { title = '-' },
       { title = 'Reload', fn = hs.reload },
       { title = 'Console...', fn = hs.openConsole },
       { title = '-' },
       { title = 'Colehack', checked = colehackActive, fn = toggleColehack },
       { title = '-' },
       { title = 'Quit', fn = function() hs.application.get(hs.processInfo.processID):kill() end }
  })
end

menu = hs.menubar.new()

----------------------------------------------------------------------------------------------------
-- Window Layout
----------------------------------------------------------------------------------------------------

function primaryScreen()
  return hs.screen.primaryScreen()
end

function screenEast()
  return primaryScreen():toEast() or primaryScreen()
end

function snap(win, cell)
  hs.grid.set(win, cell or hs.grid.get(win))
end

windowLayout = {
  ['com.apple.iTunes'] = function(win) win:maximize() end,
  ['_']                = function(win) snap(win) end,
}

function canLayoutWindow(win)
  return win:isStandard() and not win:isFullScreen()
end

function handleWindowLayout(win)
  if not canLayoutWindow(win) then return end
  local layout = windowLayout[win:application():bundleID()] or windowLayout['_']
  layout(win)
end

hs.window.filter.new({['default'] = {hasTitlebar = true}}):subscribe(hs.window.filter.windowCreated, handleWindowLayout)

----------------------------------------------------------------------------------------------------
-- Hotkey Functions (invoked from karabiner)
----------------------------------------------------------------------------------------------------

function maximizeCurrentWindow()
  hs.window.focusedWindow():maximize()
end

function moveCurrentWindowToNextScreen()
  local win = hs.window.focusedWindow()
  win:moveToScreen(win:screen():next())
  snap(win)
end

function moveCurrentWindowToLeftHalf()
  local gridSize = hs.grid.getGrid()
  snap(hs.window.focusedWindow(), hs.geometry({0, 0, gridSize.w / 2.0, gridSize.h}))
end

function moveCurrentWindowToRightHalf()
  local gridSize = hs.grid.getGrid()
  snap(hs.window.focusedWindow(), hs.geometry({gridSize.w / 2.0, 0, gridSize.w / 2.0, gridSize.h}))
end

function toggleFullscreen()
  local win = hs.window.focusedWindow()
  win:setFullScreen(not win:isFullScreen())
end

function applyLayoutToAllWindows()
  for _, win in pairs(hs.window.visibleWindows()) do handleWindowLayout(win) end
end

function systemSleep()
  hs.caffeinate.systemSleep()
end

function toggleGrid()
  hs.grid.toggleShow()
end

function toggleExpose()
  expose:toggleShow()
end

function nextWindow()
  switcher:next()
end

function previousWindow()
  switcher:previous()
end

----------------------------------------------------------------------------------------------------
-- Startup Settings
----------------------------------------------------------------------------------------------------

activateColehack()
