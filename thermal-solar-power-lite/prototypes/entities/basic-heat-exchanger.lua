---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┳┏┓┏┓
--  ┣ ┃┃ ┃ ┃ ┃ ┃┣ ┗┓
--  ┗┛┛┗ ┻ ┻ ┻ ┻┗┛┗┛
---------------------------------------------------------------------------------------------------
require "shared"
---------------------------------------------------------------------------------------------------
-- BASIC HEAT EXCHANGER
---------------------------------------------------------------------------------------------------
-- Produces steam at 165°C at a rate of 60 units/s from water and heat.
local BasicHeatEx = table.deepcopy(data.raw["boiler"]["heat-exchanger"])
-- GRAPHICS --
local path = GRAPHICS_ENTITIES.."basic-heat-exchanger/"
if SETTING.exchanger_color == true then
    local hr = "hr-basic-heatex-"
    -- High Resolution --
    BasicHeatEx.pictures.north.structure.layers[1].filename = path .. hr .. "N.png"
    BasicHeatEx.pictures.east .structure.layers[1].filename = path .. hr .. "E.png"
    BasicHeatEx.pictures.south.structure.layers[1].filename = path .. hr .. "S.png"
    BasicHeatEx.pictures.west .structure.layers[1].filename = path .. hr .. "W.png"
    BasicHeatEx.corpse = "basic-heat-exchanger-remnants"
end
-- PROPERTIES --
BasicHeatEx.name = "tspl-basic-heat-exchanger"
BasicHeatEx.icon = GRAPHICS_ICONS.."basic-heat-exchanger.png"
BasicHeatEx.minable.result = "tspl-basic-heat-exchanger"
BasicHeatEx.target_temperature = SETTING.exchanger_temp
BasicHeatEx.energy_source.min_working_temperature = EXCHANGER.target_temp
BasicHeatEx.energy_source.specific_heat = "250kJ" -- vanilla: 1MJ
BasicHeatEx.energy_source.max_transfer  = "500MW" -- vanilla: 2GW
BasicHeatEx.energy_consumption = EXCHANGER.max_output_kW .. "kW" -- default: "1800kW"

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({BasicHeatEx})
---------------------------------------------------------------------------------------------------