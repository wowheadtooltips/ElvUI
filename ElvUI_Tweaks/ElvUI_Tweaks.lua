local OnShow = function(show)
    if IsAddOnLoaded("Skada") then
        Skada:SetActive(show)
    end
     if IsAddOnLoaded("Recount") then
		if show then
			Recount.MainWindow:Show()
		else
			Recount.MainWindow:Hide()
		end
    end
    if IsAddOnLoaded("Omen") then
        Omen:Toggle(show)
	end
end

if not ChatRBackground then return end

ChatRBackground:HookScript("OnShow", function() OnShow(false) end)
ChatRBackground:HookScript("OnHide", function() OnShow(true) end)