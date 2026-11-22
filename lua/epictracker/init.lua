-- EpicTracker v1.5.0 (2026-11-22)
--[[
  EpicTracker - tracks Epic 1.5 pre-quest, Epic 1.5 and Epic 2.0 progress
  across all your boxed characters.

  Main character:   /lua run epictracker           (with window)
  Whole group:      /e3bcga /lua run epictracker bg (bots report in, no window)
                    or press "Start on group" in the window / type /epictracker group
  Slash command:    /epictracker [show|hide|scan|refresh|group|update|updatelinkdb|exportlinks|quit|quitall]

  Progress is saved per character in your MQ config folder and shared between
  clients with MQ's built-in actors messaging. E3 is only used to launch it.
]]

local mq = require('mq')
local ImGui = require('ImGui')
local actors = require('actors')

local SCRIPT = 'epictracker'
local VERSION = '1.5.0'

-- Command used to send a command to every character in the group.
-- Project Lazarus + E3Next: /e3bcga (all, including you). DanNet users: /dgga
local GROUP_CMD = '/e3bcga'

-- Lazarus wiki (toolbar button)
local WIKI_URL = 'https://www.lazaruseq.com/'

-- In-game updater (Update button). Where new versions come from:
local GITHUB_REPO = 'tbrockhubbard/EpicTracker'
-- 'releases' = only published GitHub Releases (recommended: pushing work-in-progress
--              to GitHub never reaches anyone until you publish a release)
-- 'main'     = whatever the VERSION file says on the branch below
local UPDATE_FROM = 'releases'
local UPDATE_BRANCH = 'main'
-- Quietly check for a new version once, shortly after the window opens.
local AUTO_CHECK = true

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
-- Item links learned from every box (real Lazarus items). Written only by the character
-- with the window open. v2 file: the v1.3.1 file could hold live MQ2LinkDB links.
local linksPath = string.format('%s/epictracker_links2_%s.lua', mq.configDir, server)
local exportPath = string.format('%s/epictracker_links_export.lua', mq.configDir)

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

-- Flag sets (not class-based). Each file returns { id, name, sections = { { id, steps } } }.
local FLAG_SETS = { 'pop' }
local flagCache = {}
local function getFlagData(id)
    if flagCache[id] ~= nil then return flagCache[id] or nil end
    local ok, data = pcall(require, SCRIPT .. '.flags.' .. id)
    if not ok or type(data) ~= 'table' then
        printf('\ar[EpicTracker]\ax failed to load flag data %s: %s', id, tostring(data))
        flagCache[id] = false
        return nil
    end
    flagCache[id] = data
    return data
end

---------------------------------------------------------------------------
-- State (this character)
---------------------------------------------------------------------------
-- schema 2 (v1.1.0): item counts. Older saves are checked once on load.
local SCHEMA = 2
local state = { done = {}, auto = {}, progress = {}, schema = SCHEMA, stories = {}, links = {} }
local knownLinks, linksDirty = {}, false
local dirty, needBroadcast, running = false, false, true

local function loadState()
    local f = loadfile(savePath)
    if not f then return end
    local ok, t = pcall(f)
    if ok and type(t) == 'table' then
        state.done = t.done or {}
        state.auto = t.auto or {}
        state.schema = t.schema or 1
        state.stories = t.stories or {}
    end
end

local function loadLinks()
    local f = loadfile(linksPath)
    if not f then return end
    local ok, t = pcall(f)
    if ok and type(t) == 'table' then knownLinks = t end
end

-- Guild-built Lazarus link library shipped in the repo (links/lazarus.lua).
local guildLinks = {}
do
    local ok, t = pcall(require, SCRIPT .. '.links.lazarus')
    if ok and type(t) == 'table' then guildLinks = t end
end

local function learnLink(name, link)
    if type(link) == 'string' and link ~= '' and link ~= 'NULL' and knownLinks[name] ~= link then
        knownLinks[name] = link
        linksDirty = true
    end
end

local function saveState()
    mq.pickle(savePath, { done = state.done, auto = state.auto, schema = state.schema, stories = state.stories })
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
-- How many of an item this character holds (inventory + bank, stacks counted).
-- Bank data is only known after the bank has been opened once this session.
local function itemQty(name)
    local q = '=' .. name
    return (mq.TLO.FindItemCount(q)() or 0) + (mq.TLO.FindItemBankCount(q)() or 0)
end

-- A detect entry is either 'Item Name' or { 'Item Name', count }.
local function entryOf(step, e)
    if type(e) == 'table' then return e[1], e[2] or step.count or 1 end
    return e, step.count or 1
end

-- Returns met, have, need for a step's detect list.
--   default: ANY listed item at its count (spelling variants, items that drop together)
--   all = true: EVERY listed item at its count ("collect these 4 pieces")
local function stepProgress(step)
    if not step.detect then return false, 0, 0 end
    if step.all then
        local have, need, met = 0, 0, true
        for _, e in ipairs(step.detect) do
            local name, n = entryOf(step, e)
            local q = itemQty(name)
            have, need = have + math.min(q, n), need + n
            if q < n then met = false end
        end
        return met, have, need
    end
    local bestHave, bestNeed, met = 0, 1, false
    for _, e in ipairs(step.detect) do
        local name, n = entryOf(step, e)
        local q = itemQty(name)
        if q >= n then return true, n, n end
        if bestNeed == 1 or (q / n) > (bestHave / bestNeed) then bestHave, bestNeed = q, n end
    end
    return met, bestHave, bestNeed
end

local function needsCount(step)
    if not step.detect then return false end
    if step.all and #step.detect > 1 then return true end
    for _, e in ipairs(step.detect) do
        local _, n = entryOf(step, e)
        if n > 1 then return true end
    end
    return false
end

-- Link text for an item this character carries (inventory or bank), or nil.
local function itemLinkText(name)
    local q = '=' .. name
    for _, find in ipairs({ mq.TLO.FindItem, mq.TLO.FindItemBank }) do
        local it = find and find(q)
        if it and it() then
            local ok, link = pcall(function() return it.ItemLink() end)
            if ok and type(link) == 'string' and link ~= '' and link ~= 'NULL' then return link end
        end
    end
end

-- Every item name the tracker shows for this character (built once).
local trackedList
local function trackedItems()
    if trackedList then return trackedList end
    local seen, list = {}, {}
    local function add(e)
        local name = type(e) == 'table' and e[1] or e
        if name and not seen[name] then seen[name] = true; list[#list + 1] = name end
    end
    local function addSteps(steps) for _, st in ipairs(steps) do for _, e in ipairs(st.detect or {}) do add(e) end end end
    local data = getClassData(myClass)
    for _, tier in ipairs(data and data.tiers or {}) do
        addSteps(tier.steps)
        if tier.reward then add(tier.reward) end
    end
    for _, fid in ipairs(FLAG_SETS) do
        local fdata = getFlagData(fid)
        if fdata then
            if fdata.reward then add(fdata.reward) end
            for _, sec in ipairs(fdata.sections) do addSteps(sec.steps) end
        end
    end
    trackedList = list
    return list
end

-- Used by the UI to list what a step looks for.
local function detectText(step)
    local parts = {}
    for _, e in ipairs(step.detect or {}) do
        local name, n = entryOf(step, e)
        parts[#parts + 1] = (n > 1) and string.format('%dx %s', n, name) or name
    end
    return (step.all and 'all of: ' or '') .. table.concat(parts, step.all and ', ' or ' / ')
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
    local data = getClassData(myClass) or { tiers = {} }

    local changed = false
    local highestTier = 0

    -- One-time fix for saves from before item counts (v1.0.x): steps that were
    -- auto-checked on a partial count get unchecked. Backfill below re-checks
    -- any whose later steps prove they were really finished.
    if (state.schema or 1) < SCHEMA then
        for _, tier in ipairs(data.tiers) do
            for _, step in ipairs(tier.steps) do
                local key = stepKey(tier, step)
                if state.auto[key] and needsCount(step) and not stepProgress(step) then
                    state.done[key], state.auto[key] = nil, nil
                end
            end
        end
        state.schema = SCHEMA
        changed = true
    end

    local progress = {}
    for ti, tier in ipairs(data.tiers) do
        local highest = 0
        for si, step in ipairs(tier.steps) do
            local key = stepKey(tier, step)
            local allowed = (step.after == nil) or state.done[step.after]
            if step.detect and allowed then
                local met, have, need = stepProgress(step)
                if met then
                    if markAuto(key) then changed = true end
                elseif need > 1 and have > 0 and not state.done[key] then
                    progress[key] = { have, need }
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

    -- Flag sets: detect only, no backfill (flags can be done in any order).
    for _, fid in ipairs(FLAG_SETS) do
        local fdata = getFlagData(fid)
        for _, sec in ipairs(fdata and fdata.sections or {}) do
            for _, step in ipairs(sec.steps) do
                local key = stepKey(sec, step)
                if step.detect then
                    local met, have, need = stepProgress(step)
                    if met then
                        if markAuto(key) then changed = true end
                    elseif need > 1 and have > 0 and not state.done[key] then
                        progress[key] = { have, need }
                    end
                end
            end
        end
    end

    -- Item links for quest items this character carries, so any box can open them later.
    local links = {}
    for _, name in ipairs(trackedItems()) do
        if itemQty(name) > 0 then
            local link = itemLinkText(name)
            if link then
                links[name] = link
                if state.links[name] ~= link then dirty = true end
                learnLink(name, link)
            end
        end
    end
    state.links = links

    -- Partial counts ("2/4") are shared with the group but not saved.
    for k, v in pairs(progress) do
        local old = state.progress[k]
        if not old or old[1] ~= v[1] or old[2] ~= v[2] then dirty = true end
    end
    for k in pairs(state.progress) do if not progress[k] then dirty = true end end
    state.progress = progress

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

-- Flag counting. Optional rows (raid keys) never count.
local function flagCounts(fdata, doneTbl)
    local d, n, flags = 0, 0, 0
    for _, sec in ipairs(fdata.sections) do
        for _, st in ipairs(sec.steps) do
            if not st.optional then
                n = n + 1
                if doneTbl[stepKey(sec, st)] then
                    d = d + 1
                    if st.flag then flags = flags + 1 end
                end
            end
        end
    end
    return d, n, flags
end

local function sectionCounts(sec, doneTbl)
    local d, n = 0, 0
    for _, st in ipairs(sec.steps) do
        if not st.optional then
            n = n + 1
            if doneTbl[stepKey(sec, st)] then d = d + 1 end
        end
    end
    return d, n
end

-- "Stories due": flags earned since the character last said "stories" to Gram Dunnar.
local function storiesDue(setId, c)
    local fdata = getFlagData(setId)
    if not fdata then return 0 end
    local _, _, flags = flagCounts(fdata, c.done)
    return math.max(0, flags - ((c.stories or {})[setId] or 0))
end

local function markStories(setId)
    local fdata = getFlagData(setId)
    if not fdata then return end
    local _, _, flags = flagCounts(fdata, state.done)
    state.stories[setId] = flags
    saveState()
    dirty = true
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
    send({ type = 'state', name = myName, class = myClass, done = state.done, auto = state.auto, progress = state.progress, stories = state.stories, links = state.links, version = VERSION })
end

mailbox = actors.register(SCRIPT, function(message)
    local m = message()
    if type(m) ~= 'table' or m.server ~= server or m.from == myName then return end
    if m.type == 'state' and m.name then
        peers[m.name] = { class = m.class, done = m.done or {}, auto = m.auto or {}, progress = m.progress or {}, stories = m.stories or {}, seen = os.time(), version = m.version }
        for name, link in pairs(m.links or {}) do learnLink(name, link) end
    elseif m.type == 'hello' then
        needBroadcast = true
    elseif m.type == 'set' and m.target == myName and m.key then
        setStep(m.key, m.value)
    elseif m.type == 'stories' and m.target == myName and m.set then
        markStories(m.set)
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
    local list = { { name = myName, class = myClass, done = state.done, auto = state.auto, progress = state.progress, stories = state.stories, self = true } }
    local names = {}
    for n in pairs(peers) do names[#names + 1] = n end
    table.sort(names)
    for _, n in ipairs(names) do
        local p = peers[n]
        list[#list + 1] = { name = n, class = p.class, done = p.done, auto = p.auto, progress = p.progress or {}, stories = p.stories or {}, stale = (os.time() - p.seen) > 45 }
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
                    local pr = c.progress and c.progress[stepKey(tier, s)]
                    ImGui.Text(string.format('[%s] %s%s', tier.short or tier.name, s.text,
                        pr and string.format('  (%d/%d)', pr[1], pr[2]) or ''))
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

-- Opens the in-game item window for an item, by name. Most accurate source first:
--   1. This character carries it: Inspect it.
--   2. One of your boxes carries it or has carried it (Lazarus server link, remembered).
--   3. The guild's Lazarus link library (links/lazarus.lua in the repo).
--   4. MQ2LinkDB, which is built from LIVE EverQuest. Stats may not match Lazarus. Never cached.
local function executeLink(link)
    mq.cmdf('/executelink %s', link)
end

local function openItem(name)
    local q = '=' .. name
    for _, find in ipairs({ mq.TLO.FindItem, mq.TLO.FindItemBank }) do
        local it = find and find(q)
        if it and it() then
            it.Inspect()
            return
        end
    end
    local link = knownLinks[name] or guildLinks[name]
    if link then
        executeLink(link)
        return
    end
    local ok, dblink = pcall(function() return mq.TLO.LinkDB(q)() end)
    if ok and type(dblink) == 'string' and dblink ~= '' and dblink ~= 'NULL' then
        executeLink(dblink)
        printf('\ay[EpicTracker]\ax "%s" opened from MQ2LinkDB (live EverQuest data). Lazarus may have changed this item; the link becomes exact once one of your characters carries it.', name)
        return
    end
    printf('\ay[EpicTracker]\ax No link for "%s" yet. It is learned automatically once any of your characters carries it.', name)
    if not ok then
        printf('\ay[EpicTracker]\ax Or load MQ2LinkDB and click "Update LinkDB" in the toolbar.')
    else
        printf('\ay[EpicTracker]\ax MQ2LinkDB didn\'t know it either. Click "Update LinkDB" in the toolbar to pull its item list.')
    end
end

-- Pulls MQ2LinkDB's item list (loads the plugin first if needed).
local function updateLinkDB()
    local loaded = false
    for _, n in ipairs({ 'MQ2LinkDB', 'mq2linkdb', 'linkdb' }) do
        local ok, v = pcall(function() return mq.TLO.Plugin(n).IsLoaded() end)
        if ok and v then loaded = true end
    end
    if not loaded then mq.cmd('/plugin linkdb load') end
    mq.cmd('/link /update')
    print('\ag[EpicTracker]\ax Pulling the MQ2LinkDB item list (/link /update). This can take a minute.')
end

-- Writes every Lazarus link your boxes have collected, for the guild library.
local function exportLinks()
    local n = 0
    for _ in pairs(knownLinks) do n = n + 1 end
    mq.pickle(exportPath, knownLinks)
    printf('\ag[EpicTracker]\ax Exported %d item links to %s', n, exportPath)
    print('\ag[EpicTracker]\ax Send that file in (GitHub issue or Discord) to add them to the guild link library.')
end

---------------------------------------------------------------------------
-- In-game updater
---------------------------------------------------------------------------
-- MacroQuest's Lua can't download anything itself, so the work is done by small
-- batch files that call curl.exe and tar.exe (both built into Windows 10 and 11).
-- They run minimized in the background and leave a status file the main loop polls,
-- so the game never freezes waiting on GitHub.
--   1. Check:    read the latest release (or VERSION on the branch) + CHANGELOG.md
--   2. Download: fetch the zip and unpack it into config/epictracker_update/new
--   3. Verify:   every .lua file must compile, all 16 class files must be there,
--                and the new init.lua's VERSION must match the release
--   4. Install:  back up lua/epictracker, copy the new files over it
--   5. Restart:  the tracker on this character and on every box
-- Saved progress and links live in MacroQuest/config and are never touched.
local function winPath(p) return (tostring(p):gsub('/', '\\')) end

local UPD_DIR = winPath(mq.configDir .. '/epictracker_update')
local UPD_CMD = winPath(mq.configDir .. '/epictracker_update.cmd')
local UPD_STATUS = UPD_DIR .. '\\status.txt'
local INSTALL_DIR = winPath(mq.luaDir .. '/' .. SCRIPT)

local upd = {
    phase = 'idle',   -- idle checking uptodate available confirm downloading installing done error
    open = false,     -- update panel shown
    quiet = false,    -- startup check: don't open the panel unless there's an update
}

local function parseVersion(s)
    local a, b, c = tostring(s or ''):match('^%s*v?(%d+)%.(%d+)%.(%d+)%s*$')
    if not a then return nil end
    return { tonumber(a), tonumber(b), tonumber(c) }
end

local function isNewer(remote, current)
    local r, c = parseVersion(remote), parseVersion(current)
    if not r or not c then return false end
    for i = 1, 3 do
        if r[i] ~= c[i] then return r[i] > c[i] end
    end
    return false
end

local function readFile(path)
    local f = io.open(path, 'rb')
    if not f then return nil end
    local s = f:read('*a')
    f:close()
    return s
end

-- Pulls one string value out of GitHub's JSON (top-level keys only; enough for
-- tag_name, body, html_url and zipball_url, which appear once each).
local JSON_ESC = { n = '\n', t = '  ', r = '', b = '', f = '', ['"'] = '"', ['\\'] = '\\', ['/'] = '/' }
local function jsonString(s, key)
    local _, j = s:find('"' .. key .. '"%s*:%s*"')
    if not j then return nil end
    local out, k = {}, j + 1
    while k <= #s do
        local ch = s:sub(k, k)
        if ch == '\\' then
            local n = s:sub(k + 1, k + 1)
            if n == 'u' then
                local cp = tonumber(s:sub(k + 2, k + 5), 16) or 63
                out[#out + 1] = cp < 128 and string.char(cp) or '?'
                k = k + 6
            else
                out[#out + 1] = JSON_ESC[n] or n
                k = k + 2
            end
        elseif ch == '"' then
            break
        else
            out[#out + 1] = ch
            k = k + 1
        end
    end
    return table.concat(out)
end

-- Only plain GitHub https URLs make it into a batch file (no quotes, %, &, ? or spaces).
local function safeUrl(u)
    return type(u) == 'string' and u:match('^https://[%w%.%-]*github[%w%.%-]*%.com/[%w%.%-_/]+$') ~= nil
end

-- The changelog section for one version ("## 1.5.0 (...)" up to the next "## ").
local function changelogSection(text, ver)
    if not text or not ver then return nil end
    text = '\n' .. text:gsub('\r', '')
    local pat = '\n## ' .. ver:gsub('%.', '%%.') .. '[^\n]*\n'
    local s, e = text:find(pat)
    if not s then return nil end
    local nxt = text:find('\n## ', e)
    return (text:sub(e + 1, (nxt or #text + 1) - 1):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function updFail(msg)
    upd.phase, upd.err = 'error', msg
    upd.open = true
    printf('\ar[EpicTracker]\ax Update: %s', msg)
end
local updFailLoud = updFail

-- Writes the batch file and starts it minimized. Returns false if it couldn't start.
local function runBatch(body, timeout)
    if UPD_DIR:find('[%%"]') or INSTALL_DIR:find('[%%"]') then
        updFail('your MacroQuest folder path has a % or " in it, which the updater can\'t handle. Update by hand from GitHub.')
        return false
    end
    os.remove(UPD_STATUS)
    local f = io.open(UPD_CMD, 'w')
    if not f then
        updFail('couldn\'t write ' .. UPD_CMD)
        return false
    end
    f:write('@echo off\nsetlocal\nset "W=' .. UPD_DIR .. '"\nif not exist "%W%" mkdir "%W%"\n')
    f:write(body)
    f:write('\nexit /b\n')
    f:close()
    os.execute('start "EpicTracker update" /min cmd /c ""' .. UPD_CMD .. '""')
    upd.started, upd.timeout = os.time(), timeout
    return true
end

-- Status line the batch file writes when it finishes ("ok" or "fail-...").
local function batchStatus()
    local s = readFile(UPD_STATUS)
    if not s then return nil end
    os.remove(UPD_STATUS)
    return (s:gsub('%s+$', ''))
end

local BATCH_FAIL = {
    ['fail-net'] = "couldn't reach GitHub. Check your internet connection. (Needs curl.exe, built into Windows 10 and 11.)",
    ['fail-download'] = "the download failed. Try again in a minute.",
    ['fail-extract'] = "couldn't unpack the zip (needs tar.exe, built into Windows 10 and 11).",
    ['fail-backup'] = "couldn't back up the current files, so nothing was changed.",
    ['fail-copy'] = "couldn't copy the new files. Your old version was put back.",
}

local function checkForUpdate(quiet)
    if upd.phase == 'checking' or upd.phase == 'downloading' or upd.phase == 'installing' then return end
    if not GITHUB_REPO:match('^[%w%-_%.]+/[%w%-_%.]+$') then
        updFail('GITHUB_REPO at the top of init.lua isn\'t set to "user/repo".')
        return
    end
    upd.quiet = quiet and true or false
    if not upd.quiet then upd.open = true end
    local raw = string.format('https://raw.githubusercontent.com/%s/%s', GITHUB_REPO, UPDATE_BRANCH)
    local body
    if UPDATE_FROM == 'main' then
        body = 'curl.exe -sSL -A EpicTracker -o "%W%\\remote.txt" -w "%%{http_code}" "' .. raw .. '/VERSION" > "%W%\\http.txt"\n'
    else
        body = 'curl.exe -sSL -A EpicTracker -H "Accept: application/vnd.github+json" -o "%W%\\remote.txt" -w "%%{http_code}" '
            .. '"https://api.github.com/repos/' .. GITHUB_REPO .. '/releases/latest" > "%W%\\http.txt"\n'
    end
    body = body .. 'if errorlevel 1 goto fail\n'
        .. 'curl.exe -sSL -A EpicTracker -o "%W%\\changelog.md" "' .. raw .. '/CHANGELOG.md"\n'
        .. '> "%W%\\status.txt" echo ok\nexit /b\n'
        .. ':fail\n> "%W%\\status.txt" echo fail-net\n'
    if runBatch(body, 60) then upd.phase = 'checking' end
end

local function finishCheck()
    -- The quiet startup check never nags; problems only show when you click Updates.
    local function updFail(msg)
        if upd.quiet then upd.phase = 'idle' else updFailLoud(msg) end
    end
    local http = (readFile(UPD_DIR .. '\\http.txt') or ''):match('%d+')
    local remote = readFile(UPD_DIR .. '\\remote.txt') or ''
    local changelog = readFile(UPD_DIR .. '\\changelog.md')
    local latest, notes, url, page
    if UPDATE_FROM == 'main' then
        if http ~= '200' then return updFail('couldn\'t read VERSION from GitHub (HTTP ' .. tostring(http) .. ').') end
        latest = remote:match('^%s*v?([%d%.]+)')
        url = string.format('https://github.com/%s/archive/refs/heads/%s.zip', GITHUB_REPO, UPDATE_BRANCH)
        page = string.format('https://github.com/%s', GITHUB_REPO)
    else
        if http == '404' then
            return updFail('no release published on GitHub yet (' .. GITHUB_REPO .. ' > Releases).')
        elseif http ~= '200' then
            return updFail('GitHub answered HTTP ' .. tostring(http) .. (http == '403' and ' (too many checks this hour; try again later).' or '.'))
        end
        local tag = jsonString(remote, 'tag_name')
        latest = tag and tag:match('^v?([%d%.]+)$')
        notes = jsonString(remote, 'body')
        page = jsonString(remote, 'html_url')
        -- Prefer an attached EpicTracker-vX.Y.Z.zip, otherwise GitHub's source zip.
        for u in remote:gmatch('"browser_download_url"%s*:%s*"([^"]+)"') do
            if u:match('EpicTracker%-v[%d%.]+%.zip$') then url = u end
        end
        url = url or jsonString(remote, 'zipball_url')
    end
    if not parseVersion(latest) then return updFail('couldn\'t make sense of the version on GitHub.') end
    if not safeUrl(url) then return updFail('the download link from GitHub looked wrong, so it was skipped.') end
    upd.latest, upd.url = latest, url
    upd.page = safeUrl(page) and page or ('https://github.com/' .. GITHUB_REPO)
    upd.notes = changelogSection(changelog, latest) or ((notes and notes:match('%S')) and notes) or nil
    upd.checked = os.time()
    if isNewer(latest, VERSION) then
        upd.phase = 'available'
        upd.open = true
        printf('\ag[EpicTracker]\ax Update available: v%s (you have v%s). Click the green Update button.', latest, VERSION)
    else
        upd.phase = 'uptodate'
        if not upd.quiet then printf('\ag[EpicTracker]\ax You have the latest version (v%s).', VERSION) end
    end
end

local function startDownload()
    if not upd.url then return end
    local body = 'rmdir /s /q "%W%\\new" 2>nul\n'
        .. 'del /q "%W%\\pkg.zip" "%W%\\files.txt" 2>nul\n'
        .. 'mkdir "%W%\\new"\n'
        .. 'curl.exe -fsSL -A EpicTracker -o "%W%\\pkg.zip" "' .. upd.url .. '"\n'
        .. 'if errorlevel 1 goto faildl\n'
        .. 'tar.exe -xf "%W%\\pkg.zip" -C "%W%\\new"\n'
        .. 'if errorlevel 1 goto failx\n'
        .. 'dir /s /b /a-d "%W%\\new" > "%W%\\files.txt"\n'
        .. '> "%W%\\status.txt" echo ok\nexit /b\n'
        .. ':faildl\n> "%W%\\status.txt" echo fail-download\nexit /b\n'
        .. ':failx\n> "%W%\\status.txt" echo fail-extract\n'
    if runBatch(body, 180) then
        upd.phase = 'downloading'
        printf('\ag[EpicTracker]\ax Downloading v%s from GitHub...', upd.latest)
    end
end

-- Checks the unpacked files before anything is replaced. Returns the folder to install from.
local function verifyDownload()
    local list = readFile(UPD_DIR .. '\\files.txt')
    if not list then return nil, 'the download had no files in it.' end
    local files, src = {}, nil
    for line in list:gmatch('[^\r\n]+') do
        files[#files + 1] = line
        local l = line:lower():gsub('/', '\\')
        if l:match('\\lua\\epictracker\\init%.lua$') then
            local dir = line:sub(1, #line - #'\\init.lua')
            if not src or #dir < #src then src = dir end
        end
    end
    if not src then return nil, 'the download has no lua/epictracker/init.lua. Is the repo layout right?' end
    local srcLower = src:lower() .. '\\'
    local luaCount = 0
    for _, line in ipairs(files) do
        local l = line:lower()
        if l:sub(1, #srcLower) == srcLower and l:match('%.lua$') then
            local fn, err = loadfile(line)
            if not fn then return nil, 'a file in the new version has an error: ' .. tostring(err) end
            luaCount = luaCount + 1
        end
    end
    local found = 0
    for _, file in pairs(CLASS_FILES) do
        if readFile(src .. '\\data\\' .. file .. '.lua') then found = found + 1 end
    end
    if found < 16 then return nil, string.format('the new version is missing class files (%d of 16).', found) end
    local init = readFile(src .. '\\init.lua') or ''
    local newVer = init:match("local VERSION = '([%d%.]+)'")
    if newVer ~= upd.latest then
        return nil, string.format('the new init.lua says v%s but GitHub says v%s. (VERSION and init.lua need bumping together.)', tostring(newVer), upd.latest)
    end
    if src:find('[%%"]') then return nil, 'odd characters in the download path.' end
    return src, string.format('%d Lua files checked', luaCount)
end

local function startInstall(src)
    local body = 'set "SRC=' .. src .. '"\n'
        .. 'set "DST=' .. INSTALL_DIR .. '"\n'
        .. 'rmdir /s /q "%W%\\backup" 2>nul\n'
        .. 'xcopy "%DST%" "%W%\\backup\\" /e /i /y /q >nul\n'
        .. 'if errorlevel 1 goto failb\n'
        .. 'xcopy "%SRC%" "%DST%\\" /e /i /y /q >nul\n'
        .. 'if errorlevel 1 goto failc\n'
        .. '> "%W%\\status.txt" echo ok\nexit /b\n'
        .. ':failb\n> "%W%\\status.txt" echo fail-backup\nexit /b\n'
        .. ':failc\nxcopy "%W%\\backup" "%DST%\\" /e /i /y /q >nul\n'
        .. '> "%W%\\status.txt" echo fail-copy\n'
    if runBatch(body, 60) then upd.phase = 'installing' end
end

-- Stops the tracker everywhere and starts the new version. /timed runs after this script ends.
local function restartAll()
    local boxes = false
    for _, p in pairs(peers) do
        if os.time() - (p.seen or 0) <= 45 then boxes = true end
    end
    send({ type = 'quit' }) -- every version since 1.0 understands this
    mq.cmdf('/timed 20 /lua run %s', SCRIPT)
    if boxes then mq.cmdf('/timed 40 %s /lua run %s bg', GROUP_CMD, SCRIPT) end
    printf('\ag[EpicTracker]\ax Installed v%s. Restarting%s...', upd.latest, boxes and ' here and on your boxes' or '')
    upd.phase = 'done'
    running = false
end

-- Called from the main loop: picks up a finished batch step and starts the next.
local function pollUpdater()
    if upd.phase ~= 'checking' and upd.phase ~= 'downloading' and upd.phase ~= 'installing' then return end
    local st = batchStatus()
    if not st then
        if os.time() - (upd.started or 0) > (upd.timeout or 60) then
            updFail('timed out waiting on GitHub. Try again.')
        end
        return
    end
    if st ~= 'ok' then
        if upd.phase == 'checking' and upd.quiet then
            upd.phase = 'idle' -- startup check failed quietly; the button still works
            return
        end
        return updFail(BATCH_FAIL[st] or ('unexpected result: ' .. st))
    end
    if upd.phase == 'checking' then
        finishCheck()
    elseif upd.phase == 'downloading' then
        local src, info = verifyDownload()
        if not src then return updFail(info) end
        printf('\ag[EpicTracker]\ax Download looks good (%s). Installing...', info)
        startInstall(src)
    elseif upd.phase == 'installing' then
        restartAll()
    end
end

local function drawUpdatePanel()
    if not upd.open then return end
    local p = upd.phase
    ImGui.Separator()
    if p == 'checking' then
        ImGui.Text('Checking GitHub for a new version...')
    elseif p == 'downloading' then
        ImGui.Text(string.format('Downloading v%s...', upd.latest or '?'))
    elseif p == 'installing' then
        ImGui.Text('Installing...')
    elseif p == 'done' then
        ImGui.TextColored(0.3, 0.9, 0.3, 1.0, 'Installed. Restarting...')
    elseif p == 'error' then
        ImGui.TextColored(1.0, 0.45, 0.4, 1.0, 'Update problem:')
        ImGui.SameLine()
        ImGui.TextWrapped(upd.err or '?')
        if ImGui.Button('Try again##upd') then checkForUpdate(false) end
        ImGui.SameLine()
        if ImGui.Button('Open GitHub##upderr') then openUrl('https://github.com/' .. GITHUB_REPO) end
        ImGui.SameLine()
        if ImGui.Button('Close##upderr') then upd.open = false end
    elseif p == 'uptodate' or p == 'idle' then
        ImGui.Text(string.format("You're on v%s, the latest.", VERSION))
        ImGui.SameLine()
        if ImGui.SmallButton('Check again##upd') then checkForUpdate(false) end
        ImGui.SameLine()
        if ImGui.SmallButton('Close##upd') then upd.open = false end
    elseif p == 'available' or p == 'confirm' then
        ImGui.TextColored(0.3, 0.9, 0.3, 1.0, string.format('EpicTracker v%s is available', upd.latest))
        ImGui.SameLine()
        ImGui.TextDisabled(string.format('(you have v%s)', VERSION))
        if upd.notes then
            local shown = 0
            for line in upd.notes:gmatch('[^\n]+') do
                shown = shown + 1
                if shown > 14 then
                    ImGui.TextDisabled('...more on the release page')
                    break
                end
                ImGui.TextWrapped(line)
            end
        end
        if p == 'available' then
            if ImGui.Button('Install update##upd') then upd.phase = 'confirm' end
            ImGui.SameLine()
            if ImGui.Button('Release page##upd') then openUrl(upd.page) end
            ImGui.SameLine()
            if ImGui.Button('Not now##upd') then upd.open = false end
        else
            ImGui.TextColored(0.95, 0.75, 0.30, 1.0,
                'This replaces lua/epictracker and restarts the tracker here and on your boxes. Saved progress is kept.')
            if ImGui.Button(string.format('Yes, install v%s##upd', upd.latest)) then startDownload() end
            ImGui.SameLine()
            if ImGui.Button('Cancel##upd') then upd.phase = 'available' end
        end
    end
    ImGui.Separator()
end

local function drawUpdateButton()
    local avail = upd.phase == 'available' or upd.phase == 'confirm'
    if avail then
        ImGui.PushStyleColor(ImGuiCol.Button, 0.15, 0.55, 0.20, 1.0)
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.20, 0.68, 0.26, 1.0)
    end
    local label = avail and ('Update to v' .. upd.latest) or 'Updates'
    if ImGui.Button(label .. '###updbtn') then
        if avail or upd.open then
            upd.open = not upd.open
        else
            checkForUpdate(false)
        end
    end
    if avail then ImGui.PopStyleColor(2) end
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(avail and 'A new version is on GitHub. Click to see what changed and install it.'
            or ('Check GitHub (' .. GITHUB_REPO .. ') for a new version of EpicTracker'))
    end
end

-- Draws an item name as a clickable link (item-link green, underlined on hover).
local function itemLink(name, id)
    ImGui.TextColored(0.55, 0.85, 1.0, 1.0, name)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip('Click to open the item window')
    end
    if ImGui.IsItemClicked() then openItem(name) end
end

-- The reward for a tier: explicit tier.reward, or the last step's detect item.
local function tierReward(tier)
    if tier.reward then return tier.reward end
    local last = tier.steps[#tier.steps]
    if last and last.detect then
        local e = last.detect[#last.detect]
        return type(e) == 'table' and e[1] or e
    end
end

local function startOnGroup()
    mq.cmdf('%s /lua run %s bg', GROUP_CMD, SCRIPT)
    printf('\ag[EpicTracker]\ax sent "%s /lua run %s bg" (the "already running" message on this character is normal).', GROUP_CMD, SCRIPT)
end

local function drawSteps(c, tier)
    local flags = ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg
    if not ImGui.BeginTable('steps_' .. tier.id, 4, flags) then return end
    ImGui.TableSetupColumn('Done', ImGuiTableColumnFlags.WidthFixed, 72)
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
        elseif c.progress and c.progress[key] then
            ImGui.SameLine()
            ImGui.TextColored(0.95, 0.75, 0.30, 1.0, string.format('%d/%d', c.progress[key][1], c.progress[key][2]))
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
                    ImGui.TextColored(0.45, 0.75, 1.0, 1.0, s.all and 'Auto-detects (all of):' or 'Auto-detects:')
                    for i, e in ipairs(s.detect) do
                        local name, n = entryOf(s, e)
                        ImGui.SameLine()
                        if n > 1 then ImGui.Text(n .. 'x'); ImGui.SameLine() end
                        itemLink(name, key .. '_' .. i)
                    end
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
                local reward = tierReward(tier)
                if reward then
                    if #links > 0 then ImGui.SameLine() end
                    ImGui.Text('Reward:')
                    ImGui.SameLine()
                    itemLink(reward, 'reward' .. ti)
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

---------------------------------------------------------------------------
-- Flags tab
---------------------------------------------------------------------------
local flagView = 'grid'   -- 'grid' or 'list'
local flagSel = myName    -- character shown in checklist view

local function toldGram(c, setId)
    if c.self then
        markStories(setId)
    else
        local fdata = getFlagData(setId)
        local _, _, flags = flagCounts(fdata, c.done)
        c.stories[setId] = flags -- optimistic
        send({ type = 'stories', target = c.name, set = setId })
    end
end

local function storiesCell(c, setId, idSuffix)
    local due = storiesDue(setId, c)
    if due > 0 then
        ImGui.TextColored(0.95, 0.75, 0.30, 1.0, string.format('%d due', due))
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip(string.format('%d new flag(s) since this character last said "stories" to Gram Dunnar.', due))
        end
        ImGui.SameLine()
        if ImGui.SmallButton('Told Gram##' .. idSuffix) then toldGram(c, setId) end
        if ImGui.IsItemHovered() then ImGui.SetTooltip('Click after saying "stories" to Gram Dunnar in PoK') end
    else
        ImGui.TextColored(0.3, 0.9, 0.3, 1.0, 'up to date')
    end
end

local function flagStepText(sec, st, key)
    if st.optional then
        ImGui.TextDisabled(st.text)
    else
        ImGui.Text(st.text)
    end
    if ImGui.IsItemHovered() and (st.notes or st.zone or st.detect or st.details) then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(420)
        if st.zone then ImGui.TextColored(0.85, 0.75, 0.45, 1.0, st.zone) end
        if st.notes then ImGui.TextWrapped(st.notes) end
        for i, line in ipairs(st.details or {}) do ImGui.TextWrapped(i .. '. ' .. line) end
        if st.detect then ImGui.TextColored(0.45, 0.75, 1.0, 1.0, 'Auto-detects: ' .. detectText(st)) end
        if st.optional then ImGui.TextDisabled('Optional: only one person in the raid needs this. Not counted in progress.') end
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

local function drawFlagGrid(list, fdata)
    -- Per-character summary
    local tflags = ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg
    if ImGui.BeginTable('flagsum_' .. fdata.id, 3, tflags) then
        ImGui.TableSetupColumn('Character', ImGuiTableColumnFlags.WidthFixed, 130)
        ImGui.TableSetupColumn('Progress', ImGuiTableColumnFlags.WidthStretch)
        ImGui.TableSetupColumn('Figurine stories', ImGuiTableColumnFlags.WidthFixed, 190)
        ImGui.TableHeadersRow()
        for _, c in ipairs(list) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.Text(c.name .. (c.stale and ' (offline)' or ''))
            ImGui.TableNextColumn()
            local d, n = flagCounts(fdata, c.done)
            ImGui.ProgressBar(n > 0 and d / n or 0, -1, 0, string.format('%d/%d', d, n))
            ImGui.TableNextColumn()
            storiesCell(c, fdata.id, 'sum' .. c.name)
        end
        ImGui.EndTable()
    end

    -- One collapsible table per section: steps down the side, characters across.
    for _, sec in ipairs(fdata.sections) do
        local doneChars = 0
        for _, c in ipairs(list) do
            local d, n = sectionCounts(sec, c.done)
            if d == n then doneChars = doneChars + 1 end
        end
        local label = string.format('%s   (%d/%d characters done)###grid_%s', sec.name, doneChars, #list, sec.id)
        if ImGui.CollapsingHeader(label) then
            if sec.note then ImGui.TextWrapped(sec.note) end
            if ImGui.BeginTable('grid_' .. sec.id, 1 + #list, tflags) then
                ImGui.TableSetupColumn('Step', ImGuiTableColumnFlags.WidthStretch)
                for _, c in ipairs(list) do
                    ImGui.TableSetupColumn(c.name, ImGuiTableColumnFlags.WidthFixed, 80)
                end
                ImGui.TableHeadersRow()
                for _, st in ipairs(sec.steps) do
                    local key = stepKey(sec, st)
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    flagStepText(sec, st, key)
                    for _, c in ipairs(list) do
                        ImGui.TableNextColumn()
                        local val = c.done[key] == true
                        local newVal, pressed = ImGui.Checkbox('##' .. key .. '_' .. c.name, val)
                        if pressed then toggleStep(c, key, newVal) end
                        if c.auto[key] then
                            ImGui.SameLine()
                            ImGui.TextColored(0.45, 0.75, 1.0, 1.0, 'auto')
                        elseif c.progress and c.progress[key] then
                            ImGui.SameLine()
                            ImGui.TextColored(0.95, 0.75, 0.30, 1.0, string.format('%d/%d', c.progress[key][1], c.progress[key][2]))
                        end
                    end
                end
                ImGui.EndTable()
            end
        end
    end
end

local function drawFlagList(list, fdata)
    local sel
    for _, c in ipairs(list) do if c.name == flagSel then sel = c end end
    sel = sel or list[1]
    if ImGui.BeginCombo('Character##flagsel', sel.name) then
        for _, c in ipairs(list) do
            if ImGui.Selectable(c.name .. '##flagpick', c.name == sel.name) then flagSel = c.name end
        end
        ImGui.EndCombo()
    end
    ImGui.SameLine()
    local d, n = flagCounts(fdata, sel.done)
    ImGui.Text(string.format('%d/%d done', d, n))
    ImGui.SameLine()
    ImGui.Text('|  Figurine stories:')
    ImGui.SameLine()
    storiesCell(sel, fdata.id, 'list' .. sel.name)

    for _, sec in ipairs(fdata.sections) do
        local sd, sn = sectionCounts(sec, sel.done)
        local label = string.format('%s   (%d/%d)###list_%s', sec.name, sd, sn, sec.id)
        if ImGui.CollapsingHeader(label) then
            if sec.note then ImGui.TextWrapped(sec.note) end
            drawSteps(sel, sec)
        end
    end
end

local function drawFlagSet(list, setId)
    local fdata = getFlagData(setId)
    if not fdata then
        ImGui.TextDisabled('Flag data failed to load. Check the MQ console.')
        return
    end
    if fdata.url then
        if ImGui.Button('Open guide##flag' .. setId) then openUrl(fdata.url) end
        if ImGui.IsItemHovered() then ImGui.SetTooltip(fdata.url) end
        ImGui.SameLine()
    end
    if fdata.reward then
        ImGui.Text('Reward:')
        ImGui.SameLine()
        itemLink(fdata.reward, 'flagreward' .. setId)
        ImGui.SameLine()
    end
    ImGui.Text('   View:')
    ImGui.SameLine()
    if ImGui.RadioButton('Grid##fv', flagView == 'grid') then flagView = 'grid' end
    ImGui.SameLine()
    if ImGui.RadioButton('Checklist##fv', flagView == 'list') then flagView = 'list' end
    if fdata.note then ImGui.TextWrapped(fdata.note) end
    if fdata.source then ImGui.TextDisabled('(steps from ' .. fdata.source .. ')') end

    if flagView == 'grid' then
        drawFlagGrid(list, fdata)
    else
        drawFlagList(list, fdata)
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
        if ImGui.Button('Lazarus Wiki') then openUrl(WIKI_URL) end
        if ImGui.IsItemHovered() then ImGui.SetTooltip(WIKI_URL) end
        ImGui.SameLine()
        if ImGui.Button('Update LinkDB') then updateLinkDB() end
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("If your item links don't work, use this button to pull an MQ2LinkDB item list.\n"
                .. "Runs /link /update (loads MQ2LinkDB first if needed). Takes a minute.\n"
                .. "MQ2LinkDB is built from live EverQuest, so it's only used when none of your characters\n"
                .. "has carried the item. Links from your own characters show Lazarus's real stats.")
        end
        ImGui.SameLine()
        drawUpdateButton()
        ImGui.SameLine()
        ImGui.TextDisabled('(?)')
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip('Open your bank once per session so bank items get detected.\n'
                .. "Item links don't work? Click Update LinkDB.\n"
                .. '/epictracker exportlinks shares your Lazarus item links with the guild.\n'
                .. 'Updates checks GitHub for a new version and installs it for all your boxes.')
        end
        drawUpdatePanel()

        local list = charList()
        if ImGui.BeginTabBar('maintabs') then
            if ImGui.BeginTabItem('Epics') then
                drawSummary(list)
                local sel
                for _, c in ipairs(list) do if c.name == selected then sel = c end end
                if sel then drawDetail(sel) end
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem('PoP Flags') then
                drawFlagSet(list, 'pop')
                ImGui.EndTabItem()
            end
            ImGui.EndTabBar()
        end
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
    elseif cmd == 'updatelinkdb' then
        updateLinkDB()
    elseif cmd == 'exportlinks' then
        exportLinks()
    elseif cmd == 'update' then
        show = true
        if upd.phase == 'available' or upd.phase == 'confirm' then upd.open = true else checkForUpdate(false) end
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
loadLinks()
printf('\ag[EpicTracker]\ax v%s running for %s (%s)%s. /epictracker to toggle.', VERSION, myName, myClass, headless and ' in background' or '')
send({ type = 'hello' })
broadcast()

local lastScan, lastBcast = 0, 0
local autoCheckAt = (AUTO_CHECK and not headless) and (os.time() + 15) or nil
while running do
    local now = os.time()
    if autoCheckAt and now >= autoCheckAt and mq.TLO.MacroQuest.GameState() == 'INGAME' then
        autoCheckAt = nil
        checkForUpdate(true)
    end
    pollUpdater()
    if now - lastScan >= 5 then
        if scan() then saveState(); dirty = true end
        lastScan = now
    end
    if linksDirty and not headless then
        mq.pickle(linksPath, knownLinks)
        linksDirty = false
    end
    if dirty or needBroadcast or now - lastBcast >= 15 then
        broadcast()
        dirty, needBroadcast, lastBcast = false, false, now
    end
    mq.delay(250)
end

if linksDirty and not headless then mq.pickle(linksPath, knownLinks) end
mq.unbind('/epictracker')
print('\ag[EpicTracker]\ax stopped.')
