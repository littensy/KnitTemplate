-- Spring
-- March 16, 2021

--[[
    Original author:
    https://devforum.roblox.com/t/spring-driven-motion-spr/714728
]]



local Spring = {}
Spring.__index = Spring

local SLEEP_OFFSET_SQ_LIMIT = (1/3840)^2
local SLEEP_VELOCITY_SQ_LIMIT = 1e-2^2
local EPS = 1e-5

local exp = math.exp
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt

local Types = require(script.Types)

local springsActive = {} do
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        for spring in pairs(springsActive) do
            spring:Step(dt)
        end
    end)
end

local function magnitudeSq(vec)
	local out = 0
	for _, v in ipairs(vec) do
		out += v^2
	end
	return out
end

local function distanceSq(vec0, vec1)
	local out = 0
	for i0, v0 in ipairs(vec0) do
		out += (vec1[i0] - v0)^2
	end
	return out
end

local function copyTbl(tbl)
    local newTbl = {}
    for k, v in pairs(tbl) do
        newTbl[k] = v
    end
    return newTbl
end


function Spring.Lerp(a, b, alpha)
    assert(typeof(a) == typeof(b), "a must be same type as b")
    local medium = Types[typeof(a)]
    local start = medium.ToScalar(a)
    local goal = medium.ToScalar(b)
    for i, v1 in ipairs(start) do
        local v2 = goal[i]
        start[i] = v1 + (v2 - v1) * alpha
    end
    return medium.ToType(start)
end


function Spring.new(initialValue, damping, frequency, callback)
    
    assert(Types[typeof(initialValue)], "Spring cannot be a " .. typeof(initialValue))
    assert(type(damping) == "number", "Argument #2 'damping' must be a number")
    assert(type(frequency) == "number", "Argument #3 'frequency' must be a number")
    
    local self = setmetatable({}, Spring)

    self.Damping = damping
    self.Frequency = frequency
    self.Callback = callback
    self.Playing = false
    self.Sleep = true

    self._medium = Types[typeof(initialValue)]
    self._target = self._medium.ToScalar(initialValue)
    self._position = self._medium.ToScalar(initialValue)
    self._velocity = self._medium.ToScalar(initialValue)
    
    return self
    
end


function Spring:_step(dt)
	-- https://github.com/Fraktality/spr/blob/master/spr.lua
    -- https://github.com/Fraktality/spr/blob/master/LICENSE

    local d = self.Damping
    local f = self.Frequency * 2 * math.pi
    local position = self._position
    local velocity = self._velocity
    local target = self._target

    if (d == 1) then -- critically damped
        local q = exp(-f*dt)
        local w = dt*q

        local c0 = q + w*f
        local c2 = q - w*f
        local c3 = w*f*f

        for idx, p in ipairs(position) do
            local v = velocity[idx]
            local t = target[idx]
            local o = p - t
            position[idx] = o*c0 + v*w + t
            velocity[idx] = v*c2 - o*c3
        end

    elseif (d < 1) then -- underdamped
        local q = exp(-d*f*dt)
        local c = sqrt(1 - d*d)

        local i = cos(dt*f*c)
        local j = sin(dt*f*c)

        local z
        if c > EPS then
            z = j/c
        else
            local a = dt*f
            z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
        end

        local y
        if f*c > EPS then
            y = j/(f*c)
        else
            local b = f*c
            y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
        end

        for idx, p in ipairs(position) do
            local v = velocity[idx]
            local t = target[idx]
            local o = p - t
            position[idx] = (o*(i + z*d) + v*y)*q + t
            velocity[idx] = (v*(i - z*d) - o*(z*f))*q
        end

    else -- overdamped
        local c = sqrt(d*d - 1)

        local r1 = -f*(d - c)
        local r2 = -f*(d + c)

        local ec1 = exp(r1*dt)
        local ec2 = exp(r2*dt)

        for idx, p in ipairs(position) do
            local v = velocity[idx]
            local t = target[idx]
            local o = p - t
            local co2 = (v - o*r1)/(2*f*c)
            local co1 = ec1*(o - co2)

            position[idx] = co1 + co2*ec2 + t
            velocity[idx] = co1*r1 + co2*ec2*r2
        end
    end
end


function Spring:Start()
    springsActive[self] = true
    self.Playing = true
end


function Spring:Stop()
    springsActive[self] = nil
    self.Playing = false
end


function Spring:Step(dt)
    local canSleep = self:CanSleep()

    if (canSleep and not self.Sleep) then
        -- Set position to the target if state changed to asleep:
        self._position = copyTbl(self._target)
    elseif (not canSleep) then
        self:_step(dt)
    end

    if (self.Callback and not canSleep) then
        self.Callback(self:GetPosition())
    end

    self.Sleep = canSleep
end


function Spring:CanSleep()
    if (magnitudeSq(self._velocity) > SLEEP_VELOCITY_SQ_LIMIT) then
        return false
    end
    if (distanceSq(self._position, self._target) > SLEEP_OFFSET_SQ_LIMIT) then
        return false
    end
    return true
end


function Spring:GetTarget()
    return self._medium.ToType(self._target)
end


function Spring:GetPosition()
    return self._medium.ToType(self._position)
end


function Spring:GetVelocity()
    return self._medium.ToType(self._velocity)
end


function Spring:SetTarget(target)
    self._target = self._medium.ToScalar(target)
end


function Spring:SetPosition(position)
    self._position = self._medium.ToScalar(position)
end


function Spring:SetVelocity(velocity)
    self._velocity = self._medium.ToScalar(velocity)
end


function Spring:ApplyImpulse(impulse)
    local scalar = self._medium.ToScalar(impulse)
    for i in ipairs(self._velocity) do
        self._velocity[i] += scalar[i]
    end
end


Spring.Destroy = Spring.Stop

return Spring