SLASH_CORE1 = "/core"
SlashCmdList["CORE"] = function(input, editBox)
    local params = {}

    if input == "" or input == nil then
        print("/core trash - Trash functions")
        print("/core actionBar - ActionBar functions")
        return
    end

    local commandList = {}
    local command

    for command in string.gmatch(input, "[^ ]+") do
        table.insert(commandList, command)
    end

    local arg1, arg2, arg3 = commandList[1], commandList[2], commandList[3]

    if arg1 == "trash" then
        if arg2 == "1" then
            CoreTrashConfig.enabled = true
        elseif arg2 == "0" then
            CoreTrashConfig.enabled = false
        else
            print("/core trash 0 - Disable auto-deleting trash")
            print("/core trash 1 - Enable auto-deleting trash")
        end
    
        return

    elseif arg1 == "actionBar" then
        if arg2 == "eagles" then
            if arg3 == "1" then
                CoreActionBar.eagles = true
                MainMenuBarLeftEndCap:Show();MainMenuBarRightEndCap:Show()
            elseif arg3 == "0" then
                CoreActionBar.eagles = false
                MainMenuBarLeftEndCap:Hide();MainMenuBarRightEndCap:Hide()
            else
                print("/core actionBar eagles 0 - Disable actionBar eagles")
                print("/core actionBar eagles 1 - Enable actionBar eagles")
            end
        end
        return

    elseif arg1 == "buffs" then
        CoreBuffs:checkBuffs()
        return
    end
end
