--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].gold or C["datatext"].gold == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].gold, Text)

local defaultColor = { 1, 1, 1 }
local Profit	= 0
local Spent		= 0
local OldMoney	= 0

local function formatMoney(c)
	--local gold = floor(math.abs(money) / 10000)
	--local silver = mod(floor(math.abs(money) / 100), 100)
	--local copper = mod(floor(math.abs(money)), 100)
	--if gold ~= 0 then
	--	return format("%s"..L.goldabbrev.." %s"..L.silverabbrev.." %s"..L.copperabbrev, gold, silver, copper)
	--elseif silver ~= 0 then
	--	return format("%s"..L.silverabbrev.." %s"..L.copperabbrev, silver, copper)
	--else
	--	return format("%s"..L.copperabbrev, copper)
	--end
	local str = ""
	if not c or c < 0 then 
		return str 
	end
	
	if c >= 10000 then
		local g = math.floor(c/10000)
		c = c - g*10000
		str = str.."|cFFFFD800"..g.."|r|TInterface\\MoneyFrame\\UI-GoldIcon.blp:0:0:0:0|t"
	end
	if c >= 100 then
		local s = math.floor(c/100)
		c = c - s*100
		str = str.."|cFFC7C7C7"..s.."|r|TInterface\\MoneyFrame\\UI-SilverIcon.blp:0:0:0:0|t"
	end
	if c >= 0 then
		str = str.."|cFFEEA55F"..c.."|r|TInterface\\MoneyFrame\\UI-CopperIcon.blp:0:0:0:0|t"
	end
	
	return str
end

local function FormatTooltipMoney(c)
	if not c then return end
	--local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	--local cash = ""
	--cash = format("%d"..L.goldabbrev.." %d"..L.silverabbrev.." %d"..L.copperabbrev, gold, silver, copper)		
	--return cash
	local str = ""
	if not c or c < 0 then 
		return str 
	end
	
	if c >= 10000 then
		local g = math.floor(c/10000)
		c = c - g*10000
		str = str.."|cFFFFD800"..g.."|r|TInterface\\MoneyFrame\\UI-GoldIcon.blp:0:0:0:0|t"
	end
	if c >= 100 then
		local s = math.floor(c/100)
		c = c - s*100
		str = str.."|cFFC7C7C7"..s.."|r|TInterface\\MoneyFrame\\UI-SilverIcon.blp:0:0:0:0|t"
	end
	if c >= 0 then
		str = str.."|cFFEEA55F"..c.."|r|TInterface\\MoneyFrame\\UI-CopperIcon.blp:0:0:0:0|t"
	end
	
	return str
end	

Stat:SetScript("OnEnter", function(self)
	if not InCombatLockdown() then
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.datatext_session)
		GameTooltip:AddDoubleLine(L.datatext_earned, formatMoney(Profit), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L.datatext_spent, formatMoney(Spent), 1, 1, 1, 1, 1, 1)
		if Profit < Spent then
			GameTooltip:AddDoubleLine(L.datatext_deficit, formatMoney(Spent - Profit), 1, 0, 0, 1, 1, 1)
		elseif (Profit-Spent)>0 then
			GameTooltip:AddDoubleLine(L.datatext_profit, formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
		end				
		GameTooltip:AddLine' '								
	
		local totalGold = 0				
		GameTooltip:AddLine(L.datatext_character)			

		for k,_ in pairs(ElvuiData[E.myrealm]) do
			if ElvuiData[E.myrealm][k]["gold"] then 
				GameTooltip:AddDoubleLine(k, FormatTooltipMoney(ElvuiData[E.myrealm][k]["gold"]), 1, 1, 1, 1, 1, 1)
				totalGold=totalGold+ElvuiData[E.myrealm][k]["gold"]
			end
		end 
		GameTooltip:AddLine' '
		GameTooltip:AddLine(L.datatext_server)
		GameTooltip:AddDoubleLine(L.datatext_totalgold, FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
			if name and i == 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY)
			end
			if name and count then GameTooltip:AddDoubleLine(name, count, 1, 1, 1) end
		end
		GameTooltip:Show()
	end
end)

Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		OldMoney = GetMoney()
	end
	
	local NewMoney	= GetMoney()
	local Change = NewMoney-OldMoney -- Positive if we gain money
	
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end
	
	Text:SetText(formatMoney(NewMoney))
	-- Setup Money Tooltip
	self:SetAllPoints(Text)

	if (ElvuiData == nil) then ElvuiData = {}; end
	if (ElvuiData[E.myrealm] == nil) then ElvuiData[E.myrealm] = {} end
	if (ElvuiData[E.myrealm][E.myname] == nil) then ElvuiData[E.myrealm][E.myname] = {} end
	ElvuiData[E.myrealm][E.myname]["gold"] = GetMoney()
	ElvuiData.gold = nil -- old
		
	OldMoney = NewMoney
end

Stat:RegisterEvent("PLAYER_MONEY")
Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
Stat:RegisterEvent("PLAYER_TRADE_MONEY")
Stat:RegisterEvent("TRADE_MONEY_CHANGED")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnMouseDown", function() OpenAllBags() end)
Stat:SetScript("OnEvent", OnEvent)

-- reset gold data
local function RESETGOLD()		
	for k,_ in pairs(ElvuiData[E.myrealm]) do
		ElvuiData[E.myrealm][k].gold = nil
	end 
	if (ElvuiData == nil) then ElvuiData = {}; end
	if (ElvuiData[E.myrealm] == nil) then ElvuiData[E.myrealm] = {} end
	if (ElvuiData[E.myrealm][E.myname] == nil) then ElvuiData[E.myrealm][E.myname] = {} end
	ElvuiData[E.myrealm][E.myname]["gold"] = GetMoney()		
end
SLASH_RESETGOLD1 = "/resetgold"
SlashCmdList["RESETGOLD"] = RESETGOLD
