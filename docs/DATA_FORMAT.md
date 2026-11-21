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
| `id` | yes | Unique within the tier. **The save key**: never rename or reuse an id once released, or people lose that checkbox. To insert a step, give it a new id like `s4b`. |
| `text` | yes | What to do, one line. |
| `zone` | yes | Where (`'-'` for crafting or skill-ups). |
| `notes` | no | Longer explanation, shown in the dropdown. |
| `details` | no | List of numbered sub-steps, shown in the dropdown. |
| `url`, `urlLabel` | no | Extra link button inside the dropdown. |
| `detect` | no | Exact item names. Holding **any** of them (inventory or bank) checks this step. |
| `nobackfill` | no | Use for items you can get before reaching this step (pre-farmable or tradable drops, the Anguish Globe). The item checks only its own step instead of every step before it. |
| `after` | no | Only auto-detect once that step key is checked. Use when the same item name shows up twice in a quest. |

## How detection works

1. Every 5 seconds the script checks each step's `detect` items with `FindItemCount` and `FindItemBankCount` (exact match).
2. A found item checks its step. That step is marked `auto` and stays checked after the item is turned in.
3. Unless the step is `nobackfill`, every earlier step in the same tier is checked too, and every step in earlier tiers.

### Choosing detect items

- Pick the item you **receive** at that step: a quest reward, a looted drop, a combine result.
- Item names must be exact, including backticks (`` Teir`Dal ``) and apostrophes.
- Don't detect items that appear at several steps. Detect the first one, or use `after`.
- Generic names (`Soulstone Shard`, `Broken Sword Piece`) are best left undetected.

## Testing your change

1. `/lua stop epictracker` then `/lua run epictracker`.
2. Lua syntax errors show up in the MQ console with the file and line number.
3. Open the class tab and check your step reads right.
