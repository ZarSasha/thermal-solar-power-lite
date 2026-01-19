---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- New storage variables:
storage.panels.main_register  = storage.panels.main or {}
storage.panels.removal_flag   = false
storage.surfaces              = {}
storage.surfaces.solar_mult   = {} -- filled below
storage.cycle                 = {}
storage.cycle.batch_size      = storage.panels.batch_size or 1
storage.cycle.progress        = storage.panels.progress or 1
storage.cycle.complete        = storage.panels.complete or false

for name, surface in pairs(game.surfaces) do
    storage.surfaces.solar_mult[name] = 1 -- temporary value, to keep things simple
end

-- Removed storage variables:
storage.panels.main           = nil
storage.panels.to_be_removed  = nil -- any invalid panels will be detected in the next cycle
storage.panels.batch_size     = nil
storage.panels.progress       = nil
storage.panels.complete       = nil
storage.platforms.solar_power = nil
storage.platforms             = nil

--[[
-- Complete clean-up of storage table, since old variables may have accumulated in a way that was
-- not properly accounted for through migration scripts. Too complicated to correctly identify them
-- all, so contents of tables and values will just be recalculated.

-- Creates new storage variables:
storage = {
    panels = {
        main_register = {},
        to_be_added   = {},
        removal_flag  = false,
    },
    surfaces = {
        solar_mult = {}
    },
    cycle = {
        batch_size = 1,
        progress   = 1,
        complete   = false
    }
}

-- Repopulates list of thermal panels:
do
    local panel_name_base = "tspl-thermal-solar-panel"
    local panel_variants = {}

    for key, _ in pairs(prototypes.entity) do
        if string.find(key, panel_name_base, 1, true) then
            table.insert(panel_variants, key)
        end
    end

    for _, surface in pairs(game.surfaces) do
        for _, panel in pairs(surface.find_entities_filtered{name = panel_variants}) do
            table.insert(storage.panels.main_register, panel)
            panel.clear_fluid_inside()
        end
    end
end

-- Repopulates table of surfaces names and the associated solar power:
do
    local function calculate_solar_power_for_surface(surface)
        local platform = surface.platform
        if not platform then
            return surface.get_property("solar-power")/100
        end
        if platform.space_location then
            return platform.space_location.solar_power_in_space/100
        else
            local solar_power_start = platform.space_connection.from.solar_power_in_space
            local solar_power_stop  = platform.space_connection.to.solar_power_in_space
            local distance          = platform.distance -- 0 to 1
            return (solar_power_start - (solar_power_start - solar_power_stop) * distance)/100
        end
    end

    for name, surface in pairs(game.surfaces) do
        storage.surfaces.solar_mult[name] = calculate_solar_power_for_surface(surface)
    end
end

do
    local tick_interval  = 60
    local reserved_ticks = 2
    storage.panels.batch_size =
        math.ceil(#storage.panels.main_register / (tick_interval - reserved_ticks - 1))
end

-- Prints message to console:
game.print("[color=acid]Thermal Solar Power (Lite):[/color]")
game.print("  Regarding update to v2.2.3: Stored mod data was completely reset! Fixes issue with")
game.print("  possible accummulation of obsolete data. Report any issues on the Mod Portal or on")
game.print("  GitHub. Writing '/tspl reset' in the console may help.")
]]
---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------

--[[
-- Old variables in storage that were overlooked during earlier migrations:
storage.thermal.panels = nil
storage.q_scaling = nil
storage.heat_loss_X = nil
storage.temp_gain = nil
-- These are all likely from unreleased branches!
]]
