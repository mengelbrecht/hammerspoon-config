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

expose = hs.expose.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}),{
  backgroundColor                 = {0.03, 0.03, 0.03, 0.75},
  closeModeBackgroundColor        = {0.7, 0.1, 0.1, 0.75},
  highlightColor                  = {0.6, 0.3, 0.0, 0.75},
  minimizeModeBackgroundColor     = {0.1, 0.2, 0.3, 0.75},
  nonVisibleStripBackgroundColor  = {0.03, 0.1, 0.15, 0.75},
  nonVisibleStripPosition         = 'left',
  otherSpacesStripBackgroundColor = {0.1, 0.1, 0.1, 0.75},
  otherSpacesStripWidth           = 0.15,
  showThumbnails                  = false,
  showTitles                      = false
})

switcher = hs.window.switcher.new(hs.window.filter.new():setDefaultFilter({allowTitles=1}),{
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

----------------------------------------------------------------------------------------------------
-- Menu
----------------------------------------------------------------------------------------------------

function makeMenu()
  return {
       { title = 'Hammerspoon ' .. hs.processInfo.version, disabled = true },
       { title = '-' },
       { title = 'Reload', fn = function() hs.reload() end },
       { title = 'Console...', fn = function() hs.openConsole() end },
       { title = '-' },
       { title = 'Input Source', disabled = true },
       { title = 'Colehack', checked = hs.keycodes.currentLayout() == 'U.S.', fn = function() changeToColehack() end },
       { title = 'German', checked = hs.keycodes.currentLayout() == 'German', fn = function() changeToGerman() end },
       { title = '-' },
       { title = 'Quit', fn = function() hs.application.get(hs.processInfo.processID):kill() end }
  }
end

function selectKarabinerProfile(profile)
  hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile '" .. profile .. "'")
end

function changeToColehack()
  hs.keycodes.setLayout('U.S.')
  selectKarabinerProfile('Colehack')
  menu:setMenu(makeMenu())
end

function changeToGerman()
  hs.keycodes.setLayout('German')
  selectKarabinerProfile('German')
  menu:setMenu(makeMenu())
end

menu = hs.menubar.new():setIcon(hs.configdir .. '/statusicon.tiff'):setMenu(makeMenu())

----------------------------------------------------------------------------------------------------
-- Window Layout
----------------------------------------------------------------------------------------------------

function primaryScreen()
  return hs.screen.primaryScreen()
end

function screenEast()
  return hs.screen.primaryScreen():toEast() or hs.screen.primaryScreen()
end

function maximize(win)
  win:setFrame(win:screen():fullFrame(), 0.0)
end

function fillsGrid(win)
  local gridSize = hs.grid.getGrid()
  local winGrid = hs.grid.get(win)
  return winGrid.x == 0 and winGrid.y == 0 and winGrid.w == gridSize.w and winGrid.h == gridSize.h
end

windowLayout = {
  ['com.googlecode.iterm2']             = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['com.kapeli.dash']                   = function(win) maximize(win:moveToScreen(screenEast())) end,
  ['org.mozilla.firefox']               = function(win) maximize(win:moveToScreen(screenEast())) end,
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

  ['_'] = (function(win)
    if not win:isFullScreen() then
      if fillsGrid(win) then
        maximize(win)
      else
        hs.grid.snap(win)
      end
    end
  end),
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

----------------------------------------------------------------------------------------------------
-- Hotkey functions invoked from karabiner
----------------------------------------------------------------------------------------------------

function maximizeCurrentWindow()
  maximize(hs.window.focusedWindow())
end

function moveCurrentWindowToNextScreen()
  hs.window.focusedWindow():moveToScreen(hs.window.focusedWindow():screen():next())
end

function moveCurrentWindowToLeftHalf()
  local frame = hs.window.focusedWindow():screen():fullFrame()
  hs.window.focusedWindow():setFrame({x = 0, y = 0, w = frame.w / 2.0, h = frame.h})
end

function moveCurrentWindowToRightHalf()
  local frame = hs.window.focusedWindow():screen():fullFrame()
  hs.window.focusedWindow():setFrame({x = frame.w / 2.0, y = 0, w = frame.w / 2.0, h = frame.h})
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

changeToColehack()

