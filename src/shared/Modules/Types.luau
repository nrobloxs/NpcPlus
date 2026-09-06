local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)

local Types = {}

export type NpcState = "Idle" | "Patrolling" | "Chasing" | "Attacking" | "Dead" | "Respawning" | "Destroyed"

export type NpcOverrides = Profiles.PropertyOverrides

export type Npc = {
	Profile: Profiles.Profile?,
	Connections: { [string]: RBXScriptConnection },
	Character: Model?,
	Humanoid: Humanoid?,
	State: NpcState,
	RespawnThread: thread?,
	_InitHumanoidConnections: (self: Npc) -> (),
	SetState: (self: Npc, NewState: NpcState) -> (),
	Respawn: (self: Npc) -> (),
	Spawn: (self: Npc, SpawnCFrame: CFrame?) -> (),
	SpawnAtPart: (self: Npc, Part: BasePart) -> (),
	SpawnInRegion: (self: Npc, Center: Vector3, Size: Vector3, RandomGenerator: Random?) -> (),
	Destroy: (self: Npc) -> (),
}

return Types
