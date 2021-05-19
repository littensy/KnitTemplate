-- SoundUtil
-- littensy
-- December 30, 2020



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Util.Promise)

local SoundUtil
do
    if (game:GetService("RunService"):IsClient()) then
        SoundUtil = {
            Assets = {},
            SoundGroups = {},
        }
    else
        SoundUtil = {
            Assets = {
                Music = {},
            },
            SoundGroups = {},
        }
    end
end

local SoundService = game:GetService("SoundService")

for name, soundGroup in pairs(SoundUtil.SoundGroups) do
    soundGroup.Name = name
    soundGroup.Parent = SoundService
end


function SoundUtil:Load(sound, timeout)
    if (sound.IsLoaded) then
		return Promise.resolve()
	else
		return Promise.fromEvent(sound.Loaded)
            :Timeout(timeout, "Sound did not load in time")
	end
end


function SoundUtil:Create(soundId, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    if (properties) then
        for key, value in pairs(properties) do
            sound[key] = value
        end
    end
    if (not sound.Parent) then
        sound.Parent = SoundService
    end
    return sound
end


function SoundUtil:PlayOnce(soundId, properties)
    local sound = self:Create(soundId, properties)
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound:Play()
    return sound
end


function SoundUtil:Play(soundId, properties)
    local sound = self:Create(soundId, properties)
    sound:Play()
    return sound
end


return SoundUtil