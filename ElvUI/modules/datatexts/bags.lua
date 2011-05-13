--------------------------------------------------------------------
 -- BAGS
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local KEYRING_CONTAINER = KEYRING_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

if not C["datatext"].bags or C["datatext"].bags == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].bags, Text)

local function IsAmmoBag(bagType)
	-- 4: Soul Bag
	-- 2: Ammo Pouch
	-- 1: Quiver
	if bagType == 4 or bagType == 2 or bagType == 1 then
		return true
	end
	return false
end

local function IsProfessionBag(bagType)
	-- 1024: Mining Bag
	-- 512: Gem Bag
	-- 128: Engineering Bag
	-- 64: Enchanting Bag
	-- 32: Herb Bag
	-- 16: Inscription Bag
	-- 8: Leatherworking Bag
	if bagType == 1024 or bagType == 512 or bagType == 128 or bagType == 64 or bagType == 32 or bagType == 16 or bagType == 8 then
		return true
	end
	return false
end

local function GetBagColour(percent)
	local r, g, b
	if percent < 0 then
		r, g, b = 1, 0, 0
	elseif percent <= 0.5 then
		r, g, b = 1, percent * 2, 0
	elseif percent >= 1 then
		r, g, b = 0, 1, 0
	else
		r, g, b = 2 - percent * 2, 1, 0
	end
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function OnEvent(self, event, ...)
	local free, total,used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free
	Text:SetText(L.datatext_bags..E.ValColor..used.."|r/"..E.ValColor..total)
	self:SetAllPoints(Text)
end

Stat:RegisterEvent("PLAYER_LOGIN")
Stat:RegisterEvent("BAG_UPDATE")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnMouseDown", function(self, button) 
	if button == "LeftButton" then
		OpenAllBags()
	elseif button == "RightButton" then
		ToggleBag(KEYRING_CONTAINER)
	end
end)

-- tooltip functions
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
Stat:SetScript("OnEnter", function(self)
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	local shown = 0
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Bags")
	for i = 0, NUM_BAG_SLOTS do
		local bagSize = GetContainerNumSlots(i)
		if bagSize ~= nil and bagSize > 0 then
			local name, quality, icon, _
			if i == 0 then
				name = GetBagName(0)
				icon = "Interface\\Icons\\INV_Misc_Bag_08:16"
				quality = select(4, GetItemQualityColor(1))
			else
				name = GetBagName(i)
				_,_,quality,_,_,_,_,_,_,icon = GetItemInfo(name)
				quality = select(4, GetItemQualityColor(quality))
				icon = icon .. ":16"
			end
			local freeSlots = GetContainerNumFreeSlots(i)
			local takenSlots = bagSize - freeSlots
			local colour
			colour = GetBagColour((bagSize - takenSlots) / bagSize)
			name = format("%s%s|r", quality, name)
			takenSlots = bagSize - takenSlots
			local textL, textR
			textL = format("|T%s|t %s", icon, name)
			--if db.showTotal then
				textR = format("%s%d/%d%s", colour and colour or "", takenSlots, bagSize, colour and "|r" or "")
			--else
			--	textR = string_format("%s%d%s", colour and colour or "", takenSlots, colour and "|r" or "")
			--end
			GameTooltip:AddDoubleLine(textL, textR)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffeda55fLeft Click|r to Open Bags")
	GameTooltip:AddLine("|cffeda55fRight Click|r to Open Keyring")
	GameTooltip:Show()
end)
