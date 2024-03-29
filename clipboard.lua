-- ClipboardManager
-- based on TextClipboardHistory.spoon by Diego Zamboni
-- https://github.com/Hammerspoon/Spoons/blob/28c3aa65e2de1b12a23659544693f06dd4dc9836/Source/TextClipboardHistory.spoon/init.lua
-- License: MIT - https://opensource.org/licenses/MIT
--
local clipboard = {}

clipboard.frequency = 0.8
clipboard.maxItems = 100

clipboard.ignoredIdentifiers = {
    ["org.nspasteboard.TransientType"] = true,
    ["org.nspasteboard.ConcealedType"] = true,
    ["org.nspasteboard.AutoGeneratedType"] = true
}

clipboard.ignoredApplications = {
    ["com.markmcguill.strongbox.mac"] = true
}

clipboard.emptyHistoryItem = {
    text = "《Clipboard is empty》",
    image = hs.image.imageFromName("NSCaution")
}

clipboard.clearHistoryItem = {
    text = "《Clear Clipboard History》",
    action = "clear",
    image = hs.image.imageFromName("NSTrashFull")
}

----------------------------------------------------------------------

local itemSetting = "clipboard.items"
local clipboardHistory
local chooser
local previousFocusedWindow

local function getItem(content)
    return {
        text = content:gsub("\n", " "):gsub("%s+", " "),
        subText = #content .. " characters",
        data = content
    }
end

local function dedupeAndResize(list)
    local result = {}
    local hashes = {}
    for _, v in ipairs(list) do
        if #result >= clipboard.maxItems then
            break
        end

        local hash = hs.hash.MD5(v)
        if not hashes[hash] then
            table.insert(result, v)
            hashes[hash] = true
        end
    end
    return result
end

local function addContentToClipboardHistory(content)
    table.insert(clipboardHistory, 1, content)
    clipboardHistory = dedupeAndResize(clipboardHistory)
end

local function processSelectedItem(value)
    local actions = {
        clear = clipboard.clearAll
    }

    if previousFocusedWindow ~= nil then
        previousFocusedWindow:focus()
    end

    if value == nil or type(value) ~= "table" then
        return
    end

    if value.action and actions[value.action] then
        actions[value.action]()
    elseif value.data then
        addContentToClipboardHistory(value.data)
        hs.pasteboard.setContents(value.data)
        hs.eventtap.keyStroke({ "cmd" }, "v")
    end
end

local function populateChooser()
    local menuData = hs.fnutils.imap(clipboardHistory, getItem)
    table.insert(menuData, #menuData == 0 and clipboard.emptyHistoryItem or clipboard.clearHistoryItem)
    return menuData
end

local function shouldIgnoreLatestPasteboardEntry()
    if hs.fnutils.some(hs.pasteboard.pasteboardTypes(), function(v) return clipboard.ignoredIdentifiers[v] end) then
        return true
    end

    if hs.fnutils.some(hs.pasteboard.contentTypes(), function(v) return clipboard.ignoredIdentifiers[v] end) then
        return true
    end

    if clipboard.ignoredApplications[hs.application.frontmostApplication():bundleID()] then
        return true
    end

    return false
end

local function handleNewPasteboardContent(content)
    if shouldIgnoreLatestPasteboardEntry() or content == nil then
        return
    end

    addContentToClipboardHistory(content)
end

function clipboard.start()
    clipboardHistory = {}

    chooser = hs.chooser.new(processSelectedItem)
    chooser:choices(populateChooser)

    hs.pasteboard.watcher.interval(clipboard.frequency)
    pasteboardWatcher = hs.pasteboard.watcher.new(handleNewPasteboardContent)
    pasteboardWatcher:start()
end

function clipboard.clearAll()
    hs.pasteboard.clearContents()
    clipboardHistory = {}
end

function clipboard.toggleClipboard()
    if chooser:isVisible() then
        chooser:hide()
        return
    end

    chooser:refreshChoicesCallback()
    previousFocusedWindow = hs.window.focusedWindow()
    chooser:show()
end

return clipboard
