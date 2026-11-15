-- Return Bonsai. A very rare held item: while party members wear one on a quest's map, a red tab
-- opens the bonsai storage, a window like Quest Storage with 2 cells for each bonsai worn (at most
-- 15). Items go in from the game's Quest Storage (a bonsai button on each tile) and come back the
-- same way. However the quest ends, the bonsai storage's items stay in the storage, appraised for
-- free. A bonsai lasts 3 quests, then turns to Bonsai Ashes. Frostbuy sells it for 50,000 gold, and
-- after a purchase again only once quests are cleared: 3 in the first world, 2 in the second, none
-- from the third (it is back on the next visit); it can also come out of a chest in the Malgrid
-- Dungeon's 9th and 10th strata, once per run.
-- Lua owns every rule; the loader gives the Quest Storage window's tiles, the free appraisal and the
-- window's locked cells (loader 2.47.0).

local USES = 3              -- quests a bonsai lasts
local CELLS = 2             -- cells each bonsai worn gives, once per quest
local MAX_CELLS = 15        -- as Quest Storage
local PRICE = 50000         -- Frostbuy's price, every time
local RESTOCK_AFTER = { 3, 2 } -- quests cleared after a purchase before it is sold again, by world;
                               -- from the third world, none
local DROP_QUESTS = { [145] = true, [146] = true } -- Malgrid Dungeon, 9th and 10th strata
local DROP_CHANCE = 1       -- percent, each time a chest picks its item there
local QUEST_STORAGE, STORAGE = 8, 11
local QUEST_ITEM = 22       -- an item's type that never goes in (rq.ItemDef.type "quest")
local BUTTON_W, BUTTON_H = 26, 28

-- Items ----------------------------------------------------------------------

local function uses_line(n)
  return n == 1 and "1 use left." or (n .. " uses left.")
end

-- One item number per uses left, so the save keeps the count on the item itself.
local BONSAI = {}   -- uses left -> item number
local USES_OF = {}  -- item number -> uses left
for n = USES, 1, -1 do
  local no = rq.item.define({
    id = "return-bonsai:bonsai_" .. n,
    name = "Return Bonsai",
    type = "item",
    icon = "icons/bonsai.webp",
    price = PRICE,
    info = "The legendary Return Bonsai.$Allows you to return items$even if your quest fails.$" .. uses_line(n),
  })
  BONSAI[n] = no
  USES_OF[no] = n
end

local ASHES = rq.item.define({
  id = "return-bonsai:ashes",
  name = "Bonsai Ashes",
  type = "item",
  icon = "icons/ashes.webp",
  price = 1,
  info = "The Bonsai has burned from overuse.$It can return nothing anymore.",
})

local TAB_ICON = rq.image.add("return-bonsai:tab", "icons/tab.webp", { fit = "contain", w = 32, h = 34 })
local BUTTON_ICON = rq.image.add("return-bonsai:button", "icons/tab.webp",
  { fit = "contain", w = BUTTON_W - 4, h = BUTTON_H - 4 })

-- The state, kept in the save ------------------------------------------------

-- given: the bonsai (instances) that gave cells in this quest; stored: the bonsai storage's items,
-- in its order, which live in the storage (place 11) for the whole quest.
local function list(key)
  local v = rq.savedata.get(key)
  if type(v) ~= "table" then return {} end
  return v
end

local function has(t, v)
  for _, x in ipairs(t) do
    if x == v then return true end
  end
  return false
end

local function capacity()
  return math.min(MAX_CELLS, CELLS * #list("given"))
end

-- The stored items that are still there (a mod or a test may have taken one).
local function stored()
  local out = {}
  for _, ii in ipairs(list("stored")) do
    local it = rq.item.get(ii)
    if it and it.place == STORAGE then out[#out + 1] = ii end
  end
  return out
end

-- Set when the quest's end ran: the map can still show (and its tab ask `shown`) while the game ends
-- the quest, and nothing may be counted again until the next quest.
local ended = false

local function on_map_quest()
  if ended then return false end
  local no = rq.quests.current()
  if not no or no == 0 then return false end
  local ok, q = pcall(rq.quests.get, no)
  return ok and q ~= nil and q.kind == "quest"
end

-- Each bonsai a party member wears gives its cells once per quest; falling or being switched out
-- keeps them, and a newcomer's bonsai adds its own.
local function scan()
  if not on_map_quest() then return end
  local given = list("given")
  local added = false
  for _, iic in ipairs(rq.party.get()) do
    if iic ~= 0 then
      local ii = rq.item.equipped(iic).item
      if ii and USES_OF[rq.item.number(ii)] and not has(given, ii) then
        given[#given + 1] = ii
        added = true
      end
    end
  end
  if added then rq.savedata.set("given", given) end
end

local function quest_storage_count()
  local n = 0
  for _, row in ipairs(rq.items()) do
    if row.place == QUEST_STORAGE then n = n + 1 end
  end
  return n
end

local function to_bonsai(ii)
  local s = stored()
  if #s >= capacity() or has(s, ii) then return false end
  local it = rq.item.get(ii)
  if not it or it.place ~= QUEST_STORAGE or it.type == QUEST_ITEM then return false end
  rq.item.set(ii, { place = STORAGE })
  s[#s + 1] = ii
  rq.savedata.set("stored", s)
  return true
end

local function to_quest_storage(ii)
  local s = stored()
  if not has(s, ii) or quest_storage_count() >= MAX_CELLS then return false end
  rq.item.set(ii, { place = QUEST_STORAGE })
  for i, x in ipairs(s) do
    if x == ii then table.remove(s, i) break end
  end
  rq.savedata.set("stored", s)
  return true
end

-- The map tab and the bonsai storage --------------------------------------------

local open = false

rq.gamebutton.add({
  group = "map",
  id = "storage",
  label = "Return Bonsai",
  icon = TAB_ICON,
  tip = function()
    return ("Bonsai storage: %d / %d"):format(#stored(), capacity())
  end,
  shown = function()
    scan()
    return capacity() > 0
  end,
  on_click = function() open = true end,
})

local function draw_window()
  local s = stored()
  local cap = capacity()
  local items = {}
  for _, ii in ipairs(s) do
    local it = rq.item.get(ii)
    items[#items + 1] = { item = ii, judged = it and it.identified }
  end
  local qs_full = quest_storage_count() >= MAX_CELLS
  local back
  local still = rq.uikit.item_window(items, {
    id = "bonsai",
    title = ("Return Bonsai  %d / %d"):format(#s, cap),
    rows = 3,
    capacity = cap,
    empty = "Put items in from Quest Storage.",
    cell = function(k, x, y, e)
      if not e then return end
      local bx, by = x + 100 - BUTTON_W - 2, y + 2
      rq.hud.rect(bx, by, BUTTON_W, BUTTON_H, 0, 0, 0, 140)
      if rq.uikit.icon_button(BUTTON_ICON, { x = bx, y = by, w = BUTTON_W, h = BUTTON_H,
          id = "to-quest-" .. k, label = "Return Bonsai",
          tip = qs_full and "Quest Storage is full." or "Back to Quest Storage.", disabled = qs_full }) then
        back = e.item
      end
    end,
  })
  if back then to_quest_storage(back) end
  open = still
end

-- The bonsai button on each tile of the game's Quest Storage (opened from the map panel).
local function draw_buttons()
  local qs = rq.ui.quest_storage()
  if not qs or qs.mode ~= "view" or qs.dialog then return end
  local cap = capacity()
  if cap == 0 then return end
  local full = #stored() >= cap
  local moved = false
  for _, t in ipairs(qs.tiles) do
    local it = rq.item.get(t.ii)
    if it and it.type ~= QUEST_ITEM then
      local bx, by = t.x + t.w - BUTTON_W - 2, t.y + 2
      rq.hud.rect(bx, by, BUTTON_W, BUTTON_H, 0, 0, 0, 140)
      if rq.uikit.icon_button(BUTTON_ICON, { x = bx, y = by, w = BUTTON_W, h = BUTTON_H,
          id = "to-bonsai-" .. t.index, label = "Return Bonsai",
          tip = full and "The bonsai storage is full." or "Into the bonsai storage.", disabled = full }) then
        moved = to_bonsai(t.ii) or moved
      end
    end
  end
  if moved then rq.ui.quest_storage_refresh() end
end

rq.on_frame(function()
  if ended and rq.quests.current() == 0 then ended = false end
  if open then
    if not on_map_quest() then
      open = false
      return
    end
    draw_window()
    return
  end
  draw_buttons()
end)

-- The quest's end ----------------------------------------------------------------

local function use_up(ii)
  local n = USES_OF[rq.item.number(ii) or 0]
  if not n then return end
  rq.item.transform(ii, n > 1 and BONSAI[n - 1] or ASHES)
end

rq.quests.on_end(function(ctx)
  open = false
  ended = true
  -- The items are in the storage already: appraised for free, the screen never sees them.
  local kept = stored()
  for _, ii in ipairs(kept) do rq.item.appraise(ii) end
  -- Every bonsai that gave cells loses a use, on a quest with a map.
  local ok, q = pcall(rq.quests.get, ctx.quest)
  if ok and q and q.kind == "quest" then
    for _, ii in ipairs(list("given")) do use_up(ii) end
  end
  if #kept > 0 then rq.log(("Return Bonsai: %d item(s) kept in the storage"):format(#kept)) end
  rq.savedata.set("stored", nil)
  rq.savedata.set("given", nil)
  rq.savedata.set("dropped", nil)
  if ctx.cleared and rq.savedata.get("bought", 0) > 0 then
    rq.savedata.set("cleared_since", rq.savedata.get("cleared_since", 0) + 1)
  end
end)

-- Frostbuy --------------------------------------------------------------------------

local function price_now()
  return PRICE
end

-- The quests to clear after a purchase in the world being played (1 before a save is loaded).
local function restock_after()
  return RESTOCK_AFTER[rq.world.current() or 1] or 0
end

local function for_sale()
  if rq.savedata.get("bought", 0) == 0 then return true end
  return rq.savedata.get("cleared_since", 0) >= restock_after()
end

rq.shop.on_stock(function()
  if not for_sale() then return end
  local ii
  if rq.shop.in_stock(BONSAI[USES]) then
    ii = rq.item.find(BONSAI[USES], { place = 6 })[1]
  else
    ii = rq.shop.stock(BONSAI[USES])
  end
  if ii and ii > 0 then rq.item.set(ii, { price = price_now() }) end
end)

rq.shop.on_buy(function(ctx)
  if ctx.no ~= BONSAI[USES] then return end
  rq.savedata.set("bought", rq.savedata.get("bought", 0) + 1)
  rq.savedata.set("cleared_since", 0)
end)

-- The chest in the Malgrid Dungeon's 9th and 10th strata, once per run ----------------

-- A chest tries its pools in turn until one gives an item, so the pick with an item is the chest's:
-- one roll per chest.
rq.loot.on_pick(function(ctx)
  if ctx.item == 0 or not DROP_QUESTS[rq.quests.current()] or rq.savedata.get("dropped", false) then
    return nil
  end
  if math.random(100) > DROP_CHANCE then return nil end
  return BONSAI[USES]
end)

rq.item.on_create(function(ctx)
  if not USES_OF[ctx.no] then return end
  -- A chest's bonus points would give it random effects; a bonsai has none.
  rq.item.set(ctx.ii, { effects = {} })
  if DROP_QUESTS[rq.quests.current()] then rq.savedata.set("dropped", true) end
end)

rq.on_reset(function()
  open = false
  ended = false
end)

rq.log(("Return Bonsai: bonsai %d/%d/%d, ashes %d"):format(BONSAI[3], BONSAI[2], BONSAI[1], ASHES))

-- For the Lab.
return {
  BONSAI = BONSAI,
  ASHES = ASHES,
  USES_OF = USES_OF,
  capacity = capacity,
  stored = stored,
  scan = scan,
  to_bonsai = to_bonsai,
  to_quest_storage = to_quest_storage,
  price_now = price_now,
  restock_after = restock_after,
  for_sale = for_sale,
  is_open = function() return open end,
  set_open = function(v) open = v and true or false end,
  -- The mod's rq.savedata, read and written from its own file (the store is the caller's mod's).
  data = function(key)
    local v = rq.savedata.get(key)
    return v
  end,
  set_data = function(key, value)
    rq.savedata.set(key, value)
  end,
}
