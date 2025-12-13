


-- Attempt to spread calculation over several ticks to avoid frame drops.


local function initialize_storage_table_variables()
    if storage.thermal_panels      == nil then storage.thermal_panels      = {} end
    if storage.entities_to_process == nil then storage.entities_to_process = {} end
    if storage.current_index       == nil then storage.current_index       = {} end
end

local function update_panel_temperature(event)
    if event.tick % 60 == 0 then

    end
end





script.on_init(function()
    initialize_storage_table_variables()
end)

script.on_event({defines.events.on_tick}, function(event)
    update_panel_temperature(event)
end)




---------------------------------------------------------------------------------------------------

-- google: factorio how to spread runtime script over several ticks

storage.entities_to_process = {} -- populate this elsewhere
storage.current_index = nil     -- used to store iteration state between ticks

script.on_event(defines.events.on_tick, function(event)
    -- Number of entities to process per tick
    local updates_per_tick = 10 -- change dynamically once in a while?

    for i = 1, updates_per_tick do
        local unit_number, entity = next(storage.entities_to_process, storage.current_index)
        
        if entity then
            storage.current_index = unit_number
            if entity.valid then
                -- Do work with the entity
                do_stuff(entity)
            end
        else
            -- Reached the end of the list, reset the index for the next cycle
            storage.current_index = nil
            return -- Exit the tick handler
        end
    end
end)

function do_stuff(entity)
    -- Your specific logic
end



