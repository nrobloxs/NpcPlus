--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcServiceUtils = require(ReplicatedStorage.Shared.Services.NpcService.NpcServiceUtils)
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)
local Types = require(ReplicatedStorage.Shared.Modules.Types)

local Npc = {}
Npc.__index = Npc

function Npc._InitHumanoidConnections(self: Types.Npc)
	if self.Humanoid then
		NpcServiceUtils.SetupConnections(self.Humanoid, self.Connections, {
			Died = function()
				if self.Character then
					self.Character:Destroy()
				end

				self.Character = nil
				self.SetState(self, "Dead")
				if self.Profile and self.State ~= "Destroyed" then
					self.RespawnThread = task.delay(self.Profile.SpawnProperties.SpawnDelay or 3, function()
						self.RespawnThread = nil
						self.Respawn(self)
					end)
				end
			end,
		})
	end
end

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
		Character = profileModel:Clone(),
		Humanoid = nil,
		State = "Idle" :: Types.NpcState,
		RespawnThread = nil,
	}, Npc) :: any

	self._InitHumanoidConnections(self)

	return self
end

function Npc.SetState(self: Types.Npc, NewState: Types.NpcState)
	if self.State == "Destroyed" then
		return
	end

	if self.State == NewState then
		return
	end

	self.State = NewState
end

function Npc.Respawn(self: Types.Npc)
	if self.State ~= "Dead" then
		return
	end
	self.SetState(self, "Respawning")
	self.Spawn(self)
end

function Npc.Spawn(self: Types.Npc, SpawnCFrame: CFrame?): ()
	if self.State == "Destroyed" then
		return
	end
	local profile = self.Profile
	if not profile then
		return
	end

	if not profile.SpawnProperties.CanBeSpawned then
		return
	end

	if not self.Character then
		self.Character = NpcServiceUtils.CloneProfileModel(profile)
		if not self.Character then
			warn("Profile model not found: " .. profile.Identifier)
			return
		end
	end

	if self.Character then
		local targetCFrame = NpcServiceUtils.GetSpawnCFrame(profile, SpawnCFrame)
		if not targetCFrame then
			return
		end
		self.Character:PivotTo(targetCFrame)
		self.Character.Parent = workspace
		self.Humanoid = self.Character:FindFirstChildOfClass("Humanoid")
		if self.Humanoid then
			NpcServiceUtils.UpdateProperties(self.Humanoid, profile.HumanoidProperties)
			self._InitHumanoidConnections(self)
		end

		self.SetState(self, "Idle")
	end
end

function Npc.SpawnAtPart(self: Types.Npc, Part: BasePart): ()
	self.Spawn(self, Part.CFrame)
end

function Npc.SpawnInRegion(self: Types.Npc, Center: Vector3, Size: Vector3, RandomGenerator: Random?): ()
	self.Spawn(self, NpcServiceUtils.GetRegionCFrame(Center, Size, RandomGenerator))
end

function Npc.Destroy(self: Types.Npc): ()
	if self.State == "Destroyed" then
		return
	end

	self.SetState(self, "Destroyed")
	if self.RespawnThread then
		task.cancel(self.RespawnThread)
		self.RespawnThread = nil
	end
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
