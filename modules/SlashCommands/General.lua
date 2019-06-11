--[[
    LuiExtended
    License: The MIT License (MIT)
--]]

local SC = LUIE.SlashCommands

local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat

-- Resolve the type of Merchant or Banker to summon based off player choice
function SC.ResolveMerchantBanker(type)
    -- 1 = Banker
    -- 2 = Merchant
    if type == 1 then
        if SC.SV.SlashMerchantChoice == 1 then
            SC.SlashCollectible(301) -- Nuzhimeh the Merchant
        else
            SC.SlashCollectible(6378) -- Ferez
        end
    elseif type == 2 then
        if SC.SV.SlashBankerChoice == 1 then
            SC.SlashCollectible(267) -- Tythis
        else
            SC.SlashCollectible(6376) -- Ezabi
        end
    end
end

-- Slash Command to port to primary home
function SC.SlashHome()
    local primaryHouse = GetHousingPrimaryHouse()
    -- Check if we are in combat
    if IsUnitInCombat("player") then
        printToChat(GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_IN_COMBAT), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_IN_COMBAT)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Check to make sure we're not in Cyrodiil
    if IsPlayerInAvAWorld() then
        printToChat(GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_AVA), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_AVA)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        printToChat(GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_BG), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_BG)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Check if user set a primary home
    if primaryHouse == 0 then
        printToChat(GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_NOHOME), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_FAILED_NOHOME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    else
        RequestJumpToHouse(primaryHouse)
        printToChat(GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_SUCCESS_MSG), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, (GetString(SI_LUIE_SLASHCMDS_HOME_TRAVEL_SUCCESS_MSG)))
        end
    end
end

-- Slash Command to initiate a trade dialogue
function SC.SlashTrade(option)
    if option == "" then
        printToChat(GetString(SI_LUIE_SLASHCMDS_TRADE_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, (GetString(SI_LUIE_SLASHCMDS_TRADE_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    TradeInviteByName(option)
end

-- Slash Command to queue for a campaign
function SC.SlashCampaignQ(option)
    if option == "" then
        printToChat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_NONAME), true)
        if LUIE.SV.TempAlertCampaign then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_NONAME))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if IsActiveWorldBattleground() then
        printToChat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_BG), true)
        if LUIE.SV.TempAlertCampaign then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_BG))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Compare names to campaigns available, join the campaign and bail out of the function if it is available.
    for i = 1, 100 do
        local compareName = string.lower(GetCampaignName(i))
        local option = string.lower(option)
        if compareName == option then
            local campaignName
            campaignName = GetCampaignName(i)

            if GetAssignedCampaignId() == i or GetGuestCampaignId() == i then
                QueueForCampaign (i)
                printToChat(zo_strformat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_QUEUE), campaignName), true)
                if LUIE.SV.TempAlertCampaign then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_QUEUE), campaignName))
                end
                return
            else
                printToChat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_NOT_ENTERED), true)
                if LUIE.SV.TempAlertCampaign then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_NOT_ENTERED))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end
        end
    end

    printToChat(GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_WRONGCAMPAIGN), true)
    if LUIE.SV.TempAlertCampaign then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_CAMPAIGN_FAILED_WRONGCAMPAIGN))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

-- Slash Command to use collectibles based on their collectible id
function SC.SlashCollectible(id)
    -- Check to make sure we're not in Cyrodiil
    if IsPlayerInAvAWorld() then
        printToChat(GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_AVA), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_AVA)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        printToChat(GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_BG), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_BG)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure that we have the collectible unlocked
    if IsCollectibleUnlocked(id) then
        UseCollectible(id)
    else
        printToChat(zo_strformat(GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_NOTUNLOCKED), GetCollectibleName(id)), true)
        if LUIE.SV.TempAlertHome then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(SI_LUIE_SLASHCMDS_COLLECTIBLE_FAILED_NOTUNLOCKED)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
end

-- Slash Command to equip a chosen outfit by number
function SC.SlashOutfit(option)
    if option == "" or option == nil then
        printToChat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_VALID))
        if LUIE.SV.TempAlertOutfit then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_VALID))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local valid = tonumber(option)
    if not valid or valid > 10 then
        printToChat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_VALID))
        if LUIE.SV.TempAlertOutfit then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_VALID))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local numOutfits = GetNumUnlockedOutfits()

    if valid > numOutfits then
        printToChat(zo_strformat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_UNLOCKED), valid))
        if LUIE.SV.TempAlertOutfit then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, zo_strformat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_NOT_UNLOCKED), valid))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    EquipOutfit(valid)
    -- Display a confirmation message.
    local name = GetOutfitName(valid)
    if name == "" then
        name = zo_strformat("<<1>> <<2>>", GetString(SI_CROWN_STORE_SEARCH_ADDITIONAL_OUTFITS), valid)
    end
    printToChat(zo_strformat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_CONFIRMATION), name))
    if LUIE.SV.TempAlertOutfit then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(SI_LUIE_SLASHCMDS_OUTFIT_CONFIRMATION), name))
    end
end

-- Slash Command to report a player by given name and attach useful information
function SC.SlashReport(player)
    local location = GetPlayerLocationName()
    local currenttime = GetTimeString()
    local currentdate = GetDateStringFromTimestamp(GetTimeStamp())
    local server = GetWorldName()
    local text = "I've encounterd a suspicious player.\n\nName: <<1>>\nLocation: <<2>>\nDate & Time: <<3>> <<4>>\nServer: <<5>>"

    -- Set the category to report a player
    HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectCategory(2)
    -- Set the subcategory (default: Other)
    HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectSubcategory(4)

    -- Populate the reporting window name and description
    ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:SetText(player)
	ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField:SetText(zo_strformat(text, player, location, currentdate, currenttime, server))

    -- Open the reporting window
    HELP_CUSTOMER_SUPPORT_KEYBOARD:OpenScreen(HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD_FRAGMENT)
end
