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

-- Frequency with which on-tick scripts will run (the game runs at 60 ticks/s).
local tick_interval = 60
local tick_frequency = (tick_interval/60)

-- Environmental parameters (set by game):
local env = {
    light_const  = 0.85, -- Highest level of "surface darkness" (default range: 0-0.85)
    ambient_temp = 15    -- Default ambient temperature
}

local panel_param = {
    heat_cap_kJ      = 50,
    temp_loss_factor = 0.005, -- may be changed
    quality_scaling  = 0.15   -- may be changed
}

---------------------------------------------------------------------------------------------------
    -- STORAGE TABLE CREATION (ON INIT AND ON CONFIGURATION CHANGED)
---------------------------------------------------------------------------------------------------
-- Values that can't simply be recalcuated should be stored so they can persist through the
-- save/load cycle. All variables below are used by the "on_tick" heat-generating script.

-- Function to create variables for the storage table, if they do not yet exist.
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
    -- ENTITY REGISTRATION (ON BUILT AND SIMILAR)
---------------------------------------------------------------------------------------------------
-- When a thermal panel is built by any method, a string identifier* will be added to a temporary
-- array in storage. At the end of the cycle, it will be registered into the main array, which
-- contains references to all the panels that the scripts further below should apply to.

-- Function to register entity string ID into temporary "to_be_added" array in storage.
local function register_entity(event)
    local panels = storage.panels
    local entity = event.entity or event.destination
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    table.insert(panels.to_be_added, entity)
end

-- Note: Deregistration simply happens when the entity is found to be invalid. During traversal of
-- the main table later on, its string ID will be added to a temporary array, then deleted at the
-- end of a cycle. The method is completely sufficient for this mod.

-- * A string ID is used to reference an entity and its properties. It may look like this:
--   "[LuaEntity: tspl-thermal-solar-panel-large at [gps=25.5,25.5]]",
--   "[LuaEntity: tspl-thermal-solar-panel at [gps=10.5,2.5,vulcanus]]",

---------------------------------------------------------------------------------------------------
    -- ENTITY REGISTER UPDATE (ON TICK SCRIPT, RUNS PERIODICALLY)
---------------------------------------------------------------------------------------------------
-- To keep the main table intact during a cycle that spans several game ticks, changes have to be
-- stored temporarily before being used to update the main array.

-- Function to update contents of "main" array and adjust process batch size for next cycle:
local function update_storage_register()
    local panels = storage.panels
    -- Updates main array, clears temporary arrays:
    array_append_elements(panels.main, panels.to_be_added)
    array_remove_elements(panels.main, panels.to_be_removed)
    table_clear(panels.to_be_added)
    table_clear(panels.to_be_removed)
    -- Resets status for completion of cycle, calculates batch size for the next one (they are
    -- processed on all ticks except 1 reserved for the above):
    panels.complete = false
    panels.batch_size = math.max(math.ceil(#panels.main / ((tick_interval - 1))),1)
end

---------------------------------------------------------------------------------------------------
    -- HEAT GENERATION (ON TICK SCRIPT, RUNS ON ALL BUT ONE TICK)
---------------------------------------------------------------------------------------------------
-- Script that increases temperature of thermal panel in proportion to sunlight, but also decreases
-- it in proportion to current temperature above ambient level. Adjusted for quality and solar 
-- intensity, has compatibility for some mods.

-- COMPATIBILITY: Pyanodon Coal Processing --
if script.active_mods["pycoalprocessing"] and SETTING.select_mod == "Pyanodon" then
    -- Decreases heat loss rate to allow similar efficiency at 250°C (compared to 165°C):
    panel_param.temp_loss_factor =
        round_number(panel_param.temp_loss_factor /
        ((250-env.ambient_temp)/(165-env.ambient_temp)), 7)
end

-- COMPATIBILITY: More Quality Scaling --
if script.active_mods["more-quality-scaling"] then
    -- Nullifies quality scaling factor, since heat capacity scales instead (30% pr. level):
    panel_param.q_scaling = 0
end

-- Function to update temperature of all thermal panels according to circumstances. Adapted for
-- time slicing. Generally writes to storage as little as possible, for better performance.
local function update_panel_temperature()
    local panels     = storage.panels    -- table, thus referenced
    local batch_size = panels.batch_size -- number copy
    local progress   = panels.progress   -- number copy
    local stop       = progress + batch_size - 1
    for i = progress, stop do
        local panel = panels.main[i]
        -- Resets progress and prevents activation of function till next cycle,
        -- when there are no more entries to go through:
        if panel == nil then
            panels.progress = 1
            panels.complete = true
            return
        end
        -- Marks entry for deregistration and skips it, if not valid:
        if not panel.valid then
            table.insert(panels.to_be_removed, panel)
            goto continue
        end
        -- Calculates and applies temperature change to panel:
        local q_factor    = 1 + (panel.quality.level * panel_param.quality_scaling)
        local light_corr  = (env.light_const - panel.surface.darkness) / env.light_const
        local sun_mult    = panel.surface.get_property("solar-power")/100
        local temp_gain   =
            ((SETTING.panel_output_kW * tick_frequency) / panel_param.heat_cap_kJ) *
            light_corr * sun_mult * q_factor
        local temp_loss   =
             (panel_param.temp_loss_factor * tick_frequency) *
             (panel.temperature - env.ambient_temp)
        panel.temperature = panel.temperature + temp_gain - temp_loss
        ::continue::
    end
    -- Updates progress, if cycle is not yet finished:
    if not panels.complete then panels.progress = progress + batch_size end
end

---------------------------------------------------------------------------------------------------
    -- MAKESHIFT SUNLIGHT INDICATOR (ON GUI OPENED/CLOSED)
---------------------------------------------------------------------------------------------------
-- Script that emulates a solar level indicator by filling the panel with a custom fluid when the
-- gui is opened, and removing it again when the gui is closed.

-- Function to clear fluid content and then insert new solar-fluid (on GUI opened).
local function activate_sunlight_indicator(entity)
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
local function deactivate_sunlight_indicator(entity)
    if entity == nil then return end -- same as above
    if not string.find(entity.name, panel_name_base, 1, true) then return end
    entity.clear_fluid_inside()
end

---------------------------------------------------------------------------------------------------
    -- RESETTING (RARELY IF EVER NEEDED)
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
    if panels.main == nil then panels.main = {} end
    table_clear(panels.main)
    for _, surface in pairs(game.surfaces) do
        for _, panel in pairs(surface.find_entities_filtered{name = panel_variants}) do
            table.insert(panels.main, panel)
            panel.clear_fluid_inside()
        end
    end
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
    if event.tick % tick_interval == 3 then -- not 0, to reduce risk over overlap
        update_storage_register()  -- within 1 tick
    elseif not storage.panels.complete then
        update_panel_temperature() -- within all but the 1 tick above
    end
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

-- "help": Describes the most important console commands or groups thereof.
COMMAND_parameters.help = function(pl)
    mPrint(pl, {
        clr("info",1)..  ": Provides very basic info.",
        clr("check",1).. ": Checks storage, counts thermal panels on all surfaces and within "
        .."storage.",
        clr("dump",1)..  ": Dumps contents of thermal panel ID list into log file.",
        clr("reset",1).. ": Rebuilds thermal panel ID list. Resets sunlight indicator as well.",
        clr("clear",1).. ": Clears the panel ID table.",
        clr("unlock",1)..": Forcefully unlocks all content from this mod, circumventing research."
    })
end

--[[
-- Helper function to calculate heat energy that may be converted into steam. Simulates a day cycle
-- with adjustments for day length and solar intensity. Assumes that panels have already warmed up
-- to exchanger target temperature.
local function temp_simulator(panels_num, sun_mult, day_length)
    -- Determines several values through simulation of a full day cycle.
    local temp_target = SETTING.exchanger_temp
    local panel = { temperature = temp_target }
    local excess_temp_units = 0
    for i = 1, day_length do
        -- Simulates the progression of light levels of a day, one second at a time:
        local light_level
        if                                          i < math.floor(0.20*day_length) then
            light_level = -(5/day_length) * i + 1
        elseif i >= math.floor(0.20*day_length) and i < math.floor(0.30*day_length) then
            light_level = 0
        elseif i >= math.floor(0.30*day_length) and i < math.floor(0.50*day_length) then
            light_level = (5/day_length) * i - 1.5
        elseif i >= math.floor(0.50*day_length) then
            light_level = 1
        end
        -- Calculates new temperature for each second of the simulated day:
        local panels_heat_cap_kJ  = 50 * panels_num
        local network_heat_cap_kJ =  panels_heat_cap_kJ + 250
        local panel_loss_X    = 0.005

        local heat_gain = SETTING.panel_output_kW * light_level * sun_mult
        local heat_loss = (panel.temperature - env.ambient_temperature) * panel_loss_X * panels_heat_cap_kJ

        -- Note: More mass means less temp loss but more heat energy loss, since temp is kept
        -- high for a longer time. Remember, higher temp, more heat dissipation!

        local temp_gain   = heat_gain / network_heat_cap_kJ
        local temp_loss   = heat_loss / panels_heat_cap_kJ
        local temp_change = temp_gain - temp_loss
        panel.temperature = panel.temperature + temp_change
        -- Transfers excess to another variable:
        if panel.temperature > temp_target then
            excess_temp_units = excess_temp_units + (panel.temperature - temp_target)
            panel.temperature = temp_target
        end
    end
    -- Returns total heat output in kJ which can be converted into steam at target temperature.
    local excess_heat_kJ = excess_temp_units * real_heat_cap_kJ
    local average_output_kW = round_number((excess_heat_kJ / (day_length * panels_num)), 2)
    local efficiency_pc = round_number(((average_output_kW / SETTING.panel_output_kW) * 100),1)
    --
    return average_output_kW, efficiency_pc
end

-- Inaccurate! Likely has something to do with the exchanger, which adds 250kJ of heat capacity
-- to the network. About 18,5%, which is very close to the overestimation of 18,6%
-- Nauvis: Predicts 1134kW with 27 panels, but it actually is 956kW. 18,6% error.
-- Gleba: Predicts 960kW with 120 panels, but it actually is 468kW. 105% error. Hm.
-- This, too, may be wrong. Gotta check again.
]]

-- "info": Provides some info about the thermal solar panels on the current surface.
COMMAND_parameters.info = function(pl)
    local surface_name   = pl.surface.name
    local sun_mult       = pl.surface.get_property("solar-power")/100
    local daylength_sec  = pl.surface.get_property("day-night-cycle")/60
    local temp_gain_day  = (SETTING.panel_output_kW / panel_param.heat_cap_kJ) * sun_mult
    local temp_adj       = SETTING.exchanger_temp - env.ambient_temp
    local temp_loss_day  = panel_param.temp_loss_factor * temp_adj
    local max_efficiency = (temp_gain_day - temp_loss_day) / temp_gain_day
    local max_output_kW  = SETTING.panel_output_kW * sun_mult * max_efficiency
    local nom_output_kw  = SETTING.panel_output_kW
    local panels_num     = SETTING.exchanger_output_kW / max_output_kW

    local console = {}

    console.surface_name        = clr(surface_name,2)
    console.sun_mult            = clr(sun_mult * 100 .. "%",2)

    if daylength_sec > 0 and daylength_sec ~= nil then
        console.daylength_sec = clr(daylength_sec .. " seconds",2)
    else
        console.daylength_sec = clr("N/A",2)
    end

    if max_output_kW >= 0 then
        console.panel_max_output_kW = clr(round_number(max_output_kW,2) .. "kW",2)
    else
        console.panel_max_output_kW = clr(round_number(max_output_kW,2) .. "kW",3) -- red color
    end

    console.panel_nom_output_kW = clr(round_number(nom_output_kw,2) .. "kW",2)

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
        "'storage.panels.main' was reset and its content rebuilt!",
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
        "Recipes for all entities from this mod ( "..table.concat(icons," ").." )",
        "were forcefully unlocked and had their visibility restored (hopefully)!"
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