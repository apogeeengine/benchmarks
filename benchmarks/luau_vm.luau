--!strict
--!native
-- The Luau VM on its own: calls, tables, strings, buffers and vector math.
local function fib(n: number): number
	return if n < 2 then n else fib(n - 1) + fib(n - 2)
end

return {
	name = "luau_vm",
	cases = {
		{
			name = "fib(30) recursion",
			run = function()
				fib(30)
			end,
		},
		{
			name = "table fill and sum, 1e6",
			run = function()
				local t = table.create(1000000)
				for i = 1, 1000000 do
					t[i] = i
				end
				local sum = 0
				for _, v in t do
					sum += v
				end
			end,
		},
		{
			name = "string build and find, 1e5",
			run = function()
				local parts = {}
				for i = 1, 100000 do
					parts[i] = "row" .. i
				end
				local joined = table.concat(parts, ",")
				local found = 0
				for _ in string.gmatch(joined, "row%d+7,") do
					found += 1
				end
			end,
		},
		{
			name = "buffer read/write f32, 1e6",
			run = function()
				local b = buffer.create(4000000)
				for i = 0, 999999 do
					buffer.writef32(b, i * 4, i * 0.5)
				end
				local sum = 0
				for i = 0, 999999 do
					sum += buffer.readf32(b, i * 4)
				end
			end,
		},
		{
			name = "vector math, 1e6",
			run = function()
				local p = vector.create(0, 0, 0)
				local v = vector.create(1, 0, 0.5)
				for _ = 1, 1000000 do
					p = p + v * 0.016
					if vector.magnitude(p) > 100 then
						p = vector.normalize(p)
					end
				end
			end,
		},
	},
}
