-- Check if the old key exists in the storage table
if storage.tspl_thermal_panel_table ~= nil then
    -- Transfer the data to the new key
    storage.panels = storage.tspl_thermal_panel_table

    -- Optional: Clean up the old key
    storage.tspl_thermal_panel_table = nil

    -- Log a message to the console for debugging/confirmation
    log("Migrated data from 'tspl_thermal_panel_table' to 'tspl_thermal_panel_table'.")
end