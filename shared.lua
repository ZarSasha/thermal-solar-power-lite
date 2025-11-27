---------------------------------------------------------------------------------------------------
--  ┏┓┓┏┏┓┳┓┏┓┳┓
--  ┗┓┣┫┣┫┣┫┣ ┃┃
--  ┗┛┛┗┛┗┛┗┗┛┻┛
---------------------------------------------------------------------------------------------------
-- This code contains variables used across several lua-documents within the mod.

---------------------------------------------------------------------------------------------------
-- INFO
---------------------------------------------------------------------------------------------------

MOD_NAME = "thermal-solar-power-lite"
GRAPHICS = "__"..MOD_NAME.."__/graphics/"
GRAPHICS_ENTITIES = GRAPHICS.."entities/"
GRAPHICS_ICONS = GRAPHICS.."icons/"
GRAPHICS_TECH = GRAPHICS.."tech/"

---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------

SETTING = {
    exchanger_color     = settings.startup["enable-heat-exchanger-color"].value,
    panel_output_kW     = settings.startup["custom-panel-heat-output-kW"].value,
    exchanger_output_kW = settings.startup["custom-exchanger-conversion-rate-kW"].value,
    exchanger_temp      = settings.startup["custom-exchanger-temperature-target"].value,
    select_mod          = settings.startup["choose-mod-compatibility"].value
}

---------------------------------------------------------------------------------------------------
-- KEY GLOBAL VARIABLES
---------------------------------------------------------------------------------------------------

-- PROTOTYPE PROPERTIES ---------------------------------------------------------------------------

PANEL = {           -- Thermal Solar Panel
    heat_output_kW   = SETTING.panel_output_kW, -- default: 67.5kW
    heat_loss_factor = 0.005,
    heat_capacity_kJ = 50,
    max_temp         = 1000
}

EXCHANGER = {       -- Basic Heat Exchanger
    max_output_kW    = SETTING.exchanger_output_kW, -- default: 1,800kW. Equals 60/s of 165°C steam.
    target_temp      = SETTING.exchanger_temp, -- default: 165°C (same as Boiler and Steam Engine.)
}

---------------------------------------------------------------------------------------------------