local Data = {}

function Data.enum(values)
    local result = {}
    for _, v in ipairs(values) do
        result[v] = v
    end
    return result
end

function Data.set_of(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

function Data.list_reverse(list)
    local result = {}
    for i = #list, 1, -1 do
        table.insert(result, list[i])
    end
    return result
end

function Data.list_map(fn, list)
    local result = {}
    for i = 1, #list do
        result[#result + 1] = fn(list[i], i)
    end
    return result
end

return Data
