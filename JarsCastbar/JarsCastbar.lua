-- Jar's Castbar
-- Customizable player and target cast bars

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

-- Local references
local playerCastbar, targetCastbar, configFrame

-- Database initialization
local function InitDB()
    if not JarsCastbarDB then
        JarsCastbarDB = {}
    end
    
    -- Player castbar settings
    JarsCastbarDB.playerY = JarsCastbarDB.playerY or -200
    JarsCastbarDB.width = JarsCastbarDB.width or 300
    JarsCastbarDB.font = JarsCastbarDB.font or "Friz Quadrata TT"
    JarsCastbarDB.texture = JarsCastbarDB.texture or "Blizzard"
    
    -- Target castbar settings
    JarsCastbarDB.showTarget = JarsCastbarDB.showTarget or false
    JarsCastbarDB.targetY = JarsCastbarDB.targetY or -250
end

-- Update player castbar position
local function UpdatePlayerPosition(yPos)
    JarsCastbarDB.playerY = yPos
    if playerCastbar then
        playerCastbar:ClearAllPoints()
        playerCastbar:SetPoint("TOP", UIParent, "CENTER", 0, yPos)
    end
end

-- Update target castbar position
local function UpdateTargetPosition(yPos)
    JarsCastbarDB.targetY = yPos
    if targetCastbar then
        targetCastbar:ClearAllPoints()
        targetCastbar:SetPoint("TOP", UIParent, "CENTER", 0, yPos)
    end
end

-- Update castbar width
local function UpdateWidth(width)
    JarsCastbarDB.width = width
    if playerCastbar then
        playerCastbar:SetWidth(width)
        playerCastbar.Bar:SetWidth(width - 4)
    end
    if targetCastbar then
        targetCastbar:SetWidth(width)
        targetCastbar.Bar:SetWidth(width - 4)
    end
end

-- Update font
local function UpdateFont(fontName)
    JarsCastbarDB.font = fontName
    local fontPath = LSM and LSM:Fetch("font", fontName) or "Fonts\\FRIZQT__.TTF"
    
    if playerCastbar then
        playerCastbar.Text:SetFont(fontPath, 12, "OUTLINE")
        playerCastbar.Time:SetFont(fontPath, 12, "OUTLINE")
    end
    if targetCastbar then
        targetCastbar.Text:SetFont(fontPath, 12, "OUTLINE")
        targetCastbar.Time:SetFont(fontPath, 12, "OUTLINE")
    end
end

-- Update texture
local function UpdateTexture(textureName)
    JarsCastbarDB.texture = textureName
    local texturePath = LSM and LSM:Fetch("statusbar", textureName) or "Interface\\TargetingFrame\\UI-StatusBar"
    
    if playerCastbar then
        playerCastbar.Bar:SetStatusBarTexture(texturePath)
    end
    if targetCastbar then
        targetCastbar.Bar:SetStatusBarTexture(texturePath)
    end
end

-- Toggle target castbar
local function ToggleTargetCastbar(show)
    JarsCastbarDB.showTarget = show
    if targetCastbar then
        if show then
            targetCastbar:Show()
            targetCastbar:RegisterEvent("PLAYER_TARGET_CHANGED")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "target")
        else
            targetCastbar:Hide()
            targetCastbar:UnregisterAllEvents()
        end
    end
end

-- Create a castbar frame
local function CreateCastbar(unit)
    local frame = CreateFrame("Frame", "JarsCastbar_" .. unit, UIParent)
    frame:SetSize(JarsCastbarDB.width, 24)
    frame:SetFrameStrata("MEDIUM")
    
    -- Background
    frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.Bg:SetAllPoints()
    frame.Bg:SetColorTexture(0, 0, 0, 0.7)
    
    -- Border
    frame.Border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.Border:SetAllPoints()
    frame.Border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame.Border:SetBackdropBorderColor(0, 0, 0, 1)
    
    -- Status bar
    local texturePath = LSM and LSM:Fetch("statusbar", JarsCastbarDB.texture) or "Interface\\TargetingFrame\\UI-StatusBar"
    frame.Bar = CreateFrame("StatusBar", nil, frame)
    frame.Bar:SetPoint("TOPLEFT", 2, -2)
    frame.Bar:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.Bar:SetStatusBarTexture(texturePath)
    frame.Bar:SetMinMaxValues(0, 1)
    frame.Bar:SetValue(0)
    
    -- Spell name text
    local fontPath = LSM and LSM:Fetch("font", JarsCastbarDB.font) or "Fonts\\FRIZQT__.TTF"
    frame.Text = frame.Bar:CreateFontString(nil, "OVERLAY")
    frame.Text:SetFont(fontPath, 12, "OUTLINE")
    frame.Text:SetPoint("LEFT", frame.Bar, "LEFT", 4, 0)
    frame.Text:SetTextColor(1, 1, 1)
    
    -- Time text
    frame.Time = frame.Bar:CreateFontString(nil, "OVERLAY")
    frame.Time:SetFont(fontPath, 12, "OUTLINE")
    frame.Time:SetPoint("RIGHT", frame.Bar, "RIGHT", -4, 0)
    frame.Time:SetTextColor(1, 1, 1)
    
    -- Spell icon
    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(20, 20)
    frame.Icon:SetPoint("RIGHT", frame, "LEFT", -4, 0)
    frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Icon border
    frame.IconBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.IconBorder:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -1, 1)
    frame.IconBorder:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 1, -1)
    frame.IconBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame.IconBorder:SetBackdropBorderColor(0, 0, 0, 1)
    
    frame.unit = unit
    frame.casting = false
    frame.channeling = false
    
    return frame
end

-- Update castbar
local function OnUpdate(self, elapsed)
    if not self.casting and not self.channeling then
        self:Hide()
        return
    end
    
    if self.casting then
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self.casting = false
            self:Hide()
            return
        end
    elseif self.channeling then
        self.value = self.value - elapsed
        if self.value <= 0 then
            self.channeling = false
            self:Hide()
            return
        end
    end
    
    self.Bar:SetValue(self.value)
    
    local timeLeft = self.channeling and self.value or (self.maxValue - self.value)
    self.Time:SetText(string.format("%.1f", timeLeft))
end

-- Castbar event handlers
local function OnEvent(self, event, unit)
    if unit ~= self.unit then return end
    
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible
    
    if event == "UNIT_SPELLCAST_START" then
        name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
        if not name then return end
        
        self.value = (GetTime() - (startTime / 1000))
        self.maxValue = (endTime - startTime) / 1000
        self.casting = true
        self.channeling = false
        
        self.Bar:SetMinMaxValues(0, self.maxValue)
        self.Bar:SetValue(self.value)
        self.Text:SetText(text)
        self.Icon:SetTexture(texture)
        
        if notInterruptible then
            self.Bar:SetStatusBarColor(0.7, 0.7, 0.7)
        else
            self.Bar:SetStatusBarColor(1.0, 0.7, 0.0)
        end
        
        self:Show()
        
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- Don't hide if we're channeling and the channel is still active
        if self.channeling then
            local name = UnitChannelInfo(unit)
            if name then
                return  -- Channel is still active, don't hide
            end
        end
        self.casting = false
        self.channeling = false
        self:Hide()
        
    elseif event == "UNIT_SPELLCAST_DELAYED" then
        name, text, texture, startTime, endTime = UnitCastingInfo(unit)
        if not name then return end
        
        self.value = (GetTime() - (startTime / 1000))
        self.maxValue = (endTime - startTime) / 1000
        self.Bar:SetMinMaxValues(0, self.maxValue)
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
        if not name then return end
        
        self.value = (endTime - startTime) / 1000
        self.maxValue = self.value
        self.casting = false
        self.channeling = true
        
        self.Bar:SetMinMaxValues(0, self.maxValue)
        self.Bar:SetValue(self.value)
        self.Text:SetText(text)
        self.Icon:SetTexture(texture)
        
        if notInterruptible then
            self.Bar:SetStatusBarColor(0.7, 0.7, 0.7)
        else
            self.Bar:SetStatusBarColor(0.0, 1.0, 0.0)
        end
        
        self:Show()
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        self.casting = false
        self.channeling = false
        self:Hide()
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        name, text, texture, startTime, endTime = UnitChannelInfo(unit)
        if not name then return end
        
        self.value = (endTime - startTime) / 1000
        
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        self.Bar:SetStatusBarColor(self.channeling and 0.0 or 1.0, self.channeling and 1.0 or 0.7, 0.0)
        
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        self.Bar:SetStatusBarColor(0.7, 0.7, 0.7)
    end
end

-- Create player castbar
local function CreatePlayerCastbar()
    playerCastbar = CreateCastbar("player")
    playerCastbar:SetPoint("TOP", UIParent, "CENTER", 0, JarsCastbarDB.playerY)
    
    playerCastbar:SetScript("OnUpdate", OnUpdate)
    playerCastbar:SetScript("OnEvent", OnEvent)
    
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "player")
    
    playerCastbar:Hide()
end

-- Create target castbar
local function CreateTargetCastbar()
    targetCastbar = CreateCastbar("target")
    targetCastbar:SetPoint("TOP", UIParent, "CENTER", 0, JarsCastbarDB.targetY)
    
    targetCastbar:SetScript("OnUpdate", OnUpdate)
    targetCastbar:SetScript("OnEvent", function(self, event, unit)
        if event == "PLAYER_TARGET_CHANGED" then
            -- Clear castbar when target changes
            self.casting = false
            self.channeling = false
            self:Hide()
            
            -- Check if new target is casting/channeling
            local name = UnitCastingInfo("target")
            if name then
                OnEvent(self, "UNIT_SPELLCAST_START", "target")
            else
                name = UnitChannelInfo("target")
                if name then
                    OnEvent(self, "UNIT_SPELLCAST_CHANNEL_START", "target")
                end
            end
        else
            OnEvent(self, event, unit)
        end
    end)
    
    if JarsCastbarDB.showTarget then
        targetCastbar:RegisterEvent("PLAYER_TARGET_CHANGED")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "target")
        targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "target")
    else
        targetCastbar:Hide()
    end
end

-- Create config window
local function CreateConfigWindow()
    if configFrame then return end
    
    configFrame = CreateFrame("Frame", "JarsCastbarConfig", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(450, 600)
    configFrame:SetPoint("CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:SetFrameStrata("DIALOG")
    
    configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    configFrame.title:SetPoint("TOP", 0, -5)
    configFrame.title:SetText("Jar's Castbar Configuration")
    
    -- Player section header
    local playerHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    playerHeader:SetPoint("TOPLEFT", 20, -40)
    playerHeader:SetText("Player Castbar")
    
    -- Player Y position label
    local playerYLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerYLabel:SetPoint("TOPLEFT", playerHeader, "BOTTOMLEFT", 0, -20)
    playerYLabel:SetText("Vertical Position:")
    
    -- Player Y position slider
    local playerYSlider = CreateFrame("Slider", "JarsCastbar_PlayerYSlider", configFrame, "OptionsSliderTemplate")
    playerYSlider:SetPoint("TOPLEFT", playerYLabel, "BOTTOMLEFT", 0, -20)
    playerYSlider:SetMinMaxValues(-500, 500)
    playerYSlider:SetValue(JarsCastbarDB.playerY)
    playerYSlider:SetValueStep(5)
    playerYSlider:SetObeyStepOnDrag(true)
    playerYSlider:SetWidth(400)
    playerYSlider.Low:SetText("-500")
    playerYSlider.High:SetText("500")
    playerYSlider.Text:SetText(JarsCastbarDB.playerY)
    playerYSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5 + 0.5) * 5
        self.Text:SetText(value)
        UpdatePlayerPosition(value)
    end)
    
    -- Width label
    local widthLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widthLabel:SetPoint("TOPLEFT", playerYSlider, "BOTTOMLEFT", 0, -40)
    widthLabel:SetText("Width:")
    
    -- Width slider
    local widthSlider = CreateFrame("Slider", "JarsCastbar_WidthSlider", configFrame, "OptionsSliderTemplate")
    widthSlider:SetPoint("TOPLEFT", widthLabel, "BOTTOMLEFT", 0, -20)
    widthSlider:SetMinMaxValues(150, 600)
    widthSlider:SetValue(JarsCastbarDB.width)
    widthSlider:SetValueStep(10)
    widthSlider:SetObeyStepOnDrag(true)
    widthSlider:SetWidth(400)
    widthSlider.Low:SetText("150")
    widthSlider.High:SetText("600")
    widthSlider.Text:SetText(JarsCastbarDB.width)
    widthSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 10 + 0.5) * 10
        self.Text:SetText(value)
        UpdateWidth(value)
    end)
    
    -- Font label
    local fontLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", widthSlider, "BOTTOMLEFT", 0, -40)
    fontLabel:SetText("Font:")
    
    -- Font dropdown
    local fontDropdown = CreateFrame("Frame", "JarsCastbar_FontDropdown", configFrame, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", -15, -5)
    
    UIDropDownMenu_SetWidth(fontDropdown, 380)
    UIDropDownMenu_SetText(fontDropdown, JarsCastbarDB.font)
    
    UIDropDownMenu_Initialize(fontDropdown, function(self, level)
        local fonts = LSM and LSM:List("font") or {"Friz Quadrata TT"}
        for _, fontName in ipairs(fonts) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = fontName
            info.func = function()
                UIDropDownMenu_SetText(fontDropdown, fontName)
                UpdateFont(fontName)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Texture label
    local textureLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textureLabel:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 15, -10)
    textureLabel:SetText("Texture:")
    
    -- Texture dropdown
    local textureDropdown = CreateFrame("Frame", "JarsCastbar_TextureDropdown", configFrame, "UIDropDownMenuTemplate")
    textureDropdown:SetPoint("TOPLEFT", textureLabel, "BOTTOMLEFT", -15, -5)
    
    UIDropDownMenu_SetWidth(textureDropdown, 380)
    UIDropDownMenu_SetText(textureDropdown, JarsCastbarDB.texture)
    
    UIDropDownMenu_Initialize(textureDropdown, function(self, level)
        local textures = LSM and LSM:List("statusbar") or {"Blizzard"}
        for _, textureName in ipairs(textures) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = textureName
            info.func = function()
                UIDropDownMenu_SetText(textureDropdown, textureName)
                UpdateTexture(textureName)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Target section header
    local targetHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    targetHeader:SetPoint("TOPLEFT", textureDropdown, "BOTTOMLEFT", 15, -30)
    targetHeader:SetText("Target Castbar")
    
    -- Show target checkbox
    local targetCheck = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
    targetCheck:SetPoint("TOPLEFT", targetHeader, "BOTTOMLEFT", 0, -10)
    targetCheck.text = targetCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetCheck.text:SetPoint("LEFT", targetCheck, "RIGHT", 5, 0)
    targetCheck.text:SetText("Show Target Castbar")
    targetCheck:SetChecked(JarsCastbarDB.showTarget)
    targetCheck:SetScript("OnClick", function(self)
        ToggleTargetCastbar(self:GetChecked())
    end)
    
    -- Target Y position label
    local targetYLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetYLabel:SetPoint("TOPLEFT", targetCheck, "BOTTOMLEFT", 0, -20)
    targetYLabel:SetText("Target Vertical Position:")
    
    -- Target Y position slider
    local targetYSlider = CreateFrame("Slider", "JarsCastbar_TargetYSlider", configFrame, "OptionsSliderTemplate")
    targetYSlider:SetPoint("TOPLEFT", targetYLabel, "BOTTOMLEFT", 0, -20)
    targetYSlider:SetMinMaxValues(-500, 500)
    targetYSlider:SetValue(JarsCastbarDB.targetY)
    targetYSlider:SetValueStep(5)
    targetYSlider:SetObeyStepOnDrag(true)
    targetYSlider:SetWidth(400)
    targetYSlider.Low:SetText("-500")
    targetYSlider.High:SetText("500")
    targetYSlider.Text:SetText(JarsCastbarDB.targetY)
    targetYSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5 + 0.5) * 5
        self.Text:SetText(value)
        UpdateTargetPosition(value)
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 25)
    resetBtn:SetPoint("BOTTOM", 0, 20)
    resetBtn:SetText("Reset to Default")
    resetBtn:SetScript("OnClick", function()
        playerYSlider:SetValue(-200)
        targetYSlider:SetValue(-250)
        widthSlider:SetValue(300)
        UIDropDownMenu_SetText(fontDropdown, "Friz Quadrata TT")
        UIDropDownMenu_SetText(textureDropdown, "Blizzard")
        UpdatePlayerPosition(-200)
        UpdateTargetPosition(-250)
        UpdateWidth(300)
        UpdateFont("Friz Quadrata TT")
        UpdateTexture("Blizzard")
        print("|cff00ff00Jar's Castbar|r: Settings reset to default.")
    end)
    
    configFrame:Hide()
end

-- Slash command
SLASH_JARSCASTBAR1 = "/jarscastbar"
SLASH_JARSCASTBAR2 = "/jcb"
SlashCmdList["JARSCASTBAR"] = function(msg)
    configFrame:SetShown(not configFrame:IsShown())
end

-- Initialize
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "JarsCastbar" then
        InitDB()
        CreatePlayerCastbar()
        CreateTargetCastbar()
        CreateConfigWindow()
        print("|cff00ff00Jar's Castbar|r loaded! Type |cff00ffff/jcb|r to configure.")
    end
end)
