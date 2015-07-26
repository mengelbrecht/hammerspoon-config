require 'utils'

HotkeyModal = {}
HotkeyModal.__index = HotkeyModal

local modals = {}

function HotkeyModal.new(title, modifiers, key)
  local m = setmetatable({}, HotkeyModal)
  m.active = false
  m.keys = {}
  m.title = title
  m.key = hs.hotkey.bind(modifiers, key, function() m:enter() end)
  table.insert(modals, m)
  return m
end

function HotkeyModal:_disableOtherModals()
  for _, modal in pairs(modals) do
    if modal ~= self and modal:isActive() then modal:_exitSilent() end
  end
end

function HotkeyModal:_exitSilent()
  self.active = false
  for _, key in pairs(self.keys) do hs.hotkey.disable(key) end
  self.key:enable()
end

----------------------------------------------------------------------------------------------------

function HotkeyModal:enter()
  self:_disableOtherModals()
  self.active = true
  self.key:disable()
  for _, key in pairs(self.keys) do hs.hotkey.enable(key) end
  utils.notify(self.title .. " Mode", 1.0)
end

function HotkeyModal:exit()
  self:_exitSilent()
  utils.notify("done " .. self.title, 1.0)
end

function HotkeyModal:isActive()
  return self.active
end

function HotkeyModal:bind(modifiers, key, pressedFn, releasedFn)
  table.insert(self.keys, hs.hotkey.new(modifiers, key, pressedFn, releasedFn))
end

----------------------------------------------------------------------------------------------------

return HotkeyModal
