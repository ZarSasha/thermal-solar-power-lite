---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.4.2
---------------------------------------------------------------------------------------------------

require "shared.all-stages"

if script.active_mods[MOD_NAME].version == "2.4.2" then
    game.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    game.print("  v2.4.2: The default values of the settings have been changed! Note that")
    game.print("  the current values haven't been changed, since they are player-owned.")
end

---------------------------------------------------------------------------------------------------
