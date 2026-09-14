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
function TableClear(tbl)
    for key in pairs(tbl) do
        tbl[key] = nil
    end
end

-- Checks whether a value exists within a table. Returns true or false.
function TableContainsValue(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Checks whether a key exists within a table. Returns true or false.
function TableContainsKey(tbl, element)
    for key, _ in pairs(tbl) do
        if key == element then return true end
    end
    return false
end

-- Adds all entries from one array (indexed table) to the end of another.
function ArrayAppendElements(destination, source) -- table, table
    for _, value in pairs(source) do
        table.insert(destination, value)
    end
end

-- Moves entries from one array (indexed table) to the end of another.
function ArrayMoveElements(destination, source)
    for index, value in ipairs(source) do
        table.insert(destination, value)
        source[index] = nil
    end
end

-- Removes several entries from an array (indexed table) on the basis of a simple value filter
-- and moves the rest up, all in one pass. Efficient.
function ArrayRemoveElementsByFilter(tbl, filter)
    local j, n = 1, #tbl
    for i=1,n do
        if tbl[i] == filter then
            tbl[i] = nil
        else
            if (i ~= j) then
                tbl[j] = tbl[i]
                tbl[i] = nil
            end
            j = j + 1
        end
    end
end

-- MATH --

-- Rounds a number with the desired level of precision.
function RoundNumber(num, decimals)
    decimals = 10 ^ (decimals or 0)
    num = num * decimals
    if num >= 0 then
        num = math.floor(num + 0.5)
    else num = math.ceil(num - 0.5)
    end
    return num / decimals
end

---------------------------------------------------------------------------------------------------
