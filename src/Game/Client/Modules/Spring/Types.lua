-- Types
-- March 16, 2021

--[[
    Original author:
    https://devforum.roblox.com/t/spring-driven-motion-spr/714728
]]

local min = math.min

local Types = {

    number = {
        ToType = function(value)
            return {value}
        end,

        ToScalar = function(value)
            return value[1]
        end,
    },

    table = {
        ToScalar = function(tbl)
            local newTbl = table.create(#tbl, 0)
            for i, v in ipairs(tbl) do
                newTbl[i] = v
            end
            return newTbl
        end,

        ToType = function(tbl)
            local newTbl = table.create(#tbl, 0)
            for i, v in ipairs(tbl) do
                newTbl[i] = v
            end
            return newTbl
        end,
    },

    NumberRange = {
        ToScalar = function(value)
            return {value.Min, value.Max}
        end,

        ToType = function(value)
            return NumberRange.new(value[1], value[2])
        end,
    },

    UDim = {
        ToScalar = function(value)
            return {value.Scale, value.Offset}
        end,

        ToType = function(value)
            return UDim.new(value[1], value[2])
        end,
    },

    UDim2 = {
        ToScalar = function(value)
            local x = value.X
            local y = value.Y
            return {x.Scale, x.Offset, y.Scale, y.Offset}
        end,

        ToType = function(value)
            return UDim2.new(value[1], value[2], value[3], value[4])
        end,
    },

    Vector2 = {
        ToScalar = function(value)
            return {value.X, value.Y}
        end,

        ToType = function(value)
            return Vector2.new(value[1], value[2])
        end,
    },

    Vector3 = {
        ToScalar = function(value)
            return {value.X, value.Y, value.Z}
        end,

        ToType = function(value)
            return Vector3.new(value[1], value[2], value[3])
        end,
    },

    CFrame = {
        ToScalar = function(value: CFrame)
            local axis, angle = value:ToAxisAngle()

            local qW = math.cos(angle / 2)
            local qX = math.sin(angle / 2) * axis.x
            local qY = math.sin(angle / 2) * axis.y
            local qZ = math.sin(angle / 2) * axis.z

            return {value.X, value.Y, value.Z, qX, qY, qZ, qW}
        end,

        ToType = function(value)
            return CFrame.new(table.unpack(value, 1, 7))
        end,
    },

    Color3 = {
        ToScalar = function(value)
            -- convert RGB to a variant of cieluv space
            local r, g, b = value.R, value.G, value.B

            -- D65 sRGB inverse gamma correction
            r = r < 0.0404482362771076 and r/12.92 or 0.87941546140213*(r + 0.055)^2.4
            g = g < 0.0404482362771076 and g/12.92 or 0.87941546140213*(g + 0.055)^2.4
            b = b < 0.0404482362771076 and b/12.92 or 0.87941546140213*(b + 0.055)^2.4

            -- sRGB -> xyz
            local x = 0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b
            local y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
            local z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b

            -- xyz -> modified cieluv
            local l = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y

            local u, v
            if z > 1e-14 then
                u = l*x/z
                v = l*(9*y/z - 0.46832)
            else
                u = -0.19783*l
                v = -0.46832*l
            end

            return {l, u, v}
        end,

        ToType = function(value)
            -- convert back from modified cieluv to rgb space

            local l = value[1]
            if l < 0.0197955 then
                return Color3.new(0, 0, 0)
            end
            local u = value[2]/l + 0.19783
            local v = value[3]/l + 0.46832

            -- cieluv -> xyz
            local y = (l + 16)/116
            y = y > 0.206896551724137931 and y*y*y or 0.12841854934601665*y - 0.01771290335807126
            local x = y*u/v
            local z = y*((3 - 0.75*u)/v - 5)

            -- xyz -> D65 sRGB
            local r =  7.2914074*x - 1.5372080*y - 0.4986286*z
            local g = -2.1800940*x + 1.8757561*y + 0.0415175*z
            local b =  0.1253477*x - 0.2040211*y + 1.0569959*z

            -- clamp minimum sRGB component
            if r < 0 and r < g and r < b then
                r, g, b = 0, g - r, b - r
            elseif g < 0 and g < b then
                r, g, b = r - g, 0, b - g
            elseif b < 0 then
                r, g, b = r - b, g - b, 0
            end

            -- gamma correction from D65
            -- clamp to avoid undesirable overflow wrapping behavior on certain properties (e.g. BasePart.Color)
            return Color3.new(
                min(r < 3.1306684425e-3 and 12.92*r or 1.055*r^(1/2.4) - 0.055, 1),
                min(g < 3.1306684425e-3 and 12.92*g or 1.055*g^(1/2.4) - 0.055, 1),
                min(b < 3.1306684425e-3 and 12.92*b or 1.055*b^(1/2.4) - 0.055, 1)
            )
        end,
    },

}

return Types