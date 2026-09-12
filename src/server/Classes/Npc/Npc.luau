--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)
local NpcServiceUtils = require(ReplicatedStorage.Shared.Services.NpcService.NpcServiceUtils)
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)
local Types = require(ReplicatedStorage.Shared.Modules.Types)

local Npc = {}
Npc.__index = Npc

function Npc.new(Identifier: string, Overrides: Types.NpcOverrides?)
	local Profile = Profiles.GetProfile(Identifier)
	if not Profile then
		warn("Profile not found")
		return
	end
	local profile = NpcServiceUtils.PrepareProfile(Profile, Overrides)
	local profileModel = NpcServiceUtils.CloneProfileModel(profile)
	if not profileModel then
		warn("Profile model not found: " .. Identifier)
		return
	end

	local self: Types.Npc = setmetatable({
		Profile = profile,
		Connections = {},
		Character = profileModel,
		Humanoid = nil,
		Atoms = {
			StateAtom = charm.atom("Idle"),
		},
	}, Npc) :: any

	return self
end

function Npc.SetState(self: Types.Npc, NewState: Types.NpcState)
	if self.Atoms.StateAtom() == "Destroyed" then
		return
	end

	if self.Atoms.StateAtom() == NewState then
		return
	end

	self.Atoms.StateAtom(NewState)
end

function Npc.Destroy(self: Types.Npc): ()
	if self.Atoms.StateAtom() == "Destroyed" then
		return
	end

	self.SetState(self, "Destroyed")
	if self.Character then
		self.Character:Destroy()
	end
	self.Character = nil
	for key, connection in self.Connections do
		connection:Disconnect()
		self.Connections[key] = nil
	end
	self.Humanoid = nil
	self.Profile = nil
end

return Npc
