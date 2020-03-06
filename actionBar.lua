CoreActionBar = CreateFrame("Frame")

CoreActionBarConfig = {}
CoreActionBarConfig.eagles = false

CoreActionBar:SetScript("OnUpdate", function()
    if (CoreActionBar.tick or 5) > GetTime() then return else CoreActionBar.tick = GetTime() + 5 end

    if not CoreActionBarConfig.eagles then
        MainMenuBarLeftEndCap:Hide();MainMenuBarRightEndCap:Hide()
    end
end)