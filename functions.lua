---------------------------------------------------------------------------------------------------
--  ┏┓┳┳┳┓┏┓┏┳┓┳┏┓┳┓┏┓
--  ┣ ┃┃┃┃┃  ┃ ┃┃┃┃┃┗┓
--  ┻ ┗┛┛┗┗┛ ┻ ┻┗┛┛┗┗┛
---------------------------------------------------------------------------------------------------

-- STANDARD FUNCTIONS -----------------------------------------------------------------------------

-- Clears a table of its content.
function table_clear_content(tbl)
    for key in pairs(tbl) do
        tbl[key] = nil
    end
end

-- Checks whether a value exists within a table. Returns true or false.
function table_contains_value(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Checks whether a key exists within a table. Returns true or false.
function table_contains_key(table, element)
    for key, value in pairs(table) do
        if key == element then return true end
    end
    return false
end

-- Checks the number of items in a table.
function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- Rounds a number with the desired level of precision.
function round_number(num, decimals)
    decimals = 10 ^ (decimals or 0)
    num = num * decimals
    if num >= 0 then
        num = math.floor(num + 0.5)
    else num = math.ceil(num - 0.5)
    end
    return num / decimals
end

-- Checks if a table address exists. Seems to return table value or nil.
function address_not_nil(t, ...)
    for i = 1, select("#", ...) do
        if t == nil then return nil end
        t = t[select(i, ...)]
    end
    return t
end

---------------------------------------------------------------------------------------------------