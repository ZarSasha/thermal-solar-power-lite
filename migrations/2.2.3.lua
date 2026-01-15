---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- Removal of old storage variables.
if address_not_nil(storage, "platforms", "solar_power") then
    table_clear(storage.platforms.solar_power)
    storage.platforms.solar_power = nil
    storage.platforms             = nil
end

-- New storage table variables.
storage.surfaces = {}
storage.surfaces.solar_power = {}

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------