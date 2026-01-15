---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.2
---------------------------------------------------------------------------------------------------

table_clear(storage.platforms.solar_power)
storage.platforms.solar_power = nil
storage.platforms             = nil

if storage.surfaces             == nil then storage.surfaces             = {} end
if storage.surfaces.solar_power == nil then storage.surfaces.solar_power = {} end

for name, surface in pairs(game.surfaces) do
    local platform = surface.platform
    -- Just retrieves solar power property if surface does not belong to a platform:
    if not platform then
        storage.surfaces.solar_power[name] = surface.get_property("solar-power")/100
        goto continue
    end
    -- Retrieves or calculates solar power for platform depending on location:
    if platform.space_location then
        storage.surfaces.solar_power[name] =
            platform.space_location.solar_power_in_space
    elseif platform.space_connection then
        local solar_power_start = platform.space_connection.from.solar_power_in_space
        local solar_power_stop  = platform.space_connection.to.solar_power_in_space
        local distance          = platform.distance -- 0 to 1
        storage.surfaces.solar_power[name] =
            (solar_power_start - (solar_power_start - solar_power_stop) * distance)/100
    else
        log("Error! Could not identify solar power for space platform.")
    end
    ::continue::
end

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------