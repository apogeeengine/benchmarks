--!strict
-- Runs the benchmarks and prints a table, then the results as one JSON line (BENCHMARK_JSON {...}).
--
--   apogee --headless --path . --luau-run run.luau -- [--runs=5] [--filter=text] [--json=user://results.json]
--
-- Each file in benchmarks/ returns { name, cases = { { name, setup?, run } } }: a case is timed over --runs runs after a
-- warm-up run, with `setup` (not timed) building what `run` needs fresh each time.
local suites = {
	require("./benchmarks/luau_vm"),
	require("./benchmarks/ecs"),
	require("./benchmarks/density_map"),
}

local runs = tonumber(cmdline.get("runs")) or 5
local filter = cmdline.get("filter")

local function median(values: { number }): number
	local sorted = table.clone(values)
	table.sort(sorted)
	local n = #sorted
	return if n % 2 == 1 then sorted[(n + 1) // 2] else (sorted[n // 2] + sorted[n // 2 + 1]) / 2
end

local results = {}
print(string.format("%-14s %-46s %10s %10s %10s", "suite", "case", "min ms", "median ms", "mean ms"))
for _, suite in suites do
	for _, case in suite.cases do
		local id = `{suite.name}/{case.name}`
		if filter and not string.find(id, filter, 1, true) then
			continue
		end
		local times = {}
		for i = 0, runs do -- Run 0 warms up.
			local state = if case.setup then case.setup() else nil
			local start = os.clock()
			case.run(state)
			local elapsed = (os.clock() - start) * 1000
			if i > 0 then
				table.insert(times, elapsed)
			end
		end
		local total = 0
		for _, t in times do
			total += t
		end
		local min = math.min(table.unpack(times))
		local mean = total / #times
		local med = median(times)
		print(string.format("%-14s %-46s %10.2f %10.2f %10.2f", suite.name, case.name, min, med, mean))
		table.insert(results, { id = id, min_ms = min, median_ms = med, mean_ms = mean, runs = #times })
	end
end

local report = json.encode({ engine = Engine:get_version_info().string, runs = runs, results = results })
print("BENCHMARK_JSON " .. report)
local path = cmdline.get("json")
if path then
	fs.write_text(path, report)
end
