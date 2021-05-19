-- DataService
-- littensy
-- November 30, 2020

--[[

    DataService:Get(player: Instance): PlayerData
    DataService:GlobalUpdateProfileAsync(userId: number, updateHandler: () -> void): void

    DataService.PlayerLoaded:Connect(player: Instance, playerData: PlayerData): Connection
    DataService.PlayerRemoving:Connect(player: Instance, playerData: PlayerData): Connection

]]



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicaService = Knit.ReplicaService
local Signal = require(Knit.Util.Signal)

local PlayerData = require(Knit.Modules.Data.PlayerData)
local ProfileService = require(Knit.Modules.Data.ProfileService)
local DefaultProfile = require(Knit.Modules.Data.DefaultProfile)

local Players = game:GetService("Players")

local profileClassToken = ReplicaService.NewClassToken("PlayerProfile")
local profileStore = ProfileService.GetProfileStore("PlayerData", DefaultProfile)

local DataService: Service = Knit.CreateService {
    Name = "DataService";
    Client = {};
}

DataService.PlayerLoaded = Signal.new()
DataService.PlayerRemoving = Signal.new()


function DataService:Get(player)
    return PlayerData.FromPlayer(player)
end


function DataService:GlobalUpdateProfileAsync(userId, updateHandler)
    profileStore:GlobalUpdateProfileAsync("Player_" .. userId, updateHandler)
end


function DataService:KnitInit()

    Players.PlayerAdded:Connect(function(player)
        local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")
        if (profile) then
            profile:Reconcile()
            profile:ListenToRelease(function()
                player:Kick()
            end)
            if (player.Parent) then
                local playerData = PlayerData.new(player, profile, ReplicaService.NewReplica {
                    ClassToken = profileClassToken;
                    Tags = { Player = player };
                    Data = profile.Data;
                    Replication = "All";
                })
                playerData:SyncShallow(DefaultProfile)
                playerData:SyncShallow(DefaultProfile.Config, playerData.Data.Config)
                self.PlayerLoaded:Fire(player, playerData)
            else
                profile:Release()
            end
        else
            player:Kick()
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        local playerData = PlayerData.FromPlayer(player)
        if (playerData) then
            self.PlayerRemoving:Fire(player, playerData)
            playerData:Destroy()
        end
    end)
    
end


return DataService