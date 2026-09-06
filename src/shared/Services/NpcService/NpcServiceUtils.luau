local NpcServiceUtils = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)
local Types = require(ReplicatedStorage.Shared.Modules.Types)

function NpcServiceUtils.init(_self: NpcServiceUtils) end

function NpcServiceUtils.UpdateProperties(TargetHumanoid: Humanoid?, Properties: { [string]: any })
	if not TargetHumanoid then
		return
	end
	for key, value in pairs(Properties) do
		local success, errorMessage = pcall(function()
			(TargetHumanoid :: any)[key] = value
		end)
		if not success then
			warn(string.format("Could not set Humanoid property %s: %s", key, errorMessage))
		end
	end
end

function NpcServiceUtils.SetupConnections(
	TargetHumanoid: Humanoid?,
	Connections: { [string]: RBXScriptConnection },
	Handlers: { [string]: (...any) -> () }
)
	if not TargetHumanoid then
		return
	end

	for key, callback in Handlers do
		if Connections[key] then
			Connections[key]:Disconnect()
		end

		local Signal = (TargetHumanoid :: any)[key]
		if typeof(Signal) ~= "RBXScriptSignal" then
			warn("No such signal on Humanoid: " .. key)
			continue
		end

		Connections[key] = Signal:Connect(callback)
	end
end

function NpcServiceUtils.mergeProperties(base: { [string]: any }, overrides: { [string]: any }?): { [string]: any }
	local result = table.clone(base)
	if overrides then
		for key, value in overrides do
			result[key] = value
		end
	end
	return result
end

function NpcServiceUtils.PrepareProfile(
	Profile: Profiles.Profile,
	Overrides: Profiles.PropertyOverrides?
): Profiles.Profile
	local profile = table.clone(Profile)
	profile.HumanoidProperties =
		NpcServiceUtils.mergeProperties(Profile.HumanoidProperties, Overrides and Overrides.HumanoidProperties)
	profile.SpawnProperties =
		NpcServiceUtils.mergeProperties(Profile.SpawnProperties, Overrides and Overrides.SpawnProperties)
	profile.ActionProperties = NpcServiceUtils.mergeProperties(
		Profile.ActionProperties,
		Overrides and Overrides.ActionProperties
	) :: { [string]: { [string]: any } }
	profile.BehaviourProperties =
		NpcServiceUtils.mergeProperties(Profile.BehaviourProperties, Overrides and Overrides.BehaviourProperties)
	return profile
end

function NpcServiceUtils.CloneProfileModel(Profile: Profiles.Profile): Model?
	if not Profile.Model then
		return nil
	end
	local ClonedProfile_Model = Profile.Model:Clone()
	ClonedProfile_Model.Name = Profile.Identifier
	return ClonedProfile_Model
end

function NpcServiceUtils.GetSpawnCFrame(Profile: Profiles.Profile, SpawnCFrame: CFrame?): CFrame?
	if SpawnCFrame then
		return SpawnCFrame
	end

	local spawnPosition = Profile.SpawnProperties.SpawnPosition
	if typeof(spawnPosition) ~= "Vector3" then
		warn("Invalid SpawnPosition for NPC: " .. Profile.Identifier)
		return nil
	end
	return CFrame.new(spawnPosition)
end

function NpcServiceUtils.GetRegionCFrame(Center: Vector3, Size: Vector3, RandomGenerator: Random?): CFrame
	local randomGenerator = RandomGenerator or Random.new()
	local offset = Vector3.new(
		randomGenerator:NextNumber(-Size.X / 2, Size.X / 2),
		randomGenerator:NextNumber(-Size.Y / 2, Size.Y / 2),
		randomGenerator:NextNumber(-Size.Z / 2, Size.Z / 2)
	)
	return CFrame.new(Center + offset)
end

function NpcServiceUtils.mergeOverrides(
	groupOverrides: Profiles.PropertyOverrides?,
	memberOverrides: Profiles.PropertyOverrides?
): Types.NpcOverrides?
	if not groupOverrides and not memberOverrides then
		return nil
	end

	local overrides: Types.NpcOverrides = {}
	local function mergeMap(groupMap: { [string]: any }?, memberMap: { [string]: any }?): { [string]: any }?
		if not groupMap and not memberMap then
			return nil
		end
		local result = table.clone(groupMap or {})
		local memberValues = memberMap or {}
		for key, value in memberValues do
			result[key] = value
		end
		return result
	end

	overrides.HumanoidProperties = mergeMap(
		groupOverrides and groupOverrides.HumanoidProperties,
		memberOverrides and memberOverrides.HumanoidProperties
	)
	overrides.SpawnProperties =
		mergeMap(groupOverrides and groupOverrides.SpawnProperties, memberOverrides and memberOverrides.SpawnProperties)
	overrides.ActionProperties = mergeMap(
		groupOverrides and groupOverrides.ActionProperties,
		memberOverrides and memberOverrides.ActionProperties
	) :: { [string]: { [string]: any } }?
	overrides.BehaviourProperties = mergeMap(
		groupOverrides and groupOverrides.BehaviourProperties,
		memberOverrides and memberOverrides.BehaviourProperties
	)
	return overrides
end

function NpcServiceUtils.findSpawnPart(partName: string): BasePart?
	local Instance
	for _, x in workspace:GetDescendants() do
		if x.Name == partName then
			Instance = x
		else
			continue
		end
	end
	return Instance
end

type NpcServiceUtils = typeof(NpcServiceUtils) & {}

return NpcServiceUtils :: NpcServiceUtils
