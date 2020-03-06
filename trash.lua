CoreTrash = CreateFrame("Frame")

CoreTrashConfig = {}
CoreTrashConfig.enabled = false

trashList = {
    "Troll Sweat",
    "Broken Obsidian Club",
    "Cracked Pottery",
    "Crusted Bandages",
    "Thick Scaly Tail",
    "Turtle Meat",
    "Tarnished Silver Necklace",
    "Moonberry Juice",
    "Cured Ham Steak",
    "Gelatinous Goo",
    "Slimy Ichor",
    "Raw Black Truffle",
    "Khadgar's Whisker",
    "Earthroot",
    "Silverleaf",
    "Mageroyal",
    "Broken Weapon",
    "Peacebloom",
    "Lifeless Skull"}

function trash(item)
    for k, v in pairs(trashList) do
        if v and item:find(v) then
            return true
        end
    end

    return false
end


CoreTrash:SetScript("OnUpdate", function()
    if (CoreTrash.tick or 2) > GetTime() then return else CoreTrash.tick = GetTime() + 2 end

    if CoreTrashConfig.enabled then
        for bag = 0, 4 do
            for bagSlot = 1, GetContainerNumSlots(bag) do
                local item = GetContainerItemLink(bag, bagSlot)
                if item and trash(item) then
                    PickupContainerItem(bag, bagSlot)
                    DeleteCursorItem()
                end
            end
        end
    end
end)
