local DATA_DIRECTORY = 'e:\\Games\\Factorio_Web\\Factorio\\data\\'
local full_output = true
-- local MODS_DIRECTORY = 'e:\\Games\\Factorio_Web\\Factorio\\appdata\\mods\\'
_G.mods = {}
_G.settings = {}
_G.log = function(a)
    print(a)
end

require('__stdlib__/stdlib/utils/globals')
require('__stdlib__/spec/setup/defines')

local table = require('__stdlib__/stdlib/utils/table')
local inspect = require('__stdlib__/stdlib/vendor/inspect')
local serpent = require('__stdlib__/stdlib/vendor/serpent')
-- local files = {'data', 'data-update', 'data-final-fixes'}

local lib = DATA_DIRECTORY .. 'core\\lualib\\?.lua;'
local core = DATA_DIRECTORY .. 'core\\?.lua;'
local base = DATA_DIRECTORY .. 'base\\?.lua;'

--(( CORE ))--
package.path = core .. lib
do
    require('dataloader')
    require('data')
    package.loaded['data'] = false
    for pack in pairs(package.loaded) do
        if pack:find('prototype') then
            package.loaded[package] = nil
        end
    end
end --))

--(( BASE
package.path = base .. lib
for _, file in pairs({'data', 'data-updates'}) do
    require(file)
    for pack in pairs(package.loaded) do
        if pack:find('prototype') then
            package.loaded[package] = nil
        end
    end
end --))

-- loop through all info.json and sort by dependency *shudder*
-- loop through all mods by sorted list and load data in all 3 stages
local io = _G.io
if full_output then --(( OUTPUT
    local lfs = require('lfs')
    lfs.mkdir('.output')

    -- Write data.raw
    io.open('.output/_raw.lua', 'w'):write('return '):write(inspect(_G.data.raw)):close()

    -- Write key files
    local key_counts = {}
    local key_vals = {}
    for type, v in pairs(_G.data.raw) do
        key_counts[type] = table.size(v)
        local values = {}
        for name in pairs(v) do
            values[#values + 1] = name
        end
        io.open('.output/' .. type .. '.lua', 'w'):write('return '):write(inspect(v, {longkeys = false})):close()
        key_vals[type] = table.concat(values, ' ')
    end
    io.open('.output/_key_counts.lua', 'w'):write('return '):write(inspect(key_counts, {longkeys = true})):close()
    io.open('.output/_key_vals.lua', 'w'):write('return '):write(inspect(key_vals, {longkeys = true})):close()
else
    --io.open('spec/setup/data/raw.lua', "w"):write(serpent.dump(_G.data.raw)):close()
    io.open('spec/setup/data/raw.lua', 'w'):write(serpent.block(_G.data.raw, {name = 'raw'})):close()
end --))
