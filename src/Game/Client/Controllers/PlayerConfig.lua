-- PlayerConfig
-- richard
-- April 05, 2021



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Signal = require(Knit.Util.Signal)
local Promise = require(Knit.Util.Promise)

local config = {}
local configSignals = {}
local configAllDone = false

local promiseResolutions = {}

local PlayerConfig: Controller = Knit.CreateController { Name = "PlayerConfig" }


function PlayerConfig:GetConfig()
	return config
end


function PlayerConfig:Get(key)
	return config[key]
end


function PlayerConfig:GetChangedSignal(key)
	return configSignals[key]
end


function PlayerConfig:Wait()
	if (configAllDone) then
		return Promise.resolve()
	else
		return Promise.new(function(resolve)
			table.insert(promiseResolutions, resolve)
		end)
	end
end


function PlayerConfig:KnitInit()
	Knit.Controllers.DataController:Await():Then(function(profileReplica)
		for k, v in pairs(profileReplica.Data.Config) do
			configSignals[k] = Signal.new()
			config[k] = v

			profileReplica:ListenToChange({"Config", k}, function(newValue, oldValue)
				configSignals[k]:Fire(newValue, oldValue)
			end)
		end

		configAllDone = true
		
		for _, resolve in ipairs(promiseResolutions) do
			resolve()
		end

		table.clear(promiseResolutions)
	end)
end


return PlayerConfig