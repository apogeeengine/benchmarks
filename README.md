# Apogee Engine benchmarks

Benchmarks of the [Apogee Engine](https://github.com/apogeeengine), in the spirit of
[godot-benchmarks](https://github.com/godotengine/godot-benchmarks): Luau scripts that time the engine's subsystems
and print a table and a JSON report.

| Suite | What it times |
|---|---|
| `luau_vm` | Calls, tables, strings, buffers and vector math in the Luau VM |
| `ecs` | Creating entities, iterating queries and stepping systems |
| `density_map` | Painting, reading, saving and loading the game's field layers |

## Running

With an editor or SDK from [apogeeengine/builds](https://github.com/apogeeengine/builds/releases):

```sh
apogee --headless --path . --luau-run run.luau -- --runs=10                      # all cases
apogee --headless --path . --luau-run run.luau -- --filter=ecs --json=user://results.json
```

Each case runs once to warm up, then `--runs` times; the table shows the minimum, median and mean in milliseconds, and
the last line (`BENCHMARK_JSON …`) holds the same as JSON. A new suite is a file in `benchmarks/` that returns
`{ name, cases = { { name, setup?, run } } }`, added to the list in `run.luau`.

The `Benchmarks` workflow runs them weekly on a GitHub runner and keeps `results.json` as an artifact. Runner
speed varies from run to run, so compare numbers within a run.
