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
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "target")
            targetCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "target")
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
    
    -- Empower stage pips (markers)
    frame.stagePips = {}
    for i = 1, 4 do
        local pip = frame.Bar:CreateTexture(nil, "OVERLAY")
        pip:SetSize(2, 24)
        pip:SetColorTexture(0, 0, 0, 0.8)
        pip:Hide()
        frame.stagePips[i] = pip
    end
    
    frame.unit = unit
    frame.casting = false
    frame.channeling = false
    frame.empowering = false
    frame.numStages = 0
    frame.startTime = 0
    frame.endTime = 0
    frame.holdAtMaxTime = 0
    frame.stageDurations = {}
    
    return frame
end

-- Update castbar
local function OnUpdate(self, elapsed)
    if not self.casting and not self.channeling and not self.empowering then
        self:Hide()
        return
    end
    
    if self.empowering then
        -- Empowered spells: calculate progress from start time
        local currentTime = GetTime()
        self.value = currentTime - self.startTime
        
        if self.value >= self.maxValue then
            self.empowering = false
            -- Hide stage pips
            for i = 1, 4 do
                self.stagePips[i]:Hide()
            end
            self:Hide()
            return
        end
        
        -- Calculate current stage and change color
        if self.numStages > 0 and self.stageDurations then
            local elapsedMS = self.value * 1000
            local cumulativeDuration = 0
            local currentStage = 0
            for i = 0, self.numStages - 1 do
                if self.stageDurations[i] then
                    cumulativeDuration = cumulativeDuration + self.stageDurations[i]
                    if elapsedMS < cumulativeDuration then
                        currentStage = i
                        break
                    end
                    currentStage = i + 1
                end
            end
            
            -- Color based on stage
            if currentStage == 0 then
                self.Bar:SetStatusBarColor(0.2, 0.5, 0.8)  -- Dark blue
            elseif currentStage == 1 then
                self.Bar:SetStatusBarColor(0.3, 0.7, 1.0)  -- Medium blue
            elseif currentStage == 2 then
                self.Bar:SetStatusBarColor(0.5, 0.8, 1.0)  -- Bright blue
            else
                self.Bar:SetStatusBarColor(0.7, 0.6, 1.0)  -- Purple
            end
        end
    elseif self.casting then
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self.casting = false
            self:Hide()
            return
        end
    elseif self.channeling then
        -- Regular channels: countdown
        self.value = self.value - elapsed
        if self.value <= 0 then
            self.channeling = false
            self:Hide()
            return
        end
    end
    
    self.Bar:SetValue(self.value)
    
    local timeLeft
    if self.empowering or self.casting then
        -- Show time remaining
        timeLeft = self.maxValue - self.value
    else
        -- Show time remaining for channels
        timeLeft = self.value
    end
    self.Time:SetText(string.format("%.1f", timeLeft))
end

-- Castbar event handlers
local function OnEvent(self, event, unit)
    if unit ~= self.unit then return end
    
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible
    
    if event == "UNIT_SPELLCAST_START" then
        name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
        if not name then return end
        
        -- Wrap arithmetic in pcall to handle secret values in combat
        local success = pcall(function()
            self.value = (GetTime() - (startTime / 1000))
            self.maxValue = (endTime - startTime) / 1000
            self.Bar:SetMinMaxValues(0, self.maxValue)
            self.Bar:SetValue(self.value)
        end)
        
        if not success then
            -- Fallback: just show the bar without precise timing
            self.value = 0
            self.maxValue = 1
            self.Bar:SetMinMaxValues(0, 1)
            self.Bar:SetValue(0)
        end
        
        self.casting = true
        self.channeling = false
        self.Text:SetText(text)
        self.Icon:SetTexture(texture)
        
        -- Set bar color based on interruptibility (notInterruptible may be secret in WoW 12.0)
        self.Bar:SetStatusBarColor(1.0, 0.7, 0.0)  -- Default: interruptible
        pcall(function()
            if notInterruptible then
                self.Bar:SetStatusBarColor(0.7, 0.7, 0.7)
            end
        end)
        
        self:Show()
        
    elseif event == "UNIT_SPELLCAST_EMPOWER_START" then
        -- Try UnitCastingInfo first, then UnitChannelInfo as fallback
        name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
        if not name then
            name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitChannelInfo(unit)
        end
        if not name then return end
        
        -- Hide any previous stage pips
        for i = 1, 4 do
            self.stagePips[i]:Hide()
        end
        
        -- Get empower stage information
        local numStages = 0
        local stageDurations = {}
        local totalDuration = 0
        
        for i = 0, 3 do
            local stageDuration = GetUnitEmpowerStageDuration and GetUnitEmpowerStageDuration(unit, i) or 0
            if stageDuration and stageDuration > 0 then
                numStages = i + 1
                stageDurations[i] = stageDuration
                totalDuration = totalDuration + stageDuration
            end
        end
        
        -- Get hold at max time
        local holdAtMaxTime = GetUnitEmpowerHoldAtMaxTime and GetUnitEmpowerHoldAtMaxTime(unit) or 0
        
        -- Empowered spells are CASTING (forward progress), not channeling
        local success = pcall(function()
            self.startTime = startTime / 1000
            self.endTime = endTime / 1000
            self.value = (GetTime() - self.startTime)  -- Current progress
            self.maxValue = self.endTime - self.startTime
            self.numStages = numStages
            self.stageDurations = stageDurations
            self.holdAtMaxTime = holdAtMaxTime
            self.Bar:SetMinMaxValues(0, self.maxValue)
            self.Bar:SetValue(self.value)
        end)
        
        if not success then
            self.startTime = GetTime()
            self.value = 0
            self.maxValue = 3
            self.endTime = self.startTime + 3
            self.numStages = numStages
            self.stageDurations = stageDurations
            self.holdAtMaxTime = holdAtMaxTime
            self.Bar:SetMinMaxValues(0, 3)
            self.Bar:SetValue(0)
        end
        
        -- Position stage pips
        if numStages > 0 then
            local cumulativeDuration = 0
            for i = 0, numStages - 2 do  -- Don't put a pip at the very end
                if stageDurations[i] then
                    cumulativeDuration = cumulativeDuration + stageDurations[i]
                    local percent = (cumulativeDuration / 1000) / self.maxValue
                    if percent > 0 and percent < 1 then
                        local pip = self.stagePips[i + 1]
                        pip:ClearAllPoints()
                        pip:SetPoint("BOTTOM", self.Bar, "BOTTOMLEFT", self.Bar:GetWidth() * percent, 0)
                        pip:SetPoint("TOP", self.Bar, "TOPLEFT", self.Bar:GetWidth() * percent, 0)
                        pip:Show()
                    end
                end
            end
        end
        
        self.casting = false
        self.channeling = false
        self.empowering = true
        self.Text:SetText(text)
        self.Icon:SetTexture(texture)
        
        -- Blue color for empower
        self.Bar:SetStatusBarColor(0.3, 0.7, 1.0)
        
        self:Show()
        
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        if self.empowering then
            self.empowering = false
            self.channeling = false
            self.casting = false
            -- Hide stage pips
            for i = 1, 4 do
                self.stagePips[i]:Hide()
            end
            self:Hide()
        end
        
    elseif event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
        -- Try UnitCastingInfo first, then UnitChannelInfo as fallback
        name, text, texture, startTime, endTime = UnitCastingInfo(unit)
        if not name then
            name, text, texture, startTime, endTime = UnitChannelInfo(unit)
        end
        if not name then return end
        
        -- Update the timing (may extend as they hold longer)
        pcall(function()
            self.startTime = startTime / 1000
            self.endTime = endTime / 1000
            self.maxValue = self.endTime - self.startTime
            self.Bar:SetMinMaxValues(0, self.maxValue)
        end)
        
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
        
        -- Wrap arithmetic in pcall to handle secret values in combat
        pcall(function()
            self.value = (GetTime() - (startTime / 1000))
            self.maxValue = (endTime - startTime) / 1000
            self.Bar:SetMinMaxValues(0, self.maxValue)
        end)
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
        if not name then return end
        
        -- Wrap arithmetic in pcall to handle secret values in combat
        local success = pcall(function()
            self.value = (endTime - startTime) / 1000
            self.maxValue = self.value
            self.Bar:SetMinMaxValues(0, self.maxValue)
            self.Bar:SetValue(self.value)
        end)
        
        if not success then
            -- Fallback: just show the bar
            self.value = 1
            self.maxValue = 1
            self.Bar:SetMinMaxValues(0, 1)
            self.Bar:SetValue(1)
        end
        
        self.casting = false
        self.channeling = true
        self.Text:SetText(text)
        self.Icon:SetTexture(texture)
        
        -- Set bar color based on interruptibility (notInterruptible may be secret in WoW 12.0)
        self.Bar:SetStatusBarColor(0.0, 1.0, 0.0)  -- Default: interruptible channel
        pcall(function()
            if notInterruptible then
                self.Bar:SetStatusBarColor(0.7, 0.7, 0.7)
            end
        end)
        
        self:Show()
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        self.casting = false
        self.channeling = false
        self:Hide()
        
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        name, text, texture, startTime, endTime = UnitChannelInfo(unit)
        if not name then return end

        -- Wrap arithmetic in pcall to handle secret values in combat
        pcall(function()
            self.value = (endTime - startTime) / 1000
        end)
        
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
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
    playerCastbar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "player")

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

-- Dark minimalist UI palette
local UI = {
    bg        = { 0.10, 0.10, 0.12, 0.95 },
    header    = { 0.13, 0.13, 0.16, 1 },
    accent    = { 0.30, 0.75, 0.75, 1 },
    accentDim = { 0.20, 0.50, 0.50, 1 },
    text      = { 0.90, 0.90, 0.90, 1 },
    textDim   = { 0.55, 0.55, 0.58, 1 },
    border    = { 0.22, 0.22, 0.26, 1 },
    sliderBg  = { 0.18, 0.18, 0.22, 1 },
    sliderFill= { 0.30, 0.75, 0.75, 0.6 },
    btnNormal = { 0.18, 0.18, 0.22, 1 },
    btnHover  = { 0.24, 0.24, 0.28, 1 },
    btnPress  = { 0.14, 0.14, 0.17, 1 },
    checkOn   = { 0.30, 0.75, 0.75, 1 },
    checkOff  = { 0.22, 0.22, 0.26, 1 },
}

local BACKDROP_INFO = {
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

-- Helper: modern slider (thin 4px track, teal fill)
local function CreateModernSlider(parent, name, labelText, minVal, maxVal, curVal, step, width, formatFunc, onChange)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, 40)

    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    label:SetTextColor(unpack(UI.text))
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(labelText)

    local valueText = container:CreateFontString(nil, "OVERLAY")
    valueText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    valueText:SetTextColor(unpack(UI.accent))
    valueText:SetPoint("TOPRIGHT", 0, 0)
    valueText:SetText(formatFunc and formatFunc(curVal) or tostring(curVal))

    -- Track background
    local trackBg = container:CreateTexture(nil, "BACKGROUND")
    trackBg:SetHeight(4)
    trackBg:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -8)
    trackBg:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    trackBg:SetColorTexture(unpack(UI.sliderBg))

    -- Actual slider
    local slider = CreateFrame("Slider", name, container, "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", trackBg, "TOPLEFT", 0, 0)
    slider:SetPoint("BOTTOMRIGHT", trackBg, "BOTTOMRIGHT", 0, 0)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValue(curVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Fill texture
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(4)
    fill:SetPoint("LEFT", trackBg, "LEFT", 0, 0)
    fill:SetColorTexture(unpack(UI.sliderFill))

    local function UpdateFill()
        local lo, hi = slider:GetMinMaxValues()
        local pct = (slider:GetValue() - lo) / (hi - lo)
        fill:SetWidth(math.max(1, trackBg:GetWidth() * pct))
    end

    -- Thumb styling
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(12, 12)
        thumb:SetColorTexture(unpack(UI.accent))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        valueText:SetText(formatFunc and formatFunc(value) or tostring(value))
        UpdateFill()
        if onChange then onChange(value) end
    end)

    slider:HookScript("OnShow", function() C_Timer.After(0, UpdateFill) end)

    container.slider = slider
    container.valueText = valueText
    return container
end

-- Helper: modern checkbox
local function CreateModernCheck(parent, labelText, checked, onClick)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 20)

    local box = CreateFrame("Frame", nil, container, "BackdropTemplate")
    box:SetSize(16, 16)
    box:SetPoint("LEFT", 0, 0)
    box:SetBackdrop(BACKDROP_INFO)
    box:SetBackdropColor(unpack(checked and UI.checkOn or UI.checkOff))
    box:SetBackdropBorderColor(unpack(UI.border))

    local mark = box:CreateFontString(nil, "OVERLAY")
    mark:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    mark:SetPoint("CENTER", 0, 0)
    mark:SetTextColor(unpack(UI.bg))
    mark:SetText(checked and "\226\156\147" or "")

    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    label:SetTextColor(unpack(UI.text))
    label:SetPoint("LEFT", box, "RIGHT", 8, 0)
    label:SetText(labelText)

    local state = checked and true or false

    local hitArea = CreateFrame("Button", nil, container)
    hitArea:SetAllPoints(container)
    hitArea:SetScript("OnClick", function()
        state = not state
        box:SetBackdropColor(unpack(state and UI.checkOn or UI.checkOff))
        mark:SetText(state and "\226\156\147" or "")
        if onClick then onClick(state) end
    end)

    container.SetChecked = function(_, val)
        state = val and true or false
        box:SetBackdropColor(unpack(state and UI.checkOn or UI.checkOff))
        mark:SetText(state and "\226\156\147" or "")
    end
    container.GetChecked = function(_) return state end

    return container
end

-- Helper: modern flat button
local function CreateModernButton(parent, text, width, height, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop(BACKDROP_INFO)
    btn:SetBackdropColor(unpack(UI.btnNormal))
    btn:SetBackdropBorderColor(unpack(UI.border))

    btn.label = btn:CreateFontString(nil, "OVERLAY")
    btn.label:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    btn.label:SetTextColor(unpack(UI.text))
    btn.label:SetPoint("CENTER", 0, 0)
    btn.label:SetText(text)

    btn.SetText = function(_, t) btn.label:SetText(t) end

    btn:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(UI.btnHover)) end)
    btn:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(UI.btnNormal)) end)
    btn:SetScript("OnMouseDown", function(self) self:SetBackdropColor(unpack(UI.btnPress)) end)
    btn:SetScript("OnMouseUp", function(self) self:SetBackdropColor(unpack(UI.btnHover)) end)
    btn:SetScript("OnClick", onClick)

    return btn
end

-- Helper: section header (uppercase dimmed label + thin line)
local function CreateSectionHeader(parent, text)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(parent:GetWidth() or 380, 20)

    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    label:SetTextColor(unpack(UI.textDim))
    label:SetPoint("LEFT", 0, 0)
    label:SetText(string.upper(text))

    local line = container:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", label, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    line:SetColorTexture(unpack(UI.border))

    return container
end

-- Create config window
local function CreateConfigWindow()
    if configFrame then return end

    -- Main frame
    configFrame = CreateFrame("Frame", "JarsCastbarConfig", UIParent, "BackdropTemplate")
    configFrame:SetSize(460, 560)
    configFrame:SetPoint("CENTER")
    configFrame:SetBackdrop(BACKDROP_INFO)
    configFrame:SetBackdropColor(unpack(UI.bg))
    configFrame:SetBackdropBorderColor(unpack(UI.border))
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:SetFrameStrata("DIALOG")
    tinsert(UISpecialFrames, "JarsCastbarConfig")

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
    titleBar:SetHeight(32)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetBackdrop(BACKDROP_INFO)
    titleBar:SetBackdropColor(unpack(UI.header))
    titleBar:SetBackdropBorderColor(unpack(UI.border))

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
    titleText:SetTextColor(unpack(UI.accent))
    titleText:SetPoint("LEFT", 14, 0)
    titleText:SetText("Jar's Castbar")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(32, 32)
    closeBtn:SetPoint("RIGHT", -2, 0)
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
    closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
    closeTxt:SetTextColor(unpack(UI.textDim))
    closeTxt:SetPoint("CENTER", 0, 0)
    closeTxt:SetText("x")
    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.4, 0.4, 1) end)
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(unpack(UI.textDim)) end)
    closeBtn:SetScript("OnClick", function() configFrame:Hide() end)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, configFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 12)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(390, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local contentWidth = 380
    local yOff = 0
    local function nextY(h) yOff = yOff - h; return yOff end

    -- =====================
    -- PLAYER CASTBAR section
    -- =====================
    local sec1 = CreateSectionHeader(scrollChild, "Player Castbar")
    sec1:SetSize(contentWidth, 20)
    sec1:SetPoint("TOPLEFT", 0, nextY(0))

    local playerYSlider = CreateModernSlider(scrollChild, "JarsCastbar_PlayerYSlider",
        "Vertical Position", -500, 500, JarsCastbarDB.playerY, 5, contentWidth, nil,
        function(v) UpdatePlayerPosition(v) end)
    playerYSlider:SetPoint("TOPLEFT", 0, nextY(36))

    local widthSlider = CreateModernSlider(scrollChild, "JarsCastbar_WidthSlider",
        "Width", 150, 600, JarsCastbarDB.width, 10, contentWidth, nil,
        function(v) UpdateWidth(v) end)
    widthSlider:SetPoint("TOPLEFT", 0, nextY(52))

    -- =====================
    -- APPEARANCE section
    -- =====================
    local sec2 = CreateSectionHeader(scrollChild, "Appearance")
    sec2:SetSize(contentWidth, 20)
    sec2:SetPoint("TOPLEFT", 0, nextY(56))

    local fontLabel = scrollChild:CreateFontString(nil, "OVERLAY")
    fontLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    fontLabel:SetTextColor(unpack(UI.text))
    fontLabel:SetPoint("TOPLEFT", 0, nextY(28))
    fontLabel:SetText("Font")

    local fontDropdown = CreateFrame("DropdownButton", nil, scrollChild, "WowStyle1DropdownTemplate")
    fontDropdown:SetPoint("TOPLEFT", 0, nextY(20))
    fontDropdown:SetWidth(contentWidth)
    fontDropdown:SetDefaultText(JarsCastbarDB.font or "Friz Quadrata TT")
    fontDropdown:SetupMenu(function(_, rootDescription)
        local fonts = LSM and LSM:List("font") or {"Friz Quadrata TT"}
        for _, fontName in ipairs(fonts) do
            rootDescription:CreateRadio(fontName,
                function() return JarsCastbarDB.font == fontName end,
                function() UpdateFont(fontName) end)
        end
    end)

    local textureLabel = scrollChild:CreateFontString(nil, "OVERLAY")
    textureLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    textureLabel:SetTextColor(unpack(UI.text))
    textureLabel:SetPoint("TOPLEFT", 0, nextY(40))
    textureLabel:SetText("Texture")

    local textureDropdown = CreateFrame("DropdownButton", nil, scrollChild, "WowStyle1DropdownTemplate")
    textureDropdown:SetPoint("TOPLEFT", 0, nextY(20))
    textureDropdown:SetWidth(contentWidth)
    textureDropdown:SetDefaultText(JarsCastbarDB.texture or "Blizzard")
    textureDropdown:SetupMenu(function(_, rootDescription)
        local textures = LSM and LSM:List("statusbar") or {"Blizzard"}
        for _, textureName in ipairs(textures) do
            rootDescription:CreateRadio(textureName,
                function() return JarsCastbarDB.texture == textureName end,
                function() UpdateTexture(textureName) end)
        end
    end)

    -- =====================
    -- TARGET CASTBAR section
    -- =====================
    local sec3 = CreateSectionHeader(scrollChild, "Target Castbar")
    sec3:SetSize(contentWidth, 20)
    sec3:SetPoint("TOPLEFT", 0, nextY(48))

    local targetCheck = CreateModernCheck(scrollChild, "Show Target Castbar",
        JarsCastbarDB.showTarget, function(val) ToggleTargetCastbar(val) end)
    targetCheck:SetPoint("TOPLEFT", 0, nextY(30))

    local targetYSlider = CreateModernSlider(scrollChild, "JarsCastbar_TargetYSlider",
        "Target Vertical Position", -500, 500, JarsCastbarDB.targetY, 5, contentWidth, nil,
        function(v) UpdateTargetPosition(v) end)
    targetYSlider:SetPoint("TOPLEFT", 0, nextY(32))

    -- =====================
    -- ACTIONS section
    -- =====================
    local sec4 = CreateSectionHeader(scrollChild, "Actions")
    sec4:SetSize(contentWidth, 20)
    sec4:SetPoint("TOPLEFT", 0, nextY(56))

    local resetBtn = CreateModernButton(scrollChild, "Reset to Default", 160, 30, function()
        playerYSlider.slider:SetValue(-200)
        targetYSlider.slider:SetValue(-250)
        widthSlider.slider:SetValue(300)
        fontDropdown:GenerateMenu()
        textureDropdown:GenerateMenu()
        UpdatePlayerPosition(-200)
        UpdateTargetPosition(-250)
        UpdateWidth(300)
        UpdateFont("Friz Quadrata TT")
        UpdateTexture("Blizzard")
        targetCheck:SetChecked(JarsCastbarDB.showTarget)
        print("|cff00ff00Jar's Castbar|r: Settings reset to default.")
    end)
    resetBtn:SetPoint("TOPLEFT", 0, nextY(36))

    -- Set scroll child total height
    scrollChild:SetHeight(math.abs(yOff) + 20)

    configFrame:Hide()
end

-- Slash command
SLASH_JARSCASTBAR1 = "/jarscastbar"
SLASH_JARSCASTBAR2 = "/jcb"
SlashCmdList["JARSCASTBAR"] = function(msg)
    configFrame:SetShown(not configFrame:IsShown())
end

-- Hide Blizzard cast bars
local function HideBlizzardCastbars()
    -- Hide player cast bar
    if PlayerCastingBarFrame then
        PlayerCastingBarFrame:UnregisterAllEvents()
        PlayerCastingBarFrame:Hide()
        PlayerCastingBarFrame:SetAlpha(0)
    end
    
    -- Hide target cast bar
    if TargetFrameSpellBar then
        TargetFrameSpellBar:UnregisterAllEvents()
        TargetFrameSpellBar:Hide()
        TargetFrameSpellBar:SetAlpha(0)
    end
end

-- Initialize
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "JarsCastbar" then
        InitDB()
        CreatePlayerCastbar()
        CreateTargetCastbar()
        CreateConfigWindow()
        print("|cff00ff00Jar's Castbar|r loaded! Type |cff00ffff/jcb|r to configure.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        HideBlizzardCastbars()
    end
end)
