---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┳┓┏┳┓┳┳┓┏┓┏┓
--  ┗┓┣  ┃  ┃ ┃┃┃┃┓┗┓    FIRST SETTINGS STAGE
--  ┗┛┗┛ ┻  ┻ ┻┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------

data:extend({
    {-- 1. Apply a color change to the Basic Heat Exchanger.
        type = "bool-setting",
        name = "tspl-exchanger-enable-color",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {-- 2. Configure thermal solar panel max. heat energy output within certain limits.
		type = "double-setting",
		name = "tspl-panel-heat-generation-kW",
		setting_type = "startup",
		default_value =  116,
        minimum_value =    0,
        maximum_value =  250, -- Same as max value from original mod.
		order = "b"
	},
	{-- 2. Configure thermal solar panel heat loss coefficient.
        type = "double-setting",
        name = "tspl-panel-heat-loss-coefficient",
        setting_type = "startup", -- Make it global runtime? Don't like splitting things up.
        default_value = 0.005,
        minimum_value =     0,
        maximum_value =     1,
        order = "c"
    },
	{-- 3. Configure basic heat exchanger max. steam energy output in kW within certain limits.
		type = "double-setting",
		name = "tspl-exchanger-capacity-kW",
		setting_type = "startup",
		default_value = 2100,	-- Equals 70 units/s of 165°C steam.
        minimum_value = 1,
        maximum_value = 10000,	-- Equal to vanilla Heat Exchanger, but at lower temp.
		order = "d"
	},
	{-- 4. Configure basic heat exchanger temperature target.
        type = "double-setting",
        name = "tspl-exchanger-temperature-target",
        setting_type = "startup",
        default_value = 165,	-- Similar to Boiler.
        minimum_value = 15,     -- Values less than 100 outputs hot water instead of steam!
        maximum_value = 500,	-- Equal to vanilla Heat Exchanger.
        order = "e"
    }
})

-- NOTES ------------------------------------------------------------------------------------------

-- [n1]	Thermal Solar Panels are currently balanced such that 3x9=27 panels are more than enough to
--		keep 1 Basic Heat Exchanger and 1 Steam Engine with Steam Storage running around the clock,
--		producing ~1151kW of electric energy on Nauvis.
--		While nominally producing more power than Solar Panels (116kW > 60kW), they dissipate heat
--      in proportion to their temperature above 15°C. As a result, they don't easily break the
--      temperature threshold required for electricity production, which under full load and with
--      immediate conversion happens within a much narrower time frame (~54.3% < 70%).
