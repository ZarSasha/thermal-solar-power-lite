---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┳┏┓┏┓
--  ┣ ┃┃ ┃ ┃ ┃ ┃┣ ┗┓
--  ┗┛┛┗ ┻ ┻ ┻ ┻┗┛┗┛
---------------------------------------------------------------------------------------------------
require "shared.all-stages"
require "shared.first-stages"
local hit_effects = require "__base__.prototypes.entity.hit-effects"
local sounds = require("__base__.prototypes.entity.sounds")
---------------------------------------------------------------------------------------------------
-- THERMAL SOLAR PANEL
---------------------------------------------------------------------------------------------------
-- Generates heat energy during the day, slowly losing some at night. Uses a script in control.lua.

-- GRAPHIC ASSETS ---------------------------------------------------------------------------------

-- Asset location --
local path_s = GRAPHICS_ENTITIES.."thermal-solar-panel/"

-- Normal resolution --
local panel_shadow_sprite = { -- shadow image, 100% black, transparent background
	filename = path_s .. "thermal-solar-panel-shadow.png",
	height = 123, width = 128, shift = util.by_pixel(3, -7.5),
	draw_as_shadow = true}

-- High resolution (AI-upscaled) --
local hr_panel_sprite = {
	filename = path_s .. "hr-thermal-solar-panel-trim.png",
	priority = "high", height = 256, width = 256, scale = 0.5,
    shift = util.by_pixel(0, 0.5)}

local hr_panel_connection_sprites = {
	filename = path_s .. "hr-thermal-solar-panel-connections.png",
	width = 64, height = 64, scale = 0.5, variation_count = 4,
    shift = util.by_pixel(0, 0)}

local hr_panel_disconnection_sprites = {
	filename = path_s .. "hr-thermal-solar-panel-connections.png",
	width = 64, height = 64, scale = 0.5, variation_count = 4, y = 64,
    shift = util.by_pixel(0, 5)}

-- PROPERTIES -------------------------------------------------------------------------------------

-- COMPATIBILITY for Pyanodon Coal Processing --
-- Increasing heat capacity increases heat energy output from runtime script.
local heat_capacity_kJ = 50
if MOD.PY_COAL_PROCESSING and not SETTING.select_mod == "Pyanodon" then
    -- Adjusts for steam heat capacity:
    heat_capacity_kJ = 50 * 1.122
elseif MOD.PY_COAL_PROCESSING and SETTING.select_mod == "Pyanodon" then
    -- Also adjusts for higher exchanger temperature (250°C):
    heat_capacity_kJ = 50 * 1.122 --
end

local ThermalPanel = {
	type = "reactor",
	name = "tspl-thermal-solar-panel",
    fast_replaceable_group = "tspl-thermal-solar-panel", -- for mod compat
    factoriopedia_description = {"factoriopedia-description.tspl-thermal-solar-panel"},
	icon = GRAPHICS_ICONS.."thermal-solar-panel.png",
	icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
	max_health = 200,
	selection_box = {{-1.5,	-1.5},{ 1.5, 1.5}},
	collision_box = {{-1.2, -1.2},{ 1.2, 1.2}},
	minable = {mining_time = 0.1, result = "tspl-thermal-solar-panel"},
	resistances = {{type = "fire", percent = 90}},
	corpse = "medium-remnants",
	dying_explosion = "solar-panel-explosion",
    damaged_trigger_effect = hit_effects.entity(),
    impact_category = "metal",
    consumption = (SETTING.panel_output_kW .. "kW"), -- mandatory property, must be greater than 0. 
    energy_source = { -- mandatory property
		type = "fluid",
		fluid_box = {
            volume              = 100.01,
			pipe_connections    = {},
			production_type     = "none",
			filter              = "tspl-solar-fluid" -- used by make-shift sunlight indicator
		},
		scale_fluid_usage = false,
		fluid_usage_per_tick = 0.000001, -- consumes "solar-fluid" very slowly.
		render_no_power_icon = false -- removes flashing 'No Power' icon
	},
  	neighbour_bonus = 0, -- optional, but declaring it corrects tooltip and Factoriopedia info.
    picture = {layers = {hr_panel_sprite, panel_shadow_sprite}},
    heat_buffer = { -- mandatory property
		max_temperature = 1000,
		specific_heat = (heat_capacity_kJ .. "kJ"),
		max_transfer = "36MW",
		min_temperature_gradient = 0, -- heat loss from script instead
		connections = {
			{position = { 0, -1}, direction = defines.direction.north},
			{position = { 1,  0}, direction = defines.direction.east },
			{position = { 0,  1}, direction = defines.direction.south},
			{position = {-1,  0}, direction = defines.direction.west }
		}
    },
	connection_patches_connected    = {sheet = hr_panel_connection_sprites},
	connection_patches_disconnected = {sheet = hr_panel_disconnection_sprites},
    --no heat connection patches, because they actually make the panels look worse.
    open_sound = sounds.metal_small_open,
    close_sound = sounds.metal_small_close
}

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({ThermalPanel})

---------------------------------------------------------------------------------------------------
-- THERMAL SOLAR PANEL (LARGE)
---------------------------------------------------------------------------------------------------
-- 9 times as large as the normal panels. Much better script performance for the same area.

-- GRAPHIC ASSETS ---------------------------------------------------------------------------------

-- Asset location --
local path_l = GRAPHICS_ENTITIES.."thermal-solar-panel-large/"

-- Normal resolution --
local panel_l_shadow_sprite = { -- shadow image, 100% black, transparent background
	filename = path_l .. "thermal-solar-panel-large-shadows.png",
	height = 336, width = 336, shift = util.by_pixel(0, 0), draw_as_shadow = true}

-- High resolution --
local hr_panel_l_sprite = {
	filename = path_l .. "hr-thermal-solar-panel-large-trim.png",
	priority = "high", height = 672, width = 672, scale = 0.5,
    shift = util.by_pixel(0, 0.5)}

local hr_panel_l_connection_sprites = {
	filename = path_l .. "hr-thermal-solar-panel-large-connections.png",
	width = 64, height = 64, scale = 0.5, variation_count = 12,
    shift = util.by_pixel(0, 0)}

local hr_panel_l_disconnection_sprites = {
	filename = path_l .. "hr-thermal-solar-panel-large-connections.png",
	width = 64, height = 64, scale = 0.5, variation_count = 12, y = 64,
    shift = util.by_pixel(0, 5)}

-- PROPERTIES -------------------------------------------------------------------------------------
---@diagnostic disable-next-line: undefined-field
local ThermalPanelLarge = table.deepcopy(ThermalPanel)
ThermalPanelLarge.name = "tspl-thermal-solar-panel-large"
ThermalPanelLarge.fast_replaceable_group = "tspl-thermal-solar-panel-large"
ThermalPanelLarge.factoriopedia_description =
    {"factoriopedia-description.tspl-thermal-solar-panel-large"}
ThermalPanelLarge.icon = GRAPHICS_ICONS.."thermal-solar-panel-large.png"
ThermalPanelLarge.selection_box = {{-4.5, -4.5},{ 4.5, 4.5}}
ThermalPanelLarge.collision_box = {{-4.2, -4.2},{ 4.2, 4.2}}
ThermalPanelLarge.max_health = ThermalPanel.max_health * 9
ThermalPanelLarge.minable = {mining_time = 0.25, result = "tspl-thermal-solar-panel-large"}
ThermalPanelLarge.corpse = "large-panel-remnants" -- custom remnants
ThermalPanelLarge.dying_explosion = "large-panel-explosion" -- custom explosion
ThermalPanelLarge.consumption = (SETTING.panel_output_kW * 9 .. "kW")
ThermalPanelLarge.picture.layers[1] = hr_panel_l_sprite
ThermalPanelLarge.picture.layers[2] = panel_l_shadow_sprite
ThermalPanelLarge.heat_buffer.specific_heat = (heat_capacity_kJ * 9 .. "kJ")
ThermalPanelLarge.heat_buffer.connections = {
	{position = {-3, -4}, direction = defines.direction.north},
	{position = { 0, -4}, direction = defines.direction.north},
	{position = { 3, -4}, direction = defines.direction.north},
	{position = { 4, -3}, direction = defines.direction.east },
	{position = { 4,  0}, direction = defines.direction.east },
	{position = { 4,  3}, direction = defines.direction.east },
	{position = {-3,  4}, direction = defines.direction.south},
	{position = { 0,  4}, direction = defines.direction.south},
	{position = { 3,  4}, direction = defines.direction.south},
	{position = {-4, -3}, direction = defines.direction.west },
	{position = {-4,  0}, direction = defines.direction.west },
	{position = {-4,  3}, direction = defines.direction.west }
}
ThermalPanelLarge.connection_patches_connected    = {sheet = hr_panel_l_connection_sprites}
ThermalPanelLarge.connection_patches_disconnected = {sheet = hr_panel_l_disconnection_sprites}

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({ThermalPanelLarge})

---------------------------------------------------------------------------------------------------