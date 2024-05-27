local test, addon = ...

local mainFrame = CreateFrame("Frame", "MacroMaster", UIParent, "DefaultPanelTemplate")
mainFrame.CloseButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButtonDefaultAnchors")

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGOUT")

mainFrame:SetSize(300, 300)
mainFrame:SetPoint("CENTER", 0, 0)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)

mainFrame.TitleText = mainFrame.TitleContainer.TitleText
mainFrame.TitleText:SetText("Macro Master")

mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:SetClampedToScreen(true)

mainFrame.ContentFrame =
CreateFrame("ScrollFrame", "MacroMasterContentFrame", mainFrame, "UIPanelScrollFrameTemplate")
mainFrame.ContentFrame:SetSize(274, 300 - (mainFrame.TitleContainer:GetHeight() / 2) - 60)
mainFrame.ContentFrame:SetPoint("TOPLEFT", 0, -(mainFrame.TitleContainer:GetHeight())-7)

local scrollChild = CreateFrame("Frame", nil, mainFrame.ContentFrame)
scrollChild:SetSize(mainFrame.ContentFrame:GetWidth(), 20*20)
mainFrame.ContentFrame:SetScrollChild(scrollChild)

local scrollbar = _G[mainFrame.ContentFrame:GetName() .. "ScrollBar"]
scrollbar:SetScript(
"OnValueChanged",
function(self, value)
    if value ~= nil then
        mainFrame.ContentFrame:SetVerticalScroll(value)
    end
end
)

function createRow(text, index)
    local row = CreateFrame("Button", nil, scrollChild)
    row:SetSize(mainFrame.ContentFrame:GetWidth() - 10, 20)
    row:SetFrameLevel(mainFrame:GetFrameLevel() + 1)
    row:SetPoint("TOPLEFT", 7, -20 * (index-1))
    row:SetNormalTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    row:GetNormalTexture():SetVertexColor(0, 0, 0, 0)
    row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    row:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.5)

    local rowText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rowText:SetPoint("LEFT", row, "LEFT", 5, 0)
    rowText:SetText(text)

    -- local separatorTexture = row:CreateTexture(nil, "BACKGROUND")
    -- separatorTexture:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    -- separatorTexture:SetSize(250, 2)  -- Adjust the size as needed
    -- separatorTexture:SetPoint("TOP", mainFrame, "TOP", 0, -25 * index)
end

--  Set the scrollbar for the scroll frame

function createFrames(scrollHeight)
    mainFrame.ContentFrame =
        CreateFrame("ScrollFrame", "MacroMasterContentFrame", mainFrame, "UIPanelScrollFrameTemplate")
    mainFrame.ContentFrame:SetSize(300, 300 - (mainFrame.TitleContainer:GetHeight() / 2))
    mainFrame.ContentFrame:SetPoint("TOPLEFT", 0, -(mainFrame.TitleContainer:GetHeight() / 2))

    local scrollChild = CreateFrame("Frame", nil, mainFrame.ContentFrame)
    scrollChild:SetSize(mainFrame.ContentFrame:GetWidth(), scrollHeight)
    mainFrame.ContentFrame:SetScrollChild(scrollChild)
   
    local scrollbar = _G[mainFrame.ContentFrame:GetName() .. "ScrollBar"]
    scrollbar:SetScript(
        "OnValueChanged",
        function(self, value)
            if value ~= nil then
                mainFrame.ContentFrame:SetVerticalScroll(value)
            end
        end
    )
end

-- Create the first button
local button1 = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
button1:SetSize(100, 20)
button1:SetPoint("BOTTOMLEFT", 10, 10)
button1:SetText("Export")
button1:SetScript(
    "OnClick",
    function()
        dialogFrame:Show()
    end
)

-- Create the second button
local button2 = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
button2:SetSize(100, 20)
button2:SetPoint("BOTTOMRIGHT", -10, 10)
button2:SetText("Import")

local dialogFrame = CreateFrame("Frame", "MyStaticPopup", UIParent, "DialogBoxFrame")
dialogFrame:SetSize(300, 150)
dialogFrame:SetPoint("CENTER")

-- Create a text label
local textLabel = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
textLabel:SetPoint("TOP", dialogFrame, "TOP", 0, -10)
textLabel:SetText("Enter your name:")

-- Create an edit box for input
local editBox = CreateFrame("EditBox", "MyEditBox", dialogFrame, "InputBoxTemplate")
editBox:SetSize(200, 30)
editBox:SetPoint("TOP", textLabel, "BOTTOM", 0, -10)

-- -- Create an edit box
-- local freeEditBox = CreateFrame("Frame", nil, UIParent)

-- local editBox = CreateFrame("EditBox", "MyEditBox", freeEditBox, "InputBoxTemplate")
-- editBox:SetSize(200, 30)
-- editBox:SetPoint("TOPLEFT", freeEditBox, "TOPLEFT", 50, -50)

-- editBox:SetFontObject("GameFontHighlight")
-- editBox:SetMaxLetters(100)
-- editBox:SetText("Default text")

-- Create a button to save the text in the edit box
-- local saveButton = CreateFrame("Button", nil, freeEditBox, "UIPanelButtonTemplate")
-- saveButton:SetSize(100, 30)
-- saveButton:SetPoint("TOPLEFT", editBox, "TOPRIGHT", 10, 0)
-- saveButton:SetText("Save")

-- Function to handle click events outside the edit box
local function OnClickOutsideEditBox()
    editBox:ClearFocus() -- Stop editing
end

mainFrame:SetScript("OnMouseDown", OnClickOutsideEditBox)

-- list all the profiles saved in the saved variables file as different rows in the frame
mainFrame:SetScript(
    "OnEvent",
    function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "MacroMaster" then
            
            local index = 0
            if ClassMacrosDB ~= nil then
                index = index + 1
                -- for k, v in pairs(ClassMacrosDB) do
                --     createRow(k, index)
                -- end

                for i = 1, 20 do
                    createRow("Dirtman" .. i, i)
                end
            end
        end
        -- local row = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    end
)

local frame = CreateFrame("FRAME") -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED") -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT") -- Fired when about to log out

local playerClass, englishClass = UnitClass("player") -- Might not need this anymore.
local playerName = UnitName("player")
local playerRealm = GetRealmName()

function getKey(characterName, characterRealm)
    return characterName .. "-" .. characterRealm
end

local playerClassMacros = {}
local playerMacros = {}
local importKey = ""

function frame:OnEvent(event, arg1)
    -- arg1 is whatever addon its loading, by name, has to match the title in the toc
    if event == "ADDON_LOADED" and arg1 == "MacroMaster" then
        local profile = ""
        if CharacterProperties ~= nil then
            profile = CharacterProperties["profile"]
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
            preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
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

SlashCmdList["MACRO_MASTER"] = function(args)
    local command, profile, realmName = strsplit(" ", args)
    if command == "show" or command == nil then
        mainFrame:Show()
    elseif command == "export" then
        playerMacros = {}
        exportMacros(playerMacros)
        if ClassMacrosDB == nil then
            ClassMacrosDB = {}
        end
        ClassMacrosDB[profile] = playerMacros
    elseif command == "import" then
        startImport(profile, realmName)
    elseif command == "help" then
        help()
    end
end

--
function getIcon(iconId)
    local icon = addon.ArtTexturePaths[iconId]
    if icon == nil then
        return nil
    end

    local path = {strsplit("/", icon)}
    local ln = table.getn(path)
    return path[ln]
end

--
function checkTooltip(macroBody)
    local body = {strsplit("\n", macroBody)}
    local _start, _end = strfind("#showtooltip", body[1])
    -- #showtooltip = 12
    return strlen(body[1]) == 12 and _start ~= nil and _end ~= nil
end

---
function exportMacros(exportTable)
    local lMacroSlots = getMacroSlots()
    for i = 121, 138 do
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
                ["slots"] = {[currSpecName] = slot}
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
    for i = 0, 18 do
        DeleteMacro(121)
    end
    for i = 1, table.getn(importTable) do
        local name, icon, macro, slot = importTable[i][1], importTable[i][2], importTable[i][3], importTable[i][4]
        if type(icon) == "number" then
            icon = getIcon(icon)
        end
        CreateMacro(name, icon, macro, 1)
        if slot ~= nil then
            placeMacro(120 + i, slot)
        end
    end
end

function help()
    print("MacroMaster Help")
    print("/mm import [profile] [ [character name] [character realm] ] -- imports the specified profiles macros")
    print(
        "/mm export [profile] -- Exports your current characters CHARACTER SPECIFIC macros unless a profile name is specified"
    )
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
        if actionType == "macro" then
            lTable[id] = lActionSlot
        end
    end
    return lTable
end
