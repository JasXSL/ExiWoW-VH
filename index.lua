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
	SMALL_TICKLE_RANDOM = 16,
	GROIN_RUMBLE_TOTEM = 17,
	VINE_THONG = 18,
	THONG_OF_VALOR = 19
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
	
	if globalStorage.enabled == nil then
		globalStorage.enabled = true;
	end

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
	
	VH:settingsBuild();

	if not globalStorage.enabled then
		return;
	end
	-- Check cvars
	local cvars = {
		["Gamma"]=1.0000, 
		["Contrast"]=50.0000, 
		["Brightness"]=50.0000
	};
	for k,v in pairs(cvars) do
		if tonumber(GetCVar(k)) ~= v then
			StaticPopupDialogs["VH_ERROR"] = {
				text = "VibHub connector only works with default gamma/brightness/contrast. Want to reset these?",
				button1 = "Reset",
				button2 = "Ignore",
				OnAccept = function()
					for ck,cv in pairs(cvars) do
						SetCVar(ck,cv);
					end
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
			};
			StaticPopup_Show("VH_ERROR");
			break;
		end
	end

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

	if globalStorage.enabled then
		VH.outputBox:Show();
	else
		VH.outputBox:Hide();
	end

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
		if a.t > b.t then 
			return true 
		end
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
	if not enabled then 
		enabled = nil ;
	else enabled = GetTime() end
	if type(program) ~= "number" then 
		return false ;
	end
	active[program] = enabled;
	VH:output();

end


function VH.settingsBuild()
	--if true then return end
	local panel = CreateFrame("Frame", aName.."_globalConf", UIParent);
	panel.name = "ExiWoW-VH";
	InterfaceOptions_AddCategory(panel);

	local gPadding = 30;
	local gBottom = 40;

	-- Create the buttons
	local function createCheckbutton(suffix, parent, attach, x_loc, y_loc, displayname, tooltip)
		local checkbutton = CreateFrame("CheckButton", aName .. "_globalConf_"..suffix, parent, "ChatConfigCheckButtonTemplate");
		checkbutton.tooltip = tooltip;
		checkbutton:SetPoint(attach, x_loc, y_loc);
		getglobal(checkbutton:GetName() .. 'Text'):SetText(displayname);
		return checkbutton;
	end

	local n = 0;
	createCheckbutton("enable", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable", "Enables the VibHub Connector");
	n = n+1;
	--createCheckbutton("separate_ports", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Separate Ports", "Separates the VibHub ports (1=Groin, 2=Rear, 3=Chest). Otherwise all programs will run on all ports.");
			
	panel.okay = function (self) 

		local gs = globalStorage;
		local prefix = aName.."_globalConf_";
		gs.enabled = getglobal(prefix.."enable"):GetChecked();
		--gs.separate_ports = getglobal(prefix.."separate_ports"):GetValue();
		VH.output();

	end;
	panel.cancel = function(self) 
		VH.settingsUpdate(); 
	end

	VH.settingsUpdate();

end

function VH.settingsUpdate()
	--if true then return end
	local gs = globalStorage;
	local prefix = aName.."_globalConf_";
	getglobal(prefix.."enable"):SetChecked(gs.enabled);
	--getglobal(prefix.."separate_ports"):SetValue(gs.separate_ports);

	

end



