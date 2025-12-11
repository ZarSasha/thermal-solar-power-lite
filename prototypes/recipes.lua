---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┏┓┳┏┓┏┓┏┓
--  ┣┫┣ ┃ ┃┃┃┣ ┗┓
--  ┛┗┗┛┗┛┻┣┛┗┛┗┛
---------------------------------------------------------------------------------------------------
require "mod-check"
---------------------------------------------------------------------------------------------------
-- RECIPES
---------------------------------------------------------------------------------------------------

-- FIXED PROPERTIES -------------------------------------------------------------------------------

-- Function: Recipe template.
function recipe_base(nameVal)
    return
    {
        type = "recipe",
        name = nameVal,
        enabled = false,       -- tech unlock needed
        energy_required = nil, -- assigned below
        ingredients = nil,     -- assigned below
        results = {{type = "item", name = nameVal, amount = 1}}
    }
end

-- Basic recipe creation.
local panel     = recipe_base "tspl-thermal-solar-panel"
local panel_l   = recipe_base "tspl-thermal-solar-panel-large"
local exchanger = recipe_base "tspl-basic-heat-exchanger"
local heat_pipe = recipe_base "tspl-basic-heat-pipe"

-- MOD DEPENDENT PROPERTIES: ----------------------------------------------------------------------

-- DEFAULT (VANILLA + UNLISTED MODS) --
    -- Thermal Solar Panel
    panel.ingredients = {
        {type = "item", name = "copper-plate", amount = 10},
        {type = "item", name = "iron-plate", amount = 20},
        {type = "item", name = "tspl-basic-heat-pipe", amount = 2}}
    panel.energy_required = 4
    -- Thermal Solar Panel
    panel_l.ingredients = {
        {type = "item", name = "tspl-thermal-solar-panel", amount = 9}}
    panel_l.energy_required = 1
    -- Basic Heat Exchanger
    exchanger.ingredients = {
        {type = "item", name = "copper-plate", amount = 30},
        {type = "item", name = "iron-plate", amount = 15},
        {type = "item", name = "pipe", amount = 10}}
    exchanger.energy_required = 1
    -- Basic Heat Pipe
    heat_pipe.ingredients = {
        {type = "item", name = "copper-plate", amount = 10},
        {type = "item", name = "iron-plate", amount = 10}}
    heat_pipe.energy_required = 1

-- PYANODON (COAL PROCESSING) or EARLY HEATING or CHEESE'S CONCENTRATED SOLAR --
if MOD.PY_COAL_PROCESSING or MOD.EARLY_HEATING or MOD.CHEESE_SOLAR then
    -- Basic Heat Exchanger
    exchanger.ingredients = {
        {type = "item", name = "copper-plate", amount = 15},
        {type = "item", name = "iron-plate", amount = 5},
        {type = "item", name = "pipe", amount = 5}}
    -- Basic Heat Pipe
    heat_pipe.ingredients = {
        {type = "item", name = "copper-plate", amount = 5},
        {type = "item", name = "iron-plate", amount = 5}}
end

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({panel, panel_l, exchanger, heat_pipe})

---------------------------------------------------------------------------------------------------