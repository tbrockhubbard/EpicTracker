-- EpicTracker v1.5.0 (2026-11-22)
-- Wizard epic data. See docs/DATA_FORMAT.md for the step format.
-- Source: eqprogression.com. Live steps; verify on Lazarus.
local E = 'https://www.eqprogression.com/'
return {
    class = 'Wizard',
    source = 'eqprogression.com, live steps',
    tiers = {
        {
            id = 'pre', name = '1.5 Pre-Quest', short = 'Pre', url = E .. 'wizard-1-5-epic-pre-quest-guide/',
            note = 'Only needed without the 1.0 (Staff of the Four). eqprogression says the 1.0 is easier. Progress in 1.5 auto-completes this tier.',
            steps = {
                { id = 's1', text = 'Talwyn Flamecaller (+2180, -1040): "test of intelligence"', zone = 'Lavastorm Mountains', detect = { 'Old Parchment' } },
                { id = 's2', text = 'Gather the 10 items', zone = 'various',
                  details = {
                      'Emerald-tipped Staff: Gorge of King Xorbb', 'Empty Jug: Katta Castellum', 'Golden Dagger: Skyfire Mountains',
                      'Ivory Bone: Gulf of Gunthak', "Meditation Basket: Warsliks Woods", "Old Pipe: Dagnor's Cauldron",
                      'Platinum Token: Plane of Justice', "Red Cloth: Maiden's Eye", 'White Sash: Mons Letalis', 'Worn Turban: Plane of Tranquility (fishing)',
                  } },
                { id = 's3', text = 'Turn in the 10 items (4, 4, 2), say "test of channeling"', zone = 'Lavastorm Mountains', detect = { 'Rune of Greater Desiccation' } },
                { id = 's4', text = '/open the skeleton on the throne room table, kill scorpions', zone = 'Lake of Ill Omen (Sarnak fort)', detect = { 'Cursed Talisman' } },
                { id = 's5', text = 'Show talisman to Talwyn, say "test of research"', zone = 'Lavastorm Mountains' },
                { id = 's6', text = 'Farm 9 more runes', zone = 'Vxed, LDoN hard mode, Veksar, Sewers, Bazaar',
                  notes = 'Cascade, Coruscation, Flash, Glint, Impulse, Synergy, Tempest, Vortex, Greater Conflagration (Shar Vinitras, Akheva Ruins). Main bottleneck.',
                  nobackfill = true, detect = { 'Rune of Greater Conflagration' } },
                { id = 's7', text = 'Research 190: combine 10 runes in a Spell Research Kit', zone = '-', detect = { 'Spell: Electrical Charge' } },
                { id = 's8', text = 'Show the spell to Talwyn, say "test of subtlety"', zone = 'Lavastorm Mountains' },
                { id = 's9', text = 'Yama Twerik: "ready", cast Electrical Charge on the Inactive Clockwork', zone = 'Steamfont Mountains' },
                { id = 's10', text = 'Hail Talwyn', zone = 'Lavastorm Mountains' },
            },
        },
        {
            id = 'e15', name = 'Epic 1.5: Staff of Prismatic Power', short = '1.5', url = E .. 'wizard-1-5-epic-guide-staff-of-prismatic-power/',
            steps = {
                { id = 's1', text = 'Talwyn: "Hail", "agree"', zone = 'Lavastorm Mountains' },
                { id = 's2', text = 'Kill Girplan Guardian (raid)', zone = 'Wall of Slaughter', nobackfill = true, detect = { 'Fluxing Staff' } },
                { id = 's3', text = 'In the Pot atop the mesa: "i have come for your gem", kill Elite Sun Revenant (raid)', zone = 'Scarlet Desert', detect = { 'Fluxing Gem' } },
                { id = 's4', text = 'Kill Hobgoblin Horrorfiend', zone = 'Plane of Nightmare', nobackfill = true, detect = { 'Fluxing Rune' } },
                { id = 's5', text = 'Ground spawn (+1145, -350)', zone = 'Ruined City of Dranik', nobackfill = true, detect = { 'Fluxing Chunk of Ore' } },
                { id = 's6', text = '4 Fluxing items to Talwyn, say "powerful item"', zone = 'Lavastorm Mountains', detect = { 'Staff of Fluxing Power' } },
                { id = 's7', text = 'Ring event: Pure Flame Elemental', zone = 'Caverns of Exile', detect = { 'Wisp of Pure Flame' } },
                { id = 's8', text = 'Show wisp to Talwyn', zone = 'Lavastorm Mountains' },
                { id = 's9', text = 'Kill Mistress of the Darkwater', zone = "Siren's Grotto", nobackfill = true, detect = { 'Shard of Pure Ice' } },
                { id = 's10', text = 'Show shard to Talwyn', zone = 'Lavastorm Mountains' },
                { id = 's11', text = 'Hail Kalym Rasalan (-300, -1150)', zone = 'Plane of Tranquility', detect = { 'Silken Tapestry' } },
                { id = 's12', text = 'Tailoring 125: Silk Thread x3, Silk Cord, then the satchel', zone = '-',
                  notes = 'Backpack Pattern + Silk Cord + Silken Tapestry.', detect = { 'Silken Tapestry Satchel' } },
                { id = 's13', text = 'Show satchel to Talwyn', zone = 'Lavastorm Mountains' },
                { id = 's14', text = 'Cohesion Gem + 4 Prismatic Crystals', zone = 'various',
                  details = {
                      'Cohesion Gem: Plane of Innovation, zone-wide uncommon drop',
                      'Prismatic Crystal: Twilight Sea ground spawn (+4270, +1340)',
                      'Prismatic Crystal: Veksar ground spawn (+220, +535 confirmed)',
                      "Prismatic Crystal: Dulak's Harbor, Treasure Sorter Neiben",
                      'Prismatic Crystal: Timorous Deep ground spawn (+5615, -4225)',
                  },
                  nobackfill = true, detect = { 'Cohesion Gem' } },
                { id = 's15', text = 'Combine wisp, shard, staff, gem, 4 crystals in the satchel', zone = '-', detect = { 'Full Tapestry Satchel' } },
                { id = 's16', text = 'Full satchel to Talwyn', zone = 'Lavastorm Mountains', detect = { 'Staff of Prismatic Power' } },
            },
        },
        {
            id = 'e20', name = 'Epic 2.0: Staff of Phenomenal Power', short = '2.0', url = E .. 'wizard-2-0-epic-guide-staff-of-phenomenal-power/',
            steps = {
                { id = 's1', text = 'Hail Talwyn', zone = 'Lavastorm Mountains' },
                { id = 's2', text = 'Grathnok Gilforgan (-460, +150): "intricate horn of galien"', zone = "Dranik's Scar" },
                { id = 's3', text = 'Kill Lightningcaller Vhalek (raid)', zone = 'Muramite Proving Grounds', detect = { 'Intricate Horn of Galien' } },
                { id = 's4', text = 'Horn to Grathnok', zone = "Dranik's Scar" },
                { id = 's5', text = 'Loot Globe of Discordant Energy (raid)', zone = 'Anguish', nobackfill = true, detect = { 'Globe of Discordant Energy' } },
                { id = 's6', text = 'Globe to Talwyn', zone = 'Lavastorm Mountains', detect = { 'Broken Orb of Discordant Energy' } },
                { id = 's7', text = 'Lime orb into a Spacial Distortion atop the NW spire', zone = 'Dreadlands', detect = { 'Infused Orb of Discordant Energy' } },
                { id = 's8', text = 'Teal orb into a Spacial Distortion atop the NW spire', zone = 'Mons Letalis' },
                { id = 's9', text = '2 Infused Orbs + 1.5 to Talwyn', zone = 'Lavastorm Mountains', detect = { 'Staff of Phenomenal Power' } },
            },
        },
    },
}
