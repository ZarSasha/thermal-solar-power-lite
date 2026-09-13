---------------------------------------------------------------------------------------------------
--  ┏┓┓┏┏┓┳┓┏┓┳┓
--  ┗┓┣┫┣┫┣┫┣ ┃┃
--  ┗┛┛┗┛┗┛┗┗┛┻┛
---------------------------------------------------------------------------------------------------
-- Shared document exclusive to prototype and settings stage. Must not be loaded at runtime.
---------------------------------------------------------------------------------------------------
-- CHECK FOR PRESENCE OF OTHER MODS
---------------------------------------------------------------------------------------------------

MOD = {
    PY_COAL_PROCESSING = mods["pycoalprocessing"     ] and true or false,
    AAI_INDUSTRY       = mods["aai-industry"         ] and true or false,
    EARLY_HEATING      = mods["EarlyHeating"         ] and true or false,
    CHEESE_SOLAR       = mods["ch-concentrated-solar"] and true or false
}

---------------------------------------------------------------------------------------------------
