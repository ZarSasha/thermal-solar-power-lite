---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┳┏┓┏┓
--  ┣ ┃┃ ┃ ┃ ┃ ┃┣ ┗┓
--  ┗┛┛┗ ┻ ┻ ┻ ┻┗┛┗┛
---------------------------------------------------------------------------------------------------
local hit_effects = require "__base__.prototypes.entity.hit-effects"
local sounds = require("__base__.prototypes.entity.sounds")
---------------------------------------------------------------------------------------------------
-- BASIC HEAT EXCHANGER
---------------------------------------------------------------------------------------------------
-- Produces steam at 165°C at a rate of 60 units/s from water and heat.

-- GRAPHIC ASSETS ---------------------------------------------------------------------------------

-- Asset location --
local path = GRAPHICS_ENTITIES.."basic-heat-exchanger/"

local heatex_pipe_covers = make_4way_animation_from_spritesheet({
    filename = path .. "basic-heatex-endings.png",
    width = 64, height = 64, direction_count = 4, scale = 0.5
})
local heatex_pipecovers_heated = make_4way_animation_from_spritesheet(apply_heat_pipe_glow{
    filename = path .. "basic-heatex-endings-heated.png",
    width = 64, height = 64, direction_count = 4, scale = 0.5
})
local heatex_heat_picture_north = apply_heat_pipe_glow{
    filename = path .. "basic-heatex-N-heated.png",
    priority = "extra-high", width = 44, height = 96,
    shift = util.by_pixel(-0.5, 8.5), scale = 0.5
}
local heatex_heat_picture_east  = apply_heat_pipe_glow{
    filename = path .. "basic-heatex-E-heated.png",
    priority = "extra-high", width = 80, height = 80,
    shift = util.by_pixel(-21, -13), scale = 0.5
}
local heatex_heat_picture_south = apply_heat_pipe_glow{
    filename = path .. "basic-heatex-S-heated.png",
    priority = "extra-high", width = 28, height = 40,
    shift = util.by_pixel(-1, -30), scale = 0.5
}
local heatex_heat_picture_west  = apply_heat_pipe_glow{
    filename = path .. "basic-heatex-W-heated.png",
    priority = "extra-high", width = 64, height = 76,
    shift = util.by_pixel(23, -13), scale = 0.5
}
local heatex_entity_and_shadow_north = {
    {
        filename = path .. "basic-heatex-N-idle.png",
        priority = "extra-high", width = 269, height = 221,
        shift = util.by_pixel(-1.25, 5.25), scale = 0.5
    },{
        filename = path .. "basic-heatex-N-shadow.png",
        priority = "extra-high", width = 274, height = 164,
        scale = 0.5, shift = util.by_pixel(20.5, 9),
        draw_as_shadow = true
    }
}
local heatex_entity_and_shadow_east = {
    {
        filename = path .. "basic-heatex-E-idle.png",
        priority = "extra-high", width = 211, height = 301,
        shift = util.by_pixel(-1.75, 1.25), scale = 0.5
    },{
        filename = path .. "basic-heatex-E-shadow.png",
        priority = "extra-high", width = 184, height = 194,
        scale = 0.5, shift = util.by_pixel(30, 9.5),
        draw_as_shadow = true
    }
}
local heatex_entity_and_shadow_south = {
    {
        filename = path .. "basic-heatex-S-idle.png",
        priority = "extra-high", width = 260, height = 201,
        shift = util.by_pixel(4, 10.75), scale = 0.5
    },{
        filename = path .. "basic-heatex-S-shadow.png",
        priority = "extra-high", width = 311, height = 131,
        scale = 0.5, shift = util.by_pixel(29.75, 15.75),
        draw_as_shadow = true
    }
}
local heatex_entity_and_shadow_west = {
    {
        filename = path .. "basic-heatex-W-idle.png",
        priority = "extra-high", width = 196, height = 273,
        shift = util.by_pixel(1.5, 7.75), scale = 0.5
    },{
        filename = path .. "basic-heatex-W-shadow.png",
        priority = "extra-high", width = 206, height = 218,
        scale = 0.5, shift = util.by_pixel(19.5, 6.5),
        draw_as_shadow = true
    }
}
local heatex_water_reflection = {
    filename = path .. "basic-heatex-reflection.png",
    priority = "extra-high", width = 28, height = 32, scale = 5,
    shift = util.by_pixel(5, 30), variation_count = 4
}

-- Yellow paintjob option --
if SETTING.exchanger_color then
    heatex_entity_and_shadow_north[1].filename = path .. "basic-heatex-N-idle-yellow.png"
    heatex_entity_and_shadow_east [1].filename = path .. "basic-heatex-E-idle-yellow.png"
    heatex_entity_and_shadow_south[1].filename = path .. "basic-heatex-S-idle-yellow.png"
    heatex_entity_and_shadow_west [1].filename = path .. "basic-heatex-W-idle-yellow.png"
end

-- PROPERTIES -------------------------------------------------------------------------------------

local BasicHeatEx = {
    type = "boiler",
    name = "tspl-basic-heat-exchanger",
    icon = GRAPHICS_ICONS.."basic-heat-exchanger.png",
    localised_description = {
        "entity-description.tspl-basic-heat-exchanger", tostring(SETTING.exchanger_temp_target)
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        mining_time = 0.1, result = "tspl-basic-heat-exchanger"
    },
    fast_replaceable_group = "heat-exchanger",
    max_health = 200,
    corpse = "basic-heat-exchanger-remnants",
    dying_explosion = "heat-exchanger-explosion",
    impact_category = "metal",
    mode = "output-to-separate-pipe",
    resistances = {
        {type = "fire",      percent = 90},
        {type = "explosion", percent = 30},
        {type = "impact",    percent = 30}
    },
    collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    damaged_trigger_effect = hit_effects.entity(),
    target_temperature = SETTING.exchanger_temp_target,
    fluid_box = {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            {
                flow_direction = "input-output",
                direction = defines.direction.west,
                position = {-1, 0.5}
            },
            {
                flow_direction = "input-output",
                direction = defines.direction.east,
                position = {1, 0.5}
            }
        },
        production_type = "input",
        filter = "water"
    },
    output_fluid_box = {
        volume  = 200,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            {
                flow_direction = "output",
                direction = defines.direction.north,
                position = {0, -0.5}
            }
        },
        production_type = "output",
        filter = "steam"
    },
    energy_consumption = SETTING.exchanger_output_kW .. "kW", -- default: "1800kW"
    energy_source = {
        type = "heat",
        max_temperature = 1000,
        specific_heat = "250kJ",
        max_transfer = "500MW",
        min_working_temperature = SETTING.exchanger_temp_target,
        minimum_glow_temperature = 350,
        connections = {
            {
                position = {0, 0.5},
                direction = defines.direction.south
            }
        },
        pipe_covers = heatex_pipe_covers,
        heat_pipe_covers = heatex_pipecovers_heated,
        heat_picture = {
            north = heatex_heat_picture_north,
            east  = heatex_heat_picture_east,
            south = heatex_heat_picture_south,
            west  = heatex_heat_picture_west
        }
    },
    working_sound = {
        sound = {
            filename = "__base__/sound/heat-exchanger.ogg",
            volume = 0.65,
            modifiers = volume_multiplier("main-menu", 0.7),
            audible_distance_modifier = 0.5,
        },
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    open_sound = sounds.steam_open,
    close_sound = sounds.steam_close,
    pictures = {
        north = { structure = { layers = heatex_entity_and_shadow_north } },
        east  = { structure = { layers = heatex_entity_and_shadow_east  } },
        south = { structure = { layers = heatex_entity_and_shadow_south } },
        west  = { structure = { layers = heatex_entity_and_shadow_west  } },
    },
    burning_cooldown = 20,
    water_reflection = {
        pictures = heatex_water_reflection,
        rotate = false,
        orientation_to_variation = true
    },
    circuit_connector = circuit_connector_definitions["boiler"],
    circuit_wire_max_distance = default_circuit_wire_max_distance
}

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({BasicHeatEx})

---------------------------------------------------------------------------------------------------
