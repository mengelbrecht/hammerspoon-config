require 'moonscript'

import insert from table


modals = {} -- List of registered modals

class HotkeyModal
  new: (title, mods, key) =>
    insert(modals, @)
    @key = hs.hotkey.bind(mods, key, -> @enter(self))
    @keys = {}
    @title = title
    @active = false

  bind: (mods, key, pressedfn, releasedfn) =>
    insert(@keys, hs.hotkey.new(mods, key, pressedfn, releasedfn))

  disableOtherModals: (using modals) =>
    for m in *modals do if m != @ and m\isActive! then m\exitSilent!

  enter: (using modals) =>
    @disableOtherModals!
    @active = true
    @key\disable()
    for key in *@keys do hs.hotkey.enable(key)
    hs.alert.show("#{@title} Mode", 1)

  exitSilent: =>
    @active = false
    for key in *@keys do hs.hotkey.disable(key)
    @key\enable()

  exit: =>
    @exitSilent!
    hs.alert.show("done #{@title}", 0.5)
    
  isActive: => @active


{
  :HotkeyModal
}
