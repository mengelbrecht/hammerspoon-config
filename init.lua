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
  showTitles                      = false,
})

hs.grid.setMargins({0, 0})
hs.grid.setGrid('6x4', nil)
hs.grid.HINTS = {
  {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8'},
  {'1',  '2',  '3',  '4',  '5',  '6',  '7',  '8'},
  {'Q',  'W',  'E',  'R',  'T',  'Z',  'U',  'I'},
  {'A',  'S',  'D',  'F',  'G',  'H',  'J',  'K'},
  {'Y',  'X',  'C',  'V',  'B',  'N',  'M',  ','}
}

configWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

----------------------------------------------------------------------------------------------------
-- Colehack Mode
----------------------------------------------------------------------------------------------------

colehackActive = false
colehackActiveBeforeLogout = false

function selectKarabinerProfile(profile)
  hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile '" .. profile .. "'")
end

function activateColehack()
  hs.keycodes.setLayout('U.S.')
  selectKarabinerProfile('Colehack')
  colehackActive = true
  updateMenu()
end

function deactivateColehack()
  hs.keycodes.setLayout('German')
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

function maximize(win)
  win:setFrame(win:screen():fullFrame(), 0.0)
end

function correctWindowPosition(win)
  local winGrid = hs.grid.get(win)
  if winGrid.x ~= 0 or winGrid.y ~= 0 then return end
  local winFrame = win:frame()
  winFrame.w = winFrame.w + winFrame.x
  winFrame.x = 0
  win:setFrame(winFrame)
end

function snap(win, cell)
  hs.grid.set(win, cell or hs.grid.get(win))
  correctWindowPosition(win)
end

windowLayout = {
  ['com.googlecode.iterm2']             = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.kapeli.dash']                   = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['org.mozilla.firefox']               = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.apple.Safari']                  = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.apple.SafariTechnologyPreview'] = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.google.Chrome']                 = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.apple.iTunes']                  = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.agilebits.onepassword-osx']     = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.hicknhacksoftware.MacPass']     = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['org.vim.MacVim']                    = function(win) maximize(win:moveToScreen(primaryScreen())) end,
  ['com.parallels.desktop.console']     = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.vmware.fusion']                 = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.reederapp.rkit2.mac']           = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.fournova.Tower2']               = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.apple.dt.Xcode']                = function(win) maximize(win:moveToScreen(primaryScreen())) end,
  ['Alacritty']                         = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['_']                                 = function(win) snap(win) end,
}

function canLayoutWindow(win)
  return win:isStandard() and not win:isFullScreen()
end

function handleWindowLayout(win)
  if not canLayoutWindow(win) then return end
  local layout = windowLayout[win:application():bundleID()] or windowLayout[win:application():name()] or windowLayout['_']
  layout(win)
end

hs.window.filter.new():subscribe(hs.window.filter.windowCreated, handleWindowLayout)
hs.window.filter.new():subscribe(hs.window.filter.windowFocused, correctWindowPosition)

----------------------------------------------------------------------------------------------------
-- Hotkey Functions (invoked from karabiner)
----------------------------------------------------------------------------------------------------

function maximizeCurrentWindow()
  maximize(hs.window.focusedWindow())
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

function applyLayoutToAllWindows()
  for _, win in pairs(hs.window.visibleWindows()) do handleWindowLayout(win) end
end

function lockScreen()
  hs.caffeinate.lockScreen()
end

function toggleGrid()
  hs.grid.toggleShow()
end

----------------------------------------------------------------------------------------------------
-- Startup Settings
----------------------------------------------------------------------------------------------------

activateColehack()

