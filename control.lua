---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┳┓┏┳┓┳┓┏┓┓ 
--  ┃ ┃┃┃┃ ┃ ┣┫┃┃┃ 
--  ┗┛┗┛┛┗ ┻ ┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
-- This code provides scripts for heat generation from sunlight + a makeshift sunlight indicator
-- for the Thermal Solar Panels. Contains various command functions as well.
---------------------------------------------------------------------------------------------------
require "util"
require "functions"
require "shared.all-stages"
---------------------------------------------------------------------------------------------------
-- STORAGE TABLE CREATION
---------------------------------------------------------------------------------------------------

-- Creates keys for storage table that will be needed by scripts.
local function create_storage_table_keys()
    if storage.thermal_panels == nil then storage.thermal_panels = {}    end
    if storage.temp_gain      == nil then storage.temp_gain      = 2.1   end
    if storage.heat_loss_X    == nil then storage.heat_loss_X    = 0.005 end
    if storage.q_scaling      == nil then storage.q_scaling      = 0.15  end
end

-- Names of entities that should be registered into storage.thermal_panels when they are created.
local LIST_thermal_panels = {
    "tspl-thermal-solar-panel",
    "tspl-thermal-solar-panel-large"
}

---------------------------------------------------------------------------------------------------
-- ENTITY REGISTRATION/UNREGISTRATION
---------------------------------------------------------------------------------------------------

-- Function to add entity to storage table when it is created.
local function register_entity(entity_types, storage_table, event)
    --create_storage_table_keys()
    local entity = event.entity or event.destination
    if not table_contains_value(entity_types, entity.name) then return end
    storage_table[entity.unit_number] = entity
end

-- Function to remove entity from storage table when it is mined or destroyed.
local function unregister_entity(entity_types, storage_table, event)
    --if storage.thermal_panels == nil then return end
    local entity = event.entity
    if not table_contains_value(entity_types, entity.name) then return end
    storage_table[entity.unit_number] = nil
end

-- Function to remove entities from storage table, when their surface is cleared/deleted.
local function unregister_surface_entities(entity_types, storage_table, event)
    --if storage.thermal_panels == nil then return end
    local surface = game.surfaces[event.surface_index]
    local found_entities = {}
    for _, searched_entity in pairs(surface.find_entities_filtered{name = entity_types}) do
        table.insert(found_entities, searched_entity)
    end
    for _, found_entity in pairs(found_entities) do
        storage_table[found_entity.unit_number] = nil
    end
end

-- v2.1.6: Won't check for presence of storage table, since that may simply hide bugs. Anyway, the
-- code seems robust and the reset command can still be used as a backup solution.

---------------------------------------------------------------------------------------------------
-- MAIN SCRIPT FUNCTIONS
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
    -- HEAT GENERATION
---------------------------------------------------------------------------------------------------

-- Unchanging parameters.
local ambient_temp = 15    -- Default ambient temperature.
local light_const  = 0.85  -- Highest level of "surface darkness" (default range: 0-0.85).

-- Precalculates and caches variables for on-tick script, provides compatibility for various mods.
local function precalculate_and_cache_results_for_on_tick_script()
    -- COMPATIBILITY: Pyanodon Coal Processing --
    local temp_gain_base = SETTING.panel_output_kW / 50 -- Default heat capacity: 50kJ
    if script.active_mods["pycoalprocessing"] and SETTING.select_mod == "Pyanodon" then
        -- Increases temp gain to overcome heat loss at 250°C as well as it would at 165°C:
        storage.temp_gain = temp_gain_base + 0.425
        -- Also decreases heat loss rate by roughly the same factor:
        storage.heat_loss_X = 0.005 - 0.0018
    else
        storage.temp_gain = temp_gain_base
        storage.heat_loss_X = 0.005
    end
    -- Note: Heat capacity is also increased at the prototype stage.

    -- COMPATIBILITY: More Quality Scaling --
    if script.active_mods["more-quality-scaling"] then
        if not address_not_nil(prototypes.mod_data["entity-clones"].data) then return end
        local thermal_panels = LIST_thermal_panels
        for _, panel in pairs(thermal_panels) do
            for _, panel_clone in pairs(prototypes.mod_data["entity-clones"].data[panel] or {}) do
                table.insert(LIST_thermal_panels, panel_clone)
            end
        end
        storage.q_scaling = 0    -- accounts for increased heat capacity (30% pr. quality level)
    else
        storage.q_scaling = 0.15 -- tuned to roughly match scaling of solar panels.
    end
    -- Note: No need to check for presence of Quality from Space Age DLC. Game handles quality
    -- property just fine, even if DLC is not installed.
end

-- Heat generation: Adds heat in proportion to sunlight, removes some in proportion to temperature
-- difference. Adjusted for quality and solar intensity. Fairly complex, somewhat high UPS impact.
local function update_panel_temperature()
    --if storage.thermal_panels == nil then return end -- for easier testing
    for _, panel in pairs(storage.thermal_panels) do
        if not panel.valid then goto continue end
        local q_factor    = 1 + (panel.quality.level * storage.q_scaling)
        local light_corr  = (light_const - panel.surface.darkness) / light_const
        local sun_mult    = panel.surface.get_property("solar-power")/100
        local temp_loss   = (panel.temperature - ambient_temp) * storage.heat_loss_X
        panel.temperature =
            panel.temperature + storage.temp_gain * light_corr * sun_mult * q_factor - temp_loss
        ::continue::
    end
end

---------------------------------------------------------------------------------------------------
    -- MAKESHIFT SUNLIGHT INDICATOR
---------------------------------------------------------------------------------------------------

-- Sunlight indicator: Activates by clearing and inserting new solar-fluid (on GUI opened).
local function activate_sunlight_indicator(entity)
    if entity == nil then return end -- checks that GUI is associated with an entity!
    if not table_contains_value(LIST_thermal_panels, entity.name) then return end
    --removes solar-fluid, if any:
    entity.clear_fluid_inside()
    --inputs solar-fluid:
    local light_corr = (light_const - entity.surface.darkness) / light_const
    if light_corr <= 0 then return end
    local amount = 100.01 * light_corr -- Slight increase fixes 99.9/100 indication
    entity.insert_fluid{
        name        = "tspl-solar-fluid",
        amount      = amount, -- 0-100 scale, entity buffer adjusted to fit exactly
        temperature = amount  -- matched to above, to somewhat reduce confusion
    }
end

-- Sunlight indicator: Deactivates by removing solar-fluid (on GUI closed).
local function deactivate_sunlight_indicator(entity)
    if entity == nil then return end -- same as above
    if not table_contains_value(LIST_thermal_panels, entity.name) then return end
    entity.clear_fluid_inside()
end

---------------------------------------------------------------------------------------------------
-- DEBUG: RESET FUNCTIONS (rarely if ever needed)
---------------------------------------------------------------------------------------------------

-- Function to search on all surfaces for entities from a name list, returning an array.
local function search_for_entities(entity_types)
    local found_entities = {}
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{name = entity_types}) do
            table.insert(found_entities, entity)
        end
    end
    return found_entities
end

-- Function to rebuild contents of a storage table. Also resets makeshift sunlight indicator
-- (in case gui is left open for some reason, but it's a trivial problem).
local function rebuild_entity_ID_list(entity_types, storage_table)
    table_clear_content(storage_table)
    local found_entities = search_for_entities(entity_types)
    for _, found_entity in pairs(found_entities) do
        storage_table[found_entity.unit_number] = found_entity
        found_entity.clear_fluid_inside()
    end
end

---------------------------------------------------------------------------------------------------
-- FINAL FUNCTION SETS AND SCRIPT EXECUTION
---------------------------------------------------------------------------------------------------

-- Function set to run when an entity is built.
script.on_event({
    defines.events.on_built_entity,                 -- event.entity
    defines.events.on_robot_built_entity,           -- event.entity
    defines.events.on_space_platform_built_entity,  -- event.entity
    defines.events.script_raised_built,             -- event.entity
    defines.events.script_raised_revive,            -- event.entity
    defines.events.on_entity_cloned                 -- event.destination (not a normal event) *
    -- * Event is raised for every single entity created from cloned area as well.
},  function(event)
    register_entity(LIST_thermal_panels, storage.thermal_panels, event)
end)

-- Function set to run when an entity is mined or destroyed in various ways.
script.on_event({
    defines.events.on_pre_player_mined_item,    -- *
    defines.events.on_robot_pre_mined,          -- *
    defines.events.on_space_platform_pre_mined, -- *
    defines.events.on_entity_died,
    defines.events.script_raised_destroy
    -- * Pre-stage needed to unregister entity from storage table before entity is removed.
},  function(event)
    unregister_entity(LIST_thermal_panels, storage.thermal_panels, event)
end) 

-- Function set to run when a surface is cleared or destroyed (not a normal event).
script.on_event({
    defines.events.on_pre_surface_cleared, -- *
    defines.events.on_pre_surface_deleted  -- *
    -- * Pre-stage needed to unregister entities from storage table before entities are removed.
},  function(event)
    unregister_surface_entities(LIST_thermal_panels, storage.thermal_panels, event)
end) 

-- Function set to run perpetually with a given frequency (60 ticks = 1 second interval).
script.on_event({defines.events.on_tick}, function(event)
    if event.tick % 60 == 0 then update_panel_temperature() end
end)

-- Function set to run when a GUI is opened.
script.on_event({defines.events.on_gui_opened}, function(event)
    activate_sunlight_indicator(event.entity)
end)

-- Function set to run when a GUI is closed.
script.on_event({defines.events.on_gui_closed}, function(event)
    deactivate_sunlight_indicator(event.entity)
end)

-- Function set to run on new save game, or load of save game that did not contain mod before.
script.on_init(function()
    create_storage_table_keys()
    precalculate_and_cache_results_for_on_tick_script()
    rebuild_entity_ID_list(LIST_thermal_panels, storage.thermal_panels) -- *
    -- * Just in case a personal fork with a new name is loaded in the middle of a playthrough.
end)

-- Function set to run on any change to startup settings or mods installed.
script.on_configuration_changed(function()
    create_storage_table_keys() -- For mod update to work.
    precalculate_and_cache_results_for_on_tick_script()
    rebuild_entity_ID_list(LIST_thermal_panels, storage.thermal_panels) -- *
    -- * In case any clones (like from More Quality Scaling) are removed from the game.
end)

---------------------------------------------------------------------------------------------------
-- CONSOLE COMMANDS
---------------------------------------------------------------------------------------------------
-- Execute a command by typing "/tspl " into the console, along with a parameter. Useful for
-- getting some basic info, and for debugging.

-- HELPER FUNCTIONS -------------------------------------------------------------------------------

-- Searches on all surfaces for entities from a list, returning the total number.
local function search_and_count_entities(entity_types)
    local total_count = 0
    for _, surface in pairs(game.surfaces) do
        local sub_count = surface.count_entities_filtered{name = entity_types}
        total_count = total_count + sub_count
    end
    return total_count
end

-- Prints multiple lines from an array, slightly indented to differentiate from header.
local function mPrint(player, console_lines)
    for _, line in ipairs(console_lines) do player.print("  "..line) end
end

-- Colors text.
local function clr(text, colorIndex)
    colors = {"66B2FF", "FFB266"} -- custom hues of blue and orange (easier to read)
    return "[color=#"..colors[colorIndex].."]"..text.."[/color]"
end

-- COMMAND PARAMETERS -----------------------------------------------------------------------------

-- Table to be populated with functions, each with a name matching a command parameter.
local COMMAND_parameters = {}

-- "help": Describes the most important console commands or groups thereof.
COMMAND_parameters.help = function(pl)
    mPrint(pl, {
        clr("info",1)..": Provides very basic info for now.",
        clr("debug",1)..": Provides info on available debug functions."
    })
end

-- "info": Provides some info about the thermal solar panels on the current surface.
COMMAND_parameters.info = function(pl)
    local sun_level = pl.surface.get_property("solar-power")
    --local max_temp  = ambient_temp + (((temp_gain - 0.75) * (sun_level/100)) / PANEL.heat_loss_factor)
    mPrint(pl, {
        "Solar intensity on this surface ("..clr(pl.surface.name,2)..") is "
      ..clr(sun_level.."%",2)..".",
      --[[
        "Thermal Panel temperature limit at constant sunlight is "
      ..clr(round_number(max_temp, 1),2).."°C due to heat loss, capped at "
      ..clr(PANEL.max_temp,2).."°C!"
      ]]
    })
end

-- DEBUG "debug": Describes the function of command parameters used for debugging.
COMMAND_parameters.debug = function(pl)
    mPrint(pl, {
        clr("check",1)..": Checks for existence of thermal panel ID list within storage and makes "
        .."a count.",
        clr("reset",1)..": Rebuilds the thermal panel ID list within storage. Resets the sunlight "
        .."indicator as well.",
        clr("clear",1)..": Clears the thermal panel ID list within storage of its content.",
        clr("delete",1)..": Entirely deletes the thermal panel ID list within storage.",
        clr("unlock",1)..": Forcefully unlocks all content from this mod, circumventing research."
    })
end

-- DEBUG "check": Checks if thermal panel ID list exists, provides entity count.
COMMAND_parameters.check = function(pl)
    local count1 = search_and_count_entities(LIST_thermal_panels)
    if storage.thermal_panels ~= nil then
        local count2 = table_length(storage.thermal_panels)
        mPrint(pl, {
            "The thermal panel ID list exists.",
            "Thermal panel entity count on all surfaces / registered within storage table: "
          ..clr(count1,2).." / "..clr(count2,2)..".",
        })
    else
        mPrint(pl, {
            "The thermal panel ID list does not exist within the storage table.",
            "Thermal panel entity count on all surfaces: "..clr(count1,2).."."
        })
    end
end

-- DEBUG "reset": Rebuilds thermal panel ID list, recalculates cached values, resets make-shift
-- sunlight indicator.
COMMAND_parameters.reset = function(pl)
    create_storage_table_keys()
    precalculate_and_cache_results_for_on_tick_script()
    rebuild_entity_ID_list(LIST_thermal_panels, storage.thermal_panels)
    mPrint(pl, {
        "The thermal panel ID list within storage was reset and rebuild.",
        "Any solar-fluid remaining in thermal panels was removed as well."
    })
end

-- DEBUG "clear": Clears thermal panel ID list of its content, if it exists.
COMMAND_parameters.clear = function(pl)
    if storage.thermal_panels ~= nil then
        table_clear_content(storage.thermal_panels)
        mPrint(pl, {
            "The thermal panel ID list within storage was cleared!"})
    else
        mPrint(pl, {
            "There was no thermal panel ID list within storage to clear!"})
    end
end

-- DEBUG "delete": Deletes thermal panel ID list, if it exists. Crashes the game unless
-- nil checks are added to various script functions above (they are commented out).
COMMAND_parameters.delete = function(pl)
    if storage.thermal_panels ~= nil then
        storage.thermal_panels = nil
        mPrint(pl, {
            "The thermal panel ID list within storage was deleted! Crash incoming!"})
    else
        mPrint(pl, {
            "The thermal panel ID list within storage already does not exist!"})
    end
end

-- DEBUG "unlock": Attempts to forcefully unlock recipes for all items from this mod.
COMMAND_parameters.unlock = function(pl)
    local items, icons = {"tspl-thermal-solar-panel","tspl-thermal-solar-panel-large",
        "tspl-basic-heat-exchanger", "tspl-basic-heat-pipe"}, {}
    for _,item in pairs(items) do
        pl.force.recipes[item].enabled=true
        pl.force.recipes[item].hidden=false
        table.insert(icons, "[img=item."..item.."]")
    end
    mPrint(pl, {
        "Recipes for all entities from this mod ( "..table.concat(icons," ").." ) were "
      .."forcefully unlocked (hopefully)!"
    })
end

-- CONSOLE COMMANDS -------------------------------------------------------------------------------

local function new_commands(command)
    local pl1 = game.get_player(command.player_index)
    if pl1 == nil then return end -- needed?
    pl1.print("[color=acid]Thermal Solar Power (Lite):[/color]")
    if not table_contains_key(COMMAND_parameters, command.parameter) then
        mPrint(pl1, {"Write \"/tspl help\" for an overview of command parameters."})
        return
    end
    COMMAND_parameters[command.parameter](pl1)
end

commands.add_command("tspl", nil, new_commands) -- no help text, provided above instead

---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------