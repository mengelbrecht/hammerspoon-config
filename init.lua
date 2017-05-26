local log = hs.logger.new('init', 'debug')

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
local hyper = {'shift', 'cmd', 'ctrl', 'alt'}
local meh = {'shift', 'ctrl', 'alt'}

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
-- Karabiner Configuration Automation
----------------------------------------------------------------------------------------------------
local karabinerConfig = os.getenv('HOME') .. '/.dotfiles/config/karabiner/karabiner.json'
local karabinerConfigs = {
  ['USB Keyboard'] = karabinerConfig .. '.external',
  ['_']            = karabinerConfig .. '.internal',
}

local function determineKarabinerConfigFile()
  for _, device in pairs(hs.usb.attachedDevices()) do
    local config = karabinerConfigs[device.productName]
    if config then return config end
  end
  -- no external device found, use internal config
  return karabinerConfigs['_']
end

local function selectKarabinerConfig()
  local config = determineKarabinerConfigFile()
  local currentConfig = hs.fs.pathToAbsolute(karabinerConfig)
  if currentConfig ~= config then
    log.df('switching karabiner config to %s', config)
    os.remove(karabinerConfig)
    hs.fs.link(config, karabinerConfig, true)
  end
end

selectKarabinerConfig()

usbWatcher = hs.usb.watcher.new(function(event) selectKarabinerConfig() end)
usbWatcher:start()

----------------------------------------------------------------------------------------------------
-- Window Layout
----------------------------------------------------------------------------------------------------

function primaryScreen()
  return hs.screen.primaryScreen()
end

function screenEast()
  return hs.screen.primaryScreen():toEast() or hs.screen.primaryScreen()
end

windowLayout = {
  ['com.googlecode.iterm2'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.kapeli.dash'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['org.mozilla.firefox'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.apple.SafariTechnologyPreview'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.google.Chrome'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.apple.iTunes'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.agilebits.onepassword-osx'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.hicknhacksoftware.MacPass'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['org.vim.MacVim'] = (function(win)
    win:moveToScreen(primaryScreen()):maximize()
  end),

  ['com.parallels.desktop.console'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.vmware.fusion'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.reederapp.rkit2.mac'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.fournova.Tower2'] = (function(win)
    win:moveToScreen(screenEast()):maximize()
  end),

  ['com.apple.dt.Xcode'] = (function(win)
    win:moveToScreen(primaryScreen()):maximize()
  end),

  ['_'] = (function(win)
    if not win:isFullScreen() then hs.grid.snap(win) end
  end),
}

function canLayoutWindow(win)
  return win:isStandard() and not win:isFullScreen()
end

function handleWindowLayout(win)
  if not canLayoutWindow(win) then return end
  local layout = windowLayout[win:application():bundleID()] or windowLayout['_']
  layout(win)
end

function applyLayoutToAllWindows()
  for _, win in pairs(hs.window.visibleWindows()) do handleWindowLayout(win) end
end

hs.window.filter.new():subscribe(hs.window.filter.windowCreated, handleWindowLayout)

----------------------------------------------------------------------------------------------------
-- Hotkey Bindings
----------------------------------------------------------------------------------------------------
colorBlack = {red = 0.16, green = 0.16, blue = 0.16}
colorBlue = {red = 0.27, green = 0.52, blue = 0.53}
colorRed = {red = 0.8, green = 0.14, blue = 0.11}
colorGreen = {red = 0.60, green = 0.59, blue = 0.10}

function showBar(color, textColor)
  if not barBackground then
    local screenFrame = hs.screen.mainScreen():fullFrame()
    local barFrame = {x = 0, y = screenFrame.h - 4, w = screenFrame.w, h = 4}

    barBackground = hs.drawing.rectangle(barFrame)
        :setStroke(false)
        :setLevel(hs.drawing.windowLevels.modalPanel)
  end
  barBackground:setFillColor(color)
  barBackground:show()
end

function hideBar()
  if barBackground then barBackground:hide() end
end

function key(modifiers, k)
  return function() hs.eventtap.keyStroke(modifiers, k, 0) end
end

function app(bundleID)
  return function() hs.application.launchOrFocusByBundleID(bundleID) end
end

function mouseMove(offset)
  return function()
    hs.mouse.setRelativePosition(hs.geometry(hs.mouse.getRelativePosition()):move(offset))
  end
end

function doubleClick()
  local pt = hs.mouse.getAbsolutePosition()
  local clickState = hs.eventtap.event.properties.mouseEventClickState
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pt):setProperty(clickState, 1):post()
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pt):setProperty(clickState, 1):post()
  hs.timer.usleep(1000)
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pt):setProperty(clickState, 2):post()
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pt):setProperty(clickState, 2):post()
end

function scrollWheel(offset)
  return function()
    local win = hs.window.focusedWindow()
    local frame = hs.geometry(win:frame())
    if not hs.geometry(hs.mouse.getAbsolutePosition()):inside(frame) then
      hs.mouse.setAbsolutePosition(frame.center)
      win:focus()
    end
    hs.eventtap.scrollWheel(offset, {})
  end
end

function createMomentaryLayer(layer, layout)
  for _, entry in pairs(layout) do hs.hotkey.bind(layer, entry.k, entry.f, nil, entry.f) end
end

function createToggleLayer(color, layer, activationKey, layout)
  local layerModal = hs.hotkey.modal.new(layer, activationKey)
  function layerModal:entered() showBar(color) end
  function layerModal:exited() hideBar() end
  hs.fnutils.concat(layout, {{k = activationKey, exit = true}, {k = 'escape', exit = true}, {k = 'return', exit = true}})

  for _, entry in pairs(layout) do
    local func = function()
      if entry.f then entry.f() end
      if entry['exit'] then layerModal:exit() end
    end
    local mods = entry.m or {}
    layerModal:bind(mods, entry.k, func, nil, func)
  end
end

hs.hotkey.bind({'shift'}, 'delete', key({}, 'forwarddelete'), nil, key({}, 'forwarddelete'))

-- Standard Colemak Layer
-- ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────┐
-- │  §  │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │  ─  │  =  │ BkSp  │
-- ├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────┤
-- │ Tab    │  Q  │  W  │  F  │  P  │  G  │  J  │  L  │  U  │  Y  │  ;  │  [  │  ]  │Entr│
-- ├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┐  │
-- │ Hyper    │  A  │  R  │  S  │  T  │  D  │  H  │  N  │  E  │  I  │  O  │  '  │  \  │  │
-- ├──────┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┴──┤
-- │LShift│  `  │  Z  │  X  │  C  │  V  │  B  │  K  │  M  │  ,  │  .  │  /  │ RShift/Esc │
-- ├──────┴─┬───┴──┬──┴─────┼─────┴─────┴─────┴─────┴─────┴─────┼─────┴──┬──┴───┬────────┤
-- │ LCtrl  │ Meh  │ LCmd   │ Space                             │ Meh    │ RCmd │ RCtrl  │
-- └────────┴──────┴────────┴───────────────────────────────────┴────────┴──────┴────────┘

-- Coding / Symbol Layer (momentary via Meh key)
-- ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────┐
-- │     │ F1  │ F2  │ F3  │ F4  │ F5  │ F6  │ F7  │ F8  │ F9  │ F10 │ F11 │ F12 │ BkSp  │
-- ├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────┤
-- │ Tab    │  !  │  @  │  {  │  }  │  |  │  \  │  7  │  8  │  9  │  *  │  ¨  │  ß  │Mous│
-- ├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┐eL│
-- │          │  #  │  $  │  (  │  )  │  &  │  -  │  4  │  5  │  6  │  +  │  '  │  .  │ay│
-- ├──────┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┴──┤
-- │      │  _  │  %  │  ^  │  [  │  ]  │  ~  │  =  │  1  │  2  │  3  │  0  │            │
-- ├──────┴─┬───┴──┬──┴─────┼─────┴─────┴─────┴─────┴─────┴─────┼─────┴──┬──┴───┬────────┤
-- │        │      │        │                                   │        │      │        │
-- └────────┴──────┴────────┴───────────────────────────────────┴────────┴──────┴────────┘

-- Application / OS Layer (momentary via Hyper key)
-- ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────┐
-- │     │     │     │     │     │     │     │     │     │     │     │     │     │LockScr│
-- ├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────┤
-- │        │     │     │Files│ VM  │ Git │     │     │ Up  │     │     │     │     │Layo│
-- ├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┐ut│
-- │          │Stats│ News│ Pass│ Term│ Doc │     │Left │Down │Right│     │     │     │Wi│
-- ├──────┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┴──┤
-- │      │     │     │ IDE │     │ Vim │Brows│     │Music│     │     │     │            │
-- ├──────┴─┬───┴──┬──┴─────┼─────┴─────┴─────┴─────┴─────┴─────┼─────┴──┬──┴───┬────────┤
-- │        │      │        │ Expose                            │        │      │        │
-- └────────┴──────┴────────┴───────────────────────────────────┴────────┴──────┴────────┘

-- Mouse Layer (toggled via Meh+Space key)
-- ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬───────┐
-- │     │     │     │     │     │     │     │     │     │     │     │     │     │       │
-- ├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬────┤
-- │        │     │     │     │     │     │     │LClck│ Up  │RClck│     │     │     │Exit│
-- ├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┐  │
-- │          │     │     │     │     │     │     │Left │Down │Right│     │     │     │  │
-- ├──────┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┴──┤
-- │M 50px│     │     │     │     │     │     │     │     │     │     │     │            │
-- ├──────┴─┬───┴──┬──┴─────┼─────┴─────┴─────┴─────┴─────┴─────┼─────┴──┬──┴───┬────────┤
-- │M 100px │      │ M 2px  │ Exit                              │        │      │        │
-- └────────┴──────┴────────┴───────────────────────────────────┴────────┴──────┴────────┘

createMomentaryLayer(hyper, {
  {k = 'a', f = app('com.apple.ActivityMonitor')},
  {k = 'b', f = app('com.apple.SafariTechnologyPreview')},
  {k = 'c', f = app('com.google.Chrome')},
  {k = 'd', f = app('com.kapeli.dash')},
  {k = 'f', f = app('com.apple.Finder')},
  {k = 'g', f = app('com.fournova.Tower2')},
  {k = 'm', f = app('com.apple.iTunes')},
  {k = 'p', f = app('com.vmware.fusion')},
  {k = 'r', f = app('com.reederapp.rkit2.mac')},
  {k = 's', f = app('com.agilebits.onepassword-osx')},
  {k = 't', f = app('com.googlecode.iterm2')},
  {k = 'v', f = app('org.vim.MacVim')},
  {k = 'x', f = app('com.jetbrains.intellij')},

  {k = 'n',      f = key({}, 'left')},
  {k = 'u',      f = key({}, 'up')},
  {k = 'e',      f = key({}, 'down')},
  {k = 'i',      f = key({}, 'right')},
  {k = 'up',     f = function() hs.window.focusedWindow():maximize() end},
  {k = 'down',   f = function() hs.window.focusedWindow():moveToScreen(hs.window.focusedWindow():screen():next()) end},
  {k = 'left',   f = function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 1}) end},
  {k = 'right',  f = function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 1}) end},
  {k = 'return', f = function() applyLayoutToAllWindows() end},
  {k = 'delete', f = function() hs.caffeinate.lockScreen() end},
  {k = 'space',  f = function() expose:toggleShow() end},
  {k = '2',      f = function() hs.grid.toggleShow() end},
  {k = 'tab',    f = function() switcher:next() end},
  {k = '§',      f = function() switcher:previous() end},
})

createMomentaryLayer(meh, {
  -- Left hand
  {k = '1', f = key({}, 'f1')},       {k = '2', f = key({}, 'f2')},       {k = '3', f = key({}, 'f3')},       {k = '4', f = key({}, 'f4')},       {k = '5', f = key({}, 'f5')},
  {k = 'q', f = key({'shift'}, '1')}, {k = 'w', f = key({'shift'}, '2')}, {k = 'f', f = key({'shift'}, '[')}, {k = 'p', f = key({'shift'}, ']')}, {k = 'g', f = key({'shift'}, '\\')},
  {k = 'a', f = key({'shift'}, '3')}, {k = 'r', f = key({'shift'}, '4')}, {k = 's', f = key({'shift'}, '9')}, {k = 't', f = key({'shift'}, '0')}, {k = 'd', f = key({'shift'}, '7')},
  {k = 'z', f = key({'shift'}, '5')}, {k = 'x', f = key({'shift'}, '6')}, {k = 'c', f = key({}, '[')},        {k = 'v', f = key({}, ']')},        {k = 'b', f = key({'shift'}, '`')},

  -- Right hand
  {k = '6', f = key({}, 'f6')}, {k = '7', f = key({}, 'f7')}, {k = '8', f = key({}, 'f8')}, {k = '9', f = key({}, 'f9')}, {k = '0', f = key({}, 'f10')},      {k = '-', f = key({}, 'f11')},    {k = '=', f = key({}, 'f12')},
  {k = 'j', f = key({}, '\\')}, {k = 'l', f = key({}, '7')},  {k = 'u', f = key({}, '8')},  {k = 'y', f = key({}, '9')},  {k = ';', f = key({'shift'}, '8')}, {k = '[', f = key({'alt'}, 'u')}, {k = ']', f = key({'alt'}, 's')},
  {k = 'h', f = key({}, '-')},  {k = 'n', f = key({}, '4')},  {k = 'e', f = key({}, '5')},  {k = 'i', f = key({}, '6')},  {k = 'o', f = key({'shift'}, '=')}, {k = '\\', f = key({}, '.')},
  {k = 'k', f = key({}, '=')},  {k = 'm', f = key({}, '1')},  {k = ',', f = key({}, '2')},  {k = '.', f = key({}, '3')},  {k = '/', f = key({}, '0')},
  {k = '`', f = key({'shift'}, '-')},
})

createToggleLayer(colorRed, meh, 'return', {
  {k = 'space', exit = true},
  {k = 'l', f = function() hs.eventtap.leftClick(hs.mouse.getAbsolutePosition()) end},
  {k = 'y', f = function() hs.eventtap.rightClick(hs.mouse.getAbsolutePosition()) end},
  {k = 'k', f = function() doubleClick() end},

  {k = 'n', f = scrollWheel({5, 0})},
  {k = 'u', f = scrollWheel({0, 5})},
  {k = 'e', f = scrollWheel({0, -5})},
  {k = 'i', f = scrollWheel({-5,  0})},
  {k = 'n', f = mouseMove({x = -10, y = 0}),   m = {'shift'}},
  {k = 'u', f = mouseMove({x = 0,   y = -10}), m = {'shift'}},
  {k = 'e', f = mouseMove({x = 0,   y = 10}),  m = {'shift'}},
  {k = 'i', f = mouseMove({x = 10,  y = 0}),   m = {'shift'}},
  {k = 'n', f = mouseMove({x = -50, y = 0}),   m = {'ctrl'}},
  {k = 'u', f = mouseMove({x = 0,   y = -50}), m = {'ctrl'}},
  {k = 'e', f = mouseMove({x = 0,   y = 50}),  m = {'ctrl'}},
  {k = 'i', f = mouseMove({x = 50,  y = 0}),   m = {'ctrl'}},
  {k = 'n', f = mouseMove({x = -2,  y = 0}),   m = {'cmd'}},
  {k = 'u', f = mouseMove({x = 0,   y = -2}),  m = {'cmd'}},
  {k = 'e', f = mouseMove({x = 0,   y = 2}),   m = {'cmd'}},
  {k = 'i', f = mouseMove({x = 2,   y = 0}),   m = {'cmd'}},
})

