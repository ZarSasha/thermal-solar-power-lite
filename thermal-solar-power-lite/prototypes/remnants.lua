---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┳┳┓┳┓┏┓┳┓┏┳┓┏┓
--  ┣┫┣ ┃┃┃┃┃┣┫┃┃ ┃ ┗┓
--  ┛┗┗┛┛ ┗┛┗┛┗┛┗ ┻ ┗┛
---------------------------------------------------------------------------------------------------
require "shared"
---------------------------------------------------------------------------------------------------
-- REMNANTS 
---------------------------------------------------------------------------------------------------

-- THERMAL SOLAR PANEL (LARGE) --
local panel_asset = GRAPHICS_ENTITIES.."thermal-solar-panel-large/remnants/"

local hr_panel_l_remnants_sprite = {
	filename = panel_asset .. "hr-large-panel-remnants.png",
	height = 640, width = 640, scale = 0.5, frame_count = 1, direction_count = 1,
	shift = util.by_pixel(0, -2)}

    local largePanelRemnants = {
    type = "corpse",
    name = "large-panel-remnants",
    icon = GRAPHICS_ICONS.."thermal-solar-panel-large.png",
    icon_size = 32,
    hidden_in_factoriopedia = true,
    flags = {"placeable-neutral", "not-on-map"},
    selection_box = {{-4.5,-4.5},{4.5,4.5}},
    tile_width = 9,
    tile_height = 9,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    remove_on_tile_placement = false,
    final_render_layer = "remnants",
    animation = hr_panel_l_remnants_sprite
}

-- BASIC HEAT EXCHANGER --
local exchanger_asset = GRAPHICS_ENTITIES.."basic-heat-exchanger/remnants/"

local ExchangerRemnants = table.deepcopy(data.raw.corpse["heat-exchanger-remnants"])
ExchangerRemnants.name = "basic-heat-exchanger-remnants"
ExchangerRemnants.animation.filename = exchanger_asset.."basic-heat-exchanger-remnants.png"

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({largePanelRemnants, ExchangerRemnants})

---------------------------------------------------------------------------------------------------