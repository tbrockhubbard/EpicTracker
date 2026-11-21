# EpicTracker

**Track every character's Epic 1.5 pre-quest, Epic 1.5 and Epic 2.0 from one window.**

EpicTracker is a MacroQuest Lua script for EverQuest boxers. Each character watches its own inventory and bank, ticks off epic steps as quest items show up, and reports to your main. You see your whole group's epic progress at a glance: who is on which step, what to do next, and where.

Built for **Project Lazarus** (Omens of War era, E3Next boxing). It should work on any EQEmu server running MacroQuest with Lua.

> Screenshot: _add one here once you have it running_ (`docs/screenshot.png`)

---

## Features

- **All 16 classes:** Bard, Beastlord, Berserker, Cleric, Druid, Enchanter, Magician, Monk, Necromancer, Paladin, Ranger, Rogue, Shadow Knight, Shaman, Warrior and Wizard. Each has three tiers (1.5 pre-quest, 1.5, 2.0), about 700 steps in all.
- **Auto-detection:** steps tick off when the key item is in your inventory or bank. Holding a later item also completes the earlier steps. Steps stay checked after you hand the item in.
- **Pre-farm aware:** items you can loot early, like the Globe of Discordant Energy, Lightning Cores or tradeskill materials, only check their own step. A Globe sitting in your bank won't mark a whole 2.0 done.
- **Group overview:** one row per character with progress bars and their next step, synced live between all your clients.
- **Remote checkboxes:** tick a bot's manual steps from your main's window.
- **Expandable details:** click a step to see notes, numbered sub-steps (race-specific phrases, tradeskill recipes, item locations) and what it auto-detects.
- **One-click guides:** every tier has an **Open guide** button that opens the full web walkthrough in your browser.
- **Group launch:** a **Start on group** button runs it on every character with `/e3bcga`.
- **No setup:** uses MacroQuest's built-in actors messaging. Nothing to configure, no DanNet required.

## Requirements

- MacroQuest with Lua support (the current MQ "Next" emu builds have it: you'll have a `lua` folder and `/lua` commands)
- Your characters running on the same PC (actors messaging is local)
- E3Next (optional, used only for the group launch command)

## Install

1. Download this repo (green **Code** button, then **Download ZIP**) or grab a release.
2. Copy the `lua/epictracker` folder into your MacroQuest `lua` folder, so you end up with:
   ```
   MacroQuest/lua/epictracker/init.lua
   MacroQuest/lua/epictracker/data/*.lua
   ```
3. That's it.

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
| `/epictracker quit` | Stop on this character |
| `/epictracker quitall` | Stop on every character |

### Tips

- **Open your bank once per session** on each character. MacroQuest only knows bank contents after the bank has been opened.
- Steps with no item to detect (dialogue, flags, skill-ups) are checked by hand. Click the checkbox.
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
lua/epictracker/data/<class>.lua  step data, one file per class
docs/DATA_FORMAT.md             how step data is written
CONTRIBUTING.md                 how to fix or add steps
CHANGELOG.md                    version history
```

## Credits

- Step data compiled from [EQProgression](https://www.eqprogression.com/), [Allakhazam](https://everquest.allakhazam.com/) and [Almar's Guides](https://almarsguides.com/). Go support those sites; the **Open guide** buttons link straight to them.
- Built with [MacroQuest](https://www.macroquest.org/).

## Disclaimer

A fan-made tool. It is not affiliated with or endorsed by Daybreak Game Company, Project Lazarus or the MacroQuest team. EverQuest is a trademark of Daybreak Game Company. EpicTracker only reads your inventory and draws a window; it doesn't play the game for you. Follow your server's rules on third-party tools.

## License

[MIT](LICENSE)
