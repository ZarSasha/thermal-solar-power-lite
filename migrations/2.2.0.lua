---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------

if storage.panels               == nil then storage.panels               =    {} end
if storage.panels.main          == nil then storage.panels.main          =    {} end
if storage.panels.to_be_added   == nil then storage.panels.to_be_added   =    {} end
if storage.panels.to_be_removed == nil then storage.panels.to_be_removed =    {} end
if storage.panels.batch_size    == nil then storage.panels.batch_size    =    10 end -- small, for testing
if storage.panels.progress      == nil then storage.panels.progress      =     1 end
if storage.panels.complete      == nil then storage.panels.complete      = false end

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