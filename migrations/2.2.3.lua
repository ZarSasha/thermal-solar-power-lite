---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- New storage table variables:
if storage.active_mods           == nil then storage.active_mods           =    {} end
if storage.platforms             == nil then storage.platforms             =    {} end
if storage.platforms.solar_power == nil then storage.platforms.solar_power =    {} end

---------------------------------------------------------------------------------------------------
-- END NOTES:
---------------------------------------------------------------------------------------------------