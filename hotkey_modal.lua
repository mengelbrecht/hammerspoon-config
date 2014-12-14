local modals = {}

HotkeyModal = {}
HotkeyModal.__index = HotkeyModal

function HotkeyModal.new(title, modifiers, key)
  local m = setmetatable({}, HotkeyModal)
  m.active = false
  m.keys = {}
  m.title = title
  m.key = hs.hotkey.bind(modifiers, key, function() m:enter() end)
  table.insert(modals, m)
  return m
end

function HotkeyModal:disableOtherModals_()
  for _, modal in pairs(modals) do
    if modal ~= self and modal:isActive() then modal:exitSilent_() end
  end
end

function HotkeyModal:exitSilent_()
  self.active = false
  for _, key in pairs(self.keys) do hs.hotkey.disable(key) end
  self.key:enable()
end

function HotkeyModal:enter()
  self:disableOtherModals_()
  self.active = true
  self.key:disable()
  for _, key in pairs(self.keys) do hs.hotkey.enable(key) end
  hs.alert.show(self.title .. " Mode", 1)
end

function HotkeyModal:exit()
  self:exitSilent_()
  hs.alert.show("done " .. self.title, 0.5)
end

function HotkeyModal:isActive()
  return self.active
end

function HotkeyModal:bind(modifiers, key, pressedFn, releasedFn)
  table.insert(self.keys, hs.hotkey.new(modifiers, key, pressedFn, releasedFn))
end

----------------------------------------------------------------------------------------------------

return HotkeyModal
