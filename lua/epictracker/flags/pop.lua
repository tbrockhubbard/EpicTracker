-- EpicTracker v1.7.0 (2026-11-22)
-- Planes of Power flags (the "Storytime" quest for the Intricate Wooden Figurine).
-- Source: Project Lazarus wiki, "Planes of Power Flagging" (last updated 06-29-2025 by Korwar).
-- See docs/DATA_FORMAT.md. Extra fields used here:
--   flag = true      the step gives "You've received a character flag!" (counts toward the
--                    Figurine and the "stories due" reminder)
--   optional = true  raid keys only one person needs; shown, but not counted in progress
--   seer = '...'     the Seer's line for this step, after "You have " / "You have NOT "
--                    (Seer Mal Nae`Shi, PoK: "unlock memories"). Copied from a real Lazarus
--                    log, 2026-11-22. Case and the trailing period don't matter.
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
                { id = 's1', flag = true, text = 'Adler Fuirstel (outside the PoDisease portal): say "what ward"', zone = 'Plane of Tranquility',
                  seer = 'talked to Adler Fuirstel outside of the Plane of Disease' },
                { id = 's2', flag = true, text = 'Kill Grummus, hail a planar projection', zone = 'Plane of Disease',
                  notes = 'The pit in Plane of Disease leads into Crypt of Decay.',
                  seer = 'defeated Grummus' },
            },
        },
        {
            id = 'pop.jus', name = 'Plane of Justice', short = 'Justice',
            steps = {
                { id = 's1', flag = true, text = 'Mavuin: say "information"', zone = 'Plane of Justice',
                  seer = 'talked to Mavuin, and agreed to plea his case to The Tribunal' },
                { id = 's2', flag = true, text = 'Complete 1 of the 6 trials, give the trial boss\'s Mark to one of The Tribunal', zone = 'Plane of Justice',
                  notes = 'Loot the Mark from the trial boss and trade it to a Tribunal member in the trial room.',
                  seer = 'shown the Tribunal the mark from the trial you have completed' },
                { id = 's3', flag = true, text = 'Hail Mavuin again', zone = 'Plane of Justice',
                  seer = 'returned to mavuin to tell him the tribunal will hear his case' },
                -- The six trials. Only one is needed, so they're optional (shown, not counted).
                { id = 't1', optional = true, text = 'Trial of Execution', zone = 'Plane of Justice', seer = 'completed the Trial of Execution' },
                { id = 't2', optional = true, text = 'Trial of Flame', zone = 'Plane of Justice', seer = 'completed the Trial of Flame' },
                { id = 't3', optional = true, text = 'Trial of Hanging', zone = 'Plane of Justice', seer = 'completed the Trial of Hanging' },
                { id = 't4', optional = true, text = 'Trial of Lashing', zone = 'Plane of Justice', seer = 'completed the Trial of Lashing' },
                { id = 't5', optional = true, text = 'Trial of Stoning', zone = 'Plane of Justice', seer = 'completed the Trial of Stoning' },
                { id = 't6', optional = true, text = 'Trial of Torture', zone = 'Plane of Justice', seer = 'completed the Trial of Torture' },
            },
        },
        {
            id = 'pop.inn', name = 'Plane of Innovation', short = 'Innovation',
            steps = {
                { id = 's1', flag = true, text = 'Giwin Mirakon (inside the factory door): say "I will test the machine"', zone = 'Plane of Innovation',
                  seer = 'talked to the Gnome within the Plane of Innovation factory' },
                { id = 's2', flag = true, text = 'Kill Manaetic Behemoth, hail Giwin Mirakon (spawns near the boss room)', zone = 'Plane of Innovation',
                  notes = 'The Seer says to hail the Gnome QUICKLY after the Behemoth dies.',
                  seer = 'defeated the Behemoth within the Plane of Innovation and then QUICKLY hailed the Gnome in the factory' },
                { id = 's3', text = 'Kill the dragon in the Plane of Innovation', zone = 'Plane of Innovation',
                  notes = 'The Seer tracks this one, but the Lazarus wiki flagging page does not list it.',
                  seer = 'killed the dragon within the Plane of Innovation' },
            },
        },
        {
            id = 'pop.nig', name = 'Plane of Nightmare', short = 'Nightmare',
            steps = {
                { id = 's1', flag = true, text = 'Adroha Jezith (Sick Bay): say "tormented by nightmares"', zone = 'Plane of Tranquility',
                  notes = 'The Hedge pre-flag. The Seer gives the keyword as "tormented by nightmares" (the wiki says "tortured").',
                  seer = 'spoken to Jezith within the Plane of Tranquility for the Hedge preflag by saying tormented by nightmares' },
                { id = 's2', flag = true, text = 'Complete the Hedge Maze, hail Thelin Poxbourne at the end to zone out', zone = 'Plane of Nightmare',
                  notes = 'The Seer counts this as killing the Construct of Nightmares.',
                  seer = 'killed the Construct of Nightmares' },
                { id = 's3', flag = true, text = 'Kill Terris Thule, hail a planar projection', zone = 'Plane of Nightmare B',
                  seer = 'killed Terris Thule' },
                { id = 's4', flag = true, text = 'Hail Elder Poxbourne', zone = 'Plane of Tranquility',
                  seer = 'talked to Poxbourne in the Plane of Tranquility after defeating Terris Thule' },
            },
        },
        {
            id = 'pop.cod', name = 'Crypt of Decay', short = 'Decay',
            steps = {
                { id = 's1', flag = true, text = 'Hail Elder Fuirstel (Sick Bay)', zone = 'Plane of Tranquility',
                  notes = 'Must have the Grummus flag (Plane of Disease) to get a response.',
                  seer = 'talked to Elder Fuirstel in the Plane of Tranquility' },
                { id = 's2', flag = true, text = 'Complete the Carprin event, hail Tarkil Adan for the lower floor', zone = 'Crypt of Decay',
                  notes = 'Puts "Key to the lower depths of the Ruins of Lxanvom" on your keyring.',
                  detect = { 'Key to the lower depths of the Ruins of Lxanvom' },
                  seer = 'completed the Carprin Cycle within Ruins of Laxanvom' },  -- "Laxanvom" is the server's spelling
                { id = 's3', flag = true, text = 'Complete the Bertoxxulous event, hail a planar projection', zone = 'Crypt of Decay',
                  seer = 'killed Bertox and hailed the planar projection' },
                { id = 's4', flag = true, text = 'Hail Fuirstel again after Bertoxxulous', zone = 'Plane of Tranquility',
                  notes = 'The wiki says Elder Fuirstel (Sick Bay). The Seer says Adler Fuirstel (outside the PoDisease portal). If one does not respond, try the other.',
                  seer = 'talked to Adler Fuirstel after killing Bertox' },
            },
        },
        {
            id = 'pop.tor', name = 'Plane of Torment', short = 'Torment',
            steps = {
                { id = 's1', flag = true, text = 'Fahlia Shadyglade (Sick Bay): say "I will go"', zone = 'Plane of Tranquility',
                  seer = 'talked to Shadyglade within the Plane of Tranquility' },
                { id = 'k1', optional = true, text = 'Key: A Screaming Sphere opens Saryrn\'s Tower door (1 person needs it)', zone = 'Plane of Torment',
                  detect = { 'A Screaming Sphere' } },
                { id = 's2', flag = true, text = 'Complete the Keeper of Sorrows event, hail Tylis Newleaf', zone = 'Plane of Torment',
                  notes = 'Tylis Newleaf spawns at the end of the event.',
                  seer = 'killed the Keeper of Sorrows' },
                { id = 's3', flag = true, text = 'Kill Saryrn, hail A Planar Projection', zone = 'Plane of Torment',
                  seer = 'killed Saryrn and hailed the planar projection' },
                { id = 's4', text = 'Hail both Fahlia Shadyglade and Tylis Newleaf (Sick Bay)', zone = 'Plane of Tranquility',
                  seer = 'talked to Shadyglade after killing Saryrn' },
            },
        },
        {
            id = 'pop.sto', name = 'Plane of Storms', short = 'Storms',
            steps = {
                { id = 's0', text = 'Askr the Lost: part one of his task', zone = 'Plane of Storms',
                  notes = 'The Seer tracks Askr\'s task in two parts.',
                  seer = "completed part one of Askr's task within the Plane of Storms" },
                { id = 's1', flag = true, text = 'Complete Askr the Lost\'s giant collect quest', zone = 'Plane of Storms',
                  notes = 'Puts the Talisman of Thunderous Foyer on your keyring.',
                  detect = { 'Talisman of Thunderous Foyer' },
                  seer = "killed the giants within the Plane of Storms to complete Askr's task" },
                { id = 's2', flag = true, text = 'Zone into Bastion of Thunder via the stone in the middle of the zone', zone = 'Plane of Storms' },
            },
        },
        {
            id = 'pop.val', name = 'Plane of Valor', short = 'Valor',
            steps = {
                { id = 'k1', optional = true, text = 'Key: Crystalline Globe opens the Aerin\'Dar door (1 person needs it)', zone = 'Plane of Valor',
                  detect = { 'Crystalline Globe' } },
                { id = 's1', flag = true, text = 'Kill Aerin\'Dar, hail a Planar Projection', zone = 'Plane of Valor',
                  seer = 'defeated the prismatic dragon, Aerin`Dar, within the Plane of Valor' },
                { id = 's2', flag = true, text = 'Zone into Halls of Honor via the underground tunnel entrance', zone = 'Plane of Valor' },
            },
        },
        {
            id = 'pop.bot', name = 'Bastion of Thunder', short = 'BoT',
            steps = {
                { id = 'k1', optional = true, text = 'Key: Symbol of Torden activates the stone to Agnarr\'s Chamber (1 person needs it)', zone = 'Bastion of Thunder',
                  detect = { 'Symbol of Torden' } },
                { id = 's1', flag = true, text = 'Complete the Agnarr the Storm Lord event, say "I will follow the path of the Fallen." to Karana', zone = 'Bastion of Thunder',
                  notes = 'To zone out, say "Send me on my path." to Karana.',
                  seer = 'defeated Agnarr, the Storm Lord' },
            },
        },
        {
            id = 'pop.hoh', name = 'Halls of Honor', short = 'HoH',
            steps = {
                { id = 's1', flag = true, text = 'Trial 1 (Northeast, Dragon), then hail Trydan Faye', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Trydan Faye."',
                  seer = 'completed the Halls of Honor trial given by Faye' },
                { id = 's2', flag = true, text = 'Trial 2 (Northwest, Save Villagers), then hail Rhaliq Trell', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Rhaliq Trell."',
                  seer = 'completed the Halls of Honor trial given by Rhaliq Trell' },
                { id = 's3', flag = true, text = 'Trial 3 (Southeast, Save Single Villager), then hail Alekson Garn', zone = 'Halls of Honor',
                  notes = 'Flag emote: "...Your body begins to emanate with the power of Alekson Garn."',
                  seer = 'completed the Halls of Honor trial given by Alekson Garn' },
            },
        },
        {
            id = 'pop.mar', name = 'Temple of Marr', short = 'Marr',
            steps = {
                { id = 's1', flag = true, text = 'Kill Lord Mithaniel Marr, hail A Planar Projection', zone = 'Halls of Honor B',
                  seer = 'defeated Lord Marr within his Temple' },
            },
        },
        {
            id = 'pop.tac', name = 'Plane of Tactics', short = 'Tactics',
            steps = {
                { id = 's1', flag = true, text = 'Kill Vallon Zek, hail A Planar Projection', zone = 'Plane of Tactics',
                  seer = 'killed Vallon Zek' },
                { id = 's2', flag = true, text = 'Kill Tallon Zek, hail A Planar Projection', zone = 'Plane of Tactics',
                  seer = 'killed Tallon Zek' },
                { id = 's3', flag = true, text = 'Kill Rallos Zek, hail A Planar Projection', zone = 'Plane of Tactics',
                  seer = 'killed Rallos Zek the Warlord' },
            },
        },
        {
            id = 'pop.sol', name = 'Solusek Ro Tower', short = 'Sol Ro',
            note = 'Kill all 5 mini-bosses and click through the stones after each one.',
            steps = {
                { id = 's1', flag = true, text = 'Kill Xuzl, click through the stone', zone = 'Solusek Ro\'s Tower',
                  seer = 'defeated Xuzl within the Tower of Solusek Ro' },
                { id = 's2', flag = true, text = 'Kill Arlyxir, click through the stone', zone = 'Solusek Ro\'s Tower',
                  seer = 'defeated Arlyxir within the Tower of Solusek Ro' },
                { id = 's3', flag = true, text = 'Kill Jiva, click through the stone', zone = 'Solusek Ro\'s Tower',
                  seer = 'defeated Jiva within the Tower of Solusek Ro' },
                { id = 's4', flag = true, text = 'Kill Rizlona, click through the stone', zone = 'Solusek Ro\'s Tower',
                  seer = 'defeated Rizlona within the Tower of Solusek Ro' },
                { id = 's5', flag = true, text = 'Kill The Protector of Dresolik, click through the stone', zone = 'Solusek Ro\'s Tower',
                  seer = 'defeated The Protector of Dresolik within the Tower of Solusek Ro' },
                { id = 's6', flag = true, text = 'Kill Solusek Ro, hail a Planar Projection', zone = 'Solusek Ro\'s Tower',
                  notes = 'Drop into the lava pit in Solusek Ro\'s chamber to zone into Plane of Fire.',
                  seer = 'defeated Solusek Ro within the Tower of Solusek Ro' },
            },
        },
        {
            id = 'pop.ele', name = 'Elemental Planes', short = 'Elementals',
            note = 'Each god gives an elemental item. Holding the Quintessence of Elements also counts, since it is made from all four.',
            steps = {
                { id = 's0', text = 'Speak with the grand librarian for access to the Elemental Planes', zone = '-',
                  notes = 'The Seer tracks this one, but the Lazarus wiki flagging page does not list it.',
                  seer = 'spoken with the grand librarian to receive access to the Elemental Planes' },
                { id = 's1', flag = true, text = 'Kill Fennin Ro, hail A Planar Projection', zone = 'Plane of Fire',
                  detect = { 'Globe of Dancing Flame', 'Quintessence of Elements' },
                  seer = 'defeated Fennin Ro, the Tyrant of Fire' },
                { id = 's2', flag = true, text = 'Kill Xegony, hail A Planar Projection', zone = 'Plane of Air',
                  detect = { 'Amorphous Cloud of Air', 'Quintessence of Elements' },
                  seer = 'defeated Xegony, the Queen of Air' },
                { id = 's3', flag = true, text = 'Kill Coirnav, hail A Planar Projection', zone = 'Plane of Water',
                  detect = { 'Sphere of Coalesced Water', 'Quintessence of Elements' },
                  seer = 'defeated Coirnav, the Avatar of Water' },
                { id = 's4', flag = true, text = 'Complete the 4 ring events, kill A Mystical Arbitor of Earth, hail A Planar Projection', zone = 'Plane of Earth A',
                  notes = 'Gives Passkey of the Twelve on your keyring. The passkey is not required, but the Arbitor kill is. Click the nearby door into Plane of Earth B.',
                  detect = { 'Passkey of the Twelve' },
                  seer = 'defeated the Arbitor of Earth within Plane of Earth A' },
                { id = 's5', flag = true, text = 'Kill The Rathe Council, hail A Planar Projection', zone = 'Plane of Earth B',
                  detect = { 'Mound of Living Stone', 'Quintessence of Elements' },
                  seer = 'defeated the Rathe Council within Plane of Earth B' },
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
                  notes = 'Bring the Quintessence of Elements.',
                  seer = 'completed your Plane of Time flag' },
            },
        },
    },
}
