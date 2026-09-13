---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.4.2
---------------------------------------------------------------------------------------------------

require "shared.all-stages"

if script.active_mods[MOD_NAME].version == "2.4.2" then
    game.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    game.print("  v2.4.2: The default values of the settings have been changed! The currently")
    game.print("  selected values should not have been changed, since they are player-owned.")
end

---------------------------------------------------------------------------------------------------
