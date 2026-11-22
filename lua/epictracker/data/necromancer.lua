-- EpicTracker v1.6.0 (2026-11-22)
-- Necromancer epic data. See docs/DATA_FORMAT.md for the step format.
-- Source: eqprogression.com. Live steps; verify on Lazarus.
local E = 'https://www.eqprogression.com/'
return {
    class = 'Necromancer',
    source = 'eqprogression.com, live steps',
    tiers = {
        {
            id = 'pre', name = '1.5 Pre-Quest', short = 'Pre', url = E .. '?p=49685',
            note = 'Only needed without the 1.0 (Scythe of the Shadowed Soul). Progress in 1.5 auto-completes this tier.',
            steps = {
                { id = 's1', text = 'Hail Geboron (SE building, evil side)', zone = 'Plane of Knowledge', detect = { 'Note to Yuanda' } },
                { id = 's2', text = 'Note to Yuanda, kill 5 snarling werewolves', zone = 'West Karana' },
                { id = 's3', text = 'Hail and kill a shady bandit (south side)', zone = 'West Karana', detect = { 'Contract of Sale' } },
                { id = 's4', text = 'Contract to Egonis', zone = 'Lake Rathetear' },
                { id = 's5', text = 'Hail and kill Ronaiar Skullmoore (west)', zone = 'Lake Rathetear' },
                { id = 's6', text = 'Worboli: "do somethings", kill the Gnoll Scavanger', zone = 'Lake Rathetear', detect = { 'Rotten Fish' } },
                { id = 's7', text = 'Kill the Man-eating Freshwater Shark', zone = 'Lake Rathetear', detect = { 'Piece of the Staff' } },
                { id = 's8', text = 'Rotten Fish to Worboli', zone = 'Lake Rathetear' },
                { id = 's9', text = 'Show Piece of the Staff to Geboron', zone = 'Plane of Knowledge' },
                { id = 's10', text = 'Piece of the Staff to Kazen Fecae', zone = 'Lake Rathetear', detect = { 'Note to Biddliss', 'Note to Biddlis' } },
            },
        },
        {
            id = 'e15', name = 'Epic 1.5: Soulwhisper', short = '1.5', url = E .. 'necromancer-1-5-epic-guide-soulwhisper/',
            steps = {
                { id = 's1', text = 'Hail Kazen Fecae (+340, -1600) for the note (skip if pre-quest done)', zone = 'Lake Rathetear' },
                { id = 's2', text = 'Note to Biddliss Sperandu (+400, -1140)', zone = 'Steamfont Mountains', detect = { 'Gleaming Ore Satchel' } },
                { id = 's3', text = 'Loot 4x Gleaming Zraxthril Ore (south side)', zone = 'Torgiran Mines', nobackfill = true, count = 4, detect = { 'Gleaming Zraxthril Ore' } },
                { id = 's4', text = 'Combine ore in the satchel', zone = '-', detect = { 'Sealed Ore Satchel' } },
                { id = 's5', text = 'Sealed satchel to Biddliss', zone = 'Steamfont Mountains', detect = { "Biddliss's Research Tools" } },
                { id = 's6', text = 'Tools to Kazen Fecae', zone = 'Lake Rathetear', detect = { 'Drawing of Rune' } },
                { id = 's7', text = 'Drawing to Ruandia, instructions to Tebarin', zone = 'Plane of Knowledge', detect = { "Ruandia's Instructions", 'Intricately Carved Box' } },
                { id = 's8', text = 'Loot 2x Ball of Elemental Clay', zone = 'The Hole / Plane of Earth', nobackfill = true, count = 2, detect = { 'Ball of Elemental Clay' } },
                { id = 's9', text = 'Combine clay in the box, give to Tebarin', zone = 'Plane of Knowledge', detect = { 'Strange Smelling Oil' } },
                { id = 's10', text = 'Kill old gargoyle (rare, city rooftops)', zone = 'The Hole', nobackfill = true, detect = { 'Ancient Tome of Lost Lore' } },
                { id = 's11', text = 'Combine tome + oil in the box', zone = '-', detect = { 'Protected Tome' } },
                { id = 's12', text = 'Tome to Tebarin, give the Glowing Tome back', zone = 'Plane of Knowledge', detect = { 'Rune Covered Insert' } },
                { id = 's13', text = 'Blacksmithing to 100', zone = '-' },
                { id = 's14a', text = 'Loot Gnarled Wood (gnarled treant, rare)', zone = 'Plane of Nightmare', nobackfill = true, detect = { 'Gnarled Wood' } },
                { id = 's14b', text = 'Loot Elaborate Hinge (scrap collector, rare)', zone = 'Plane of Innovation', nobackfill = true, detect = { 'Elaborate Hinge' } },
                { id = 's15', text = 'Forge: wood + hinge + insert', zone = '-', detect = { 'Glowing Box of Protection' } },
                { id = 's16', text = 'Box to Tebarin', zone = 'Plane of Knowledge', detect = { 'Paladin Headhunting Satchel' } },
                { id = 's17', text = 'Kill the 4 Karana paladins (roam)', zone = 'Karanas',
                  details = { "East: Sir Gregon Sulltor -> Sir Gregon's Head", "North: Sir Gerwin Thunderblade -> Sir Gerwin's Head", "West: Sir Arlindo Goldheart -> Sir Arlindo's Head", "South: Sir Telian Mottsworth -> Sir Telian's Head" },
                  nobackfill = true, all = true, detect = { "Sir Gregon's Head", "Sir Gerwin's Head", "Sir Arlindo's Head", "Sir Telian's Head" } },
                { id = 's18', text = 'Combine heads in the satchel, give to Tebarin', zone = 'Plane of Knowledge', detect = { 'Orb of Deathspeaking' } },
                { id = 's19', text = 'Whiahdi (+400, -930): say "staff"', zone = 'Natimbi' },
                { id = 's20', text = 'Taiandao (+360, -120): "Hail", "killed whiahdi", kill Viarglug', zone = 'Barindu', detect = { "Whiahdi's Earthly Possessions" } },
                { id = 's21', text = 'Possessions to Whiahdi, say "power"', zone = 'Natimbi' },
                { id = 's22', text = 'Hail and kill Tarlang (-150, +1350; 4-5 groups)', zone = "Nobles' Causeway", detect = { "Tarlang's Head" } },
                { id = 's23', text = 'Head to Whiahdi', zone = 'Natimbi', detect = { 'Soulwhisper' } },
            },
        },
        {
            id = 'e20', name = 'Epic 2.0: Deathwhisper', short = '2.0', url = E .. '?p=21288',
            steps = {
                { id = 's1', text = 'Whiahdi: "locate the paladin"', zone = 'Natimbi' },
                { id = 's2', text = 'Discord Fluctuation: "sanait sanaiij tsulum"; kill Gronogg + Arlagai (raid)', zone = 'Ruined City of Dranik',
                  detect = { 'Staff Piece Number Two', 'Staff Piece Number Three' } },
                { id = 's3', text = 'Loot Globe of Discordant Energy (raid)', zone = 'Anguish', nobackfill = true, detect = { 'Globe of Discordant Energy' } },
                { id = 's4', text = '2 staff pieces + Globe + 1.5 to Whiahdi', zone = 'Natimbi', detect = { 'Deathwhisper' } },
            },
        },
    },
}
