--------------------------------------------------------------------
-- Recount DPS
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local playerName = UnitName("player")
local currentFightDPS

if not C["datatext"].recount or C["datatext"].recount == 0 then return end

local RecountDPS = CreateFrame("Frame")
RecountDPS:EnableMouse(true)
RecountDPS:SetFrameStrata("MEDIUM")
RecountDPS:SetFrameLevel(3)

local Text = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].recount, Text)
RecountDPS:SetAllPoints(Text)

function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if IsAddOnLoaded("Recount") then
			RecountDPS:RegisterEvent("PLAYER_REGEN_ENABLED")
			RecountDPS:RegisterEvent("PLAYER_REGEN_DISABLED")
			playerName = UnitName("player")
			currentFightDPS = 0
		else
			return
		end
		RecountDPS:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.updateDPS()
		RecountDPS:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function RecountDPS:RecountHook_UpdateText()
	self:updateDPS()
end

function RecountDPS:updateDPS()
	Text:SetText("DPS: " .. E.ValColor .. RecountDPS.getDPS() .. "|r")
end

function RecountDPS:getDPS()
	if not IsAddOnLoaded("Recount") then return "N/A" end
	if C["datatext"].recountraiddps == true then
		-- show raid dps
		_, dps = RecountDPS:getRaidValuePerSecond(Recount.db.profile.CurDataSet)
		return dps
	else
		return RecountDPS.getValuePerSecond()
	end
end

-- quick dps calculation from recount's data
function RecountDPS:getValuePerSecond()
	local _, dps = Recount:MergedPetDamageDPS(Recount.db2.combatants[playerName], Recount.db.profile.CurDataSet)
	return math.floor(10 * dps + 0.5) / 10
end

function RecountDPS:getRaidValuePerSecond(tablename)
	local dps, curdps, data, damage, temp = 0, 0, nil, 0, 0
	for _,data in pairs(Recount.db2.combatants) do
		if data.Fights and data.Fights[tablename] and (data.type=="Self" or data.type=="Grouped" or data.type=="Pet" or data.type=="Ungrouped") then
			temp, curdps = Recount:MergedPetDamageDPS(data,tablename)
			if data.type ~= "Pet" or (not Recount.db.profile.MergePets and data.Owner and (Recount.db2.combatants[data.Owner].type=="Self" or Recount.db2.combatants[data.Owner].type=="Grouped" or Recount.db2.combatants[data.Owner].type=="Ungrouped")) or (not Recount.db.profile.MergePets and data.Name and data.GUID and self:matchUnitGUID(data.Name, data.GUID)) then
				dps = dps + 10 * curdps
				damage = damage + temp
			end
		end
	end
	return math.floor(damage + 0.5) / 10, math.floor(dps + 0.5)/10
end

-- tracked events
RecountDPS:RegisterEvent("PLAYER_LOGIN")
RecountDPS:RegisterEvent("PLAYER_ENTERING_WORLD")

-- scripts
RecountDPS:SetScript("OnEnter", function(self)
	if InCombatLockdown() then return end
	
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	if IsAddOnLoaded("Recount") then
		local damage, dps = Recount:MergedPetDamageDPS(Recount.db2.combatants[playerName], Recount.db.profile.CurDataSet)
		local raid_damage, raid_dps = RecountDPS:getRaidValuePerSecond(Recount.db.profile.CurDataSet)
		-- format the number
		dps = math.floor(10 * dps + 0.5) / 10
		GameTooltip:AddLine("Recount")
		GameTooltip:AddDoubleLine("Personal Damage:", damage, 1, 1, 1, 0.8, 0.8, 0.8)
		GameTooltip:AddDoubleLine("Personal DPS:", dps, 1, 1, 1, 0.8, 0.8, 0.8)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Raid Damage:", raid_damage, 1, 1, 1, 0.8, 0.8, 0.8)
		GameTooltip:AddDoubleLine("Raid DPS:", raid_dps, 1, 1, 1, 0.8, 0.8, 0.8)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cffeda55fLeft Click|r to toggle Recount")
		GameTooltip:AddLine("|cffeda55fRight Click|r to reset data")
		GameTooltip:AddLine("|cffeda55fShift + Right Click|r to open config")
	else
		GameTooltip:AddLine("Recount is not loaded.", 255, 0, 0)
		GameTooltip:AddLine("Enable Recount and reload your UI.")
	end
	GameTooltip:Show()
end)
RecountDPS:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		if not IsShiftKeyDown() then
			Recount:ShowReset()
		else
			Recount:ShowConfig()
		end
	elseif button == "LeftButton" then
		if Recount.MainWindow:IsShown() then
			Recount.MainWindow:Hide()
		else 
			Recount.MainWindow:Show()
			Recount:RefreshMainWindow()
		end
	end
end)
RecountDPS:SetScript("OnEvent", OnEvent)
RecountDPS:SetScript("OnLeave", function() GameTooltip:Hide() end)
RecountDPS:SetScript("OnUpdate", function(self, t)
	local int = -1
	int = int - t
	if int < 0 then
		self.updateDPS()
		int = 1
	end
end)