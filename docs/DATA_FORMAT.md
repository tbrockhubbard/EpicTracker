<!-- EpicTracker v1.7.0 (2026-11-22) -->
# Step data format

Each class lives in `lua/epictracker/data/<class>.lua` and returns one Lua table.

```lua
return {
    class  = 'Shadow Knight',          -- must match ${Me.Class.Name} exactly
    source = 'eqprogression.com, live steps',
    tiers = {
        {
            id    = 'pre',              -- 'pre', 'e15', 'e20' (save keys, don't rename)
            name  = '1.5 Pre-Quest',    -- tab title
            short = 'Pre',              -- shown in the "Next Step" column
            url   = 'https://...',      -- "Open guide" button
            links = { { 'Tradeskills', 'https://...' } },  -- optional extra buttons
            note  = 'Shown above the step table.',         -- optional
            steps = { ... },
        },
        -- three tiers, in order: pre-quest, 1.5, 2.0
    },
}
```

## Steps

```lua
{ id = 's4', text = 'Kill Captain Varns', zone = "Dulak's Harbor",
  notes   = 'Paragraph shown when the step is expanded.',
  details = { 'Numbered sub-step one', 'Numbered sub-step two' },
  url     = 'https://...', urlLabel = 'Open 1.0 guide',
  detect  = { 'Ancient Flamberge of Hatred' },
  nobackfill = true,
  after   = 'e15.s16' },
```

| Field | Required | Meaning |
|---|---|---|
| `reward` (tier) | no | Item shown as a clickable **Reward:** at the top of the tier tab. Defaults to the last step's detect item. |
| `id` | yes | Unique within the tier. **The save key**: never rename or reuse an id once released, or people lose that checkbox. To insert a step, give it a new id like `s4b`. |
| `text` | yes | What to do, one line. |
| `zone` | yes | Where (`'-'` for crafting or skill-ups). Several zones: `"Kod'Taz / Yxtta"` or `'Barindu or Qinimi'`. Used by the This Zone tab, through `zones.lua` (see below). |
| `zones` | no | EQ zone short names, if `zone` text can't be matched: `zones = { 'potranquility' }`. |
| `notes` | no | Longer explanation, shown in the dropdown. |
| `details` | no | List of numbered sub-steps, shown in the dropdown. |
| `url`, `urlLabel` | no | Extra link button inside the dropdown. |
| `detect` | no | Exact item names. Holding **any** of them (inventory or bank) checks this step. |
| `count` | no | How many of each detect item are needed (default 1). Inventory and bank stacks are added up. `detect = { 'Hynid Blood' }, count = 4` |
| `all` | no | Every detect item is required, not just one. Use for "collect these pieces" steps. Without it, ANY one item counts, which is right for spelling variants or items that drop together. |
| `nobackfill` | no | Use for items you can get before reaching this step (pre-farmable or tradable drops, the Anguish Globe). The item checks only its own step instead of every step before it. |
| `after` | no | Only auto-detect once that step key is checked. Use when the same item name shows up twice in a quest. |

### Mixed counts

A detect entry can be a plain name or `{ 'Name', count }`, which is useful with `all`:

```lua
all = true, detect = { { 'Gem of the Void', 2 }, 'Chunk of Dense Fungal Padding', 'Perfect Acrylia Ore' }
```

While a counted step isn't finished, the window shows `have/need` (for example `2/4`) for every character.

## Flag sets (`lua/epictracker/flags/<set>.lua`)

Flags aren't class-based, so they live in their own files and every character gets the same list.

```lua
return {
    id = 'pop', name = 'Planes of Power', short = 'PoP',
    url = 'https://www.lazaruseq.com/pages/pop-flagging',
    reward = 'Intricate Wooden Figurine',      -- clickable at the top of the tab
    note = 'Shown above the grid.',
    sections = {
        { id = 'pop.dis', name = 'Plane of Disease', note = 'optional',
          steps = {
              { id = 's1', flag = true, text = '...', zone = '...' },
              { id = 'k1', optional = true, text = 'Key: ...', detect = { '...' } },
          } },
    },
}
```

- Section `id` includes the set prefix (`pop.dis`), so save keys look like `pop.dis.s1`. **Never rename or reuse them.**
- `flag = true`: the step gives "You've received a character flag!". These count toward the Figurine "stories due" reminder.
- `optional = true`: raid keys only one person needs. Shown, but not counted in progress.
- `seer = '...'`: the line Seer Mal Nae`Shi gives for this step when you say "unlock memories", without the leading "You have " / "You have NOT ". Copy it from a real log (case and the trailing period don't matter). "You have" ticks the step, "You have NOT" unticks it, and item detection won't re-tick a step the Seer says is not done. Lines the tracker doesn't recognise are printed in the MQ console so they can be added.
- Flags don't backfill, because Lazarus flags can be done in any order. Detection only ticks the step whose item is found.
- All the normal step fields work (`detect`, `count`, `all`, `notes`, `details`, `url`).

## How detection works

1. Every 5 seconds the script counts each step's `detect` items with `FindItemCount` + `FindItemBankCount` (exact match, stacks included).
2. When the count is met (and, with `all`, every item is met), the step is checked. That step is marked `auto` and stays checked after the item is turned in.
3. Unless the step is `nobackfill`, every earlier step in the same tier is checked too, and every step in earlier tiers.

### Choosing detect items

- Pick the item you **receive** at that step: a quest reward, a looted drop, a combine result.
- Item names must be exact, including backticks (`` Teir`Dal ``) and apostrophes.
- Don't detect items that appear at several steps. Detect the first one, or use `after`.
- Generic names (`Soulstone Shard`, `Broken Sword Piece`) are best left undetected.

## Zones (`lua/epictracker/zones.lua`)

The This Zone tab matches each step's `zone` text to the zone you're in (`${Zone.ShortName}`). `zones.lua` maps the names used in the data to EQ short names, for example `["nedaria's landing"] = { 'nedaria' }`.

- Matching ignores case and a leading "The ". A trailing note in brackets is dropped: `'Lake of Ill Omen (Sarnak fort)'` works.
- Several zones are split on ` / `, ` or ` and `, `.
- `'-'`, `'various'` and whole regions (`'Luclin'`, `'OoW zones'`) never match anything, so those steps don't show in This Zone.
- Using a new zone name? Add it to `zones.lua`, then run `lua tools/check_zones.lua` from the repo root. It lists every step whose zone doesn't match.

## Testing your change

1. `/lua stop epictracker` then `/lua run epictracker`.
2. Lua syntax errors show up in the MQ console with the file and line number.
3. Open the class tab and check your step reads right.
