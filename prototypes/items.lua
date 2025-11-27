---------------------------------------------------------------------------------------------------
--  ┳┏┳┓┏┓┳┳┓┏┓
--  ┃ ┃ ┣ ┃┃┃┗┓
--  ┻ ┻ ┗┛┛ ┗┗┛
---------------------------------------------------------------------------------------------------
require "shared"
local item_sounds = require "__base__.prototypes.item_sounds"
local item_tints = require("__base__.prototypes.item-tints")
---------------------------------------------------------------------------------------------------
-- ITEMS + SUBGROUPS
---------------------------------------------------------------------------------------------------

-- Subgroup for inventory sorting --
local subgroup_thermal = {
    type = "item-subgroup",
    name = "thermal-solar-energy",
    group = "production",
    order = "ba"
}

-- Thermal Solar Panel --
local panel = { 
    type = "item",
    name = "tspl-thermal-solar-panel",
    icon = GRAPHICS_ICONS.."thermal-solar-panel.png",
    icon_size = 32,		
    subgroup = "thermal-solar-energy",
    order = "a[tspl]-a",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "tspl-thermal-solar-panel",
    weight = 20*kg,
    stack_size = 50
}
-- Thermal Solar Panel (Large) --
local panel_l = { 
    type = "item",
    name = "tspl-thermal-solar-panel-large",
    icon = GRAPHICS_ICONS.."thermal-solar-panel-large.png",
    icon_size = 32,		
    subgroup = "thermal-solar-energy",
    order = "a[tspl]-b",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "tspl-thermal-solar-panel-large",
    weight = 200*kg,
    stack_size = 10
}
-- Basic Heat Exchanger --
local exchanger = { 
    type = "item",
    name = "tspl-basic-heat-exchanger",
    icon = GRAPHICS_ICONS.."basic-heat-exchanger.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "thermal-solar-energy",
    order = "a[tspl]-c",
    inventory_move_sound = item_sounds.steam_inventory_move,
    pick_sound = item_sounds.steam_inventory_pickup,
    drop_sound = item_sounds.steam_inventory_move,
    place_result = "tspl-basic-heat-exchanger",
    weight = 20*kg,
    stack_size = 50,
    random_tint_color = item_tints.iron_rust
}
-- Basic Heat Pipe --
local heat_pipe = { 
    type = "item",
    name = "tspl-basic-heat-pipe",
    icon = GRAPHICS_ICONS.."basic-heat-pipe.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "thermal-solar-energy",
    order = "a[tspl]-d",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "tspl-basic-heat-pipe",
    weight = 20*kg,
    stack_size = 50
}

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({subgroup_thermal, panel, panel_l, exchanger, heat_pipe})

---------------------------------------------------------------------------------------------------

-- NOTE: Item weights in Factorio are seriously all over the place, so I just chose som neat values
-- that seem to fit in, even if they don't always make sense.