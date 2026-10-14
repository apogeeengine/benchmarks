--!strict
--!native
-- The ECS (flecs): creating entities, iterating a query and stepping systems.
local COUNT = 100000

local function newWorld(): (any, any, any)
	local world: any = ECSWorld.new()
	local Position = world:component("Position", { value = "vec3" })
	local Speed = world:component("Speed", { value = "f32" })
	return world, Position, Speed
end

local function populated(): any
	local world, Position, Speed = newWorld()
	for i = 1, COUNT do
		local e = world:entity()
		world:set(e, Position, { value = Vector3(i, 0, 0) })
		world:set(e, Speed, { value = 1.5 })
	end
	return { world = world, Position = Position, Speed = Speed }
end

return {
	name = "ecs",
	cases = {
		{
			name = `create {COUNT} entities with 2 components`,
			run = function()
				populated()
			end,
		},
		{
			name = `each over {COUNT} entities`,
			setup = populated,
			run = function(state: any)
				local sum = 0
				state.world:each({ state.Position, state.Speed }, function(_: any, position: any, speed: any)
					sum += speed.value
				end)
			end,
		},
		{
			name = `system step over {COUNT} entities x10`,
			setup = function(): any
				local state = populated()
				state.world:system("move", { state.Position, state.Speed }, function(_: any, position: any, speed: any, dt: number)
					position.value = position.value + Vector3(speed.value * dt, 0, 0)
				end)
				return state
			end,
			run = function(state: any)
				for _ = 1, 10 do
					state.world:progress(1 / 60)
				end
			end,
		},
	},
}
