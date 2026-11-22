-- EpicTracker v1.7.0 (2026-11-22)
-- Lists step zone texts that zones.lua can't match to an EverQuest zone.
-- Run from the repo root with any Lua 5.1+ or LuaJIT:   lua tools/check_zones.lua
-- Exit code 1 if anything is unmatched.
package.path = './lua/?.lua;' .. package.path
local zones = require('epictracker.zones')

local files = {}
local windows = package.config:sub(1, 1) == '\\'
local p = io.popen(windows and 'dir /b /s lua\\epictracker\\data\\*.lua lua\\epictracker\\flags\\*.lua'
    or 'ls lua/epictracker/data/*.lua lua/epictracker/flags/*.lua')
for line in p:lines() do files[#files + 1] = line end
p:close()

local bad, steps, matched = 0, 0, 0
for _, f in ipairs(files) do
    local ok, t = pcall(dofile, f)
    if ok and type(t) == 'table' then
        for _, g in ipairs(t.tiers or t.sections or {}) do
            for _, st in ipairs(g.steps or {}) do
                steps = steps + 1
                if st.zones then
                    matched = matched + 1
                else
                    local set, unknown = zones.resolve(st.zone)
                    if #unknown > 0 then
                        bad = bad + 1
                        print(string.format('%s  %s.%s  zone = %q  (no match for: %s)', f, g.id, st.id, tostring(st.zone), table.concat(unknown, ', ')))
                    elseif next(set) then
                        matched = matched + 1
                    end
                end
            end
        end
    else
        print('could not load ' .. f .. ': ' .. tostring(t))
        bad = bad + 1
    end
end
print(string.format('%d steps, %d matched to a zone, %d unmatched (the rest are "-" or "various").', steps, matched, bad))
os.exit(bad > 0 and 1 or 0)
