local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)

local Types = {}

export type NpcState = "Idle" | "Patrolling" | "Chasing" | "Attacking" | "Dead" | "Destroyed"

export type NpcOverrides = Profiles.PropertyOverrides

export type Npc = {
	Profile: Profiles.Profile?,
	Connections: { [string]: RBXScriptConnection },
	Character: Model?,
	Humanoid: Humanoid?,
	Atoms: {
		StateAtom: any,
	},
	_InitHumanoidConnections: (self: Npc) -> (),
	SetState: (self: Npc, NewState: NpcState) -> (),
	Destroy: (self: Npc) -> (),
}

return Types
