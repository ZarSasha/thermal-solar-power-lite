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
function table_contains_value(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Checks whether a key exists within a table. Returns true or false.
function table_contains_key(tbl, element)
    for key, _ in pairs(tbl) do
        if key == element then return true end
    end
    return false
end

-- Adds all entries from one array (indexed table) to the end of another.
function array_append_elements(destination, source) -- table, table
    for _, value in pairs(source) do
        table.insert(destination, value)
    end
end

-- Moves entries from one array (indexed table) to the end of another.
function array_move_elements(destination, source)
    for index, value in ipairs(source) do
        table.insert(destination, value)
        source[index] = nil
    end
end

-- Removes several entries from an array (indexed table) on the basis of a simple value filter
-- and moves the rest up, all in one pass. Efficient.
function array_remove_elements_by_filter(tbl, filter)
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

-- Writes entries from one array over elements with a particular value in another array. Adds to
-- end of array if none were found.
function array_replace_first_element_by_filter(tbl, new_value, filter)
    local switch = false
    for index, value in ipairs(tbl) do
        if value == filter then
            tbl[index] = new_value
            switch = true
            break
        end
    end
    if switch == false then
        table.insert(tbl, new_value)
    end
end


-- Checks if a table address exists. Seems to return table value or nil.
-- Arguments: Main table, followed by subvariable names (string format).
function address_exists(tbl, ...)
    for i = 1, select("#", ...) do
        if tbl == nil then return nil end
        tbl = tbl[select(i, ...)]
    end
    return tbl
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

---------------------------------------------------------------------------------------------------