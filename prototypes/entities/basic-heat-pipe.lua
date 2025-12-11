---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┳┏┓┏┓
--  ┣ ┃┃ ┃ ┃ ┃ ┃┣ ┗┓
--  ┗┛┛┗ ┻ ┻ ┻ ┻┗┛┗┛
---------------------------------------------------------------------------------------------------
require "shared.all-stages"
---------------------------------------------------------------------------------------------------
-- BASIC HEAT PIPE
---------------------------------------------------------------------------------------------------
-- Cheaper than the vanilla variant, available much earlier.
---@diagnostic disable-next-line: undefined-field
local BasicHeatPipe = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
-- PROPERTIES --
BasicHeatPipe.name = "tspl-basic-heat-pipe"
BasicHeatPipe.icon = GRAPHICS_ICONS.."basic-heat-pipe.png"
BasicHeatPipe.heat_buffer.specific_heat = "250kJ"      -- vanilla: 1MJ
BasicHeatPipe.heat_buffer.max_transfer  = "500MW"      -- vanilla: 1GW
BasicHeatPipe.minable.result = "tspl-basic-heat-pipe"
BasicHeatPipe.heat_buffer.min_temperature_gradient = 2 -- vanilla: 1
BasicHeatPipe.working_sound.sound.volume = 0.3         -- vanilla: 0.4

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({BasicHeatPipe})

-- END NOTES --------------------------------------------------------------------------------------

-- v2.1.16 note: Both "max_transfer" and "min_temperature_gradient" influence the range over which
-- heat can be effectively transferred for useful work, but in different ways. Increasing the
-- latter for balance feels less frustrating and is immediately measurable by comparison.

