---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- Obsolete storage variable (assumed to be garbage collected).
storage.panels.to_be_removed = nil
storage.platforms.solar_power = nil
storage.platforms = nil

-- New storage variables:
storage.panels.removed_flag  = false
storage.surfaces             = {}
storage.surfaces.solar_power = {}

for name, _ in pairs(game.surfaces) do
    storage.surfaces.solar_power[name] = 100 -- just a temporary value
end

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------
