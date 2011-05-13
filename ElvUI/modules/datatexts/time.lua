--------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].wowtime or C["datatext"].wowtime == 0 then return end

local europeDisplayFormat = string.join("", "%02d", E.ValColor, ":|r%02d")
local ukDisplayFormat = string.join("", "", "%d", E.ValColor, ":|r%02d", E.ValColor, " %s|r")
local europeDisplayFormat_nocolor = string.join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = string.join("", "", "%d", ":|r%02d", " %s|r")
local timerLongFormat = "%d:%02d:%02d"
local timerShortFormat = "%d:%02d"
local lockoutInfoFormat = "|cffcccccc[%d%s]|r %s |cfff04000(%s/%s)|r"
local formatBattleGroundInfo = "%s: "
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local difficultyInfo = { "N", "N", "H", "H" }
local lockoutFormatString = { "%dd %02dh %02dm", "%dd %dh %02dm", "%02dh %02dm", "%dh %02dm", "%dh %02dm", "%dm" }
local curHr, curMin, curAmPm
local playedTime, levelTime

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local o = ChatFrame_DisplayTimePlayed
ChatFrame_DisplayTimePlayed = function( ... )
	if requesting then
		requesting = false
		return
	end
	return o( ... )
end

function UpdateTimePlayed()
	requesting = true
	RequestTimePlayed()
end

local function OnEvent(self, event, ...)
	if event == "TIME_PLAYED_MSG" then
		playedTime = select(1, ...)
		levelTime = select(2, ...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdateTimePlayed()
	end
end

local fader = CreateFrame("Frame", "TimeDataText", ElvuiInfoLeft)

local Text = fader:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].wowtime, Text)
fader:SetFrameLevel(fader:GetParent():GetFrameLevel())
fader:SetFrameStrata(fader:GetParent():GetFrameStrata())
	
local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }

local FormatTime
do
	local DAY, MIN, HOUR, SEC
	function FormatTime( t )
		if not t then return end

		if not DAY then
			if C["datatext"].uselongtime == true then
				local DAY_ABBR, HOUR_ABBR, MIN_ABBR, SEC_ABBR = "days", "hours", "minutes", "seconds"
				DAY = format("|cffffffff%s|r |cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r", "%d", DAY_ABBR, "%02d", HOUR_ABBR, "%02d", MIN_ABBR, "%02d", SEC_ABBR)
				HOUR = format("|cffffffff%s|r |cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r", "%d", HOUR_ABBR, "%02d", MIN_ABBR, "%02d", SEC_ABBR)
				MIN = format("|cffffffff%s|r|cffffcc00%s|r, |cffffffff%s|r |cffffcc00%s|r", "%d", MIN_ABBR, "%02d", SEC_ABBR)
				SEC = format("|cffffffff%s|r |cffffcc00%s|r", "%d", SEC_ABBR)
			else
				local DAY_ABBR, HOUR_ABBR, MIN_ABBR, SEC_ABBR = DAY_ONELETTER_ABBR:replace( "%d", "" ), HOUR_ONELETTER_ABBR:replace( "%d", "" ), MINUTE_ONELETTER_ABBR:replace( "%d", ""), SECOND_ONELETTER_ABBR:replace( "%d", "" )
				DAY = format("|cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r", "%d", DAY_ABBR, "%02d", HOUR_ABBR, "%02d", MIN_ABBR, "%02d", SEC_ABBR)
				HOUR = format("|cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r", "%d", HOUR_ABBR, "%02d", MIN_ABBR, "%02d", SEC_ABBR)
				MIN = format("|cffffffff%s|r|cffffcc00%s|r |cffffffff%s|r|cffffcc00%s|r", "%d", MIN_ABBR, "%02d", SEC_ABBR)
				SEC = format("|cffffffff%s|r|cffffcc00%s|r", "%d", SEC_ABBR)
			end
		end

		local d, h, m, s = floor(t / 86400), mod(floor(t / 3600), 24), mod(floor(t / 60), 60), mod(floor(t), 60)
		if d > 0 then
			return format(DAY, d, h, m, s)
		elseif h > 0 then
			return format(HOUR, h, m, s)
		elseif m > 0 then
			return format(MIN, m, s)
		else
			return format(SEC, s)
		end
	end
end

local function CalculateTimeValues(tt)
	local Hr, Min, AmPm
	if tt and tt == true then
		if C["datatext"].localtime == true then
			Hr, Min = GetGameTime()
			if C["datatext"].time24 == true then
				return Hr, Min, -1
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr - 12 end
					AmPm = 1
				else
					if Hr == 0 then Hr = 12 end
					AmPm = 2
				end
				return Hr, Min, AmPm
			end			
		else
			local Hr24 = tonumber(date("%H"))
			Hr = tonumber(date("%I"))
			Min = tonumber(date("%M"))
			if C["datatext"].time24 == true then
				return Hr24, Min, -1
			else
				if Hr24>=12 then AmPm = 1 else AmPm = 2 end
				return Hr, Min, AmPm
			end
		end
	else
		if C["datatext"].localtime == true then
			local Hr24 = tonumber(date("%H"))
			Hr = tonumber(date("%I"))
			Min = tonumber(date("%M"))
			if C["datatext"].time24 == true then
				return Hr24, Min, -1
			else
				if Hr24>=12 then AmPm = 1 else AmPm = 2 end
				return Hr, Min, AmPm
			end
		else
			Hr, Min = GetGameTime()
			if C["datatext"].time24 == true then
				return Hr, Min, -1
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr - 12 end
					AmPm = 1
				else
					if Hr == 0 then Hr = 12 end
					AmPm = 2
				end
				return Hr, Min, AmPm
			end
		end	
	end
end

local function CalculateTimeLeft(time)
		local hour = floor(time / 3600)
		local min = floor(time / 60 - (hour*60))
		local sec = time - (hour * 3600) - (min * 60)
		
		return hour, min, sec
end

local function formatResetTime(sec)
	local d,h,m,s = ChatFrame_TimeBreakDown(floor(sec))
	if d > 0 then 
		return format(lockoutFormatString[h>10 and 1 or 2], d, h, m)
	end
	if h > 0 then
		return format(lockoutFormatString[h>10 and 3 or 4], h, m)
	end
	if m > 0 then 
		return format(lockoutFormatString[m>10 and 5 or 6], m) 
	end
end

local int = 1
E.SetUpAnimGroup(TimeDataText)
local function Update(self, t)
	int = int - t
	if int > 0 then return end
	
	local Hr, Min, AmPm = CalculateTimeValues(false)
	
	if GameTimeFrame.flashInvite then
		E.Flash(TimeDataText, 0.53)
	else
		E.StopFlash(TimeDataText)
	end
	
	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) then
		int = 2
		return
	end
	
	curHr = Hr
	curMin = Min
	curAmPm = AmPm
		
	if AmPm == -1 then
		Text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		Text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
	
	self:SetAllPoints(Text)
	int = 2
end

Stat:SetScript("OnEnter", function(self)
	if InCombatLockdown() then return end 
	OnLoad = function(self) RequestRaidInfo() UpdatePlayedTime() end
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(fader)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()

	-- played times
	GameTooltip:AddLine("Played Time")
	GameTooltip:AddDoubleLine("Total:", FormatTime(playedTime), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	GameTooltip:AddDoubleLine("Level:", FormatTime(levelTime), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	GameTooltip:AddLine(" ")
	
	GameTooltip:AddLine(VOICE_CHAT_BATTLEGROUND);
	local localizedName, isActive, canQueue, startTime, canEnter
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				local hour, min, sec = CalculateTimeLeft(startTime)
				if hour > 0 then 
					startTime = string.format(timerLongFormat, hour, min, sec) 
				else 
					startTime = string.format(timerShortFormat, min, sec)
				end
			end
			GameTooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)	
		end
	end	

	local timeText
	local Hr, Min, AmPm = CalculateTimeValues(true)

	GameTooltip:AddLine(" ")
	timeText = C["datatext"].localtime == true and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME
	if AmPm == -1 then
			GameTooltip:AddDoubleLine(timeText, string.format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
			GameTooltip:AddDoubleLine(timeText, string.format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	local oneraid, lockoutColor
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, difficulty, locked, extended, _, isRaid, maxPlayers, _, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			local tr,tg,tb,diff
			if not oneraid then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L.datatext_savedraid)
				oneraid = true
			end
			if extended then lockoutColor = lockoutColorExtended else lockoutColor = lockoutColorNormal end
			GameTooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, difficultyInfo[difficulty], name, encounterProgress, numEncounters), formatResetTime(reset), 1,1,1, lockoutColor.r,lockoutColor.g,lockoutColor.b)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffeda55fClick|r to Show Calendar")
	GameTooltip:Show()
end)

Stat:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("UPDATE_INSTANCE_INFO")
Stat:RegisterEvent("TIME_PLAYED_MSG")

Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
Stat:SetScript("OnMouseDown", function() GameTimeFrame:Click() end)
Stat:SetScript("OnUpdate", Update)
Stat:SetScript("OnEvent", OnEvent)
Update(Stat, 6)
