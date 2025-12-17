---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┳┓┏┳┓┳┓┏┓┓ 
--  ┃ ┃┃┃┃ ┃ ┣┫┃┃┃ 
--  ┗┛┗┛┛┗ ┻ ┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
-- This code provides a script for heat generation from sunlight, a makeshift sunlight indicator
-- for the Thermal Solar Panels, as well as various command functions (mostly for debugging). The
-- heat script uses time slicing to distribute calculations across many game ticks.
---------------------------------------------------------------------------------------------------
require "functions"
require "shared.all-stages"

---------------------------------------------------------------------------------------------------
-- THERMAL SOLAR PANEL SCRIPTS
---------------------------------------------------------------------------------------------------

-- The shared string component of all thermal panel names, including those of any clones:
local panel_name_base = "tspl-thermal-solar-panel"

-- Parameters shared by scripts:
local script_frequency = 20 -- 1 second = 60 ticks
local light_const      = 0.85 -- Highest level of "surface darkness" (default range: 0-0.85)

---------------------------------------------------------------------------------------------------
    -- STORAGE TABLE CREATION (ON INIT AND CONFIGURATION CHANGED)
---------------------------------------------------------------------------------------------------

-- Function to fill storage with variables needed for the heat-generating script.
local function create_storage_table_keys()
    if storage.panels               == nil then storage.panels               =    {} end
    if storage.panels.main          == nil then storage.panels.main          =    {} end
    if storage.panels.to_be_added   == nil then storage.panels.to_be_added   =    {} end
    if storage.panels.to_be_removed == nil then storage.panels.to_be_removed =    {} end
    if storage.panels.batch_size    == nil then storage.panels.batch_size    =    10 end
    if storage.panels.progress      == nil then storage.panels.progress      =     1 end
    if storage.panels.complete      == nil then storage.panels.complete      = false end
end

---------------------------------------------------------------------------------------------------
    -- THERMAL PANEL ENTITY REGISTRATION (ON BUILT AND SIMILAR)
---------------------------------------------------------------------------------------------------

-- Function to register entity string identifier into temporary "to_be_added" array in storage.
local function register_entity(event)
    local panels = storage.panels
    local entity = event.entity or event.destination
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    table.insert(panels.to_be_added, entity)
end

-- Note: Deregistration happens later when entity is discovered to be invalid. This is sufficient,
-- since no new scripts must run when entity is mined or otherwise removed.

---------------------------------------------------------------------------------------------------
    -- THERMAL PANEL CYCLICAL REGISTER UPDATE (ON TICK)
---------------------------------------------------------------------------------------------------

-- Function to update contents of "main" array and adjust process batch size for next cycle:
local function update_storage_register()
    local panels = storage.panels
    -- Updates main array, clears temporary arrays that keep track of change (this is done to
    -- prevent any change to array during loop):
    array_append_elements(panels.main, panels.to_be_added)
    array_remove_elements(panels.main, panels.to_be_removed)
    table_clear(panels.to_be_added)
    table_clear(panels.to_be_removed)
    -- Resets status for completion of cycle, calculates batch size for next cycle (batches are
    -- processed on no more than 59 of 60 ticks):
    panels.complete = false
    panels.batch_size = math.max(math.ceil(#panels.main / ((script_frequency - 1))),1)
end

---------------------------------------------------------------------------------------------------
    -- HEAT GENERATION (ON TICK)
---------------------------------------------------------------------------------------------------
-- Script that increases temperature of entity in proportion to sunlight, but also decreases it in
-- proportion to current temperature above ambient level. Adjusted for quality and solar intensity.
-- Fairly complex, somewhat high UPS impact at scale.

-- Various parameters:
local ambient_temp     = 15   -- Default ambient temperature
local base_heat_cap    = 50   -- Default panel heat capacity in kJ

-- Panel temperature gain pr. cycle, before loss:
local temp_gain     = (SETTING.panel_output_kW * (script_frequency / 60)) / base_heat_cap

-- Panel temperature loss pr. cycle, pr. degree above ambient temperature:
local heat_loss_X   = 0.005 * (script_frequency / 60)

-- Scaling of heat generation according to quality level:
local q_scaling     = 0.15  -- finetuned to roughly match scaling of solar panels

-- COMPATIBILITY: Pyanodon Coal Processing --
if script.active_mods["pycoalprocessing"] and SETTING.select_mod == "Pyanodon" then
    -- Decreases heat loss rate to allow similar efficiency at 250°C (compared to 165°C):
    heat_loss_X =  round_number(0.005 / ((250-ambient_temp)/(165-ambient_temp)), 4)
end

-- COMPATIBILITY: More Quality Scaling --
if script.active_mods["more-quality-scaling"] then
    -- Nullifies quality scaling factor, since heat capacity scales instead (30% pr. level):
    q_scaling = 0
end

-- Function to update temperature of all thermal panels according to circumstances. Incorporates
-- time slicing (distributes array iteration over up to 59 of 60 game ticks).
local function update_panel_temperature()
    local panels = storage.panels -- table, thus referenced
    for i = panels.progress, panels.progress + panels.batch_size - 1 do
        local panel = panels.main[i]
        -- Resets progress and prevents activation of function till next cycle,
        -- when there are no more entries to go through:
        if not panel then
            panels.progress = 1
            panels.complete = true
            return
        end
        -- Keeps track of progress:
        panels.progress = panels.progress + 1
        -- Marks entry for removal from storage table and skips it, if not valid:
        if not panel.valid then
            table.insert(panels.to_be_removed, panel)
            goto continue
        end
        -- Calculates and applies temperature change to panel:
        local q_factor    = 1 + (panel.quality.level * q_scaling)
        local light_corr  = (light_const - panel.surface.darkness) / light_const
        local sun_mult    = panel.surface.get_property("solar-power")/100
        local temp_loss   = (panel.temperature - ambient_temp) * heat_loss_X
        panel.temperature =
            panel.temperature + (temp_gain * light_corr * sun_mult * q_factor) - (temp_loss)
        ::continue::
    end
end

---------------------------------------------------------------------------------------------------
    -- MAKESHIFT SUNLIGHT INDICATOR (ON GUI OPENED/CLOSED)
---------------------------------------------------------------------------------------------------
-- Script that emulates a solar level indicator by filling entity with a custom fluid when the gui
-- is opened, and removing it again when gui is closed.

-- Function to clear fluid content and then insert new solar-fluid (on GUI opened).
local function activate_sunlight_indicator(entity)
    if entity == nil then return end -- checks that GUI is associated with an entity!
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    entity.clear_fluid_inside()
    local light_corr = (light_const - entity.surface.darkness) / light_const
    if light_corr <= 0 then return end
    local amount = 100.01 * light_corr -- Slight increase fixes 99.9/100 indication
    entity.insert_fluid{
        name        = "tspl-solar-fluid",
        amount      = amount, -- 0-100 scale, entity buffer adjusted to fit exactly
        temperature = amount  -- matched to above, to somewhat reduce confusion
    }
end

-- Function to remove solar-fluid (on GUI closed).
local function deactivate_sunlight_indicator(entity)
    if entity == nil then return end -- same as above
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    entity.clear_fluid_inside()
end

---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS (RESETTING, DEBUGGING, CONSOLE MESSAGES & COMMANDS) --
---------------------------------------------------------------------------------------------------

-- Complete list of panel variants, including any clones.
local panel_variants = {}

for key, _ in pairs(prototypes.entity) do
    if string.find(key, panel_name_base, 1, true) then
        table.insert(panel_variants, key)
    end
end

-- Function to clear and rebuild panel ID list within storage, as well as clear the panels of any
-- "solar-fluid" that may accidentally have remained for whatever reason.
local function reset_thermal_panels()
    local panels = storage.panels
    if panels.main == nil then
        panels.main = {}
    else
        table_clear(panels.main)
    end
    for _, surface in pairs(game.surfaces) do
        for _, panel in pairs(surface.find_entities_filtered{name = panel_variants}) do
            table.insert(panels.main, panel)
            panel.clear_fluid_inside()
        end
    end
end

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
    for _, line in ipairs(console_lines) do player.print("  "..line) end
end

-- Colors text.
local function clr(text, colorIndex)
    colors = {"66B2FF", "FFB266"} -- custom hues of blue and orange (easier to read)
    return "[color=#"..colors[colorIndex].."]"..text.."[/color]"
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
    register_entity(event)
end)

-- Function set to run perpetually with a given frequency.
script.on_event({defines.events.on_tick}, function(event)
    if event.tick % script_frequency == 3 then -- 1/60 ticks *
        update_storage_register() return
    end
    if storage.panels.complete then return end
    if event.tick % script_frequency ~= 3 then -- 59/60 ticks *
        update_panel_temperature()
    end
end) -- * Number different from 0, to reduce change of overlapping with scripts from other mods.

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
    reset_thermal_panels() -- *
    -- * Just in case a personal fork with a new name is loaded in the middle of a playthrough.
end)

-- Function set to run on any change to startup settings or mods installed.
script.on_configuration_changed(function()
    create_storage_table_keys()
end)

-- Note: Overwriting code of mod without changing its name or version may break the scripts, since
-- it's not a detectable event. Running the reset command provided below may help.

---------------------------------------------------------------------------------------------------
-- CONSOLE COMMANDS
---------------------------------------------------------------------------------------------------
-- Execute a command by typing "/tspl " into the console, along with a parameter. Useful for
-- getting some basic info, and for debugging.

-- COMMAND PARAMETERS -----------------------------------------------------------------------------

-- Table to be populated with functions, each with a name matching a command parameter.
local COMMAND_parameters = {}

-- "help": Describes the most important console commands or groups thereof.
COMMAND_parameters.help = function(pl)
    mPrint(pl, {
        clr("info",1)..": Provides very basic info.",
        clr("check",1)..": Checks storage, counts thermal panels on all surfaces and within "
        .."storage.",
        clr("dump",1)..": Dumps contents of thermal panel ID list into log file.",
        clr("reset",1)..": Rebuilds thermal panel ID list. Resets sunlight indicator as well.",
        clr("clear",1)..": Clears the panel ID table.",
        clr("unlock",1)..": Forcefully unlocks all content from this mod, circumventing research."
    })
end

-- "info": Provides some info about the thermal solar panels on the current surface.
COMMAND_parameters.info = function(pl)
    local sun_level = pl.surface.get_property("solar-power")
    mPrint(pl, {
        "Solar intensity on this surface ("..clr(pl.surface.name,2)..") is "
      ..clr(sun_level.."%",2)..".",
    })
end

-- DEBUG "check": Checks if thermal panel ID list exists, provides entity count.
COMMAND_parameters.check = function(pl)
    if storage.panels ~= nil then
        -- Storage table:
        mPrint(pl, {"The table 'storage.panels' exists. Any missing subkeys are written here:"})
        local subvars = {
            "main", "to_be_added", "to_be_removed", "batch_size", "progress", "complete"
        }
        for _, subvar in ipairs(subvars) do
            if storage.panels[subvar] == nil then mPrint(pl, {"  "..subvar}) end
        end
        -- Entity count:
        mPrint(pl, {"Thermal solar panel entity count:"})
        local count1 = search_and_count_thermal_panels()
        mPrint(pl, {"  Found within world (all surfaces): "..clr(count1,2).."."})
        if storage.panels.main ~= nil then
            local count2 = table_length(storage.panels.main)
            mPrint(pl, {"  Registered within storage table: "..clr(count2,2).."."})
        end
    else
        mPrint(pl, {"The table 'storage.panels' does not exist!"})
    end
end

-- DEBUG "reset": Clears and rebuilds panel ID table in storage, resets sunlight indicator.
COMMAND_parameters.reset = function(pl)
    reset_thermal_panels()
    mPrint(pl, {
        "'storage.panels.main' was reset and rebuilt!",
        "Any remaining solar-fluid was removed as well."
    })
end

-- DEBUG "clear": Clears panel ID table within storage of its contents, if it exists.
COMMAND_parameters.clear = function(pl)
    if not address_not_nil(storage.panels.main) then return end
    table_clear(storage.panels.main)
    mPrint(pl, {
        "'storage.panels.main' was cleared of its contents!"
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
        "Recipes for all entities from this mod ( "..table.concat(icons," ").." ) were "
      .."forcefully unlocked and had their visibility restored (hopefully)!"
    })
end

-- DEBUG "dump": Dumps contents of panel ID table into log file (%APPDATA%/roaming/Factorio).
COMMAND_parameters.dump = function(pl)
    log("Mod Storage Contents: " .. serpent.block(storage.panels.main, {comment=false}))
    mPrint(pl, {"Contents of 'storage.panels.main' was dumped to log file."})
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