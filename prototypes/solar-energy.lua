---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┓ ┏┓┳┓  ┏┓┳┓┏┓┳┓┏┓┓┏
--  ┗┓┃┃┃ ┣┫┣┫━━┣ ┃┃┣ ┣┫┃┓┗┫
--  ┗┛┗┛┗┛┛┗┛┗  ┗┛┛┗┗┛┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- MAKESHIFT SUNLIGHT INDICATOR: CUSTOM SOLAR-FLUID
---------------------------------------------------------------------------------------------------
-- Creates a custom fluid that allows 1) the display of current heat energy output of the thermal
-- solar panels (important because it's configurable), and 2) the creation of a makeshift sunlight
-- indicator through a script (visible only when the panel's GUI is open). See control.lua.
---------------------------------------------------------------------------------------------------
data:extend({
	{-- Category
		type = "fuel-category",
		name = "tspl-solar-energy"
	},
	{-- Fluid
		type = "fluid",
		icon = "__base__/graphics/icons/tooltips/tooltip-category-chemical.png",
		icon_size = 40, icon_mipmaps = 2,
		name = "tspl-solar-fluid",
		hidden = true,
		auto_barrel = false,
		base_color = { 1, 1, 0.2 },
		flow_color = { 1, 1, 0.2 },
		default_temperature = 0,
		max_temperature = 100,
		heat_capacity = "1kJ"
	}
})

---------------------------------------------------------------------------------------------------

-- NOTE: The thermal solar panels are set to scale consumption of the fluid and burn it at a very
-- low rate (it's not 0, because the game doesn't allow that).