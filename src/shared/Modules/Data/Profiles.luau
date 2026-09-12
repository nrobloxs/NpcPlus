export type PropertyOverrides = {
	HumanoidProperties: { [string]: any }?,
	ActionProperties: { [string]: { [string]: any } }?,
	BehaviourProperties: { [string]: any }?,
}

export type Profile = {
	Identifier: string,
	Group: string,
	Model: Model?,
	Properties: {
		HumanoidProperties: { [string]: any },
		ActionProperties: { [string]: { [string]: any } },
		BehaviourProperties: { [string]: any },
	},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = {
	Npc = {
		DefaultNPC = {
			Identifier = "DefaultNPC",
			Model = ReplicatedStorage.Assets.NpcModels:FindFirstChild("DefaultNPC_Model"),
			Group = "DefaultNPC_Group",
			Properties = {
				HumanoidProperties = {
					Health = 100,
					MaxHealth = 100,
					JumpPower = 60,
					WalkSpeed = 16,
					BreakJointsOnDeath = false,
				},
				ActionProperties = {},
				BehaviourProperties = {},
			},
		},
	},
}

function Profiles.GetProfile(Identifier: string)
	local Profile: Profile?
	for _, profile in Profiles.Npc do
		if profile.Identifier == Identifier then
			Profile = profile
			break
		else
			continue
		end
	end
	return Profile
end

function Profiles.GetProfilesInGroup(GroupIdentifier: string): { Profile }
	local retrievedProfiles: { Profile } = {}
	for _, profile in Profiles.Npc do
		if profile.Group == GroupIdentifier then
			table.insert(retrievedProfiles, profile)
		end
	end
	return retrievedProfiles
end

function Profiles.GetProfileInGroup(GroupIdentifier: string): Profile?
	for _, profile in Profiles.Npc do
		if profile.Group == GroupIdentifier then
			return profile
		end
	end
	return nil
end

function Profiles.IsIdentifierValid(Identifier: string)
	for _, profile in Profiles.Npc do
		if profile.Identifier == Identifier then
			return true
		end
	end
	return false
end

type Profiles = typeof(Profiles) & {
	Npc: { [string]: Profile },
}

return Profiles :: Profiles
