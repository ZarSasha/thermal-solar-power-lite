---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------

-- Change to name of storage table key, that contain thermal solar panel IDs:
if storage.tspl_thermal_panel_table ~= nil then
    -- Transfers data from old to new key:
    storage.thermal_panels = storage.tspl_thermal_panel_table
    -- Cleans up the old key:
    storage.tspl_thermal_panel_table = nil
    -- Logs a message to the console for debugging/confirmation:
    log("Migrated data from 'tspl_thermal_panel_table' to 'panel_IDs'.")
end

---------------------------------------------------------------------------------------------------