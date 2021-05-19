-- ClientRuntime
-- littensy
-- February 06, 2021



local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit: Knit = require(ReplicatedStorage.Knit)
local Component = require(Knit.Util.Component)

-- Load ReplicaController:
Knit.ReplicaController = require(ReplicatedStorage:WaitForChild("Replica"):WaitForChild("ReplicaController"))

-- Populate Knit:
Knit.Assets = ReplicatedStorage:WaitForChild("Assets")
Knit.Shared = ReplicatedStorage.Game.Shared
Knit.Components = script.Parent.Components
Knit.Modules = script.Parent.Modules

-- Add controllers & components:
Knit.AddControllersDeep(script.Parent.Controllers)
Component.Auto(script.Parent.Components)

-- Start Knit:
Knit.Start():Then(function()
    Knit.ReplicaController.RequestData()
end):Catch(function(err)
    warn("Knit framework failure: " .. tostring(err))
end)