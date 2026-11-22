-- EpicTracker v1.5.0 (2026-11-22)
-- Planes of Power flags (the "Storytime" quest for the Intricate Wooden Figurine).
-- Source: Project Lazarus wiki, "Planes of Power Flagging" (last updated 06-29-2025 by Korwar).
-- See docs/DATA_FORMAT.md. Extra fields used here:
--   flag = true      the step gives "You've received a character flag!" (counts toward the
--                    Figurine and the "stories due" reminder)
--   optional = true  raid keys only one person needs; shown, but not counted in progress
-- Flags do NOT have to be done in order on Lazarus, so nothing here backfills.
-- Save keys look like "pop.dis.s1" (section id + step id). Never rename or reuse them.
return {
    id = 'pop',
    name = 'Planes of Power',
    short = 'PoP',
    url = 'https://www.lazaruseq.com/pages/pop-flagging',
    reward = 'Intricate Wooden Figurine',
    source = 'Lazarus wiki: Planes of Power Flagging',
    note = 'Zone access requirements are removed on Lazarus. Flags upgrade the Intricate Wooden Figurine, a powerful augment. '
        .. 'After each flag, go back to Gram Dunnar in PoK and say "stories" to update it. Flags can be done in any order.',
    sections = {
        {
            id = 'pop.fig', name = 'The Figurine', short = 'Figurine',
            steps = {
                { id = 's1', text = 'Level 51+: hail Gram Dunnar (-341, -181), say "craft"', zone = 'Plane of Knowledge',
                  notes = 'Gives the starting Intricate Wooden Figurine. Come back after each flag and say "stories" to upgrade it.',
                  detect = { 'Intricate Wooden Figurine' } },
            },
        },
        {
            id = 'pop.dis', name = 'Plane of Disease', short = 'Disease',
            steps = {
                { id = 's1', flag = true, text = 'Adler Fuirstel (outside the PoDisease portal): say "what ward"', zone = 'Plane of Tranquility' },
                { id = 's2', flag = true, text = 'Kill Grummus, hail a planar projection', zone = 'Plane of Disease',
                  notes = 'The pit in Plane of Disease leads into Crypt of Decay.' },
            },
        },
        {
            id = 'pop.jus', name = 'Plane of Justice', short = 'Justice',
            steps = {
                { id = 's1', flag = true, text = 'Mavuin: say "information"', zone = 'Plane of Justice' },
                { id = 's2', flag = true, text = 'Complete 1 of the 6 trials, give the trial boss\'s Mark to one of The Tribunal', zone = 'Plane of Justice',
                  notes = 'Loot the Mark from the trial boss and trade it to a Tribunal member in the trial room.' },
                { id = 's3', flag = true, text = 'Hail Mavuin again', zone = 'Plane of Justice' },
            },
        },
        {
            id = 'pop.inn', name = 'Plane of Innovation', short = 'Innovation',
            steps = {
                { id = 's1', flag = true, text = 'Giwin Mirakon (inside the factory door): say "I will test the machine"', zone = 'Plane of Innovation' },
                { id = 's2', flag = true, text = 'Kill Manaetic Behemoth, hail Giwin Mirakon (spawns near the boss room)', zone = 'Plane of Innovation' },
            },
        },
        {
            id = 'pop.nig', name = 'Plane of Nightmare', short = 'Nightmare',
            steps = {
                { id = 's1', flag = true, text = 'Adroha Jezith (Sick Bay): say "tortured by nightmares"', zone = 'Plane of Tranquility' },
                { id = 's2', flag = true, text = 'Complete the Hedge Maze, hail Thelin Poxbourne at the end to zone out', zone = 'Plane of Nightmare' },
                { id = 's3', flag = true, text = 'Kill Terris Thule, hail a planar projection', zone = 'Plane of Nightmare B' },
                { id = 's4', flag = true, text = 'Hail Elder Poxbourne', zone = 'Plane of Tranquility' },
            },
        },
        {
            id = 'pop.cod', name = 'Crypt of Decay', short = 'Decay',
            steps = {
                { id = 's1', flag = true, text = 'Hail Elder Fuirstel (Sick Bay)', zone = 'Plane of Tranquility',
                  notes = 'Must have the Grummus flag (Plane of Disease) to get a response.' },
                { id = 's2', flag = true, text = 'Complete the Carprin event, hail Tarkil Adan for the lower floor', zone = 'Crypt of Decay',
                  notes = 'Puts "Key to the lower depths of the Ruins of Lxanvom" on your keyring.',
                  detect = { 'Key to the lower depths of the Ruins of Lxanvom' } },
                { id = 's3', flag = true, text = 'Complete the Bertoxxulous event, hail a planar projection', zone = 'Crypt of Decay' },
                { id = 's4', flag = true, text = 'Hail Elder Fuirstel again (Sick Bay)', zone = 'Plane of Tranquility' },
            },
        },
        {
            id = 'pop.tor', name = 'Plane of Torment', short = 'Torment',
            steps = {
                { id = 's1', flag = true, text = 'Fahlia Shadyglade (Sick Bay): say "I will go"', zone = 'Plane of Tranquility' },
                { id = 'k1', optional = true, text = 'Key: A Screaming Sphere opens Saryrn\'s Tower door (1 person needs it)', zone = 'Plane of Torment',
                  detect = { 'A Screaming Sphere' } },
                { id = 's2', flag = true, text = 'Complete the Keeper of Sorrows event, hail Tylis Newleaf', zone = 'Plane of Torment',
                  notes = 'Tylis Newleaf spawns at the end of the event.' },
                { id = 's3', flag = true, text = 'Kill Saryrn, hail A Planar Projection', zone = 'Plane of Torment' },
                { id = 's4', text = 'Hail both Fahlia Shadyglade and Tylis Newleaf (Sick Bay)', zone = 'Plane of Tranquility' },
            },
        },
        {
            id = 'pop.sto', name = 'Plane of Storms', short = 'Storms',
            steps = {
                { id = 's1', flag = true, text = 'Complete Askr the Lost\'s giant collect quest', zone = 'Plane of Storms',
                  notes = 'Puts the Talisman of Thunderous Foyer on your keyring.',
                  detect = { 'Talisman of Thunderous Foyer' } },
                { id = 's2', flag = true, text = 'Zone into Bastion of Thunder via the stone in the middle of the zone', zone = 'Plane of Storms' },
            },
        },
        {
            id = 'pop.val', name = 'Plane of Valor', short = 'Valor',
            steps = {
                { id = 'k1', optional = true, text = 'Key: Crystalline Globe opens the Aerin\'Dar door (1 person needs it)', zone = 'Plane of Valor',
                  detect = { 'Crystalline Globe' } },
                { id = 's1', flag = true, text = 'Kill Aerin\'Dar, hail a Planar Projection', zone = 'Plane of Valor' },
                { id = 's2', flag = true, text = 'Zone into Halls of Honor via the underground tunnel entrance', zone = 'Plane of Valor' },
            },
        },
        {
            id = 'pop.bot', name = 'Bastion of Thunder', short = 'BoT',
            steps = {
                { id = 'k1', optional = true, text = 'Key: Symbol of Torden activates the stone to Agnarr\'s Chamber (1 person needs it)', zone = 'Bastion of Thunder',
                  detect = { 'Symbol of Torden' } },
                { id = 's1', flag = true, text = 'Complete the Agnarr the Storm Lord event, say "I will follow the path of the Fallen." to Karana', zone = 'Bastion of Thunder',
                  notes = 'To zone out, say "Send me on my path." to Karana.' },
            },
        },
        {
            id = 'pop.hoh', name = 'Halls of Honor', short = 'HoH',
            steps = {
                { id = 's1', flag = true, text = 'Trial 1 (Northeast, Dragon), then hail Trydan Faye', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Trydan Faye."' },
                { id = 's2', flag = true, text = 'Trial 2 (Northwest, Save Villagers), then hail Rhaliq Trell', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Rhaliq Trell."' },
                { id = 's3', flag = true, text = 'Trial 3 (Southeast, Save Single Villager), then hail Alekson Garn', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Alekson Garn."' },
            },
        },
        {
            id = 'pop.mar', name = 'Temple of Marr', short = 'Marr',
            steps = {
                { id = 's1', flag = true, text = 'Kill Lord Mithaniel Marr, hail A Planar Projection', zone = 'Halls of Honor B' },
            },
        },
        {
            id = 'pop.tac', name = 'Plane of Tactics', short = 'Tactics',
            steps = {
                { id = 's1', flag = true, text = 'Kill Vallon Zek, hail A Planar Projection', zone = 'Plane of Tactics' },
                { id = 's2', flag = true, text = 'Kill Tallon Zek, hail A Planar Projection', zone = 'Plane of Tactics' },
                { id = 's3', flag = true, text = 'Kill Rallos Zek, hail A Planar Projection', zone = 'Plane of Tactics' },
            },
        },
        {
            id = 'pop.sol', name = 'Solusek Ro Tower', short = 'Sol Ro',
            note = 'Kill all 5 mini-bosses and click through the stones after each one.',
            steps = {
                { id = 's1', flag = true, text = 'Kill Xuzl, click through the stone', zone = 'Solusek Ro\'s Tower' },
                { id = 's2', flag = true, text = 'Kill Arlyxir, click through the stone', zone = 'Solusek Ro\'s Tower' },
                { id = 's3', flag = true, text = 'Kill Jiva, click through the stone', zone = 'Solusek Ro\'s Tower' },
                { id = 's4', flag = true, text = 'Kill Rizlona, click through the stone', zone = 'Solusek Ro\'s Tower' },
                { id = 's5', flag = true, text = 'Kill The Protector of Dresolik, click through the stone', zone = 'Solusek Ro\'s Tower' },
                { id = 's6', flag = true, text = 'Kill Solusek Ro, hail a Planar Projection', zone = 'Solusek Ro\'s Tower',
                  notes = 'Drop into the lava pit in Solusek Ro\'s chamber to zone into Plane of Fire.' },
            },
        },
        {
            id = 'pop.ele', name = 'Elemental Planes', short = 'Elementals',
            note = 'Each god gives an elemental item. Holding the Quintessence of Elements also counts, since it is made from all four.',
            steps = {
                { id = 's1', flag = true, text = 'Kill Fennin Ro, hail A Planar Projection', zone = 'Plane of Fire',
                  detect = { 'Globe of Dancing Flame', 'Quintessence of Elements' } },
                { id = 's2', flag = true, text = 'Kill Xegony, hail A Planar Projection', zone = 'Plane of Air',
                  detect = { 'Amorphous Cloud of Air', 'Quintessence of Elements' } },
                { id = 's3', flag = true, text = 'Kill Coirnav, hail A Planar Projection', zone = 'Plane of Water',
                  detect = { 'Sphere of Coalesced Water', 'Quintessence of Elements' } },
                { id = 's4', flag = true, text = 'Complete the 4 ring events, kill A Mystical Arbitor of Earth, hail A Planar Projection', zone = 'Plane of Earth A',
                  notes = 'Gives Passkey of the Twelve on your keyring. The passkey is not required, but the Arbitor kill is. Click the nearby door into Plane of Earth B.',
                  detect = { 'Passkey of the Twelve' } },
                { id = 's5', flag = true, text = 'Kill The Rathe Council, hail A Planar Projection', zone = 'Plane of Earth B',
                  detect = { 'Mound of Living Stone', 'Quintessence of Elements' } },
            },
        },
        {
            id = 'pop.tim', name = 'Plane of Time', short = 'Time',
            note = 'Every character must do this for full Figurine stats.',
            steps = {
                { id = 's1', text = 'Craft an Odylic Vial (tradable 4-slot container)', zone = '-',
                  detect = { 'Odylic Vial', 'Quintessence of Elements' } },
                { id = 's2', text = 'Combine the 4 elemental items in the Odylic Vial', zone = '-',
                  details = { 'Globe of Dancing Flame', 'Amorphous Cloud of Air', 'Sphere of Coalesced Water', 'Mound of Living Stone' },
                  detect = { 'Quintessence of Elements' } },
                { id = 's3', text = 'Chronographer Muan: "yes" to port up; Loreseeker Maelin: "researched"; click the machine into Plane of Time', zone = 'Plane of Innovation',
                  notes = 'Bring the Quintessence of Elements.' },
            },
        },
    },
}
