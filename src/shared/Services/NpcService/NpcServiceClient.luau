local Networker = require("../../../Packages/Networker")
local NpcServiceClient = {}

function NpcServiceClient.init(self: NpcServiceClient)
	self.Networker = Networker.client.new("NpcService", self)
end

type NpcServiceClient = typeof(NpcServiceClient) & {
	Networker: Networker.Client,
}

return NpcServiceClient :: NpcServiceClient
