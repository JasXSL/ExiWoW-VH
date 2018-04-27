local aName, aTable = ...;
local frame = CreateFrame("Frame",nil);
local require = ExiWoW.require;

local Event = require("Event");
local Timer = require("Timer");

frame:RegisterEvent("ADDON_LOADED");
local INI = false

local VH = {
	active_programs = {},		-- programNR => timeAdded, the last one in will be used unless it's MAX_AROUSAL, which always ends up at the bottom
	outputBox = nil,			-- Colored pixel
}

-- These are short programs that can be toggled
VH.programs = {
	MAX_AROUSAL = 1,
	BUZZROCKET = 2,
	PAIN_RECEIVE_SMALL = 3,
	PAIN_RECEIVE_LARGE = 4,
	AROUSAL_RECEIVE_SMALL = 5,
	AROUSAL_RECEIVE_LARGE = 6,
	JADE_ROD = 7,
	SMALL_TICKLE = 8,
	IDLE_OOZE = 9,
	PULSATING_MUSHROOM = 10,
	PULSATING_MUSHROOM_SMALL = 11,
	SHARAS_FEL_ROD = 12,
	SHATTERING_SONG = 13,
	PULSATING_MANA_GEM = 14,
	PULSATING_MANA_GEM_NIGHTBORNE = 15,
	SMALL_TICKLE_RANDOM = 16
}

-- Timeouts for temporary effects
VH.timeouts = {}

frame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	
	if event == "ADDON_LOADED" then

		if ExiWoW and not INI then
			
			INI = true;
			ExiWoW.VH = VH
			VH:ini();
			
		end

	end
end)

function VH:ini()
	
	local box = CreateFrame("Frame", "VibHubConnector", UIParent);
	VH.outputBox = box;
	box:SetSize(5,5)
	box:SetFrameStrata("TOOLTIP");
	box:SetPoint("TOPLEFT")
	box.bg = box:CreateTexture(nil, "BACKGROUND")
	box.bg:SetAllPoints(true)
	box.bg:SetColorTexture(0.0, 0.0, 0.0, 1)

	VH.toggleProgram(VH.programs.MAX_AROUSAL, ExiWoW.ME.excitement >= 1)

	Event.on(Event.Types.EXADD, function(data)
		VH.toggleProgram(VH.programs.MAX_AROUSAL, ExiWoW.ME.excitement >= 1)
	end)

	Event.on(Event.Types.EXADD_DEFAULT, function(data)
		if data.vh then
			VH.addTempProgram(VH.programs.AROUSAL_RECEIVE_SMALL, 0.25)
		end
	end)
	Event.on(Event.Types.EXADD_CRIT, function(data)
		if data.vh then
			VH.addTempProgram(VH.programs.AROUSAL_RECEIVE_LARGE, 1)
		end
	end)
	Event.on(Event.Types.EXADD_M_DEFAULT, function(data)
		if data.vh then
			VH.addTempProgram(VH.programs.PAIN_RECEIVE_SMALL, 0.5)
		end
	end)
	Event.on(Event.Types.EXADD_M_CRIT, function(data)
		if data.vh then
			VH.addTempProgram(VH.programs.PAIN_RECEIVE_LARGE, 1)
		end
	end)
	
	

end

-- Use false duration to turn off
function VH.addTempProgram(program, duration)
	Timer.clear(VH.timeouts[program])
	if type(duration) == "number" and duration > 0 then
		VH.timeouts[program] = Timer.set(function()
			VH.toggleProgram(program, false)
		end, duration)
		VH.toggleProgram(program, true)
	else
		VH.toggleProgram(program, false)
	end
end



function VH.output()

	local programs = {}
	for p,t in pairs(VH.active_programs) do
		table.insert(programs, {p=p,t=t})
	end
	table.sort(programs, function(a, b)
		-- Max arousal program gets bottom priority
		if a.p == VH.programs.MAX_AROUSAL then 
			return false
		elseif b.p == VH.programs.MAX_AROUSAL then 
			return true
		end
		if a.t > b.t then return true end
		return false
	end)

	local out = 0
	if #programs > 0 then
		out = programs[1].p;
	end

	-- 0.2 = Validator. If green is not exactly this (51) it will be assumed your program isn't running
	VH.outputBox.bg:SetColorTexture(out/255, 0.2, 0.0, 1)

end

function VH:toggleMaxArousal(on)
	VH.arousal_maxed = not not on;
	VH:output();
end

-- /run ExiWoW.VH.toggleProgram(1, true)
function VH.toggleProgram(program, enabled)
	local active = VH.active_programs;
	if not enabled then enabled = nil 
	else enabled = GetTime() end
	if type(program) ~= "number" then return false end
	active[program] = enabled
	VH:output();
end

