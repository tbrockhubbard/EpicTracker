<!-- EpicTracker v1.5.0 (2026-11-22) -->
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

## Contributing item links

MQ2LinkDB's item list comes from live EverQuest, so Lazarus's changed items (epics especially) can show the wrong stats. The guild link library fixes that with links from real Lazarus items.

1. Play with the tracker running. It collects links for every quest item your characters carry.
2. Type `/epictracker exportlinks`. It writes `MacroQuest/config/epictracker_links_export.lua`.
3. Attach that file to a GitHub issue (or drop it in Discord). It gets merged into `lua/epictracker/links/lazarus.lua` for the next release.

Never hand-type link text. Only paste what the export produced.

## Marking a class as verified

When a guildie has walked a whole tier on Lazarus and the steps match, add a line to that tier's `note`, for example `Verified on Lazarus by <name>, Nov 2026`.

## Code changes

`init.lua` holds the UI, detection and sync. Keep it a single file that runs under stock MacroQuest Lua with no extra libraries, so installing stays a folder copy.

## Publishing a release (maintainer)

The in-game **Updates** button only offers **published GitHub Releases**, so pushing commits is safe: nobody gets them until you publish.

1. Bump every version stamp, `VERSION`, the `VERSION` constant in `init.lua`, and add the `CHANGELOG.md` entry (see Versioning below). The updater refuses a release whose `init.lua` version doesn't match its tag, and it shows the matching `CHANGELOG.md` section as the "what's new" text.
2. Push to `main`.
3. On GitHub: **Releases > Draft a new release**. Create the tag `vX.Y.Z` (for example `v1.5.1`), give it the same title, and click **Publish release**.
4. Optional: attach `EpicTracker-vX.Y.Z.zip`. If you don't, the updater uses GitHub's automatic source zip, which works just as well.

Everyone's tracker picks it up the next time they open the window or click **Updates**.

## Style

- Keep step `text` to one line. Put the rest in `notes` or `details`.
- Coordinates as `(+X, -Y)` the way the guides write them.
- Zone names as players say them (`Dranik's Scar`, not `draniksscar`).

## Versioning

Every file carries a version stamp on its first line (after front matter in the issue template):

- Lua: `-- EpicTracker v1.5.0 (2026-11-22)`
- Markdown: `<!-- EpicTracker v1.5.0 (2026-11-22) -->`
- `.gitignore`: `# EpicTracker v1.5.0 (2026-11-22)`

On every release, all stamps move to the new version together. The new version also goes in `VERSION`, the `VERSION` constant in `init.lua` and a new `CHANGELOG.md` entry. Version numbers follow `MAJOR.MINOR.PATCH`:

- **PATCH** (1.0.1): step data fixes, typos
- **MINOR** (1.1.0): new features, new fields, new classes or tiers
- **MAJOR** (2.0.0): changes that break saved progress or the data format

`LICENSE` is left untouched.
