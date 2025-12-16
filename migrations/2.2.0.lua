---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------
-- The new time slicing feature needs several variables to be stored within the storage table. The
-- main table that holds the string identifiers also needs to replaced with a simple array
-- (contiguous indexed table).

-- Adds new table to storage.
storage.panels = {
    main          = {},
    to_be_added   = {},
    to_be_removed = {},
    batch_size    = 10,
    progress      =  1,
    complete      = false
}

-- Transfer of data from storage table to new variable:
if storage.tspl_thermal_panel_table ~= nil then
    -- Extracts values (ignoring keys) from table and copies them into new array in storage:
    for _, v in pairs(storage.tspl_thermal_panel_table) do
        table.insert(storage.panels.main, v)
    end
    -- Deletes old table in storage:
    table_clear(storage.tspl_thermal_panel_table)
    storage.tspl_thermal_panel_table = nil
    log(
        "Migrated data from table: 'storage.tspl_thermal_panel_table' "
      .."to new array: 'storage.panels.main'."
    )
end

---------------------------------------------------------------------------------------------------