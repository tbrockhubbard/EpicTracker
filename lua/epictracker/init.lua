--[[
  EpicTracker - tracks Epic 1.5 pre-quest, Epic 1.5 and Epic 2.0 progress
  across all your boxed characters.

  Main character:   /lua run epictracker           (with window)
  Whole group:      /e3bcga /lua run epictracker bg (bots report in, no window)
                    or press "Start on group" in the window / type /epictracker group
  Slash command:    /epictracker [show|hide|scan|refresh|group|quit|quitall]

  Progress is saved per character in your MQ config folder and shared between
  clients with MQ's built-in actors messaging. E3 is only used to launch it.
]]

local mq = require('mq')
local ImGui = require('ImGui')
local actors = require('actors')

local SCRIPT = 'epictracker'
local VERSION = '1.0.0'

-- Command used to send a command to every character in the group.
-- Project Lazarus + E3Next: /e3bcga (all, including you). DanNet users: /dgga
local GROUP_CMD = '/e3bcga'

---------------------------------------------------------------------------
-- Args / identity
---------------------------------------------------------------------------
local args = { ... }
local headless = false
for _, a in ipairs(args) do
    local l = tostring(a):lower()
    if l == 'bg' or l == 'nogui' or l == 'hide' then headless = true end
end

local myName = mq.TLO.Me.CleanName() or 'Unknown'
local myClass = mq.TLO.Me.Class.Name() or 'Unknown'
local server = ((mq.TLO.EverQuest.Server() or 'server'):gsub('%s', '_'))
local savePath = string.format('%s/epictracker_%s_%s.lua', mq.configDir, server, myName)

---------------------------------------------------------------------------
-- Class data
---------------------------------------------------------------------------
local CLASS_FILES = {
    ['Bard']          = 'bard',
    ['Beastlord']     = 'beastlord',
    ['Berserker']     = 'berserker',
    ['Cleric']        = 'cleric',
    ['Druid']         = 'druid',
    ['Enchanter']     = 'enchanter',
    ['Magician']      = 'magician',
    ['Monk']          = 'monk',
    ['Necromancer']   = 'necromancer',
    ['Paladin']       = 'paladin',
    ['Ranger']        = 'ranger',
    ['Rogue']         = 'rogue',
    ['Shadow Knight'] = 'shadowknight',
    ['Shaman']        = 'shaman',
    ['Warrior']       = 'warrior',
    ['Wizard']        = 'wizard',
}

local dataCache = {}
local function getClassData(className)
    if not className then return nil end
    if dataCache[className] ~= nil then return dataCache[className] or nil end
    local file = CLASS_FILES[className]
    local ok, data = false, nil
    if file then ok, data = pcall(require, SCRIPT .. '.data.' .. file) end
    if not ok or type(data) ~= 'table' then
        if file then printf('\ar[EpicTracker]\ax failed to load data for %s: %s', className, tostring(data)) end
        dataCache[className] = false
        return nil
    end
    dataCache[className] = data
    return data
end

local function stepKey(tier, step) return tier.id .. '.' .. step.id end

---------------------------------------------------------------------------
-- State (this character)
---------------------------------------------------------------------------
local state = { done = {}, auto = {} }
local dirty, needBroadcast, running = false, false, true

local function loadState()
    local f = loadfile(savePath)
    if not f then return end
    local ok, t = pcall(f)
    if ok and type(t) == 'table' then
        state.done = t.done or {}
        state.auto = t.auto or {}
    end
end

local function saveState()
    mq.pickle(savePath, { done = state.done, auto = state.auto })
end

local function setStep(key, value)
    if value then
        state.done[key] = true
    else
        state.done[key] = nil
        state.auto[key] = nil
    end
    saveState()
    dirty = true
end

---------------------------------------------------------------------------
-- Auto-detection (inventory + bank)
---------------------------------------------------------------------------
local function hasItem(name)
    local q = '=' .. name
    if (mq.TLO.FindItemCount(q)() or 0) > 0 then return true end
    -- Bank data is only known after the bank has been opened once this session.
    if (mq.TLO.FindItemBankCount(q)() or 0) > 0 then return true end
    return false
end

local function markAuto(key)
    if state.done[key] then return false end
    state.done[key] = true
    state.auto[key] = true
    return true
end

-- Returns true if anything changed.
local function scan()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then return false end
    local data = getClassData(myClass)
    if not data then return false end

    local changed = false
    local highestTier = 0

    for ti, tier in ipairs(data.tiers) do
        local highest = 0
        for si, step in ipairs(tier.steps) do
            local key = stepKey(tier, step)
            local allowed = (step.after == nil) or state.done[step.after]
            if step.detect and allowed then
                for _, item in ipairs(step.detect) do
                    if hasItem(item) then
                        if markAuto(key) then changed = true end
                        break
                    end
                end
            end
            -- Auto-detected steps stay done even after the item is turned in.
            -- Pre-farmable items (nobackfill) only tick their own step.
            if state.done[key] and state.auto[key] and not step.nobackfill then highest = si end
        end
        -- Holding a later step's item means the earlier steps are done.
        if highest > 0 then
            for si = 1, highest - 1 do
                if markAuto(stepKey(tier, tier.steps[si])) then changed = true end
            end
            highestTier = ti
        end
    end

    -- Progress in a later tier means earlier tiers are complete (or skipped).
    for ti = 1, highestTier - 1 do
        local tier = data.tiers[ti]
        for _, step in ipairs(tier.steps) do
            if markAuto(stepKey(tier, step)) then changed = true end
        end
    end

    return changed
end

---------------------------------------------------------------------------
-- Progress helpers
---------------------------------------------------------------------------
local function tierProgress(tier, doneTbl)
    local d = 0
    for _, s in ipairs(tier.steps) do
        if doneTbl[stepKey(tier, s)] then d = d + 1 end
    end
    return d, #tier.steps
end

local function nextStep(data, doneTbl)
    for _, tier in ipairs(data.tiers) do
        for _, s in ipairs(tier.steps) do
            if not doneTbl[stepKey(tier, s)] then return tier, s end
        end
    end
end

---------------------------------------------------------------------------
-- Multi-box sync (actors)
---------------------------------------------------------------------------
local peers = {}
local mailbox

local function send(msg)
    msg.server = server
    msg.from = myName
    if mailbox then mailbox:send({ mailbox = SCRIPT }, msg) end
end

local function broadcast()
    send({ type = 'state', name = myName, class = myClass, done = state.done, auto = state.auto, version = VERSION })
end

mailbox = actors.register(SCRIPT, function(message)
    local m = message()
    if type(m) ~= 'table' or m.server ~= server or m.from == myName then return end
    if m.type == 'state' and m.name then
        peers[m.name] = { class = m.class, done = m.done or {}, auto = m.auto or {}, seen = os.time(), version = m.version }
    elseif m.type == 'hello' then
        needBroadcast = true
    elseif m.type == 'set' and m.target == myName and m.key then
        setStep(m.key, m.value)
    elseif m.type == 'quit' then
        running = false
    end
end)

---------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------
local show = not headless
local selected = myName
local TIER_HEADERS = { 'Pre / 1.0', 'Epic 1.5', 'Epic 2.0' }

local function charList()
    local list = { { name = myName, class = myClass, done = state.done, auto = state.auto, self = true } }
    local names = {}
    for n in pairs(peers) do names[#names + 1] = n end
    table.sort(names)
    for _, n in ipairs(names) do
        local p = peers[n]
        list[#list + 1] = { name = n, class = p.class, done = p.done, auto = p.auto, stale = (os.time() - p.seen) > 45 }
    end
    return list
end

local function progressCell(tier, doneTbl)
    if not tier or #tier.steps == 0 then
        ImGui.TextDisabled(tier and 'no data' or '-')
        return
    end
    local d, n = tierProgress(tier, doneTbl)
    local complete = d == n
    if complete then ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.20, 0.70, 0.25, 1.0) end
    ImGui.ProgressBar(n > 0 and d / n or 0, -1, 0, complete and 'Done' or string.format('%d/%d', d, n))
    if complete then ImGui.PopStyleColor() end
end

local function drawSummary(list)
    local flags = ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg
    if ImGui.BeginTable('summary', 6, flags) then
        ImGui.TableSetupColumn('Character', ImGuiTableColumnFlags.WidthFixed, 110)
        ImGui.TableSetupColumn('Class', ImGuiTableColumnFlags.WidthFixed, 95)
        for _, h in ipairs(TIER_HEADERS) do
            ImGui.TableSetupColumn(h, ImGuiTableColumnFlags.WidthFixed, 85)
        end
        ImGui.TableSetupColumn('Next Step', ImGuiTableColumnFlags.WidthStretch)
        ImGui.TableHeadersRow()

        for _, c in ipairs(list) do
            local data = getClassData(c.class)
            ImGui.TableNextRow()

            ImGui.TableNextColumn()
            local label = c.name .. (c.stale and ' (offline)' or '')
            if ImGui.Selectable(label .. '##sel' .. c.name, selected == c.name) then selected = c.name end

            ImGui.TableNextColumn()
            ImGui.Text(c.class or '?')

            for ti = 1, 3 do
                ImGui.TableNextColumn()
                progressCell(data and data.tiers[ti], c.done)
            end

            ImGui.TableNextColumn()
            if not data then
                ImGui.TextDisabled('no class data')
            else
                local tier, s = nextStep(data, c.done)
                local total = 0
                for _, t in ipairs(data.tiers) do total = total + #t.steps end
                if total == 0 then
                    ImGui.TextDisabled('steps not filled in yet')
                elseif s then
                    ImGui.Text(string.format('[%s] %s', tier.short or tier.name, s.text))
                    if ImGui.IsItemHovered() and s.zone then ImGui.SetTooltip(s.zone) end
                else
                    ImGui.TextColored(0.3, 0.9, 0.3, 1.0, 'All epics complete!')
                end
            end
        end
        ImGui.EndTable()
    end
end

local function toggleStep(c, key, value)
    if c.self then
        setStep(key, value)
    else
        c.done[key] = value or nil -- optimistic, confirmed on next broadcast
        send({ type = 'set', target = c.name, key = key, value = value })
    end
end

-- Opens a guide in the default Windows browser. Also copies it to the clipboard
-- in case the shell call is blocked.
local function openUrl(url)
    if type(url) ~= 'string' or not url:match('^https?://') or url:find('["%c]') then
        print('\ar[EpicTracker]\ax refusing odd URL: ' .. tostring(url))
        return
    end
    pcall(ImGui.SetClipboardText, url)
    local ok = pcall(os.execute, 'start "" "' .. url .. '"')
    printf('\ag[EpicTracker]\ax %s %s', ok and 'opening' or 'copied to clipboard:', url)
end

local function startOnGroup()
    mq.cmdf('%s /lua run %s bg', GROUP_CMD, SCRIPT)
    printf('\ag[EpicTracker]\ax sent "%s /lua run %s bg" (the "already running" message on this character is normal).', GROUP_CMD, SCRIPT)
end

local function drawSteps(c, tier)
    local flags = ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg
    if not ImGui.BeginTable('steps_' .. tier.id, 4, flags) then return end
    ImGui.TableSetupColumn('Done', ImGuiTableColumnFlags.WidthFixed, 60)
    ImGui.TableSetupColumn('#', ImGuiTableColumnFlags.WidthFixed, 24)
    ImGui.TableSetupColumn('Step', ImGuiTableColumnFlags.WidthStretch)
    ImGui.TableSetupColumn('Zone', ImGuiTableColumnFlags.WidthFixed, 150)
    ImGui.TableHeadersRow()

    for si, s in ipairs(tier.steps) do
        local key = stepKey(tier, s)
        ImGui.TableNextRow()

        ImGui.TableNextColumn()
        local val = c.done[key] == true
        local newVal, pressed = ImGui.Checkbox('##' .. key, val)
        if pressed then toggleStep(c, key, newVal) end
        if c.auto[key] then
            ImGui.SameLine()
            ImGui.TextColored(0.45, 0.75, 1.0, 1.0, 'auto')
        end

        ImGui.TableNextColumn()
        ImGui.Text(tostring(si))

        ImGui.TableNextColumn()
        local hasDetails = s.notes or s.details or s.detect or s.url
        if val then ImGui.PushStyleColor(ImGuiCol.Text, 0.55, 0.55, 0.55, 1.0) end
        if hasDetails then
            local open = ImGui.TreeNode(s.text .. '##node' .. key)
            if val then ImGui.PopStyleColor(); val = false end
            if open then
                if s.notes then ImGui.TextWrapped(s.notes) end
                if s.details then
                    for i, line in ipairs(s.details) do
                        ImGui.TextColored(0.85, 0.75, 0.45, 1.0, string.format('%d.', i))
                        ImGui.SameLine()
                        ImGui.TextWrapped(line)
                    end
                end
                if s.detect then
                    ImGui.TextColored(0.45, 0.75, 1.0, 1.0, 'Auto-detects: ' .. table.concat(s.detect, ', '))
                end
                if s.url then
                    if ImGui.SmallButton((s.urlLabel or 'Open guide') .. '##url' .. key) then openUrl(s.url) end
                end
                ImGui.TreePop()
            end
        else
            ImGui.TextWrapped(s.text)
        end
        if val then ImGui.PopStyleColor() end

        ImGui.TableNextColumn()
        ImGui.Text(s.zone or '')
    end
    ImGui.EndTable()
end

local function drawDetail(c)
    ImGui.Separator()
    ImGui.Text(string.format('%s - %s', c.name, c.class or '?'))
    local data = getClassData(c.class)
    if not data then
        ImGui.TextDisabled('No step data for this class yet.')
        return
    end
    if data.source then
        ImGui.SameLine()
        ImGui.TextDisabled('(steps from ' .. data.source .. ')')
    end
    if ImGui.BeginTabBar('tiers##' .. c.name) then
        for ti, tier in ipairs(data.tiers) do
            local d, n = tierProgress(tier, c.done)
            if ImGui.BeginTabItem(string.format('%s (%d/%d)###tier%d', tier.name, d, n, ti)) then
                local links = {}
                if tier.url then links[#links + 1] = { 'Open guide', tier.url } end
                for _, l in ipairs(tier.links or {}) do links[#links + 1] = l end
                for i, l in ipairs(links) do
                    if i > 1 then ImGui.SameLine() end
                    if ImGui.Button(l[1] .. '##tierlink' .. ti .. '_' .. i) then openUrl(l[2]) end
                    if ImGui.IsItemHovered() then ImGui.SetTooltip(l[2]) end
                end
                if tier.note then ImGui.TextWrapped(tier.note) end
                if n == 0 then
                    ImGui.TextDisabled('Steps not filled in yet.')
                else
                    drawSteps(c, tier)
                end
                ImGui.EndTabItem()
            end
        end
        ImGui.EndTabBar()
    end
end

local function draw()
    if not show then return end
    ImGui.SetNextWindowSize(ImVec2(820, 520), ImGuiCond.FirstUseEver)
    local shouldDraw
    show, shouldDraw = ImGui.Begin('Epic Tracker##' .. myName, show)
    if shouldDraw then
        if ImGui.Button('Rescan') then
            if scan() then saveState(); dirty = true end
        end
        ImGui.SameLine()
        if ImGui.Button('Refresh boxes') then send({ type = 'hello' }) end
        ImGui.SameLine()
        if ImGui.Button('Start on group') then startOnGroup() end
        if ImGui.IsItemHovered() then ImGui.SetTooltip(GROUP_CMD .. ' /lua run ' .. SCRIPT .. ' bg') end
        ImGui.SameLine()
        ImGui.TextDisabled('Tip: open your bank once per session so bank items get detected.')

        local list = charList()
        drawSummary(list)

        local sel
        for _, c in ipairs(list) do if c.name == selected then sel = c end end
        if sel then drawDetail(sel) end
    end
    ImGui.End()
end

mq.imgui.init('EpicTracker', draw)

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------
mq.bind('/epictracker', function(cmd)
    cmd = (cmd or ''):lower()
    if cmd == 'hide' then
        show = false
    elseif cmd == 'scan' then
        if scan() then saveState(); dirty = true end
        print('\ag[EpicTracker]\ax scanned.')
    elseif cmd == 'refresh' then
        send({ type = 'hello' })
    elseif cmd == 'group' then
        startOnGroup()
    elseif cmd == 'quit' then
        running = false
    elseif cmd == 'quitall' then
        send({ type = 'quit' })
        running = false
    else
        show = not show or cmd == 'show'
    end
end)

---------------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------------
loadState()
printf('\ag[EpicTracker]\ax v%s running for %s (%s)%s. /epictracker to toggle.', VERSION, myName, myClass, headless and ' in background' or '')
send({ type = 'hello' })
broadcast()

local lastScan, lastBcast = 0, 0
while running do
    local now = os.time()
    if now - lastScan >= 5 then
        if scan() then saveState(); dirty = true end
        lastScan = now
    end
    if dirty or needBroadcast or now - lastBcast >= 15 then
        broadcast()
        dirty, needBroadcast, lastBcast = false, false, now
    end
    mq.delay(250)
end

mq.unbind('/epictracker')
print('\ag[EpicTracker]\ax stopped.')
