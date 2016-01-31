
-- spell on dest (src)
local singleTargetAuras = {
    -- 'Hand of Freedom',
    'Hand of Protection',
    'Hand of Sacrifice',
    'Pain Suppression',
    'Guardian Spirit',
    'Ironbark',
    'Hand of Purity',
}

-- spell on dest
local selfAuras = {
    'Icebound Fortitude',
    'Survival Instincts',
    'Ardent Defender',
    'Guardian of Ancient Kings',
    'Shield Wall',
    'Last Stand',
    -- 'Deterrence',
}

-- spell up  (not working)
local raidAuras = {
    'Devotion Aura',
    'Aspect of the Fox',
}

-- spell on dest (src)
local spellCasts = {
    'Lay on Hands',
}


-- Me
local playerUnitName = GetUnitName('player', false)


-- Audio reminder  (flag, not setting)
local reminderInfusionOfLight = false


-- Prints to best channel
local autoPrint = function(msg, channel)
    if BantreSettings.Enabled == false then
        print('Bantre silenced: ', msg)
    elseif channel ~= nil then
        SendChatMessage(msg, channel);
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then  -- order important
        SendChatMessage(msg, 'INSTANCE_CHAT');
    elseif IsInRaid() then
        SendChatMessage(msg, 'RAID')
    elseif IsInGroup() then
        SendChatMessage(msg, 'PARTY');
    else
		print('Bantre unknown channel: ', msg)
    end
end


-- Combat log parsing!
local eventCombatLog = function(...)
    
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    -- raid, party, or me
    if UnitInParty(destName) or UnitInRaid(destName) or (destName == playerUnitName) then

        if type == 'SPELL_CAST_SUCCESS' then
            local spellId, spellName, spellSchool = select(12, ...)
            
            if tContains(spellCasts, spellName) then 
                autoPrint(GetSpellLink(spellId) .. ' on ' .. destName .. ' (' .. sourceName .. ')')   
            end
            
            if (sourceName == playerUnitName) and (spellName == 'Flash of Light') and reminderInfusionOfLight then
                -- print('Flash of Light while Infusion of Light is up!')
                -- PlaySoundFile("Sound/Interface/LFG_Denied.ogg", "Master")
            end
            
        elseif type == 'SPELL_AURA_APPLIED' then
            local spellId, spellName, spellSchool = select(12, ...)
            
            if sourceName == 'Rebizle' and spellName == 'Barkskin' then
                autoPrint(GetSpellLink(spellId) .. ' on Rebizle (standing in the fire again)') 
            elseif tContains(singleTargetAuras, spellName) then 
                autoPrint(GetSpellLink(spellId) .. ' on ' .. destName .. ' (' .. sourceName .. ')') 
            elseif tContains(selfAuras, spellName) then 
                autoPrint(GetSpellLink(spellId) .. ' on ' .. destName) 
            elseif tContains(raidAuras, spellName) and (destName == sourceName) then 
                autoPrint(GetSpellLink(spellId) .. ' up (' .. sourceName .. ')') 
            end
            
            if (sourceName == playerUnitName) and (spellName == 'Infusion of Light') then
                reminderInfusionOfLight = true
            end
        
        elseif type == 'SPELL_AURA_REMOVED' then
            local spellId, spellName, spellSchool = select(12, ...)
            
            if tContains(singleTargetAuras, spellName) then 
                autoPrint(GetSpellLink(spellId) .. ' faded from ' .. destName) 
            elseif tContains(selfAuras, spellName) then 
                autoPrint(GetSpellLink(spellId) .. ' faded from ' .. destName) 
            end
            
            if (sourceName == playerUnitName) and (spellName == 'Infusion of Light') then
                reminderInfusionOfLight = false
            end
        end
    end
    

    if type == 'SPELL_AURA_APPLIED_DOSE' then
        local spellId, spellName, spellSchool, something, stacks = select(12, ...)
        -- print(sourceName, destName, spellName, something, stack)
        
        -- if spellName == 'Flesh Eater' then
        --     if stacks >= 3 and stacks <= 4 then
        --         autoPrint(destName .. ' has ' .. stacks .. ' stacks of ' .. GetSpellLink(spellId))
        --     elseif stacks > 5 then
        --         autoPrint(destName .. ' has ' .. stacks .. ' stacks of ' .. GetSpellLink(spellId), 'RAID_WARNING')
        --     end
        -- end
    end
    
end


-- AttendanceReport
local attendanceReportFrame = CreateFrame("Frame", "AttendanceReport", UIParent)
-- attendanceReportFrame:SetFrameStrata("FULLSCREEN_DIALOG")
attendanceReportFrame:SetWidth(430)
attendanceReportFrame:SetHeight(140)
attendanceReportFrame:SetPoint("TOP", 0, -230)
attendanceReportFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
    insets = {left = 11, right = 12, top = 12, bottom = 11},
})
attendanceReportFrame:Hide()

local attendanceReportFrameFontString = attendanceReportFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
attendanceReportFrameFontString:SetWidth(410)
attendanceReportFrameFontString:SetHeight(0)
attendanceReportFrameFontString:SetPoint("TOP", 0, -16)

local attendanceReportFrameEditBox = CreateFrame("EditBox", nil, attendanceReportFrame)
attendanceReportFrameEditBox:SetHeight(32)
attendanceReportFrameEditBox:SetWidth(250)
attendanceReportFrameEditBox:SetPoint("TOP", attendanceReportFrameFontString, "BOTTOM", 0, -4)
attendanceReportFrameEditBox:SetFontObject("GameFontHighlight")
attendanceReportFrameEditBox:SetTextInsets(0, 0, 0, 1)
attendanceReportFrameEditBox:SetFocus()
attendanceReportFrameEditBox:SetText("Hello World")
attendanceReportFrameEditBox:HighlightText()

local attendanceReportFrameButton = CreateFrame("Button", nil, attendanceReportFrame)
attendanceReportFrameButton:SetHeight(24)
attendanceReportFrameButton:SetWidth(75)
attendanceReportFrameButton:SetPoint("BOTTOM", 0, 13)
attendanceReportFrameButton:SetNormalFontObject("GameFontNormal")
attendanceReportFrameButton:SetHighlightFontObject("GameFontHighlight")
attendanceReportFrameButton:SetNormalTexture(attendanceReportFrameButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture"))
attendanceReportFrameButton:SetPushedTexture(attendanceReportFrameButton:CreateTexture(nil, nil, "UIPanelButtonDownTexture"))
attendanceReportFrameButton:SetHighlightTexture(attendanceReportFrameButton:CreateTexture(nil, nil, "UIPanelButtonHighlightTexture"))
attendanceReportFrameButton:SetText('Close')
attendanceReportFrameButton:SetScript("OnClick", function(self)
    attendanceReportFrame:Hide()
end)


-- These are flags, no settings 
local lfgScannerNeedTank = false
local lfgScannerNeedHealer = false
local lfgScannerNeedDamage = false

-- Call every 10 seconds till the end of time
local lfgScannerTimer = C_Timer.NewTicker(10, function()
    RequestLFDPlayerLockInfo()
end, nil)

-- No args passed
local lfgScanner = function(...)
    -- Get a list of all the random dungeons and their ids
    -- for i = 1, GetNumRandomDungeons() do
    --     local id, name = GetLFGRandomDungeonInfo(i)
    --     print(id .. ": " .. name)
    -- end
    
    local randomWodHeroicId = 789
    local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(randomWodHeroicId, 1)
    
    if BantreSettings.LfgScannerEnabled then
        
        --[[
        if (lfgScannerNeedTank == true) and (forTank == false) then
            print('Bantre LFG Scanner  --  |cFFC00000Tank Full|r')
        elseif (lfgScannerNeedTank == false) and (forTank == true) then
            print('Bantre LFG Scanner  --  |cFF00C000Tank Needeed|r')
        end
        ]]
        
        if (lfgScannerNeedDamage == true) and (forDamage == false) then
            print('Bantre LFG Scanner  --  |cFFC00000Damage Full|r')
        elseif (lfgScannerNeedDamage == false) and (forDamage == true) then
            print('Bantre LFG Scanner  --  |cFF00C000Damage Needeed|r')
        end
        
        if (lfgScannerNeedHealer == true) and (forHealer == false) then
            print('Bantre LFG Scanner  --  |cFFC00000Healer Full|r')
        elseif (lfgScannerNeedHealer == false) and (forHealer == true) then
            print('Bantre LFG Scanner  --  |cFF00C000Healer Needeed|r')
            PlaySoundFile("Sound/Spells/DefensiveStance.wav", "Master")
        end
    end

    lfgScannerNeedTank = forTank
    lfgScannerNeedHealer = forHealer
    lfgScannerNeedDamage = forDamage
end




local rfState = {}

local rfScanner = function(...)
    for i=1, GetNumRFDungeons() do
        local rf_id, rf_name = GetRFDungeonInfo(i)
        local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(rf_id, 1)
        
        if rf_id ~= nil and eligible and BantreSettings.LfgScannerEnabled then
            
            if rfState[rf_id] == nil then
                rfState[rf_id] = {forTank=false, forHealer=false, forDamage=false}
            end
            
            --[[
            if rfState[rf_id]['forTank'] == false and forTank == true then
                print('Bantre RF Scanner  --  |cFF00C000Tank Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forTank'] == true and forTank == false then
                print('Bantre RF Scanner  --  |cFF00C000Tank Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end
            ]]
            
            if rfState[rf_id]['forHealer'] == false and forHealer == true then
                print('Bantre RF Scanner  --  |cFF00C000Healer Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forHealer'] == true and forHealer == false then
                print('Bantre RF Scanner  --  |cFF00C000Healer Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end
            
            if rfState[rf_id]['forDamage'] == false and forDamage == true then
                print('Bantre RF Scanner  --  |cFF00C000Damage Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forDamage'] == true and forDamage == false then
                print('Bantre RF Scanner  --  |cFF00C000Damage Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end
        end
                
        rfState[rf_id] = {forTank=forTank, forHealer=forHealer, forDamage=forDamage}
        
    end
end




-- Default settings
if BantreSettings == nil then BantreSettings = {} end
if BantreSettings.Enabled == nil then BantreSettings.Enabled = true end
if BantreSettings.LfgScannerEnabled == nil then BantreSettings.LfgScannerEnabled = true end


-- Slash commands
SLASH_Bantre1 = '/bantre'
SlashCmdList['Bantre'] = function(msg, editbox)
    if msg == 'hide' then      
        print('Bantre hiding')
        BantreSettings.Enabled = false
    elseif msg == 'show' then
        print('Bantre showing')
        BantreSettings.Enabled = true
    elseif msg == 'attendance' or msg == 'att' then
        print('Bantre creating attendance report')
        for i=1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)
            print('Roster', i, name);
        end
        attendanceReportFrame:Show()
    elseif msg == 'lfg show' then
        print('Banre showing LFG messages')
        BantreSettings.LfgScannerEnabled = true
    elseif msg == 'lfg hide' then
        print('Banre showing LFG messages')
        BantreSettings.LfgScannerEnabled = false        
    else
        print('Bantre (version: |cFFFFD000' .. GetAddOnMetadata('Bantre', 'Version') .. '|r) - Commands:')
		print('  /bantre show - Announce messages')
		print('  /bantre hide - Supress messages')
        print('  /bantre attendance|att - Show attendance report')
        print('  /bantre lfg hide - Hide LFG messages')
        print('  /bantre lfg show - Show LFG messages')
    end
end


-- Default Frame
local bantrePanel = CreateFrame('Frame', 'bantrePanel', UIParent)
bantrePanel:Hide()
bantrePanel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
bantrePanel:RegisterEvent('GARRISON_MISSION_FINISHED')
bantrePanel:RegisterEvent('GARRISON_MISSION_STARTED')
bantrePanel:RegisterEvent('GARRISON_UPDATE')
bantrePanel:RegisterEvent('LFG_UPDATE_RANDOM_INFO')
bantrePanel:RegisterEvent('CHAT_MSG_LOOT')



bantrePanel:SetScript('OnEvent', function(self, event, ...)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        eventCombatLog(...)
    elseif tContains({'GARRISON_MISSION_FINISHED', 'GARRISON_MISSION_STARTED', 'GARRISON_UPDATE'}, event) then
        BantreSettings.CurrentGarisonMissions = C_Garrison.GetInProgressMissions();
        BantreSettings.GarisonUpdateTime = GetGameTime();
    elseif event == 'LFG_UPDATE_RANDOM_INFO' then
        lfgScanner(...)
        rfScanner(...)
    elseif event == 'CHAT_MSG_LOOT' then
        -- print(...)
    end
end)
