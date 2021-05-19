-- Countdown
-- richard
-- April 01, 2021

--[[

	countdown = Countdown.new(duration: number, maid: Maid?): Countdown

	countdown:Start()
	countdown:Pause()
	countdown:Unpause()
	countdown:Cancel()
	countdown:WaitPromise(): Promise<CountdownState>

	countdown.Clock:Connect(secondsLeft: number)
	countdown.Completed:Connect(state: CountdownState)

]]



local Knit: Knit = require(game:GetService("ReplicatedStorage").Knit)
local Maid = require(Knit.Util.Maid)
local Thread = require(Knit.Util.Thread)
local Signal = require(Knit.Util.Signal)
local EnumList = require(Knit.Util.EnumList)

local Countdown = {}
Countdown.__index = Countdown

Countdown.CountdownState = EnumList.new("CountdownState", {"Completed", "Cancelled"})


function Countdown.new(duration, maid)
	
	local self = setmetatable({}, Countdown)

	self._maid = Maid.new()

	self.Clock = Signal.new(self._maid)
	self.Completed = Signal.new(self._maid)

	self.Playing = false
	self.Duration = duration
	self.SecondsLeft = 0

	if (maid) then
		maid:GiveTask(self)
	end
	
	return self
	
end


function Countdown:Start()
	self.SecondsLeft = self.Duration
	self:Unpause()
end


function Countdown:Pause()
	self._maid.DelayRepeat = nil
end


function Countdown:Unpause()
	self._maid.DelayRepeat = Thread.DelayRepeat(1, function()
		self.SecondsLeft -= 1
		self.Clock:Fire(self.SecondsLeft)
		if (self.SecondsLeft == 0) then
			self.Completed:Fire(Countdown.CountdownState.Completed)
			self._maid.DelayRepeat = nil
		end
	end)
end


function Countdown:Cancel()
	self._maid.DelayRepeat = nil
	self.SecondsLeft = 0
	self.Completed:Fire(Countdown.CountdownState.Cancelled)
end


function Countdown:WaitPromise()
	return self._maid:GivePromise(self.Completed:WaitPromise())
end


function Countdown:Destroy()
	self._maid:Destroy()
end


return Countdown