---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- Removal of old storage variables (thoroughness probably not needed).
if address_exists(storage, "panels", "to_be_removed") then
    table_clear(storage.panels.to_be_removed)
    storage.panels.to_be_removed = nil
end
if address_exists(storage, "platforms", "solar_power") then
    table_clear(storage.platforms.solar_power)
    storage.platforms.solar_power = nil
    storage.platforms             = nil
end

-- The shared string component of all thermal panel names, including those of any clones:
local panel_name_base = "tspl-thermal-solar-panel"

local function create_storage_table_keys()
    if storage.panels               == nil then storage.panels               =    {} end
    if storage.panels.main          == nil then storage.panels.main          =    {} end
    if storage.panels.to_be_added   == nil then storage.panels.to_be_added   =    {} end
    if storage.panels.removed_flag  == nil then storage.panels.removed_flag  = false end
    if storage.panels.batch_size    == nil then storage.panels.batch_size    =    10 end
    if storage.panels.progress      == nil then storage.panels.progress      =     1 end
    if storage.panels.complete      == nil then storage.panels.complete      = false end
    if storage.surfaces             == nil then storage.surfaces             =    {} end
    if storage.surfaces.solar_power == nil then storage.surfaces.solar_power =    {} end
end

-- Function to calculate max. solar power of a surface, using a string ID LuaSurface reference.
local function calculate_solar_power_for_surface(surface)
    local platform = surface.platform
    -- Just retrieves solar power property if surface does not belong to a platform:
    if not platform then
        return surface.get_property("solar-power")/100
    end
    -- Retrieves or calculates solar power for platform depending on location:
    if platform.space_location then -- stationed (typically near planet)
        return platform.space_location.solar_power_in_space/100
    else -- in transit (linear change, similar to that of solar panels)
        local solar_power_start = platform.space_connection.from.solar_power_in_space
        local solar_power_stop  = platform.space_connection.to.solar_power_in_space
        local distance          = platform.distance -- 0 to 1
        return (solar_power_start - (solar_power_start - solar_power_stop) * distance)/100
    end
end

-- Function to calculate and store solar power for all surfaces.
local function update_surface_solar_power_storage_register()
    for name, surface in pairs(game.surfaces) do
        storage.surfaces.solar_power[name] = calculate_solar_power_for_surface(surface)
    end
end

-- Complete list of panel variants, including any clones.
local panel_variants = {}

-- Finds all panel variants (calculated by whatever function uses the variable right above).
for key, _ in pairs(prototypes.entity) do
    if string.find(key, panel_name_base, 1, true) then
        table.insert(panel_variants, key)
    end
end

-- Function to reset storage table. Rebuilds array of thermal panels and removes any solar-fluid;
-- rebuilds table of space platform names + current solar power.
local function reset_panels_and_platforms()
    -- Initializes storage variables just in case they are missing:
    create_storage_table_keys()
    -- Clears storage of all thermal panels and resets related values, then rebuilds contents:
    table_clear(storage.panels.main)
    table_clear(storage.panels.to_be_added)
    storage.panels.removed_flag = false
    storage.panels.batch_size   = 10
    storage.panels.progress     = 1
    storage.panels.complete     = false
    for _, surface in pairs(game.surfaces) do
        for _, panel in pairs(surface.find_entities_filtered{name = panel_variants}) do
            table.insert(storage.panels.main, panel)
            panel.clear_fluid_inside()
        end
    end
    -- Clears storage of all surfaces, then rebuilds contents.
    table_clear(storage.surfaces.solar_power)
    update_surface_solar_power_storage_register()
end

reset_panels_and_platforms()

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------