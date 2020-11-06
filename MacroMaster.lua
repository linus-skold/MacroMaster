local test,addon = ...

local frame = CreateFrame("FRAME")      -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED")     -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT")    -- Fired when about to log out

local playerClass, englishClass = UnitClass("player")
local playerClassMacros = {}

function frame:OnEvent(event, arg1)
    -- arg1 is whatever addon its loading, by name, has to match the title in the toc
    if event == "ADDON_LOADED" and arg1 == "MacroMaster" then
        if ClassMacrosDB ~= nil then
            if ClassMacrosDB[englishClass] ~= nil then
                playerClassMacros = ClassMacrosDB[englishClass]
            end
        end
    elseif event == "PLAYER_LOGOUT" then 
        ClassMacrosDB[englishClass] = playerClassMacros
    end
end

frame:SetScript("OnEvent", frame.OnEvent)

SLASH_MACRO_MASTER1 = "/macromaster"
SLASH_MACRO_MASTER2 = "/mm"

SlashCmdList["MACRO_MASTER"] = function (arg) 
    if arg == "export" then
        playerClassMacros = {}
        exportMacros(playerClassMacros)
    elseif arg == "import" then
        importMacros()
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
    for i=121,138 do 
        local name, iconId, body, isLocal = GetMacroInfo(i)
        if name ~= nil and iconId ~= nil and body ~= nil then
            local icon = getIcon(iconId)
            if checkTooltip(body) == true or icon == nil then
                icon = "INV_Misc_QuestionMark" -- Make sure it's the ? icon
            end
            local macro = {
                name,
                icon,
                body,
            }
            table.insert(exportTable, macro)
        end
    end
end

--
function importMacros() 
    for i=0,18 do
        DeleteMacro(121)
    end
    
    for i=1,table.getn(playerClassMacros) do
        local macro = playerClassMacros[i]
        local icon = macro[2]
        if type(icon) == 'number' then
            icon = getIcon(icon)
        end
        CreateMacro(macro[1], icon, macro[3], 1)
    end
end
