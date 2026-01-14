---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.0
---------------------------------------------------------------------------------------------------
-- The new time slicing feature needs several variables to be stored within the storage table. The
-- main table that holds the string identifiers also needs to be replaced with a simple array.

-- New storage table variables:
if storage.panels               == nil then storage.panels               =    {} end
if storage.panels.main          == nil then storage.panels.main          =    {} end
if storage.panels.to_be_added   == nil then storage.panels.to_be_added   =    {} end
if storage.panels.to_be_removed == nil then storage.panels.to_be_removed =    {} end
if storage.panels.batch_size    == nil then storage.panels.batch_size    =    10 end
if storage.panels.progress      == nil then storage.panels.progress      =     1 end
if storage.panels.complete      == nil then storage.panels.complete      = false end

-- Transfer of data from old storage variable to new one:
if storage.tspl_thermal_panel_table ~= nil then
    for _, v in pairs(storage.tspl_thermal_panel_table) do
        table.insert(storage.panels.main, v)
    end
    table_clear(storage.tspl_thermal_panel_table)
    storage.tspl_thermal_panel_table = nil
    log(
        "Migrated data from table: 'storage.tspl_thermal_panel_table' "
      .."to new array: 'storage.panels.main'."
    )
end

-- Message to console:
game.print("[color=acid]Thermal Solar Power (Lite):[/color]")
game.print("  Regarding update to v2.2.0: It is recommended to read the changelog!")
game.print("  If panels don't work, please report the issue on the Mod Portal or on GitHub.")
game.print("  However, writing '/tspl reset' in the console should quickly resolve any issues.")

---------------------------------------------------------------------------------------------------
-- END NOTES:
---------------------------------------------------------------------------------------------------