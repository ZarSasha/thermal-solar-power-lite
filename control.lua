---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┳┓┏┳┓┳┓┏┓┓ 
--  ┃ ┃┃┃┃ ┃ ┣┫┃┃┃     RUNTIME STAGE
--  ┗┛┗┛┛┗ ┻ ┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
-- This code provides a script for heat generation from sunlight, a makeshift sunlight indicator
-- for the Thermal Solar Panels, as well as various command functions (one provides information,
-- the rest are used for debugging). The heat script uses time slicing to distribute calculations
-- across many game ticks. Also works with space platforms in Space Age.
---------------------------------------------------------------------------------------------------
require "functions"
require "shared.all-stages"
---------------------------------------------------------------------------------------------------
-- THERMAL SOLAR PANEL HEAT GENERATION
---------------------------------------------------------------------------------------------------

-- The shared string component of all thermal panel names, including those of any clones:
local panel_name_base = "tspl-thermal-solar-panel"

-- Frequency with which on-tick scripts will run (the game runs at 60 ticks/s).
local tick_interval = 15
local tick_frequency = (tick_interval/60)
local reserved_ticks = 2

-- Environmental parameters (set by game):
local env = {
    light_const  = 0.85, -- Highest level of "surface darkness" (default range: 0-0.85)
    ambient_temp = 15    -- Default ambient temperature
}

-- Parameters pertaining to the thermal solar panels:
local panel_param = {
    heat_cap_kJ      = 50,    -- default value, will not change
    temp_loss_factor = 0.005, -- updated during startup
    quality_scaling  = 0.15   -- updated during startup
}

---------------------------------------------------------------------------------------------------
    -- MOD CHECK AND COMPATIBILITY
---------------------------------------------------------------------------------------------------

-- Checks for presence of mods through independent script (no need to tie to event).
local ACTIVE_MODS = {
    SPACE_AGE            = script.active_mods["space-age"],
    PY_COAL_PROCESSING   = script.active_mods["pycoalprocessing"],
    MORE_QUALITY_SCALING = script.active_mods["more-quality-scaling"]
}

-- Test
if ACTIVE_MODS.SPACE_AGE then
    panel_param.heat_cap_kJ = 1000000
end

-- Pyanodon Coal Processing:
if ACTIVE_MODS.PY_COAL_PROCESSING and SETTING.select_mod == "Pyanodon" then
    -- Decreases heat loss rate to allow similar efficiency at 250°C (compared to 165°C).
    -- Also accounts for doubled heat capacity of panels, which keeps temperatures higher
    -- during night and thus slightly increases heat energy loss.
    panel_param.temp_loss_factor = 0.00314 -- "correct" value: 0.0031915
end
-- More Quality Scaling:
if ACTIVE_MODS.MORE_QUALITY_SCALING and table_contains_value(
    {"capacity", "both"}, settings.startup["mqs-heat-changes"].value) then
    -- Nullifies quality scaling factor, since heat capacity scales instead (30% pr. level):
    panel_param.quality_scaling = 0
end

---------------------------------------------------------------------------------------------------
    -- STORAGE TABLE CREATION (ON_INIT AND ON_CONFIGURATION_CHANGED)
---------------------------------------------------------------------------------------------------
-- Values that are not easy or fast to recalculate on the spot should be stored so they can persist
-- through the save/load cycle. All variables below are needed for the heat-generating script.

-- Function to create variables for the storage table, if they do not yet exist.
local function create_storage_table_keys()
    if storage.panels               == nil then storage.panels               =    {} end
    if storage.panels.main          == nil then storage.panels.main          =    {} end
    if storage.panels.to_be_added   == nil then storage.panels.to_be_added   =    {} end
    if storage.panels.to_be_removed == nil then storage.panels.to_be_removed =    {} end
    if storage.panels.batch_size    == nil then storage.panels.batch_size    =    10 end
    if storage.panels.progress      == nil then storage.panels.progress      =     1 end
    if storage.panels.complete      == nil then storage.panels.complete      = false end
    if storage.surfaces             == nil then storage.surfaces             =    {} end
    if storage.surfaces.solar_power == nil then storage.surfaces.solar_power =    {} end
end

---------------------------------------------------------------------------------------------------
    -- ENTITY REGISTRATION (ON_BUILT AND SIMILAR)
---------------------------------------------------------------------------------------------------
-- When a thermal panel is built by any method, a string identifier* used as a reference will be
-- added to a temporary array in storage. At the end of the cycle, it will be registered into the
-- main array, which the heat generating script relies on.

-- Function to register entity string ID into temporary "to_be_added" array in storage.
local function register_panel_entity(event)
    local panels = storage.panels
    local entity = event.entity or event.destination
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    table.insert(panels.to_be_added, entity)
end

-- Note: An entity will simply be deregistered when found to be invalid during an update cycle
-- (the string ID is added to a temporary array and then later removed from the main array).

-- * A string ID is used to reference a Lua object and gain access to its properties. Example:
--   "[LuaEntity: tspl-thermal-solar-panel at [gps=10.5,2.5,nauvis]]"

---------------------------------------------------------------------------------------------------
    -- PANEL ENTITY REGISTER UPDATE (ON_TICK SCRIPT, RUNS PERIODICALLY)
---------------------------------------------------------------------------------------------------
-- To keep the main array intact during a cycle that spans several game ticks, changes have to be
-- stored temporarily before being used to update the main array.

-- Function to update contents of "main" array and adjust process batch size for the next cycle:
local function update_panel_storage_register()
    local panels = storage.panels
    -- Updates main array, clears temporary arrays:
    array_append_elements(panels.main, panels.to_be_added)
    array_remove_elements(panels.main, panels.to_be_removed)
    table_clear(panels.to_be_added)
    table_clear(panels.to_be_removed)
    -- Resets status for completion of cycle, calculates batch size for the next one
    -- (panels are processed on ticks that are not reserved for other purposes):
    panels.complete   = false
    panels.batch_size = math.ceil(#panels.main / ((tick_interval - reserved_ticks - 1)))
    -- Note: One additional tick reserved for detecting that traversal was completed.
end

---------------------------------------------------------------------------------------------------
    -- SURFACE SOLAR POWER CALCULATION (MAINLY ON_TICK SCRIPT, RUNS PERIODICALLY)
---------------------------------------------------------------------------------------------------
-- Script for calculating and caching solar power for all surfaces, including those of platforms.

local function calculate_solar_power_for_surface(name, surface)
    local platform = surface.platform
    -- Just retrieves solar power property if surface does not belong to a platform:
    if not platform then
        storage.surfaces.solar_power[name] = surface.get_property("solar-power")/100
        return
    end
    -- Retrieves or calculates solar power for platform depending on location:
    if platform.space_location then -- if stationed (orbiting planet)
        storage.surfaces.solar_power[name] =
            platform.space_location.solar_power_in_space/100
    elseif platform.space_connection then -- if in transit
        local solar_power_start = platform.space_connection.from.solar_power_in_space
        local solar_power_stop  = platform.space_connection.to.solar_power_in_space
        local distance          = platform.distance -- 0 to 1
        storage.surfaces.solar_power[name] =
            (solar_power_start - (solar_power_start - solar_power_stop) * distance)/100
    else
        log("Error! Could not identify solar power for space platform.")
    end
end

-- Function to calculate and store solar power for all surfaces.
local function calculate_solar_power_for_all_surfaces()
    for name, surface in pairs(game.surfaces) do
        calculate_solar_power_for_surface(name, surface)
    end
end

---------------------------------------------------------------------------------------------------
    -- SURFACE DEREGISTRATION (ON_PRE_SURFACE_DELETED)
---------------------------------------------------------------------------------------------------

-- Function to deregister a surface from storage table upon deletion (just to prevent bloat).
local function deregister_surface(event)
    local surface_name = game.surfaces[event.surface_index].name
    storage.surfaces.solar_power[surface_name] = nil
end

---------------------------------------------------------------------------------------------------
    -- HEAT GENERATION (ON_TICK SCRIPT, RUNS ON MOST TICKS)
---------------------------------------------------------------------------------------------------
-- Here is the main script that increases temperature of thermal panel in proportion to sunlight,
-- while decreases it in proportion to current temperature above ambient level. It has been
-- adjusted for quality and solar intensity, and has compatibility for some mods.

-- Function to update temperature of all thermal panels according to circumstances. Adapted for
-- time slicing. Generally writes to storage as little as possible, for better performance.
local function update_panel_temperature()
    local panels     = storage.panels    -- table reference
    local surfaces   = storage.surfaces
    local batch_size = panels.batch_size -- number copy
    local progress   = panels.progress   -- number copy
    for i = progress, progress + batch_size - 1 do
        local panel = panels.main[i]
        -- Marks cycle as completed when there are no more array entries to go through:
        if panel == nil then
            panels.complete = true
            break
        end
        -- Marks entry for deregistration and skips it, if not valid:
        if not panel.valid then
            table.insert(panels.to_be_removed, panel)
            goto continue
        end
        -- Calculates and applies temperature change to panel:
        local q_factor    = 1 + (panel.quality.level * panel_param.quality_scaling)
        local light_corr  = (env.light_const - panel.surface.darkness) / env.light_const
        local sun_mult    = surfaces.solar_power[panel.surface.name] -- nil -> crash
        local temp_gain   =
            ((SETTING.panel_output_kW * tick_frequency) / panel_param.heat_cap_kJ) *
            light_corr * sun_mult * q_factor
        local temp_loss   =
             (panel_param.temp_loss_factor * tick_frequency) *
             (panel.temperature - env.ambient_temp)
        panel.temperature = panel.temperature + temp_gain - temp_loss
        ::continue::
    end
    -- Stores current progress if cycle is not yet finished, otherwise resets:
    panels.progress = panels.complete and 1 or progress + batch_size
end

-- Note: If the number of panels perfectly match batch size, an extra cycle will be needed to tell
-- that the array has been fully traversed. Find better solution than providing an extra tick?

---------------------------------------------------------------------------------------------------
    -- MAKESHIFT SUNLIGHT INDICATOR (ON_GUI_OPENED/ON_GUI_CLOSED)
---------------------------------------------------------------------------------------------------
-- Script that emulates a solar level indicator by filling the panel with a custom fluid when the
-- gui is opened, and removing it again when the gui is closed.

-- Function to clear fluid content and then insert new solar-fluid (on GUI opened).
local function activate_sunlight_indicator(event)
    local entity = event.entity
    if entity == nil then return end -- checks that GUI is associated with an entity!
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    entity.clear_fluid_inside()
    local light_corr =
        (env.light_const - entity.surface.darkness) / env.light_const
    if light_corr <= 0 then return end
    local amount = 100.01 * light_corr -- Slight increase fixes 99.9/100 indication
    entity.insert_fluid{
        name        = "tspl-solar-fluid",
        amount      = amount, -- 0-100 scale, entity buffer adjusted to fit exactly
        temperature = amount  -- matched to above, to somewhat reduce confusion
    }
end

-- Function to remove solar-fluid (on GUI closed).
local function deactivate_sunlight_indicator(event)
    local entity = event.entity
    if entity == nil then return end -- same as above
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    entity.clear_fluid_inside()
end

---------------------------------------------------------------------------------------------------
    -- RESETTING (ON_INIT AND WITH RESET COMMAND)
---------------------------------------------------------------------------------------------------

-- Complete list of panel variants, including any clones.
local panel_variants = {}

-- Finds all panel variants (calculated by whatever function uses the variable right above).
for key, _ in pairs(prototypes.entity) do
    if string.find(key, panel_name_base, 1, true) then
        table.insert(panel_variants, key)
    end
end

-- Function to reset storage table. Rebuilds array of thermal panels and removes any solar-fluid;
-- rebuilds table of space platform names + current solar power.
local function reset_panels_and_platforms()
    -- Initializes storage variables just in case they are missing:
    create_storage_table_keys()
    -- Clears storage of all thermal panels and resets related values, then rebuilds contents:
    table_clear(storage.panels.main)
    table_clear(storage.panels.to_be_added)
    table_clear(storage.panels.to_be_removed)
    storage.panels.batch_size = 10
    storage.panels.progress   = 1
    storage.panels.complete   = false
    for _, surface in pairs(game.surfaces) do
        for _, panel in pairs(surface.find_entities_filtered{name = panel_variants}) do
            table.insert(storage.panels.main, panel)
            panel.clear_fluid_inside()
        end
    end
    -- Clears storage of all surfaces, then rebuilds contents.
    table_clear(storage.surfaces.solar_power)
    calculate_solar_power_for_all_surfaces()
end

---------------------------------------------------------------------------------------------------
    -- FINAL FUNCTION SETS AND SCRIPT EXECUTION
---------------------------------------------------------------------------------------------------

-- Function set to run when an entity is built.
script.on_event({
    defines.events.on_built_entity,                -- event.entity
    defines.events.on_robot_built_entity,          -- event.entity
    defines.events.on_space_platform_built_entity, -- event.entity
    defines.events.script_raised_built,            -- event.entity
    defines.events.script_raised_revive,           -- event.entity
    defines.events.on_entity_cloned                -- event.destination (not a normal event) *
    -- * Event is raised for every single entity created from cloned area as well.
},  function(event)
    register_panel_entity(event)
end)

-- Function set to run on surface deleted (triggers 5 minutes after a platform is marked for
-- deletion and immediately on platform destruction).
script.on_event({defines.events.on_pre_surface_deleted}, function(event)
    deregister_surface(event) -- just clean-up, not critical
end)

-- Function set to run perpetually with a given frequency.
script.on_event({defines.events.on_tick}, function(event)
    if event.tick % tick_interval == 0 then
        update_panel_storage_register()
    elseif event.tick % tick_interval == 1 then
        calculate_solar_power_for_all_surfaces()
    else
        if not storage.panels.complete then
            update_panel_temperature()
        end
    end
end)

-- Function set to run when a GUI is opened.
script.on_event({defines.events.on_gui_opened}, function(event)
    activate_sunlight_indicator(event)
end)

-- Function set to run when a GUI is closed.
script.on_event({defines.events.on_gui_closed}, function(event)
    deactivate_sunlight_indicator(event)
end)

-- Function set to run on new save game, or load of save game that did not contain mod before.
script.on_init(function()
    create_storage_table_keys() -- essential
    calculate_solar_power_for_all_surfaces()
    reset_panels_and_platforms() -- *
    -- * Just in case a personal fork with a new name is loaded in the middle of a playthrough.
end)

-- Function set to run on any change to startup settings or mods installed.
script.on_configuration_changed(function()
    create_storage_table_keys() -- maybe better to use migration when relevant
    calculate_solar_power_for_all_surfaces()
end)

-- Note: Overwriting code of mod without changing its name or version may break the scripts, since
-- it's not a detectable event. Running the reset command provided below may help.

---------------------------------------------------------------------------------------------------
-- CONSOLE COMMANDS
---------------------------------------------------------------------------------------------------
-- Execute a command by typing "/tspl " into the console, along with a parameter. Useful for
-- getting some basic info, and for debugging.

---------------------------------------------------------------------------------------------------
    -- HELPER FUNCTIONS FOR CONSOLE COMMANDS
---------------------------------------------------------------------------------------------------

-- Searches on all surfaces for entities from a list, returning the total number.
local function search_and_count_thermal_panels()
    local total_count = 0
    for _, surface in pairs(game.surfaces) do
        local sub_count = surface.count_entities_filtered{name = panel_variants}
        total_count = total_count + sub_count
    end
    return total_count
end

-- Prints multiple lines from an array, slightly indented to differentiate from header.
local function mPrint(player, console_lines)
    for _, line in pairs(console_lines) do
        if line ~= nil then player.print("  "..line) end
    end
end

-- Colors text.
local function clr(text, colorIndex)
    colors = {"66B2FF", "FFB366", "FF6666"} -- custom hues of blue, orange and red (easier to read)
    return "[color=#"..colors[colorIndex].."]"..text.."[/color]"
end

-- COMMAND PARAMETERS -----------------------------------------------------------------------------

-- Table to be populated with functions, each with a name matching a command parameter.
local COMMAND_parameters = {}

-- "help": Describes all console commands provides by this mod.
COMMAND_parameters.help = function(pl)
    mPrint(pl, {
        clr("info",1)..  ": Provides some helpful info relevant to the current surface.",
        clr("check",1).. ": Counts thermal panels on all surfaces and within storage.",
        clr("dump",1)..  ": Dumps contents of storage into log file.",
        clr("reset",1).. ": Rebuilds thermal panel ID list. Resets sunlight indicator as well.",
        clr("clear",1).. ": Clears the panel ID table of its contents.",
        clr("unlock",1)..": Forcefully unlocks all content from this mod, circumventing research."
    })
end

-- "info": Provides some info about the thermal solar panels on the current surface.
COMMAND_parameters.info = function(pl)
    calculate_solar_power_for_surface(pl.surface.name, pl.surface) -- just in case
    local sun_mult       = storage.surfaces.solar_power[pl.surface.name]
    local daylength_sec  = pl.surface.get_property("day-night-cycle")/60
    local temp_gain_day  = (SETTING.panel_output_kW / panel_param.heat_cap_kJ) * sun_mult
    local temp_adj       = SETTING.exchanger_temp - env.ambient_temp
    local temp_loss_day  = panel_param.temp_loss_factor * temp_adj
    local max_efficiency = (temp_gain_day - temp_loss_day) / temp_gain_day
    local max_output_kW  = SETTING.panel_output_kW * sun_mult * max_efficiency
    local nom_output_kW  = SETTING.panel_output_kW
    local panels_num     = SETTING.exchanger_output_kW / (max_output_kW)

    if ACTIVE_MODS.PY_COAL_PROCESSING and SETTING.select_mod == "Pyanodon" then
        panels_num = panels_num / 2
    end

    local console = {}

    console.surface_name        = clr(pl.surface.name,2)
    console.sun_mult            = clr(round_number(sun_mult * 100,2).."%",2)

    if daylength_sec ~= nil and daylength_sec > 0 then
        console.daylength_sec = clr(daylength_sec.." seconds",2)
    else
        console.daylength_sec = clr("N/A",2)
    end

    if max_output_kW >= 0 then
        console.panel_max_output_kW = clr(round_number(max_output_kW,2).."kW",2)
    else
        console.panel_max_output_kW = clr(round_number(max_output_kW,2).."kW",3) -- red color
    end

    console.panel_nom_output_kW = clr(round_number(nom_output_kW,2).."kW",2)

    if max_efficiency > 0 then
        console.panels_ratio = clr(round_number(panels_num, 2),2).." : "..clr("1",2)
    else
        console.panels_ratio = clr("N/A",2)
        console.note = "NB: Power production is entirely impossible on this surface!"
    end

    mPrint(pl, {
        "Surface name ID: "..console.surface_name..". "
      .."Solar intensity: "..console.sun_mult..". "
      .."Day cycle length: "..console.daylength_sec..".",
        "Panel maximum/nominal output: "
      ..console.panel_max_output_kW.." / "
      ..console.panel_nom_output_kW..".",
        "Ideal panel-to-exchanger ratio: "
      ..console.panels_ratio..".",
        console.note
    })
end

-- DEBUG "check": Counts number of thermal panels on all surfaces plus references within storage.
COMMAND_parameters.check = function(pl)
    mPrint(pl, {"Thermal solar panel entity count:"})
    local count1 = search_and_count_thermal_panels()
    mPrint(pl, {"  Found within world (all surfaces): "..clr(count1,2).."."})
    if storage.panels.main ~= nil then
        local count2 = table_length(storage.panels.main)
        mPrint(pl, {"  Registered within storage table: "..clr(count2,2).."."})
    end
end

-- DEBUG "reset": Resets contents of storage.
COMMAND_parameters.reset = function(pl)
    reset_panels_and_platforms()
    mPrint(pl, {
        "The storage table was reset!"
    })
end

-- DEBUG "clear": Clears storage variables related to panels and restores default values.
COMMAND_parameters.clear = function(pl)
    table_clear(storage.panels.main)
    table_clear(storage.panels.to_be_added)
    table_clear(storage.panels.to_be_removed)
    table_clear(storage.surfaces.solar_power)
    storage.panels.batch_size = 10
    storage.panels.progress   = 1
    storage.panels.complete   = false
    mPrint(pl, {
        "storage.panels' subtables were cleared of their contents or had values reset to default."
    })
end

-- DEBUG "unlock": Attempts to forcefully unlock and unhide recipes for all items from this mod.
COMMAND_parameters.unlock = function(pl)
    local items, icons = {"tspl-thermal-solar-panel","tspl-thermal-solar-panel-large",
        "tspl-basic-heat-exchanger", "tspl-basic-heat-pipe"}, {}
    for _,item in pairs(items) do
        pl.force.recipes[item].enabled=true
        pl.force.recipes[item].hidden=false
        table.insert(icons, "[img=item."..item.."]")
    end
    mPrint(pl, {
        "Recipes for all entities from this mod ( "..table.concat(icons," ").." )",
        "were forcefully unlocked and had their visibility restored (hopefully)!"
    })
end

-- DEBUG "dump": Dumps contents of storage table into log file (%APPDATA%/roaming/Factorio).
COMMAND_parameters.dump = function(pl)
    log("Mod Storage Contents: " .. serpent.block(storage, {comment=false}))
    mPrint(pl, {"Contents of storage was dumped to log file."})
end

-- CONSOLE COMMANDS -------------------------------------------------------------------------------

local function new_commands(command)
    local pl1 = game.get_player(command.player_index)
    if pl1 == nil then return end
    pl1.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    if not table_contains_key(COMMAND_parameters, command.parameter) then
        mPrint(pl1, {"Write '/tspl help' for an overview of command parameters."})
        return
    end
    COMMAND_parameters[command.parameter](pl1)
end

commands.add_command("tspl", nil, new_commands) -- no help text, provided above instead

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------