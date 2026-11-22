<!-- EpicTracker v1.6.0 (2026-11-22) -->
# Changelog

## 1.6.0 (2026-11-22)

- **Ask the Seer.** New button on the PoP Flags tab (also `/epictracker seer`). Stand your group next to Seer Mal Nae`Shi in the Plane of Knowledge and click it: every character running the tracker targets her, says "guided meditation", then "unlock memories", and her answer ticks its PoP flags.
  - Her answer lists every flag as "You have..." or "You have NOT...", so it also **unticks** flags that were ticked by mistake, and item detection won't re-tick them. Ticking a box by hand afterwards still wins until you ask her again.
  - Seer-confirmed flags show a purple `seer` tag. The summary shows when each character last checked.
  - Talking to her by hand works too: the tracker listens for her answer either way.
  - Each box reports a one-line summary to your main's MQ console. Any line the tracker doesn't recognise is printed so it can be added.
- **PoP data from the Seer** (her exact wording from a Lazarus log):
  - New steps the Seer tracks but the wiki page doesn't list: the Plane of Innovation dragon, part one of Askr's task (Storms), and speaking with the grand librarian for Elemental Planes access. They count in progress but not toward Figurine stories.
  - The six Plane of Justice trials are listed as optional rows, so you can see which trial each character did.
  - **Fix:** the Plane of Nightmare pre-flag keyword is "tormented by nightmares" (the wiki said "tortured").
  - The second Fuirstel hail after Bertoxxulous: the wiki says Elder Fuirstel, the Seer says Adler Fuirstel. The step now notes both.
- New `seer` field for flag steps, documented in `docs/DATA_FORMAT.md`.

## 1.5.0 (2026-11-22)

- **In-game updater.** A new **Updates** toolbar button checks GitHub for a newer version and installs it for every box on the PC. Also `/epictracker update`.
  - Checks once quietly when the window opens. If there's a new version, the button turns green (**Update to vX.Y.Z**) and shows what changed, from `CHANGELOG.md`.
  - **Install update** asks for confirmation, then downloads the release, checks it, backs up your current `lua/epictracker` folder, installs, and restarts the tracker on your main and your boxes.
  - Before anything is replaced: every `.lua` file must load without errors, all 16 class files must be present, and the new `init.lua` version must match the release. If the copy fails, the backup is put back.
  - Only **published GitHub Releases** are offered by default, so work pushed to the repo doesn't reach anyone until a release is published. (`UPDATE_FROM = 'main'` at the top of `init.lua` switches to following the main branch's `VERSION` file.)
  - Saved progress and item links live in `MacroQuest/config` and are never touched.
  - Uses `curl.exe` and `tar.exe`, which come with Windows 10 and 11. A minimized command window may flash for a moment during a check.

## 1.4.0 (2026-11-22)

- **Update LinkDB** toolbar button: if item links don't work, click it to pull the MQ2LinkDB item list (`/link /update`, loads the plugin first if needed). Also `/epictracker updatelinkdb`.
- **Lazarus-accurate item links.** MQ2LinkDB is built from live EverQuest, so Lazarus's changed and buffed items (like epics) can show live stats. Links are now tried in this order:
  1. The item is on this character
  2. One of your boxes carries it or has carried it (real Lazarus link, remembered)
  3. The guild Lazarus link library, `lua/epictracker/links/lazarus.lua`
  4. MQ2LinkDB, with a chat note that its stats may be live's. Never saved.
- `/epictracker exportlinks` writes the Lazarus links your characters have collected, to contribute to the guild library
- **Fix:** v1.3.1 saved MQ2LinkDB links alongside real ones. Links now live in a fresh file (`epictracker_links2_<server>.lua`) that your boxes refill automatically.
- Toolbar tip moved into a `(?)` hover to make room

## 1.3.1 (2026-11-22)

- **Fix:** clicking an item you don't carry showed "no link found". Item links now work like this:
  1. You carry it: opens directly (unchanged)
  2. **Any of your boxes carries it, or ever has:** every box shares links for the quest items it holds, and your main remembers them in `config/epictracker_links_<server>.lua`, so links keep working after items are turned in
  3. MQ2LinkDB knows it
- Links now open with MacroQuest's documented `/executelink` command
- Clearer chat message when no link is known yet, including how to fill LinkDB (`/link /update`)

## 1.3.0 (2026-11-22)

- **PoP Flags tab**: every Planes of Power flag for the Intricate Wooden Figurine ("Storytime" quest), from the Lazarus wiki
  - **Grid view**: steps down the side, your characters across, one collapsible table per plane
  - **Checklist view**: one character at a time, with full step details
  - Switch between them with the Grid / Checklist buttons
  - Optional raid keys (Screaming Sphere, Crystalline Globe, Symbol of Torden) are shown but don't count toward progress
  - Auto-detects the Figurine, elemental items, Odylic Vial, Quintessence of Elements and keyring keys. Everything else is ticked by hand until Seer detection lands.
- **Figurine "stories" reminder**: shows how many new flags each character has since they last said "stories" to Gram Dunnar, with a **Told Gram** button
- **Clickable item links**: item names open the in-game item window. Items you carry open directly; anything else uses MQ2LinkDB.
- **Reward line** on every epic tier (e.g. Innoruuk's Voice, Innoruuk's Dark Blessing), clickable
- New `flags/` data folder and `flag`, `optional`, `reward` fields (see docs/DATA_FORMAT.md)

## 1.2.0 (2026-11-22)

- **Lazarus Wiki** button in the toolbar, opens https://www.lazaruseq.com/ (also copied to the clipboard)

## 1.1.0 (2026-11-22)

- **Fix:** steps that need several of an item (e.g. 4x Hynid Blood) no longer tick off when you hold just one. New `count` field.
- **Fix:** "collect these pieces" steps (e.g. the 4 Stones of Eternal Power) now need every piece. New `all` field.
- Partial progress shows as `2/4` in the step list and the Next Step column, for bots too.
- Detect entries can carry their own count: `{ 'Gem of the Void', 2 }`.
- Counts added to 41 steps across all classes.
- Saves from 1.0.x are checked once: steps auto-ticked on a partial count are unticked, unless later steps prove they're done. Steps you ticked by hand are never touched.
- Added TODO.md to track the roadmap, Seer logs, wiki imports and bugs.

## 1.0.0 (2026-11-21)

First public release.

- Step data for all 16 classes: 1.5 pre-quest, Epic 1.5 and Epic 2.0 (about 700 steps)
- Auto-detection from inventory and bank, with backfill of earlier steps
- `nobackfill` for pre-farmable items such as the Globe of Discordant Energy
- Group overview with progress bars and next step, synced over MQ actors
- Remote checkboxes: tick a bot's steps from your main
- Expandable step details (notes, sub-steps, detected items)
- Open guide buttons per tier and per step
- Start on group button and `/epictracker group` (uses `/e3bcga`)

## 0.3.0

- Expandable step details and guide links

## 0.2.0

- Shaman, Cleric, Rogue, Bard and Berserker data
- Pre-farmable item handling

## 0.1.0

- Prototype with Shadow Knight data
