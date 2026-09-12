local NpcServiceUtils = {}

local DEBUG_ENABLED = true

local function debugPrint(message: string, ...: any)
	if not DEBUG_ENABLED then
		return
	end
	print("[NpcServiceUtils]", message, ...)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.sift)
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)
local Types = require(ReplicatedStorage.Shared.Modules.Types)
local TableUtils = require(ReplicatedStorage.Shared.Modules.Utils.TableUtils)

function NpcServiceUtils.init(_self: NpcServiceUtils) end

function NpcServiceUtils.mergeProperties(base: { [string]: any }, overrides: { [string]: any }?): { [string]: any }
	return TableUtils.mergeDeep(base, overrides)
end

function NpcServiceUtils.PrepareProfile(
	Profile: Profiles.Profile,
	Overrides: Profiles.PropertyOverrides?
): Profiles.Profile
	debugPrint("Preparing profile for", Profile.Identifier)
	local profile: Profiles.Profile = Sift.Dictionary.mergeDeep(Profile)

	profile.Properties.HumanoidProperties = NpcServiceUtils.mergeProperties(
		Profile.Properties.HumanoidProperties,
		Overrides and Overrides.HumanoidProperties
	)
	profile.Properties.BehaviourProperties = NpcServiceUtils.mergeProperties(
		Profile.Properties.BehaviourProperties,
		Overrides and Overrides.BehaviourProperties
	)
	debugPrint("Profile prepared for", Profile.Identifier)
	return profile
end

function NpcServiceUtils.CloneProfileModel(Profile: Profiles.Profile): Model?
	if not Profile.Model then
		debugPrint("CloneProfileModel called without a model for", Profile.Identifier)
		return nil
	end

	local clonedProfileModel = Profile.Model:Clone()
	clonedProfileModel.Name = Profile.Identifier
	debugPrint("Cloned model for", Profile.Identifier)
	return clonedProfileModel
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
		return TableUtils.mergeDeep(groupMap or {}, memberMap)
	end

	overrides.HumanoidProperties = mergeMap(
		groupOverrides and groupOverrides.HumanoidProperties,
		memberOverrides and memberOverrides.HumanoidProperties
	)
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

type NpcServiceUtils = typeof(NpcServiceUtils) & {}

return NpcServiceUtils :: NpcServiceUtils
