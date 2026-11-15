# Testing Return Bonsai

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading return-bonsai` and the line `Return Bonsai: bonsai <3 uses>/<2>/<1>, ashes <n>`, which gives
the items' numbers.

## What it adds

- **The map tab:** the control `return-bonsai.storage` on a quest's map, while a party member wears
  a bonsai (or one did in this quest). Pressing it opens the bonsai storage.
- **The bonsai storage:** `page-bonsai`, its close button `button-close-bonsai`, its tiles
  `item-bonsai-<n>`, and on each tile the button `button-to-quest-<n>` (back to Quest Storage).
- **On the game's Quest Storage** (opened from the map panel, not the give-up or failure screens):
  the tiles are `item-<n>` of the `quest-storage` screen (1 to 15), and each tile that is not a quest
  item has the button `button-to-bonsai-<n>` while the bonsai storage has cells. A full bonsai
  storage greys them.
- **Log:** `Return Bonsai: <n> item(s) kept in the storage` at the end of a quest with items in it.

## How to check it

1. Give a bonsai (`rq.item.give(<3 uses>, { to = iic })`) to a party member and start a quest
   with a map. The red tab shows on the map's right edge; its tip says `Bonsai storage: 0 / 2`.
2. Pick up an item, open Quest Storage from the map panel and press the bonsai button on its tile.
   The tile leaves Quest Storage; the tab's window shows it.
3. In the bonsai storage, press the button on the tile: it goes back to Quest Storage.
4. Put an item in, then give up the quest. The item is in the vault's storage afterwards,
   identified. The bonsai now says `2 uses left.`
5. After its third quest with a map the bonsai is Bonsai Ashes.
6. Frostbuy sells the bonsai for 50,000; after buying it she has none until 3 quests are cleared
   in the first world (2 in the second), then it costs 50,000 again. From the third world it is
   back on the next visit.

## Forcing it for a test

`require("return-bonsai")` (from another mod) or `rq.mod.get("return-bonsai")` returns `BONSAI`
(uses left to item number), `ASHES`, `USES_OF`, `capacity()`, `stored()`, `scan()`,
`to_bonsai(ii)`, `to_quest_storage(ii)`, `price_now()`, `restock_after()` (the quests to clear
in the world being played), `for_sale()`, `is_open()`,
`set_open(v)`, `data(key)` and `set_data(key, value)`. The state is the mod's `rq.savedata`
(`stored`, `given`, `bought`, `cleared_since`, `dropped`), which only the mod's own file reaches:
use `data` and `set_data`. Work on a copy of the save.

## Test Lab

`return-bonsai` (with this mod installed): the tab and its cells, the buttons on Quest Storage and
in the bonsai storage, the items kept and appraised at a failure, the uses and the ashes, the shop's
price and restock, and the chest.
