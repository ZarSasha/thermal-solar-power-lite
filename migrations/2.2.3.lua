---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- New storage variables:
storage.panels.main_register  = storage.panels.main or {}
storage.panels.removal_flag   = false
storage.surfaces              = {}
storage.surfaces.solar_mult   = {} -- filled below
storage.cycle                 = {}
storage.cycle.batch_size      = storage.panels.batch_size or 1
storage.cycle.progress        = storage.panels.progress or 1
storage.cycle.complete        = storage.panels.complete or false

for name, surface in pairs(game.surfaces) do
    storage.surfaces.solar_mult[name] = 1 -- temporary value, to keep things simple
end

-- Removed storage variables:
storage.panels.main           = nil
storage.panels.to_be_removed  = nil -- <- any remaining, invalid panels will be detected
storage.panels.batch_size     = nil --    in the next cycle, so no worries.
storage.panels.progress       = nil
storage.panels.complete       = nil
storage.platforms.solar_power = nil
storage.platforms             = nil

-- * 

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------

-- Development note: New storage variables that were created during development and later
-- abandonded may actually remain if a game is saved while that version is active. They have to be
-- actively deleted! Some examples are: thermal_panels, q_scaling, heat_loss_X, temp_gain.

-- General note: This and the earlier migration script *should* be complete, so the above doesn't
-- happen with any of the variables that exist with released versions of the mod. Else, the "reset"
-- command can help clear out storage completely from this version onwards.