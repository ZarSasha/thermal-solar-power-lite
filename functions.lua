---------------------------------------------------------------------------------------------------
--  ┏┓┳┳┳┓┏┓┏┳┓┳┏┓┳┓┏┓
--  ┣ ┃┃┃┃┃  ┃ ┃┃┃┃┃┗┓
--  ┻ ┗┛┛┗┗┛ ┻ ┻┗┛┛┗┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- STANDARD FUNCTIONS
---------------------------------------------------------------------------------------------------

-- TABLES & ARRAYS --

-- Clears a table of its content.
function table_clear(tbl)
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

-- Adds all entries from one array (indexed table) to the end of another.
function array_append_elements(destination, source) -- table, table
    for _, value in pairs(source) do
        table.insert(destination, value)
    end
end

-- Removes several entries from an array (indexed table) and moves the rest up, all in one pass.
-- Efficient. Requires another standard function above.
function array_remove_elements(table, elements)
    local j, n = 1, #table
    for i=1,n do
        if table_contains_value(elements, table[i]) then
            table[i] = nil
        else
            if (i ~= j) then
                table[j] = table[i]
                table[i] = nil
            end
            j = j + 1
        end
    end
end

-- Checks if a table address exists. Seems to return table value or nil.
function address_not_nil(t, ...)
    for i = 1, select("#", ...) do
        if t == nil then return nil end
        t = t[select(i, ...)]
    end
    return t
end

-- MATH --

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

-- Rounds up a number to nearest factor.
function round_up_to_nearest_factor(number, factor)
    if number % factor == 0 then
        return number
    else
        return math.ceil(number / factor) * factor
    end
end

---------------------------------------------------------------------------------------------------