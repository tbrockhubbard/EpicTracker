# Contributing

The most useful help is **checking steps against Project Lazarus**. The data came from live-server guides, and Lazarus has tweaked epics.

## Reporting a wrong step

Open an issue with:

- Class and tier (for example *Rogue, Epic 1.5*)
- The step number or text as it shows in the window
- What actually happens on Lazarus (NPC, keyword, item name, zone)
- The exact item name, if detection is wrong. Copy it from the item window if you can.

## Fixing it yourself

1. Fork the repo and edit `lua/epictracker/data/<class>.lua`.
2. Follow [docs/DATA_FORMAT.md](docs/DATA_FORMAT.md). The one hard rule: **never rename or reuse a step `id`**, because it's the save key. Add new steps with new ids (`s7b`), and remove steps by deleting them.
3. Test it in game (`/lua stop epictracker`, then `/lua run epictracker`).
4. Open a pull request saying what you changed and that you verified it on Lazarus.

## Marking a class as verified

When a guildie has walked a whole tier on Lazarus and the steps match, add a line to that tier's `note`, for example `Verified on Lazarus by <name>, Nov 2026`.

## Code changes

`init.lua` holds the UI, detection and sync. Keep it a single file that runs under stock MacroQuest Lua with no extra libraries, so installing stays a folder copy.

## Style

- Keep step `text` to one line. Put the rest in `notes` or `details`.
- Coordinates as `(+X, -Y)` the way the guides write them.
- Zone names as players say them (`Dranik's Scar`, not `draniksscar`).
