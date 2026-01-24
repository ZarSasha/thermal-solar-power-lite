---------------------------------------------------------------------------------------------------
-- MIGRATIONS FOR V2.2.3
---------------------------------------------------------------------------------------------------

-- New storage variables:
storage.panels.main_register  = storage.panels.main or {}
storage.panels.removal_flag   = false
storage.surfaces              = {}
storage.surfaces.solar_mult   = {} -- filled below
storage.cycle                 = {}
storage.cycle.batch_size      = storage.panels.batch_size or 3
storage.cycle.progress        = storage.panels.progress or 1
storage.cycle.complete        = storage.panels.complete or false

for name, surface in pairs(game.surfaces) do
    storage.surfaces.solar_mult[name] = 1 -- temporary value, to keep things simple
end

-- Removed storage variables:
if storage.panels then
    if storage.panels.main           then storage.panels.main           = nil end
    if storage.panels.to_be_removed  then storage.panels.to_be_removed  = nil end -- *
    if storage.panels.batch_size     then storage.panels.batch_size     = nil end
    if storage.panels.progress       then storage.panels.progress       = nil end
    if storage.panels.complete       then storage.panels.complete       = nil end
end
if storage.platforms then
    if storage.platforms.solar_power then storage.platforms.solar_power = nil end
    storage.platforms = nil
end

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------

-- * Any remaining, invalid panels will be detected in the next cycle, so no worries.

-- Development note: New storage variables that were created during development and later
-- abandonded may actually remain if a game is saved while that version is active. They have to be
-- actively deleted! Some examples are: thermal_panels, q_scaling, heat_loss_X, temp_gain.

-- General note: This and the earlier migration script *should* be complete, so the above doesn't
-- happen with any of the variables that exist with released versions of the mod. Else, the "reset"
-- command can help clear out storage completely from this version onwards.