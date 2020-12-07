local test, addon = ...


local frame = CreateFrame("FRAME")      -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED")     -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT")    -- Fired when about to log out

local playerClass, englishClass = UnitClass("player") -- Might not need this anymore.
local playerName = UnitName("player")
local playerRealm = GetRealmName()

function getKey(characterName, characterRealm) 
    return characterName .. '-' .. characterRealm
end

local playerClassMacros = {}
local playerMacros = {}
local importKey = ""

function frame:OnEvent(event, arg1)
    -- arg1 is whatever addon its loading, by name, has to match the title in the toc
    if event == "ADDON_LOADED" and arg1 == "MacroMaster" then
        local profile = ""
        if CharacterProperties ~= nil then
            profile = CharacterProperties['profile']
        end

        if ClassMacrosDB ~= nil then
            if ClassMacrosDB[profile] ~= nil then 
                playerMacros = ClassMacrosDB[profile]
            end
        end

        StaticPopupDialogs["MACRO_MASTER"] = {
            text = "This action will delete all your current character specific macros! Make sure you back them up if you want to keep them! Do you want to continue?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                importMacros(playerMacros)
            end,
            timeout = 0,
            preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
          }

    elseif event == "PLAYER_LOGOUT" then 
        if ClassMacrosDB == nil then
            ClassMacrosDB = {}
        end
        -- ClassMacrosDB[englishClass] = playerClassMacros
    end
end

frame:SetScript("OnEvent", frame.OnEvent)

SLASH_MACRO_MASTER1 = "/macromaster"
SLASH_MACRO_MASTER2 = "/mm"

SlashCmdList["MACRO_MASTER"] = function (args) 
    local command, profile, realmName = strsplit(" ", args)
    if command == "export" then
        playerMacros = {}
        exportMacros(playerMacros)
        if ClassMacrosDB == nil then
            ClassMacrosDB = {}
        end
        ClassMacrosDB[profile] = playerMacros
    elseif command == "import" then
        startImport(profile, realmName)
    elseif command == "help" then 
        help();
    end
end

-- 
function getIcon(iconId) 
    local icon = addon.ArtTexturePaths[iconId]
    if icon == nil then
        return nil
    end

    local path = { strsplit("/", icon) }
    local ln = table.getn(path)
    return path[ln]
end

--
function checkTooltip(macroBody)
    local body = { strsplit("\n", macroBody) }
    local _start, _end = strfind("#showtooltip", body[1])
    -- #showtooltip = 12
    return strlen(body[1]) == 12 and _start ~= nil and _end ~= nil;
end

---
function exportMacros(exportTable) 
    local lMacroSlots = getMacroSlots()

    for i=121,138 do 
        local name, iconId, body, isLocal = GetMacroInfo(i)
        if name ~= nil and iconId ~= nil and body ~= nil then
            local icon = getIcon(iconId)
            if checkTooltip(body) == true or icon == nil then
                icon = "INV_Misc_QuestionMark" -- Make sure it's the ? icon
            end
            local currSpec = GetSpecialization()
            local currSpecName = select(2, GetSpecializationInfo(currSpec))
            local slot = lMacroSlots[i]
            local macro = {
                name,
                icon,
                body,
                ["slots"] = { [currSpecName] = slot }
            }

            table.insert(exportTable, macro)
        end
    end
end

--
function startImport(profile, realmName) 
    importKey = profile
    if realmName ~= nil then
        importKey = getKey(profile, realmName)
    end
    playerMacros = ClassMacrosDB[importKey]
    StaticPopup_Show("MACRO_MASTER")
end

-- macro 121 to 138 is your local character macro
function importMacros(importTable) 
    StaticPopup_Hide("MACRO_MASTER")
    for i=0,18 do
        DeleteMacro(121)
    end
    for i=1,table.getn(importTable) do
        local name, icon, macro, slot = importTable[i][1], importTable[i][2],importTable[i][3], importTable[i][4]
        if type(icon) == 'number' then
            icon = getIcon(icon)
        end
        CreateMacro(name, icon, macro, 1)
        if slot ~= nil then
            placeMacro(120+i, slot)
        end
    end
end

function help() 
    print('MacroMaster Help')
    print('/mm import [profile] [ [character name] [character realm] ] -- imports the specified profiles macros')
    print('/mm export [profile] -- Exports your current characters CHARACTER SPECIFIC macros unless a profile name is specified')
end

function placeMacro(macroId, actionSlot) 
    PickupMacro(macroId)
    PlaceAction(actionSlot)
    ClearCursor()
end

function getMacroSlots()
    local lTable = {}
	local lActionSlot = 0
    for lActionSlot = 1, 120 do
        local actionType, id = GetActionInfo(lActionSlot)
        if actionType == 'macro' then
            lTable[id] = lActionSlot
        end
    end
    return lTable
end