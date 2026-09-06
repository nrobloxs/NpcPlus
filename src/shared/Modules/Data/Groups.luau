local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)

export type Member = {
	ProfileIdentifier: string,
	Overrides: Profiles.PropertyOverrides?,
}

export type Group = {
	GroupIdentifier: string,
	MemberQty: number,
	Members: { Member }?,
	Overrides: Profiles.PropertyOverrides?,
}

local Groups = {
	NpcGroups = {
		DefaultNPC_Group = {
			GroupIdentifier = "DefaultNPC_Group",
			MemberQty = 4,
			Members = {
				{
					ProfileIdentifier = "DefaultNPC",
				},
			},
		},
	},
}

function Groups.GetGroup(GroupIdentifier: string): Group?
	return Groups.NpcGroups[GroupIdentifier]
end

type Groups = typeof(Groups) & {
	NpcGroups: { [string]: Group },
}

return Groups
