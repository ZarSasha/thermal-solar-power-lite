---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┓┏┓┓ ┏┓┏┓┳┏┓┳┓┏┓
--  ┣  ┃┃ ┃┃┃ ┃┃┗┓┃┃┃┃┃┗┓
--  ┗┛┗┛┗┛┣┛┗┛┗┛┗┛┻┗┛┛┗┗┛
---------------------------------------------------------------------------------------------------
local sounds = require "__base__.prototypes.entity.sounds"
---------------------------------------------------------------------------------------------------
-- ENTITY DYING EXPLOSION EFFECT
---------------------------------------------------------------------------------------------------

-- Thermal Solar Panel (Large) --
---@diagnostic disable-next-line: undefined-field
local largePanelExplosion = table.deepcopy(data.raw["explosion"]["solar-panel-explosion"])
largePanelExplosion.name = "large-panel-explosion"
largePanelExplosion.sound = sounds.large_explosion(0.6)
local effects = largePanelExplosion.created_effect.action_delivery.target_effects
local dev = 3
---@diagnostic disable-next-line: undefined-field
local copy1 = table.deepcopy(effects[1])
copy1.repeat_count = 252 
copy1.offset_deviation = {{-(0.7+dev), -(0.5+dev)},{ (0.7+dev), (0.5+dev)}}
table.insert(effects,copy1)
---@diagnostic disable-next-line: undefined-field
local copy2 = table.deepcopy(effects[2])
copy2.repeat_count = 288
copy2.offset_deviation = {{-(0.9+dev), -(0.8+dev)},{ (0.9+dev), (0.8+dev)}}
table.insert(effects,copy2)
---@diagnostic disable-next-line: undefined-field
local copy3 = table.deepcopy(effects[3])
copy3.repeat_count = 738
copy3.offset_deviation = {{-(0.4+dev), -(0.5+dev)},{ (0.4+dev), (0.5+dev)}}
table.insert(effects,copy3)

-- FINAL DATA WRITE -------------------------------------------------------------------------------
data:extend({largePanelExplosion})

---------------------------------------------------------------------------------------------------