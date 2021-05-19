local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Util.Promise)

local function SafeWaitForChild(parent, childName, timeout)
    return Promise.new(function(resolve, reject, onCancel)
        local child = parent:FindFirstChild(childName)
        if child then
            resolve(child)
        else
            local offset = timeout or 5
            local startTime = os.clock()
            local cancelled = false
            local connection

            onCancel(function()
                cancelled = true
                if connection then
                    connection = connection:Disconnect()
                end

                return reject("SafeWaitForChild(" .. parent:GetFullName() .. ", \"" .. tostring(childName) .. "\") was cancelled.")
            end)

            connection = parent:GetPropertyChangedSignal("Parent"):Connect(function()
                if not parent.Parent then
                    if connection then
                        connection = connection:Disconnect()
                    end

                    cancelled = true
                    return reject("SafeWaitForChild(" .. parent:GetFullName() .. ", \"" .. tostring(childName) .. "\") was cancelled.")
                end
            end)

            repeat
                Promise.Delay(0.03):Await()
                child = parent:FindFirstChild(childName)
            until child or startTime + offset < os.clock() or cancelled

            if connection then
                connection = connection:Disconnect()
            end

            if not timeout then
                reject("Infinite yield possible for SafeWaitForChild(" .. parent:GetFullName() .. ", \"" .. tostring(childName) .. "\")")
            elseif child then
                resolve(child)
            end
        end
    end)
end

return SafeWaitForChild