local TYPE = "type"
local ID_LIST = "idList"
local GROUP = "group"
local CLASSES = "classes"
local COMBAT = "combat"

local ENCHANT = "enchant"
local BUFF = "buff"
local DEBUFF = "debuff"

local PARTY = "party"
local RAID = "raid"

local WARRIOR = "WARRIOR"
local MAGE = "MAGE"
local SHAMAN = "SHAMAN"
local HUNTER = "HUNTER"
local ROGUE = "ROGUE"
local PRIEST = "PRIEST"
local DRUID = "DRUID"
local PALADIN = "PALADIN"
local WARLOCK = "WARLOCK"

local CLASS_TABLE = {
    [WARRIOR] = {},
    [MAGE] = {},
    [SHAMAN] = {},
    [HUNTER] = {},
    [ROGUE] = {},
    [PRIEST] = {},
    [DRUID] = {},
    [PALADIN] = {},
    [WARLOCK] = {}
}

CoreBuffs = CreateFrame("frame")
CoreBuffs.raidRoster = {
    [1] = CLASS_TABLE,
    [2] = CLASS_TABLE,
    [3] = CLASS_TABLE,
    [4] = CLASS_TABLE,
    [5] = CLASS_TABLE,
    [6] = CLASS_TABLE,
    [7] = CLASS_TABLE,
    [8] = CLASS_TABLE
}
CoreBuffs.partyRoster = CLASS_TABLE

CoreBuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
CoreBuffs:RegisterEvent("GROUP_ROSTER_UPDATE")

CoreBuffs:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
        CoreBuffs:buildRoster()	
    end
end)

CoreBuffs:SetScript("OnUpdate", function()
    if (CoreBuffs.tick or 2) > GetTime() then return else CoreBuffs.tick = GetTime() + 2 end

    CoreBuffs:checkBuffs()
end)


buffs = {
    ["Windfury"] = {
        [TYPE] = ENCHANT,
        [ID_LIST] = {564},
        [GROUP] = PARTY,
        [CLASSES] = {SHAMAN},
        [COMBAT] = true
    },
    ["Faerie Fire"] = {
        [TYPE] = DEBUFF,
        [ID_LIST] = {770, 778, 9749, 9907, 13424, 13752, 16857, 17390, 17391, 17392},
        [GROUP] = RAID,
        [CLASSES] = {PRIEST, PALADIN},
        [COMBAT] = false
    }
}

function CoreBuffs:buildRoster()
    CoreBuffs:resetRosters()

    if IsInRaid() then
        for raidIndex = 1, GetNumGroupMembers() do
            name, _, subGroup = GetRaidRosterInfo(raidIndex)
            _, class = UnitClass(name)

            if name and name == UnitName("player") then
                CoreBuffs.raidRoster["player"] = {["name"]= name, ["subGroup"]= subGroup}
            end

            table.insert(CoreBuffs.raidRoster[subGroup][class], name)
        end

    elseif GetNumGroupMembers() > 0 then
        for partyIndex = 1, GetNumGroupMembers() do
            name = UnitName("party"..partyIndex)
            if name then
                _, class = UnitClass(name)

                table.insert(CoreBuffs.partyRoster[class], name)
            end
        end
    end
end

function CoreBuffs:checkBuffs()
    for buffName, buff in pairs(buffs) do
        if UnitIsDeadOrGhost("player") then return end
        if buff[COMBAT] and not UnitAffectingCombat("player") then return end

        if buff[TYPE] == ENCHANT then
            if not CoreBuffs:hasEnchant(buff[ID_LIST]) then
                players = CoreBuffs:findPlayers(buff)
                CoreBuffs:messagePlayers(players, buffName, buff)
            end
        elseif buff[TYPE] == BUFF then
            if not CoreBuffs:hasBuff(buff[ID_LIST]) then
                players = CoreBuffs:findPlayers(buff)
                CoreBuffs:messagePlayers(players, buffName, buff)
            end
        elseif buff[TYPE] == DEBUFF then
            if CoreBuffs:hasDebuff(buff[ID_LIST]) then
                players = CoreBuffs:findPlayers(buff)
                CoreBuffs:messagePlayers(players, buffName, buff)
            end
        end
    end
end

function CoreBuffs:resetRosters()
    CoreBuffs.raidRoster = {
        [1] = CLASS_TABLE,
        [2] = CLASS_TABLE,
        [3] = CLASS_TABLE,
        [4] = CLASS_TABLE,
        [5] = CLASS_TABLE,
        [6] = CLASS_TABLE,
        [7] = CLASS_TABLE,
        [8] = CLASS_TABLE
    }
    CoreBuffs.partyRoster = CLASS_TABLE
end

function CoreBuffs:hasEnchant(idList)
    _, _, _, mhEnchantId = GetWeaponEnchantInfo()
    for _, id in pairs(idList) do
        if mhEnchantId and mhEnchantId == id then
            return true
        end
    end

    return false
end

function CoreBuffs:hasBuff(idList)
    for buffIndex = 1, 40 do
        _, _, _, _, _, _, _, _, _, buffId = UnitBuff("player", buffIndex)
        for _, id in pairs(idList) do
            if buffId and buffId == id then
                return true
            end
        end
    end

    return false
end

function CoreBuffs:hasDebuff(idList)
    for debuffIndex = 1, 40 do
        _, _, _, _, _, _, _, _, _, debuffId = UnitDebuff("player", debuffIndex)
        for _, id in pairs(idList) do
            if debuffId and debuffId == id then
                return true
            end
        end
    end

    return false
end

function CoreBuffs:messagePlayers(players, buffName, buff)
    for _, player in pairs(players) do
        if buff[TYPE] == ENCHANT then
            SendChatMessage("NO "..buffName.." ON "..UnitName("player"), "WHISPER", nil, player)
        elseif buff[TYPE] == BUFF then
            SendChatMessage("PLEASE BUFF "..UnitName("player").." with "..buffName, "WHISPER", nil, player)
        elseif buff[TYPE] == DEBUFF then
            SendChatMessage("PLEASE DISPELL "..buffName.." OFF "..UnitName("player"), "WHISPER", nil, player)
        end
    end
end

function CoreBuffs:findPlayers(buff)
    local players = {}

    if IsInRaid() then
        if buff[GROUP] == PARTY then
            local subGroup = CoreBuffs.raidRoster["player"]["subGroup"]
            for _, class in pairs(buff[CLASSES]) do
                for _, player in pairs(CoreBuffs.raidRoster[subGroup][class]) do
                    if not UnitIsDeadOrGhost(player) and UnitInRange(player) then
                        table.insert(players, player)
                    end
                end
            end

        elseif buff[GROUP] == RAID then
            for _, class in pairs(buff[CLASSES]) do
                for subGroup, classes in pairs(CoreBuffs.raidRoster) do
                    for _, player in pairs(classes[class]) do
                        if not UnitIsDeadOrGhost(player) and UnitInRange(player) then
                            table.insert(players, player)
                        end
                    end
                end
            end
        end

    elseif GetNumGroupMembers() > 0 then
        for _, class in pairs(buff[CLASSES]) do
            for _, player in pairs(CoreBuffs.partyRoster[class]) do
                if not UnitIsDeadOrGhost(player) and UnitInRange(player) then
                    table.insert(players, player)
                end
            end
        end
    end

    return players
end
