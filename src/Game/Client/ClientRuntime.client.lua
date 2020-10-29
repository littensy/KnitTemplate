local Knit = require(game:GetService("ReplicatedStorage").Knit)

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