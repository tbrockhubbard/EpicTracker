-- EpicTracker v1.7.0 (2026-11-22)
-- Zone names used in the step data -> EverQuest zone short names (${Zone.ShortName}).
-- Used by the "This Zone" tab. Short names from the RedGuides zone list
-- (https://www.redguides.com/docs/projects/everquest/general/zone-short-names/).
--
-- A step's `zone` text is split on " / ", " or " and ", ", and a trailing "(...)" note is
-- dropped, so "Kod'Taz / Yxtta" and "Lake of Ill Omen (Sarnak fort)" work without their
-- own entry. Matching ignores case and a leading "The ".
-- A step can also name its zones directly: zones = { 'poknowledge' }.
-- Run tools/check_zones.lua after adding steps: it lists any zone text that doesn't match.

local M = {}

-- Name (lowercase, no leading "the ") -> short names
M.names = {
    -- Base EverQuest
    ["ak'anon"] = { 'akanon' },
    ['butcherblock mountains'] = { 'butcher' },
    ['castle mistmoore'] = { 'mistmoore' },
    ['caverns of exile'] = { 'soldungc' },
    ['solc'] = { 'soldungc' },
    ['commonlands'] = { 'commons', 'ecommons', 'commonlands' },
    ['east freeport'] = { 'freporte', 'freeporteast' },
    ['west freeport'] = { 'freportw', 'freeportwest' },
    ['freeport'] = { 'freporte', 'freportw', 'freportn', 'freeporteast', 'freeportwest' },
    ['east karana'] = { 'eastkarana' },
    ['north karana'] = { 'northkarana' },
    ['south karana'] = { 'southkarana' },
    ['west karana'] = { 'qey2hh1' },
    ['karanas'] = { 'qey2hh1', 'northkarana', 'southkarana', 'eastkarana' },
    ['erudin'] = { 'erudnext', 'erudnint' },
    ['estate of unrest'] = { 'unrest' },
    ['everfrost'] = { 'everfrost' },
    ['everfrost ldon'] = { 'everfrost' },
    ['feerrott'] = { 'feerrott' },
    ['greater faydark'] = { 'gfaydark' },
    ['lesser faydark'] = { 'lfaydark' },
    ['high keep'] = { 'highkeep' },
    ['highpass hold'] = { 'highpasshold' },
    ['hole'] = { 'hole' },
    ['innothule swamp'] = { 'innothule', 'innothuleb' },
    ['jaggedpine forest'] = { 'jaggedpine' },
    ['kithicor forest'] = { 'kithicor', 'kithforest' },
    ['lake rathetear'] = { 'lakerathe' },
    ['lavastorm mountains'] = { 'lavastorm' },
    ['misty thicket'] = { 'misty', 'mistythicket' },
    ['najena'] = { 'najena' },
    ["nedaria's landing"] = { 'nedaria' },
    ['north felwithe'] = { 'felwithea' },
    ['north qeynos'] = { 'qeynos2' },
    ['south qeynos'] = { 'qeynos' },
    ['north ro'] = { 'nro', 'northro' },
    ['south ro'] = { 'sro', 'southro' },
    ['oasis'] = { 'oasis' },
    ['ocean of tears'] = { 'oot', 'oceanoftears' },
    ['plane of fear'] = { 'fearplane' },
    ['plane of hate'] = { 'hateplane', 'hateplaneb' },
    ['plane of sky'] = { 'airplane' },
    ['rathe mountains'] = { 'rathemtn' },
    ['rathe mtns'] = { 'rathemtn' },
    ['rivervale'] = { 'rivervale' },
    ['steamfont mountains'] = { 'steamfont', 'steamfontmts' },
    ['stonebrunt mountains'] = { 'stonebrunt' },
    ['surefall glade'] = { 'qrg' },
    ['surefall'] = { 'qrg' },
    ['temple of cazic-thule'] = { 'cazicthule' },
    ['temple of solusek ro'] = { 'soltemple' },
    ['toxxulous forest'] = { 'tox', 'toxxulia' },
    ['toxxulia forest'] = { 'tox', 'toxxulia' },
    ['bazaar'] = { 'bazaar' },
    ['warrens'] = { 'warrens' },

    -- Ruins of Kunark
    ['burning woods'] = { 'burningwood' },
    ['city of mist'] = { 'citymist' },
    ['dreadlands'] = { 'dreadlands' },
    ['firiona vie'] = { 'firiona' },
    ['hall of betrayal'] = { 'chardokb' },
    ['halls of betrayal'] = { 'chardokb' },
    ['howling stones'] = { 'charasis' },
    ['charasis'] = { 'charasis' },
    ['lake of ill omen'] = { 'lakeofillomen' },
    ['old sebilis'] = { 'sebilis' },
    ['overthere'] = { 'overthere' },
    ['emerald jungle'] = { 'emeraldjungle' },
    ['skyfire mountains'] = { 'skyfire' },
    ['swamp of no hope'] = { 'swampofnohope' },
    ['temple of droga'] = { 'droga' },
    ['timorous deep'] = { 'timorous' },
    ['veksar'] = { 'veksar' },

    -- Scars of Velious
    ['cobalt scar'] = { 'cobaltscar' },
    ['dragon necropolis'] = { 'necropolis' },
    ['eastern wastes'] = { 'eastwastes' },
    ['western wastes'] = { 'westwastes' },
    ['great divide'] = { 'greatdivide' },
    ['iceclad ocean'] = { 'iceclad' },
    ['kael drakkel'] = { 'kael' },
    ['kael drakkal'] = { 'kael' },
    ['plane of growth'] = { 'growthplane' },
    ['plane of mischief'] = { 'mischiefplane' },
    ["siren's grotto"] = { 'sirens' },
    ['thurgadin'] = { 'thurgadina' },
    ['tower of frozen shadow'] = { 'frozenshadow' },
    ["velketor's labyrinth"] = { 'velketor' },
    ['wakening lands'] = { 'wakening' },
    ['wakening land'] = { 'wakening' },

    -- Shadows of Luclin
    ['akheva ruins'] = { 'akheva' },
    ['dawnshroud peaks'] = { 'dawnshroud' },
    ['fungus grove'] = { 'fungusgrove' },
    ["grieg's end"] = { 'griegsend' },
    ['grimling forest'] = { 'grimling' },
    ['hollowshade moor'] = { 'hollowshade' },
    ['katta castellum'] = { 'katta' },
    ["maiden's eye"] = { 'maiden' },
    ['mons letalis'] = { 'letalis' },
    ['scarlet desert'] = { 'scarlet' },
    ["shadeweaver's thicket"] = { 'shadeweaver' },
    ['shadowhaven'] = { 'shadowhaven' },
    ['shadow haven'] = { 'shadowhaven' },
    ['shar vahl'] = { 'sharvahl' },
    ['ssraeshza temple'] = { 'ssratemple' },
    ['tenebrous mountains'] = { 'tenebrous' },
    ['deep'] = { 'thedeep' },
    ['grey'] = { 'thegrey' },
    ['twilight sea'] = { 'twilight' },
    ['umbral plains'] = { 'umbral' },

    -- Planes of Power
    ['plane of knowledge'] = { 'poknowledge' },
    ['plane of tranquility'] = { 'potranquility' },
    ['potranq'] = { 'potranquility' },
    ['plane of disease'] = { 'podisease' },
    ['crypt of decay'] = { 'codecay' },
    ['ruins of lxanvom'] = { 'codecay' },
    ['plane of justice'] = { 'pojustice' },
    ['plane of innovation'] = { 'poinnovation' },
    ['plane of nightmare'] = { 'ponightmare' },
    ['plane of nightmare b'] = { 'nightmareb' },
    ['lair of terris thule'] = { 'nightmareb' },
    ['plane of torment'] = { 'potorment' },
    ['plane of valor'] = { 'povalor' },
    ['plane of storms'] = { 'postorms' },
    ['bastion of thunder'] = { 'bothunder' },
    ['halls of honor'] = { 'hohonora' },
    ['halls of honor b'] = { 'hohonorb' },
    ['temple of marr'] = { 'hohonorb' },
    ['plane of tactics'] = { 'potactics' },
    ["solusek ro's tower"] = { 'solrotower' },
    ['plane of fire'] = { 'pofire' },
    ['plane of air'] = { 'poair' },
    ['plane of water'] = { 'powater' },
    ['plane of earth a'] = { 'poeartha' },
    ['plane of earth b'] = { 'poearthb' },
    ['plane of earth'] = { 'poeartha', 'poearthb' },
    ['elemental planes'] = { 'pofire', 'poair', 'powater', 'poeartha', 'poearthb' },
    ['plane of time'] = { 'potimea', 'potimeb' },

    -- Legacy of Ykesha
    ["dulak's harbor"] = { 'dulak' },
    ['gulf of gunthak'] = { 'gunthak' },
    ["hate's fury"] = { 'hatesfury' },
    ['crypt of nadox'] = { 'nadox' },
    ['torgiran mines'] = { 'torgiran' },

    -- Lost Dungeons of Norrath
    ['mistmoore catacombs'] = { 'mmca', 'mmcb', 'mmcc', 'mmcd', 'mmce', 'mmcf', 'mmcg', 'mmch', 'mmci', 'mmcj' },

    -- Gates of Discord
    ['abysmal sea'] = { 'abysmal' },
    ['barindu'] = { 'barindu' },
    ['ferubi'] = { 'ferubi' },
    ["kod'taz"] = { 'kodtaz' },
    ['natimbi'] = { 'natimbi' },
    ['qinimi'] = { 'qinimi' },
    ['riwwi'] = { 'riwwi' },
    ['tipt'] = { 'tipt' },
    ['vxed'] = { 'vxed' },
    ['yxtta'] = { 'yxtta' },
    ["god zones (kod'taz, yxtta, tipt, natimbi)"] = { 'kodtaz', 'yxtta', 'tipt', 'natimbi' },

    -- Omens of War
    ['anguish'] = { 'anguish' },
    ['asylum of anguish'] = { 'anguish' },
    ['bloodfields'] = { 'bloodfields' },
    ["dranik's scar"] = { 'draniksscar' },
    ["dranik's hollows"] = { 'dranikhollowsa', 'dranikhollowsb', 'dranikhollowsc', 'dranikhollowsd', 'dranikhollowse',
                            'dranikhollowsf', 'dranikhollowsg', 'dranikhollowsh', 'dranikhollowsi', 'dranikhollowsj' },
    ['ruined city of dranik'] = { 'dranik' },
    ['rcod'] = { 'dranik' },
    ["harbinger's spire"] = { 'harbingers' },
    ["harbingers' spire"] = { 'harbingers' },
    ['muramite proving grounds'] = { 'provinggrounds', 'chambersa', 'chambersb', 'chambersc', 'chambersd', 'chamberse', 'chambersf' },
    ['mpg'] = { 'provinggrounds', 'chambersa', 'chambersb', 'chambersc', 'chambersd', 'chamberse', 'chambersf' },
    ["nobles' causeway"] = { 'causeway' },
    ["riftseekers' sanctum"] = { 'riftseekers' },
    ['wall of slaughter'] = { 'wallofslaughter' },
}

-- Texts that are not a single place: crafting, "various", whole continents or expansions.
-- Steps with only these never show in This Zone.
M.ignore = {
    ['-'] = true, ['various'] = true, ['hometown'] = true, ['faydwer'] = true, ['luclin'] = true,
    ['oow zones'] = true, ['god zones'] = true, ['ldon hard mode'] = true, ['sewers'] = true,
}

local function norm(s)
    s = tostring(s or ''):lower():gsub('`', "'"):gsub('\226\128\153', "'"):gsub('%s+', ' ')
    s = s:gsub('^ ', ''):gsub(' $', ''):gsub('^the ', '')
    return s
end
M.norm = norm

-- Every known short name also matches itself.
local shorts = {}
for _, list in pairs(M.names) do for _, sn in ipairs(list) do shorts[sn] = true end end

local function lookup(part)
    local p = norm(part)
    if p == '' or M.ignore[p] then return {}, true end
    if M.names[p] then return M.names[p], true end
    if shorts[p] then return { p }, true end
    local bare = norm(p:gsub('%s*%b()$', ''))
    if bare ~= p then
        if M.ignore[bare] then return {}, true end
        if M.names[bare] then return M.names[bare], true end
    end
    return {}, false
end

-- Returns a set { shortname = true } and a list of parts that matched nothing.
function M.resolve(text)
    local set, unknown = {}, {}
    if text == nil then return set, unknown end
    local whole, ok = lookup(text)
    if ok then
        for _, sn in ipairs(whole) do set[sn] = true end
        return set, unknown
    end
    local s = ' ' .. norm(text):gsub(' / ', '\1'):gsub(' or ', '\1'):gsub(', ', '\1') .. ' '
    for part in s:gmatch('[^\1]+') do
        local list, found = lookup(part)
        if found then
            for _, sn in ipairs(list) do set[sn] = true end
        else
            unknown[#unknown + 1] = norm(part)
        end
    end
    return set, unknown
end

return M
