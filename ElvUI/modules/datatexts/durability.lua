--------------------------------------------------------------------
-- DURABILITY
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local Crayon = LibStub:GetLibrary("LibCrayon-3.0")
	
if not C["datatext"].dur or C["datatext"].dur == 0 then return end

local join = string.join
local floor = math.floor
local random = math.random
local sort = table.sort

local displayString = string.join("", DURABILITY, ": ", "%s%d%%|r")
local tooltipString = "%d %%"

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local fader = CreateFrame("Frame", "DurabilityDataText", ElvuiInfoLeft)

local Text  = DurabilityDataText:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].dur, Text)
fader:SetFrameLevel(fader:GetParent():GetFrameLevel())
fader:SetFrameStrata(fader:GetParent():GetFrameStrata())

local Total = 0
local current, max

E.SetUpAnimGroup(DurabilityDataText)
local function OnEvent(self)
	-- local hexString = "|cff%s"
	Total = 0
	for i = 1, 11 do
		if GetInventoryItemLink("player", L.Slots[i][1]) ~= nil then
			current, max = GetInventoryItemDurability(L.Slots[i][1])
			if current then 
				L.Slots[i][3] = current/max
				Total = Total + 1
			end
		end
	end
	sort(L.Slots, function(a, b) return a[3] < b[3] end)

	if Total > 0 then
		percent = floor(L.Slots[1][3] * 100)
		Text:SetFormattedText(displayString, format("|cff%s", Crayon:GetThresholdHexColor(L.Slots[1][3])), percent)
		if floor(L.Slots[1][3]*100) <= 20 then
			local int = -1
			Stat:SetScript("OnUpdate", function(self, t)
				int = int - t
				if int < 0 then
					E.Flash(DurabilityDataText, 0.53)
					int = 1
				end
			end)				
		else
			Stat:SetScript("OnUpdate", function() end)
			E.StopFlash(DurabilityDataText)
		end
	else
		Text:SetFormattedText(displayString, statusColors[1], 100)
	end
	-- Setup Durability Tooltip
	self:SetAllPoints(Text)
end

Stat:SetScript("OnEnter", function()
	if not InCombatLockdown() then
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(fader)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		for i = 1, 11 do
			if L.Slots[i][3] ~= 1000 then
				green = L.Slots[i][3]*2
				red = 1 - green
				-- print(green); print(red);
				GameTooltip:AddDoubleLine(L.Slots[i][2], format(tooltipString, floor(L.Slots[i][3]*100)), 1 ,1 , 1, red + 1, green, 0)
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cffeda55fClick|r to Show Character Pane")
		GameTooltip:Show()
	end
end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)

Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
Stat:RegisterEvent("MERCHANT_SHOW")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnMouseDown", function() ToggleCharacter("PaperDollFrame") end)
Stat:SetScript("OnEvent", OnEvent)