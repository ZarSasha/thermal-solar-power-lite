---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------

if storage.panels               == nil then storage.panels               =    {} end
if storage.panels.main          == nil then storage.panels.main          =    {} end

-- Transfer of data from storage table to new variable:
if storage.tspl_thermal_panel_table ~= nil then
    -- Extracts values (ignoring keys) and copies them into new array:
    for _, v in pairs(storage.tspl_thermal_panel_table) do
        table.insert(storage.panels.main, v)
    end
    table_clear(storage.tspl_thermal_panel_table)
    log(
        "Migrated data from table: 'storage.tspl_thermal_panel_table' "
      .."to new array: 'storage.panels.main'."
    )
end

---------------------------------------------------------------------------------------------------