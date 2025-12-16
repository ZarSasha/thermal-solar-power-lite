---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------

-- Transfer of data from storage table to new variable:
if storage.tspl_thermal_panel_table ~= nil then
    -- Extracts values (ignoring keys) and copies them into new array:
    for _, v in pairs(storage.tspl_thermal_panel_table) do
        table.insert(storage.panels.main, v)
    end
    storage.tspl_thermal_panel_table = nil
    log(
        "Migrated data from table: 'storage.tspl_thermal_panel_table' "
      .."to new array: 'storage.panels.main'."
    )
end

---------------------------------------------------------------------------------------------------