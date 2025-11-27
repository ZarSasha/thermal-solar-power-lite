---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┳┓┏┳┓┳┳┓┏┓┏┓
--  ┗┓┣  ┃  ┃ ┃┃┃┃┓┗┓
--  ┗┛┗┛ ┻  ┻ ┻┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------

data:extend({
    {-- 1. Apply a color change to the Basic Heat Exchanger.
        type = "bool-setting",
        name = "enable-heat-exchanger-color",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {-- 2. Configure thermal solar panel max. heat energy output within certain limits.
		type = "double-setting",
		name = "custom-panel-heat-output-kW",
		setting_type = "startup",
		default_value = 67.5,	-- [n1]
        minimum_value = 37.5, 	-- Too low to work, actually.
        maximum_value = 250, 	-- Max. output from original mod, already OP.
		order = "b"
	},
	{-- 3. Configure basic heat exchanger max. steam energy output in kW within certain limits.
		type = "double-setting",
		name = "custom-exchanger-conversion-rate-kW",
		setting_type = "startup",
		default_value = 1800,	-- Similar to Boiler. Equals 60 units/s of 165°C steam.
        minimum_value = 1,
        maximum_value = 10000,	-- Equal to vanilla Heat Exchanger, but at lower temp.
		order = "c"
	},
	{-- 4. Configure basic heat exchanger temperature target.
        type = "double-setting",
        name = "custom-exchanger-temperature-target",
        setting_type = "startup",
        default_value = 165,	-- Similar to Boiler.
        minimum_value = 100,    -- Water boiling point.
        maximum_value = 500,	-- Equal to vanilla Heat Exchanger.
        order = "d"
    },
	{-- 5. Optionally provides some sort of adaptation for certain mods.
		type = "string-setting",
		name = "choose-mod-compatibility",
		setting_type = "startup",
		default_value = "Default",
		allowed_values = {
            "Default",
            "Pyanodon" -- adjusts heat-generating script
        },
		order = "e"
	}
})

-- NOTES ------------------------------------------------------------------------------------------

-- [n1]	Thermal Solar Panels are currently balanced such that 3x9=27 panels are more than enough to
--		keep 1 Basic Heat Exchanger and 1 Steam Engine with Steam Storage running around the clock,
--		producing at least 900 kW of electric energy.
--		While nominally producing more power than Solar Panels (67.5kW > 60kW), they are typically
--		active for a much shorter time (52.5% < 70%). This is because the panels constantly lose
--      heat in proportion to their temperature above 15°C, and it takes a while for the panels to
--      rise above the productive threshold of 165°C again in the morning.