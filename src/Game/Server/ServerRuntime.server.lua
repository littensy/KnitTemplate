-- Client Runtime
-- littensy
-- January 13, 2021



local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit: Knit = require(ReplicatedStorage.Knit)
local Component = require(Knit.Util.Component)

-- Load ReplicaService:
Knit.ReplicaService = require(game:GetService("ServerScriptService").Replica.ReplicaService)

-- Populate Knit:
Knit.Assets = ReplicatedStorage:WaitForChild("Assets")
Knit.Shared = ReplicatedStorage.Game.Shared
Knit.Components = script.Parent.Components
Knit.Modules = script.Parent.Modules

-- Add controllers & components:
Knit.AddServicesDeep(script.Parent.Services)
Component.Auto(script.Parent.Components)

-- Start Knit:
Knit.Start():Catch(function(err)
    warn("Knit framework failure: " .. tostring(err))
end)