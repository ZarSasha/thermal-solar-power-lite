---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.4.2
---------------------------------------------------------------------------------------------------

require "shared.all-stages"

if storage.calc                 == nil then storage.calc                 =             {} end
if storage.calc.tick_frequency  == nil then storage.calc.tick_frequency  =              1 end
if storage.calc.base_temp_gain  == nil then storage.calc.base_temp_gain  =           2.32 end
if storage.calc.base_temp_loss  == nil then storage.calc.base_temp_loss  =           0.75 end

if script.active_mods[MOD_NAME].version == "2.4.2" then
    game.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    game.print("  v2.4.2: The default values of the settings have been changed! Note that")
    game.print("  the current values haven't been changed, since they are player-owned.")
end

---------------------------------------------------------------------------------------------------
