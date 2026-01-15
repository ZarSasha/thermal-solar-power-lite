---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.2
---------------------------------------------------------------------------------------------------

table_clear(storage.platforms.solar_power)
storage.platforms.solar_power = nil
storage.platforms             = nil

if storage.surfaces             == nil then storage.surfaces             = {} end
if storage.surfaces.solar_power == nil then storage.surfaces.solar_power = {} end

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------