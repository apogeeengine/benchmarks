--!strict
--!native
-- The DensityMap (the game's field layers): painting rectangles, reading rows back, saving and loading.
local CELLS = 4096
local CELL_SIZE = 0.5

local function newMap(): any
	local map: any = DensityMap.new()
	map:create(CELLS, CELLS, CELL_SIZE, 64)
	map:add_layer("crop", (DensityMap :: any).LAYER_U32, 1)
	map:add_channel("kind", "crop", 0, 8)
	map:add_channel("stage", "crop", 8, 8)
	return map
end

local function painted(): any
	local map = newMap()
	local size = CELLS * CELL_SIZE
	for z = 0, 7 do
		for x = 0, 7 do
			local min = vector.create(x * size / 8, 0, z * size / 8)
			local shape = { type = "rect", min = min, max = min + vector.create(size / 10, 0, size / 10) }
			map:set_value("kind", 1, shape)
			map:set_value("stage", 3, shape)
		end
	end
	return map
end

return {
	name = "density_map",
	cases = {
		{
			name = `paint 64 rects on {CELLS}x{CELLS} cells`,
			run = function()
				painted()
			end,
		},
		{
			name = "read every row (8 rows at a time)",
			setup = painted,
			run = function(map: any)
				local rows = 8
				local block = buffer.create(CELLS * rows * 4)
				for z = 0, CELLS - 1, rows do
					map:read_rows("crop", z, rows, block)
				end
			end,
		},
		{
			name = "save and load the layers",
			setup = painted,
			run = function(map: any)
				map:load_layers(map:save_layers())
			end,
		},
	},
}
