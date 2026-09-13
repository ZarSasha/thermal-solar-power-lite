---------------------------------------------------------------------------------------------------
--  ┏┓┓┏┏┓┳┓┏┓┳┓
--  ┗┓┣┫┣┫┣┫┣ ┃┃
--  ┗┛┛┗┛┗┛┗┗┛┻┛
---------------------------------------------------------------------------------------------------
-- Shared document for all mod load stages and runtime. Contains no code that could cause conflict
-- between them.
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
    exchanger_color     = settings.startup["tspl-enable-heat-exchanger-color"            ].value,
    panel_output_kW     = settings.startup["tspl-custom-panel-nominal-heat-generation-kW"].value,
    exchanger_output_kW = settings.startup["tspl-custom-exchanger-conversion-rate-kW"    ].value,
    exchanger_temp      = settings.startup["tspl-custom-exchanger-temperature-target"    ].value,
    select_mod          = settings.startup["tspl-choose-mod-compatibility"               ].value
}

---------------------------------------------------------------------------------------------------
