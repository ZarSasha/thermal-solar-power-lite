---------------------------------------------------------------------------------------------------
--  ┏┳┓┏┓┏┓┓┏┳┓┏┓┓ ┏┓┏┓┳┏┓┏┓
--   ┃ ┣ ┃ ┣┫┃┃┃┃┃ ┃┃┃┓┃┣ ┗┓
--   ┻ ┗┛┗┛┛┗┛┗┗┛┗┛┗┛┗┛┻┗┛┗┛
---------------------------------------------------------------------------------------------------
require "shared"
---------------------------------------------------------------------------------------------------
-- TECHNOLOGY: THERMAL SOLAR POWER
---------------------------------------------------------------------------------------------------

-- COMMON PROPERTIES ------------------------------------------------------------------------------
local solarTech =
{
	type = "technology",
	name = "tspl-thermal-solar-power",
	icon_size = 128,
	icon = GRAPHICS_TECH.."solar-energy.png",
	effects = {
		{type = "unlock-recipe", recipe = "tspl-thermal-solar-panel"},
		{type = "unlock-recipe", recipe = "tspl-thermal-solar-panel-large"},
		{type = "unlock-recipe", recipe = "tspl-basic-heat-exchanger"},
		{type = "unlock-recipe", recipe = "tspl-basic-heat-pipe"}
	},
	prerequisites = nil,	-- assigned below
	unit = nil,				-- assigned below
    order = nil             -- assigned below
}

-- MOD DEPENDENT PROPERTIES: ----------------------------------------------------------------------

-- DEFAULT (VANILLA + UNLISTED MODS) --
    solarTech.prerequisites = {"automation-science-pack"}
    solarTech.unit = {
        ingredients = {
            {"automation-science-pack", 1}
        },
        count = 30,
        time = 15
    }

-- AAI INDUSTRIES --
if mods["aai-industry"] then
    solarTech.prerequisites = {"fluid-handling"}
    solarTech.unit = {
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack",   1}
        },
        count = 100,
        time = 20
    }
    solarTech.order = "a" -- same as Steam power
end

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({solarTech})

---------------------------------------------------------------------------------------------------