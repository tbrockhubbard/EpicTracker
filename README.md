<!-- EpicTracker v1.6.0 (2026-11-22) -->
# EpicTracker

**Any Questions?  Give Ougabouga a tell in game, or on the Lazarus Project Discord Server.**

**Track every character's Epic 1.5 pre-quest, Epic 1.5 and Epic 2.0 from one window.**
**v1.5.0 Added PoP Flagging.  Added automation to detect flags at Seer Mal Nae'Shi.**
**v1.6.0 Added Version Updater.  This lua can be updated in game, no need for restarting or revisiting this github.  Improvement logs are listed before you download.  It's pretty nifty.**

I'm guilty of improperly documenting this, I'm making improvements on the fly as I go.  I'm doing the quests as I go, and testing the lua along the way.  Expect small differences, due to live being different from Project Lazarus.  This project is geared towards Project Lazarus only, and improvements will trickle through as I go.  As the program improves and is finalized, so will the documentation be.  



EpicTracker is a MacroQuest Lua script for EverQuest boxers. Each character watches its own inventory and bank, ticks off epic steps as quest items show up, and reports to your main. You see your whole group's epic progress at a glance: who is on which step, what to do next, and where.

Built for **Project Lazarus** (Omens of War era, E3Next boxing). It should work on any EQEmu server running MacroQuest with Lua.

> Screenshot: _add one here once you have it running_ (`docs/screenshot.png`)

---

## Features

- **All 16 classes:** Bard, Beastlord, Berserker, Cleric, Druid, Enchanter, Magician, Monk, Necromancer, Paladin, Ranger, Rogue, Shadow Knight, Shaman, Warrior and Wizard. Each has three tiers (1.5 pre-quest, 1.5, 2.0), about 700 steps in all.
- **Planes of Power flags:** a PoP Flags tab with every flag for the Intricate Wooden Figurine (Lazarus "Storytime" quest), in a who-has-what grid or a per-character checklist, plus a reminder of who still needs to say "stories" to Gram Dunnar. **Ask the Seer** reads every character's flags straight from Seer Mal Nae`Shi in the Plane of Knowledge.
- **Clickable items:** click any item name (rewards, quest items) to open the in-game item window. Links come from your own characters first, so they show Lazarus's real stats. A guild-built Lazarus link library covers the rest, with MQ2LinkDB as a last resort.
- **Update LinkDB button:** item links not working? One click pulls the MQ2LinkDB item list.
- **Auto-detection:** steps tick off when the key item is in your inventory or bank. Steps that need several items count them and show partial progress (`2/4`). Holding a later item also completes the earlier steps. Steps stay checked after you hand the item in.
- **Pre-farm aware:** items you can loot early, like the Globe of Discordant Energy, Lightning Cores or tradeskill materials, only check their own step. A Globe sitting in your bank won't mark a whole 2.0 done.
- **Group overview:** one row per character with progress bars and their next step, synced live between all your clients.
- **Remote checkboxes:** tick a bot's manual steps from your main's window.
- **Expandable details:** click a step to see notes, numbered sub-steps (race-specific phrases, tradeskill recipes, item locations) and what it auto-detects.
- **One-click guides:** every tier has an **Open guide** button that opens the full web walkthrough in your browser.
- **Lazarus Wiki button:** opens the [Project Lazarus wiki](https://www.lazaruseq.com/) from the toolbar.
- **In-game updates:** an **Updates** button checks GitHub and installs new versions for all your boxes in one click. The button turns green when there's a new one.
- **Group launch:** a **Start on group** button runs it on every character with `/e3bcga`.
- **No setup:** uses MacroQuest's built-in actors messaging. Nothing to configure, no DanNet required.

## Requirements

- MacroQuest with Lua support (the current MQ "Next" emu builds have it: you'll have a `lua` folder and `/lua` commands)
- Your characters running on the same PC (actors messaging is local)
- E3Next (optional, used only for the group launch command)
- MQ2LinkDB (optional, `/plugin linkdb load`) so item links work for items you don't carry

## Install

1. Download this repo (green **Code** button, then **Download ZIP**) or grab a release.
2. Copy the `lua/epictracker` folder into your MacroQuest `lua` folder, so you end up with:
   ```
   MacroQuest/lua/epictracker/init.lua
   MacroQuest/lua/epictracker/data/*.lua
   ```
3. That's it.

## Updating

Once you're on v1.5.0 or later, you never have to copy files again:

1. Click **Updates** in the toolbar. (It also checks by itself when the window opens, and turns green when there's a new version.)
2. Read what changed, click **Install update**, then **Yes, install**.
3. The tracker downloads the new version, checks it, installs it and restarts on your main and every box. Your saved progress is kept.

Needs Windows 10 or 11 (for the built-in `curl` and `tar`). If an update ever fails, your old version stays in place; you can always install by hand as above.

## Usage

On your main:
```
/lua run epictracker
```
Then click **Start on group**, or type:
```
/e3bcga /lua run epictracker bg
```
`bg` runs it without a window on the bots. Your main will print "already running", which is expected.

Using DanNet instead of E3? Use `/dgga /lua run epictracker bg`, and change `GROUP_CMD` at the top of `init.lua`.

### Commands

| Command | What it does |
|---|---|
| `/epictracker` | Toggle the window |
| `/epictracker show` / `hide` | Show or hide the window |
| `/epictracker scan` | Rescan inventory and bank now |
| `/epictracker refresh` | Ask every box to report in |
| `/epictracker group` | Start the script on the whole group |
| `/epictracker seer` | Ask Seer Mal Nae`Shi for PoP flags on every character (same as the Ask the Seer button) |
| `/epictracker update` | Check GitHub for a new version (same as the Updates button) |
| `/epictracker updatelinkdb` | Pull the MQ2LinkDB item list (same as the Update LinkDB button) |
| `/epictracker exportlinks` | Export your collected Lazarus item links for the guild library |
| `/epictracker quit` | Stop on this character |
| `/epictracker quitall` | Stop on every character |

### Tips

- **Open your bank once per session** on each character. MacroQuest only knows bank contents after the bank has been opened.
- Steps with no item to detect (dialogue, skill-ups) are checked by hand. Click the checkbox.
- **PoP flags:** stand your group next to Seer Mal Nae`Shi in the Plane of Knowledge and click **Ask the Seer** on the PoP Flags tab. Every character running the tracker targets her, says "guided meditation" and "unlock memories", and her answer ticks (and unticks) its flags. Those show a purple `seer` tag. Talking to her by hand works too.
- Progress is saved per character in `MacroQuest/config/epictracker_<server>_<name>.lua`.

## Accuracy, and how you can help

The step lists come from public live-server guides, mainly [EQProgression](https://www.eqprogression.com/) with [Allakhazam](https://everquest.allakhazam.com/) and [Almar's Guides](https://almarsguides.com/) filling gaps. **Project Lazarus has buffed and tweaked epics**, so some steps may differ on the server.

If a step is wrong, missing or out of order on Lazarus, please open an issue or a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md). Each class is one small, readable file in `lua/epictracker/data/`, and the format is documented in [docs/DATA_FORMAT.md](docs/DATA_FORMAT.md).

## Roadmap

Ideas the guild has floated. PRs are welcome.

- [ ] Lazarus-verified flag per class (a guildie confirms the steps match the server)
- [ ] Server overrides: a small file that patches steps for one server without forking the class data
- [ ] "What can I do here?": highlight steps for the zone you're standing in, across the whole group
- [ ] Raid planner: list which characters need which raid targets (Anguish Globe, named raids)
- [ ] Hide completed tiers / compact mode
- [ ] 1.0 epic tracking
- [ ] Remember window size, position and selected character

## Project layout

```
lua/epictracker/init.lua        the script (UI, detection, sync)
lua/epictracker/data/<class>.lua  epic step data, one file per class
lua/epictracker/flags/<set>.lua   flag data (pop.lua = Planes of Power)
lua/epictracker/links/lazarus.lua guild Lazarus item link library
VERSION                         current version (the updater compares against it)
docs/DATA_FORMAT.md             how step data is written
CONTRIBUTING.md                 how to fix or add steps
CHANGELOG.md                    version history
TODO.md                         roadmap, open bugs, data still to collect
```

## Credits

- Step data compiled from [EQProgression](https://www.eqprogression.com/), [Allakhazam](https://everquest.allakhazam.com/) and [Almar's Guides](https://almarsguides.com/). Go support those sites; the **Open guide** buttons link straight to them.
- Built with [MacroQuest](https://www.macroquest.org/).

## Disclaimer

A fan-made tool. It is not affiliated with or endorsed by Daybreak Game Company, Project Lazarus or the MacroQuest team. EverQuest is a trademark of Daybreak Game Company. EpicTracker only reads your inventory and draws a window; it doesn't play the game for you. Follow your server's rules on third-party tools.

## License

[MIT](LICENSE)
