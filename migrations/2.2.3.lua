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

-- New storage table variables.
storage.panels.removed_flag = false
storage.surfaces = {}
storage.surfaces.solar_power = {}

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------