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
    exchanger_color       = settings.startup["tspl-exchanger-enable-color"      ].value,
    panel_output_kW       = settings.startup["tspl-panel-heat-generation-kW"    ].value,
    panel_heat_loss_coeff = settings.startup["tspl-panel-heat-loss-coefficient" ].value,
    exchanger_output_kW   = settings.startup["tspl-exchanger-capacity-kW"       ].value,
    exchanger_temp_target = settings.startup["tspl-exchanger-temperature-target"].value,
    --select_mod_adaptation = settings.startup["tspl-choose-mod-adaptation"       ].value
}

---------------------------------------------------------------------------------------------------
