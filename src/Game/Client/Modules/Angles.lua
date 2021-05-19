-- Angles
-- littensy
-- August 31, 2020



local Angles = {}

local PI = math.pi
local HALF_PI = math.pi/2
local COMPONENTS = {"X", "Y", "Z"}


function Angles.ToOrientation(cframe)
    return Vector3.new(cframe:ToOrientation())
end


function Angles.FromOrientation(orientation)
    return CFrame.fromOrientation(orientation.X, orientation.Y, orientation.Z)
end


function Angles.Subtract(a, b)
    local d = table.create(3, 0)
    for i = 1, 3 do
        d[i] = (a[COMPONENTS[i]] - b[COMPONENTS[i]] + HALF_PI) % PI - HALF_PI
    end
    return Vector3.new(d[1], d[2], d[3])
end


return Angles