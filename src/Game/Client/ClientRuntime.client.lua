local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Component = require(Knit.Util.Component)

-- Expose module folders:
Knit.Shared = game:GetService("ReplicatedStorage").Game.Shared
Knit.Components = script.Parent.Components
Knit.Modules = script.Parent.Modules

-- Load all controllers:
for _,obj in ipairs(script.Parent.Controllers:GetDescendants()) do
    if (obj:IsA("ModuleScript")) then
        require(obj)
    end
end

Knit.Start()

-- Load Components:
Component.Auto(Knit.Components)