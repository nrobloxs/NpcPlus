local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Npc = require(ServerScriptService.Server.Classes.Npc.Npc)

local Networker = require(ReplicatedStorage.Packages.Networker)
local Groups = require(ReplicatedStorage.Shared.Modules.Data.Groups)
local Profiles = require(ReplicatedStorage.Shared.Modules.Data.Profiles)
local Types = require(ReplicatedStorage.Shared.Modules.Types)
local NpcServiceUtils = require(ReplicatedStorage.Shared.Services.NpcService.NpcServiceUtils)

local NpcServiceServer = {}

function NpcServiceServer.init(self: NpcServiceServer)
	self.Networker = Networker.server.new("NpcService", self, {})
	self.CreatedNpcs = {}
	self.CreatedNpcGroups = {}
	game:BindToClose(function()
		self:DestroyAll()
	end)
end

function NpcServiceServer._CreateNpc(
	self: NpcServiceServer,
	Identifier: string,
	Overrides: Types.NpcOverrides?,
	Spawn: ((Types.Npc) -> ())?
): Types.Npc?
	if not Profiles.IsIdentifierValid(Identifier) then
		warn("Invalid NPC identifier: " .. Identifier)
		return nil
	end

	local existingNpc = self.CreatedNpcs[Identifier]
	if existingNpc then
		existingNpc:Destroy()
	end

	local npc = Npc.new(Identifier, Overrides)
	if not npc then
		return nil
	end

	if Spawn then
		Spawn(npc)
	else
		npc:Spawn()
	end
	self.CreatedNpcs[Identifier] = npc
	return npc
end

function NpcServiceServer.CreateNpc(self: NpcServiceServer, Identifier: string): Types.Npc?
	return self:_CreateNpc(Identifier)
end

function NpcServiceServer.CreateNpcAtPart(self: NpcServiceServer, Identifier: string, Part: BasePart): Types.Npc?
	return self:_CreateNpc(Identifier, nil, function(npc)
		npc:SpawnAtPart(Part)
	end)
end

function NpcServiceServer.CreateNpcInRegion(
	self: NpcServiceServer,
	Identifier: string,
	Center: Vector3,
	Size: Vector3
): Types.Npc?
	return self:_CreateNpc(Identifier, nil, function(npc)
		npc:SpawnInRegion(Center, Size)
	end)
end

function NpcServiceServer.CreateNpcGroup(self: NpcServiceServer, GroupIdentifier: string): { Types.Npc }?
	local Group = Groups.GetGroup(GroupIdentifier)
	if not Group then
		warn("Invalid NPC group identifier: " .. GroupIdentifier)
		return nil
	end

	self:RemoveNpcGroup(GroupIdentifier)
	local createdGroup = {}
	self.CreatedNpcGroups[GroupIdentifier] = createdGroup

	local members = Group.Members
	if not members then
		local profiles = Profiles.GetProfilesInGroup(Group.GroupIdentifier)
		members = {}
		for _, profile in profiles do
			table.insert(members, {
				ProfileIdentifier = profile.Identifier,
			})
		end
	end

	if #members == 0 then
		return createdGroup
	end

	for index = 1, Group.MemberQty do
		local member = members[((index - 1) % #members) + 1]
		local npc = Npc.new(member.ProfileIdentifier, NpcServiceUtils.mergeOverrides(Group.Overrides, member.Overrides))
		if npc then
			if Group.SpawnPartNames and #Group.SpawnPartNames > 0 then
				local partName = Group.SpawnPartNames[math.random(1, #Group.SpawnPartNames)]
				local part = NpcServiceUtils.findSpawnPart(partName)
				if part then
					npc:SpawnAtPart(part)
				else
					npc:Spawn()
				end
			elseif Group.SpawnRegion then
				npc:SpawnInRegion(Group.SpawnRegion, Group.SpawnRegionSize or Vector3.zero)
			else
				npc:Spawn()
			end
			table.insert(createdGroup, npc)
		end
	end
	return createdGroup
end

function NpcServiceServer.RemoveNpc(self: NpcServiceServer, Identifier: string): ()
	local npc = self.CreatedNpcs[Identifier]
	if not npc then
		return
	end

	npc:Destroy()
	self.CreatedNpcs[Identifier] = nil
end

function NpcServiceServer.RemoveNpcGroup(self: NpcServiceServer, GroupIdentifier: string): ()
	local group = self.CreatedNpcGroups[GroupIdentifier]
	if not group then
		return
	end

	for _, npc in group do
		npc:Destroy()
	end
	self.CreatedNpcGroups[GroupIdentifier] = nil
end

function NpcServiceServer.DestroyAll(self: NpcServiceServer): ()
	for identifier, npc in self.CreatedNpcs do
		npc:Destroy()
		self.CreatedNpcs[identifier] = nil
	end
	for groupIdentifier, group in self.CreatedNpcGroups do
		for _, npc in group do
			npc:Destroy()
		end
		self.CreatedNpcGroups[groupIdentifier] = nil
	end
end

type NpcServiceServer = typeof(NpcServiceServer) & {
	Networker: Networker.Server,
	CreatedNpcs: { [string]: Types.Npc },
	CreatedNpcGroups: { [string]: { Types.Npc } },
}

return NpcServiceServer :: NpcServiceServer
