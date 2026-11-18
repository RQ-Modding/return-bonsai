# Return Bonsai

A legendary held item that keeps a quest's best finds, even when the quest fails.

## Showcase

### Return Bonsai sold in Frostbuy

<img width="475" height="160" alt="image" src="https://github.com/user-attachments/assets/25870171-1d51-45e4-93b0-efb9df07d856" />

## Return Bonsai Button during Quest

<img width="532" height="272" alt="image" src="https://github.com/user-attachments/assets/05b65e1e-7a5e-43f8-b625-8d04b15a1f63" />

## Return Bonsai Storage

<img width="967" height="448" alt="image" src="https://github.com/user-attachments/assets/63381315-9b87-4a85-a11c-01ddf080d210" />

## Button to move from Quest Storage into Bonsai Storage

<img width="671" height="447" alt="image" src="https://github.com/user-attachments/assets/e146373e-d1f7-47fc-965a-4d829e6731ba" />

## An item in the Bonsai Storage

<img width="685" height="536" alt="image" src="https://github.com/user-attachments/assets/a34660a4-7be8-45ec-9b6a-37d457782a8b" />


## What it changes

- **The Return Bonsai**, a held item (the item slot). While party members wear one on a quest's
  map, a red tab appears on the map's right edge: the **bonsai storage**, a window like Quest
  Storage.
  - Each bonsai worn gives the bonsai storage **2 cells**, once per quest, up to 15. The cells stay
    when its wearer falls or is switched out; a newcomer wearing a bonsai that has not given cells
    yet adds 2 more.
  - In Quest Storage (the map panel's button), each tile has a small bonsai button at its top
    right: it moves the item into the bonsai storage. Each tile of the bonsai storage has the same
    button, to move it back. Quest items cannot go in; unidentified items can.
  - **However the quest ends** (cleared, defeated, abandoned or by an escape device), the bonsai
    storage's items are in your storage afterwards, appraised for free.
- **A bonsai lasts 3 quests with a map**: each bonsai that gave cells in a quest loses a use. Then it
  turns to **Bonsai Ashes**, good only to donate.
- **Frostbuy** sells one for 50,000 gold, always. After a purchase she has another only once you
  have cleared more quests: 3 in the first world, 2 in the second. From the third world she has
  another on your next visit.
- **A chest** in the Malgrid Dungeon's 9th or 10th stratum, or anywhere in its Xth Stratum, may hold
  one: 1% per chest, at most one per run.

## Keys and settings

None.

## Saves

The bonsai and the ashes are items the loader gives the mod (1000 and up); without the mod they
show as plain items. During a quest the bonsai storage's items wait in your storage, and the mod
keeps their list in `rq.savedata` beside the save, with the purchases and the quests cleared since
the last one; the game ignores it.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.47.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/return-bonsai/mod.json`.

## How it works

- The items: `rq.item.define`, one number per use left; a use is `rq.item.transform`.
- The tab: `rq.gamebutton` group `"map"`; the window: `rq.uikit.item_window` with `capacity`.
- The buttons on Quest Storage: `rq.ui.quest_storage` gives the tiles, `rq.uikit.icon_button`
  draws them, `rq.item.set`'s `place` moves the item and `rq.ui.quest_storage_refresh` redraws the
  window.
- The quest's end: `rq.quests.on_end` and `rq.item.appraise`.
- Frostbuy: `rq.shop.on_stock`, `on_buy` and `rq.item.set`'s `price`; the chest: `rq.loot.on_pick`.

## Credits

The icons are AliceSoft's art: `icons/bonsai.webp` (the Return Bonsai), `icons/ashes.webp` (Bonsai
Ashes) and `icons/tab.webp` (the map tab and the Quest Storage button) are sprites from AliceSoft's
Rance games, each edited for this mod. All rights to them are reserved by AliceSoft; they are not
covered by this mod's MIT license.

## License

MIT, see [LICENSE](LICENSE).
