---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------
-- The new time slicing feature needs several variables to be stored within the storage table. The
-- main table that holds the string identifiers also needs to replaced with a simple array
-- (contiguous indexed table).

-- Transfer of data from storage table to new variable:
if storage.tspl_thermal_panel_table ~= nil then
    -- Extracts values from table and copies them into new array in storage:
    for _, v in pairs(storage.tspl_thermal_panel_table) do
        table.insert(storage.panels.main, v)
    end
    -- Deletes old table in storage:
    table_clear(storage.tspl_thermal_panel_table)
    storage.tspl_thermal_panel_table = nil
    -- Writes to log (factorio-current.log in hidden AppData/Roaming/Factorio folder)
    log(
        "Migrated data from table: 'storage.tspl_thermal_panel_table' "
      .."to new array: 'storage.panels.main'."
    )
end

-- Message:
local pl = game.player
if script.active_mods[MOD_NAME] == "2.2.0" then
    pl.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    pl.print("  Regarding update to v2.2.0: Make sure to read the changelog!")
    pl.print("  If panels don't work, please report the issue on the Mod Portal.")
    pl.print("  Writing '/tspl reset' in the console may resolve the issue quickly.")
end

---------------------------------------------------------------------------------------------------