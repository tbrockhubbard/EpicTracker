<!-- EpicTracker v1.5.0 (2026-11-22) -->
# TODO

The working list for the tracker. Tick items off as they land, and note the version they shipped in.

## Bugs

### Open
- _(none reported)_

### Fixed
- [x] Item links: "no link found" for items the clicking character doesn't carry. Fixed in v1.3.1 (links shared between boxes and remembered)
- [x] Counted items tick off with only 1 (e.g. 2 of 4 Hynid Blood). Fixed in v1.1.0 (`count`)
- [x] "Collect these pieces" steps tick off with only 1 piece. Fixed in v1.1.0 (`all`)

## LazTrack (v2.0.0): the progression tracker

Going all-in on Project Lazarus: epics, flags, keys and custom progression in one tool, built for new guildies as much as veterans. **Not started. Building waits until the data below is collected.**

### Rename
- [ ] Rename EpicTracker → **LazTrack** (repo, `lua/laztrack` folder, `/laztrack` command, window title)
- [ ] Carry everyone's saved epic progress over automatically on first run
- [ ] Keep `/epictracker` working for a while as an alias

### Seer logs (needed for flag auto-detection)
Process: `/log on`, sit near the Seer in the Plane of Knowledge, say "guided meditation", then send the log (`Logs\eqlog_<name>_<server>.txt`).
- [ ] Shadow Knight
- [ ] Shaman
- [ ] Cleric
- [ ] Rogue
- [ ] Bard
- [ ] Berserker
- [ ] Map each Seer line to a flag (Lazarus wording may differ from live)
- [ ] List the custom Lazarus flag NPCs: name, zone, what to say, what they report
- [ ] **Gram Dunnar (PoK) as an auto-detector**: log what he says on "stories" and use it to tick PoP flags and clear the "stories due" reminder automatically
- [ ] Get logs from each custom flag NPC

### Lazarus wiki pages (added to the Project as PDFs, one at a time)
The wiki blocks automated tools, so pages come in as PDFs.
- [x] Planes of Power Flagging (`PoP Flagging.pdf`): built into the PoP Flags tab, v1.3.0
- [ ] Hard Core Zone Guide
- [ ] NPCs (Special NPCs to Lazarus)
- [ ] Currencies
- [ ] Leveling Guide
- [ ] Instancing (Expeditions)
- [ ] Zone Level Minimums
- [ ] Individual custom zone / event pages (list them here as they come in)

### Flags
- [x] Planes of Power: full flag list from the Lazarus wiki, manual ticks + item detection (v1.3.0)
- [ ] Planes of Power: Seer / Gram Dunnar auto-detection (needs logs)
- [ ] Confirm in game that keyring keys (Passkey of the Twelve, Talisman of Thunderous Foyer, Lxanvom key) are detected
- [ ] Confirm the PoP key item names: A Screaming Sphere, Crystalline Globe, Symbol of Torden
- [ ] Gates of Discord
- [ ] Omens of War
- [ ] Keys (item-detected where possible)
- [ ] Lazarus custom flags and progression
- [x] Who-has-what grid, steps down the side and characters across (v1.3.0)
- [x] Per-character checklist view, with a toggle between the two (v1.3.0)
- [ ] Pick a favorite view (grid vs checklist) after using both; maybe remember the choice
- [ ] "Ask the Seer" button: the whole group targets her and says "guided meditation"

### New-player help
- [ ] Starter checklist for new guildies (currencies, starter gear quests, leveling path)

## In-game updater

- [x] Updates button: check GitHub Releases, install for all boxes, restart (v1.5.0)
- [ ] Publish v1.5.0 as the first GitHub Release (tag `v1.5.0`) so the button has something to find
- [ ] Test in game: Check, Install, restart on main and boxes (only tested in a simulation so far)
- [ ] Check whether the minimized command window during a check is annoying; if so, look at a hidden launcher

## Item links

- [x] Click item names to open the item window: Inspect for carried items, MQ2LinkDB for the rest (v1.3.0)
- [x] Reward line on every epic tier and the Figurine (v1.3.0)
- [ ] Test in game: `/executelink` opens items another box carries (v1.3.1)
- [x] Update LinkDB button (v1.4.0)
- [x] Prefer real Lazarus links (your boxes, guild library) over MQ2LinkDB's live data (v1.4.0)
- [ ] **Lazarus link library:** collect `/epictracker exportlinks` files from guildies and merge them into `links/lazarus.lua` (start with all 6 of your characters)
- [ ] Confirm in game: does a MQ2LinkDB link show live stats or Lazarus stats for a buffed epic? (Tells us how much the library matters)
- [x] No Lazarus-specific MQ2LinkDB exists publicly (checked 2026-11-22). The guild library is the replacement.
- [ ] Check whether Lazarus-only items get links (LinkDB learns them from chat)

## Epic data

- [ ] Verify each class against Lazarus and mark the tiers verified (guild help)
- [ ] Druid 1.5: rebuild from a better source (currently an older Allakhazam wiki page)
- [ ] Rogue 1.5: find how the Soulstone of Lanys is assembled
- [ ] Test the 10 classes nobody has run yet in a live client
- [ ] Review the remaining steps for counts that aren't marked yet

## Roadmap ideas (from README)
- [ ] Server override files (patch steps without editing class data)
- [ ] "What can I do in this zone?" view
- [ ] Hide completed tiers / compact mode
- [ ] 1.0 epic tracking
- [ ] Remember window size, position and selected character
