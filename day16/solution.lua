local function msb(n)
    if n == 0 then
        return 0
    end

    local result = 1
    while n > 1 do
        n = n >> 1
        result = result << 1
    end

    return result
end

local function is_2_power(n)
    local number_of_ones = 0

    while n > 0 do
        number_of_ones = number_of_ones + (n & 1)
        n = n >> 1
    end

    return number_of_ones == 1
end

local function odd_factor(n)
    local result = 1
    while n & 1 == 0 do
        n = n >> 1
        result = result << 1
    end

    return result
end

local function reverse(l)
    local reversed = {}
    local size = #l
    for i = 1, size, 1 do
        reversed[size + 1 - i] = not l[i]
    end

    return reversed
end

local function dragon_number(n)
    if is_2_power(n) then
        return false
    end

    return not dragon_number((msb(n) << 1) - n)
end

local function solve(input, disk_size)
    local reversed_input = reverse(input)
    local block_size = odd_factor(disk_size)
    local cycle_size = #input + 1
    local index = 1
    local checksums = {}

    for _ = 1, disk_size // block_size, 1 do
        local checksum = true

        for _ = 1, block_size, 1 do
            local cur
            if index % cycle_size == 0 then
                cur = dragon_number(index // cycle_size)
            elseif (index // cycle_size) % 2== 0 then
                cur = input[index % cycle_size]
            else
                cur = reversed_input[index % cycle_size]
            end

            checksum = not ((checksum or cur) and not (checksum and cur))
            index = index + 1
        end

        table.insert(checksums, checksum and "1" or "0")
    end

    return table.concat(checksums, "")
end

local input = {}
io.read("*line"):gsub(".", function (c)
    table.insert(input, c == "1")
end)

print(solve(input, 272))
print(solve(input, 35651584))