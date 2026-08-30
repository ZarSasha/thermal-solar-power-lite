---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┳┳┓┳┓┏┓┳┓┏┳┓┏┓
--  ┣┫┣ ┃┃┃┃┃┣┫┃┃ ┃ ┗┓
--  ┛┗┗┛┛ ┗┛┗┛┗┛┗ ┻ ┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- REMNANTS
---------------------------------------------------------------------------------------------------

-- THERMAL SOLAR PANEL (LARGE) --
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
animation = {
    filename = GRAPHICS_ENTITIES.."thermal-solar-panel-large/remnants/hr-large-panel-remnants.png",
    height = 640, width = 640, scale = 0.5, frame_count = 1,
    direction_count = 1, shift = util.by_pixel(0, -2)}
}

-- BASIC HEAT EXCHANGER --
local ExchangerRemnants = {
    type = "corpse",
    name = "basic-heat-exchanger-remnants",
    icon = "__base__/graphics/icons/heat-boiler.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "energy-remnants",
    order = "a-g-a",
    selection_box = {{-1.5, -1}, {1.5, 1}},
    tile_width = 3,
    tile_height = 2,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = {
        filename = GRAPHICS_ENTITIES.."basic-heat-exchanger/remnants/basic-heatex-remnants.png",
        line_length = 1, width = 272, height = 262, direction_count = 4,
        shift = util.by_pixel(0.5, 8), scale = 0.5
    }
}

if SETTING.exchanger_color then
    ExchangerRemnants.animation.filename =
        GRAPHICS_ENTITIES.."basic-heat-exchanger/remnants/basic-heatex-remnants-yellow.png"
end

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({largePanelRemnants, ExchangerRemnants})

---------------------------------------------------------------------------------------------------