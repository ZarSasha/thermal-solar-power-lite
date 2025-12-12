---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------

-- Name change for storage table key:
if storage.tspl_thermal_panel_table ~= nil then
    storage.thermal_panels = storage.tspl_thermal_panel_table
    storage.tspl_thermal_panel_table = nil
    log("Migrated data from 'storage.tspl_thermal_panel_table' to 'storage.thermal_panels'.")
end

---------------------------------------------------------------------------------------------------