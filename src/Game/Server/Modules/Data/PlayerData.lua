-- PlayerData
-- littensy
-- November 30, 2020



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Thread = require(Knit.Util.Thread)

local PlayerData = {}
PlayerData.__index = PlayerData

local playerDataByPlayer = {}


function PlayerData.FromPlayer(player)
    return playerDataByPlayer[player]
end


function PlayerData.new(player, profile, replica)

    local self = setmetatable({}, PlayerData)

    self.Player = player
    self.Profile = profile
    self.Data = profile.Data
    self.Replica = replica

    -- Check global updates:
    Thread.SpawnNow(function()
        for _, update in ipairs(profile.GlobalUpdates:GetActiveUpdates()) do
            self.Profile.GlobalUpdates:LockActiveUpdate(update[1])
        end
        for _, update in ipairs(profile.GlobalUpdates:GetLockedUpdates()) do
            self:ClearLockedUpdate(update[1], update[2])
        end
    end)

    profile.GlobalUpdates:ListenToNewActiveUpdate(function(updateId)
        self.Profile.GlobalUpdates:LockActiveUpdate(updateId)
    end)

    profile.GlobalUpdates:ListenToNewLockedUpdate(function(updateId, updateData)
        self:ClearLockedUpdate(updateId, updateData)
    end)

    profile:ListenToRelease(function()
        replica:Destroy()
        playerDataByPlayer[player] = nil
    end)

    playerDataByPlayer[player] = self

    return self

end


function PlayerData:ClearLockedUpdate(updateId, _updateData)
    -- Handle updateData here

    self.Profile.GlobalUpdates:ClearLockedUpdate(updateId)
end


function PlayerData:Increment(key, value)
    self.Replica:SetValue({key}, self.Data[key] + value)
    if (self[key .. "Changed"]) then
        self[key .. "Changed"]:Fire(self.Data[key])
    end
end


function PlayerData:Set(path, value)
    self.Replica:SetValue(path, value)
end


function PlayerData:SetValues(path, values)
    self.Replica:SetValues(path, values)
end


function PlayerData:SyncShallow(template, target)
    local data = target or self.Profile.Data
    for k in pairs(data) do
        if (template[k] == nil) then
            data[k] = nil
        end
    end
    for k, v in pairs(template) do
        if (data[k] == nil) then
            data[k] = v
        end
    end
end


function PlayerData:Destroy()
    self.Profile:Release()
end


return PlayerData