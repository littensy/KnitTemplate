-- DataController
-- littensy
-- November 30, 2020



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Signal = require(Knit.Util.Signal)
local Promise = require(Knit.Util.Promise)
local ReplicaController = Knit.ReplicaController

local replicasByPlayer = {}

local DataController: Controller = Knit.CreateController { Name = "DataController" }

DataController.PlayerLoaded = Signal.new()


function DataController:Get(player)
    return replicasByPlayer[player]
end


function DataController:GetAll()
    return replicasByPlayer
end


function DataController:Await(player)
    player = player or Knit.Player

    if (replicasByPlayer[player]) then
        return Promise.resolve(replicasByPlayer[player])
    else
        return Promise.new(function(resolve)
            local connection
            connection = self.PlayerLoaded:Connect(function(newPlayer, replica)
                if (newPlayer == player) then
                    connection:Disconnect()
                    resolve(replica)
                end
            end)
        end)
    end
end


function DataController:KnitInit()
    ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(replica)
        local player = replica.Tags.Player
        if (not player) then
            warn("Player profile received with no player")
        else
            replicasByPlayer[player] = replica
        end
        self.PlayerLoaded:Fire(player, replica)
    end)
end


return DataController