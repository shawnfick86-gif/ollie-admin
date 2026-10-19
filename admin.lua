-- ============================================
-- OLLIE ADMIN  •  v28 (Full Premium Unlocked)
-- All Features  •  Kill Orbit  •  Troll  •  Configs
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local isPremium = true

-- ============================================
-- CONFIG STATE
-- ============================================
local CFG = {
    teamCheck = true, aimbot = false, aimPart = "Head", aimFov = 150, aimSmooth = 0.2,
    triggerbot = false, triggerDelay = 0.1, triggerRange = 200,
    rapidFire = false, rapidFireRate = 0.04,
    walkSpeed = 16, jumpPower = 50, fly = false, flySpeed = 50, noclip = false, infJump = false,
    esp = false, fullbright = false, speedLock = true, noAcceleration = false,
    orbitEnabled = false, orbitRadius = 10, orbitSpeed = 3,
    keySpeed = "None", keyJump = "None", keyAimbot = "None", keyTriggerbot = "None",
}

local flags = {
    flyConn = nil, isSpectating = false, oldCamSubject = nil,
    noclipConn = nil, infJumpConn = nil, savedLighting = {},
    aiming = false, uiItems = {}, configScroll = nil,
    bindingKey = nil, orbitConn = nil, orbitAngle = 0,
    isMouseDown = false, lastFireTime = 0, musicInstance = nil,
    killOrbitActive = false, originalCFrame = nil, killOrbitConns = {}
}

-- ============================================
-- HELPERS
-- ============================================
local function isTeam(plr)
    if not CFG.teamCheck then return false end
    if not lp.Team then return false end
    return plr.Team == lp.Team
end

local function getAimPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild(CFG.aimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- CONFIG SAVE / LOAD
-- ============================================
local CONFIG_FOLDER = "OllieConfigs"
local DEFAULT_CONFIG = CONFIG_FOLDER .. "/default.json"

if makefolder and not isfolder(CONFIG_FOLDER) then
    pcall(function() makefolder(CONFIG_FOLDER) end)
end

local function applyConfig()
    for _, item in ipairs(flags.uiItems) do item.update(CFG[item.key]) end
end

local function saveConfig(fileName)
    fileName = fileName or "default.json"
    if not fileName:match("%.json$") then fileName = fileName .. ".json" end
    local fullPath = CONFIG_FOLDER .. "/" .. fileName
    
    pcall(function()
        local data = {}
        for k, v in pairs(CFG) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                data[k] = v
            end
        end
        if writefile then writefile(fullPath, HttpService:JSONEncode(data)) end
    end)
end

local function loadConfig(fileName)
    fileName = fileName or "default.json"
    local fullPath = CONFIG_FOLDER .. "/" .. fileName
    
    pcall(function()
        if isfile and isfile(fullPath) then
            local raw = readfile(fullPath)
            if raw and raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                for k, v in pairs(data) do
                    if CFG[k] ~= nil then CFG[k] = v end
                end
                applyConfig()
            end
        end
    end)
end

loadConfig() 

-- ============================================
-- DA HOOD SPEED BYPASS
-- ============================================
RunService:BindToRenderStep("OllieSpeedBypass", Enum.RenderPriority.Camera.Value + 2, function()
    if CFG.speedLock then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed ~= CFG.walkSpeed then hum.WalkSpeed = CFG.walkSpeed end
            if hum.UseJumpPower and hum.JumpPower ~= CFG.jumpPower then hum.JumpPower = CFG.jumpPower end
        end
    end
end)

-- ============================================
-- RAPID FIRE LOGIC
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
        flags.isMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        flags.isMouseDown = false
    end
end)

RunService.RenderStepped:Connect(function()
    if CFG.rapidFire and flags.isMouseDown then
        local char = lp.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local now = tick()
            if now - flags.lastFireTime >= CFG.rapidFireRate then
                flags.lastFireTime = now
                local fired = false
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("RemoteEvent") and (child.Name:lower():find("fire") or child.Name:lower():find("shoot")) then
                        pcall(function() child:FireServer() end)
                        fired = true
                        break
                    end
                end
                if not fired then pcall(function() tool:Activate() end) end
            end
        end
    end
end)

-- ============================================
-- UI BUILDERS (Cyber Edition)
-- ============================================
local function makeLabel(parent, text, size, color, font)
    local lbl = Instance.new("TextLabel")
    lbl.Size = size or UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    lbl.Font = font or Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeButton(parent, text, size, bgColor, hoverColor, isPremiumFeature)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(80, 100, 255); stroke.Thickness = 1; stroke.Transparency = 0.7; stroke.Parent = btn
    local grad = Instance.new("UIGradient"); grad.Color = ColorSequence.new(Color3.fromRGB(40, 40, 55), Color3.fromRGB(25, 25, 35)); grad.Rotation = 90; grad.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor or Color3.fromRGB(50, 50, 80)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bgColor or Color3.fromRGB(30, 30, 45)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    return btn
end

local function makeToggle(parent, label, cfKey, cb, isPremiumFeature)
    local default = CFG[cfKey]
    local btn = makeButton(parent, "  " .. label, UDim2.new(1, 0, 0, 32), Color3.fromRGB(25, 25, 35), Color3.fromRGB(40, 40, 60), isPremiumFeature)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -8)
    indicator.Position = UDim2.new(0, 4, 0, 4)
    indicator.BackgroundColor3 = default and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(1, 0); ic.Parent = indicator
    local ig = Instance.new("UIGradient"); ig.Color = ColorSequence.new(indicator.BackgroundColor3); ig.Parent = indicator

    local function updateState(state)
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        ig.Color = ColorSequence.new(indicator.BackgroundColor3)
    end
    
    btn.MouseButton1Click:Connect(function()
        CFG[cfKey] = not CFG[cfKey]
        updateState(CFG[cfKey])
        saveConfig()
        if cb then cb(CFG[cfKey]) end
    end)
    table.insert(flags.uiItems, {type = "toggle", key = cfKey, update = updateState})
    return btn
end

local function makeTextInput(parent, cfKey, cb)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 20)
    box.Position = UDim2.new(1, -55, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    box.TextColor3 = Color3.fromRGB(0, 255, 150)
    box.Text = tostring(CFG[cfKey])
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = box
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(0, 255, 150); s.Transparency = 0.5; s.Parent = box
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            CFG[cfKey] = num
            saveConfig()
            if cb then cb(num) end
        else
            box.Text = tostring(CFG[cfKey])
        end
    end)
    table.insert(flags.uiItems, {type = "textbox", key = cfKey, update = function(v) box.Text = tostring(v) end})
end

local function makeSlider(parent, label, min, max, cfKey, cb)
    local default = CFG[cfKey]
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 44)
    holder.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 6); hc.Parent = holder
    local hs = Instance.new("UIStroke"); hs.Color = Color3.fromRGB(60, 60, 90); hs.Parent = holder
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    makeTextInput(holder, cfKey, cb)
    
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 45); bar.BorderSizePixel = 0; bar.Parent = holder
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255); fill.BorderSizePixel = 0; fill.Parent = bar
    local fcn = Instance.new("UICorner"); fcn.CornerRadius = UDim.new(1, 0); fcn.Parent = fill
    local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new(Color3.fromRGB(0, 255, 200), Color3.fromRGB(0, 100, 255)); fg.Parent = fill
    
    local function updateVisual(val)
        local rel = math.clamp((val - min) / (max - min), 0, 1)
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
    end
    
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * rel) * 100) / 100
            CFG[cfKey] = val
            updateVisual(val)
            saveConfig()
            if cb then cb(val) end
        end
    end)
    table.insert(flags.uiItems, {type = "slider", key = cfKey, update = updateVisual})
    return holder
end

-- ============================================
-- MAIN GUI & SIDEBAR
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdmin"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 700, 0, 460)
main.Position = UDim2.new(0.5, -350, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = main

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 30), Color3.fromRGB(10, 10, 15))
mainGrad.Rotation = 45
mainGrad.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 200, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main
local title = makeLabel(topBar, "  OLLIE ADMIN PREMIUM", UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
title.TextSize = 16

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new(Color3.fromRGB(0, 255, 200), Color3.fromRGB(0, 100, 255))
titleGrad.Parent = title

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 60, 60))
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.TextSize = 12
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = sidebar
local ss = Instance.new("UIStroke"); ss.Color = Color3.fromRGB(40, 40, 60); ss.Parent = sidebar

local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 6); navLayout.SortOrder = Enum.SortOrder.LayoutOrder; navLayout.Parent = sidebar
local navPad = Instance.new("UIPadding"); navPad.PaddingTop = UDim.new(0, 10); navPad.PaddingLeft = UDim.new(0, 5); navPad.PaddingRight = UDim.new(0, 5); navPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -300, 1, -50)
content.Position = UDim2.new(0, 160, 0, 50)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local currentPage
local navButtons = {}

local function setPage(name)
    if currentPage then currentPage.Visible = false end
    currentPage = pages[name]
    if currentPage then currentPage.Visible = true end
    
    for _, btn in pairs(navButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        btn.UIStroke.Transparency = 1
    end
    if navButtons[name] then
        navButtons[name].BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        navButtons[name].TextColor3 = Color3.fromRGB(0, 255, 200)
        navButtons[name].UIStroke.Transparency = 0
    end
end

local function addTab(name)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, 0, 0, 34), Color3.fromRGB(15, 15, 22), Color3.fromRGB(25, 25, 40))
    btn.TextXAlignment = Enum.TextXAlignment.Left
    navButtons[name] = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 10); pl.Parent = page
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- CLICKABLE SAVED CONFIGS BOX
-- ============================================
local configBoxFrame = Instance.new("Frame")
configBoxFrame.Size = UDim2.new(0, 140, 1, -50)
configBoxFrame.Position = UDim2.new(1, -150, 0, 50)
configBoxFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
configBoxFrame.BorderSizePixel = 0
configBoxFrame.Parent = main
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 8); cbc.Parent = configBoxFrame
local cbs = Instance.new("UIStroke"); cbs.Color = Color3.fromRGB(40, 40, 60); cbs.Parent = configBoxFrame

local configTitle = makeLabel(configBoxFrame, "  SAVED CONFIGS", UDim2.new(1, 0, 0, 20), Color3.fromRGB(0, 255, 200))
configTitle.Position = UDim2.new(0, 10, 0, 10)
configTitle.TextSize = 11
configTitle.Font = Enum.Font.GothamBold

flags.configScroll = Instance.new("ScrollingFrame")
flags.configScroll.Size = UDim2.new(1, -20, 1, -40)
flags.configScroll.Position = UDim2.new(0, 10, 0, 35)
flags.configScroll.BackgroundTransparency = 1
flags.configScroll.BorderSizePixel = 0
flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
flags.configScroll.ScrollBarThickness = 2
flags.configScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
flags.configScroll.Parent = configBoxFrame

local cfgListLayout = Instance.new("UIListLayout")
cfgListLayout.Padding = UDim.new(0, 4)
cfgListLayout.Parent = flags.configScroll

local function refreshConfigList()
    for _, c in ipairs(flags.configScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    pcall(function()
        if listfiles then
            for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
                if f:lower():match("%.json$") then
                    count = count + 1
                    local btn = makeButton(flags.configScroll, "  " .. f, UDim2.new(1, 0, 0, 26), Color3.fromRGB(20, 20, 30), Color3.fromRGB(35, 35, 55))
                    btn.TextSize = 11
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.MouseButton1Click:Connect(function() loadConfig(f) end)
                end
            end
        end
    end)
    flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, count * 30)
end

-- ============================================
-- TAB: PLAYERS
-- ============================================
local playersPage = addTab("Players")
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 32); searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
searchBox.PlaceholderText = "Search players..."; searchBox.Text = ""; searchBox.TextColor3 = Color3.fromRGB(0, 255, 200)
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.BorderSizePixel = 0; searchBox.Parent = playersPage
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 6); sbc.Parent = searchBox

local pList = Instance.new("ScrollingFrame")
pList.Size = UDim2.new(1, 0, 0, 130); pList.Position = UDim2.new(0, 0, 0, 45)
pList.BackgroundColor3 = Color3.fromRGB(15, 15, 22); pList.BorderSizePixel = 0
pList.CanvasSize = UDim2.new(0, 0, 0, 0); pList.ScrollBarThickness = 2; pList.Parent = playersPage
local plc = Instance.new("UICorner"); plc.CornerRadius = UDim.new(0, 8); plc.Parent = pList
local pLayout = Instance.new("UIListLayout"); pLayout.Padding = UDim.new(0, 2); pLayout.Parent = pList

local detailsPanel = Instance.new("Frame")
detailsPanel.Size = UDim2.new(1, 0, 1, -250); detailsPanel.Position = UDim2.new(0, 0, 0, 205)
detailsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 22); detailsPanel.BorderSizePixel = 0; detailsPanel.Parent = playersPage
local dpc = Instance.new("UICorner"); dpc.CornerRadius = UDim.new(0, 8); dpc.Parent = detailsPanel

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(0, 60, 0, 60); avatarImg.Position = UDim2.new(0, 10, 0, 10)
avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 35); avatarImg.BorderSizePixel = 0; avatarImg.Parent = detailsPanel
local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(0, 8); avc.Parent = avatarImg
local avs = Instance.new("UIStroke"); avs.Color = Color3.fromRGB(0, 200, 255); avs.Parent = avatarImg

local detailsText = makeLabel(detailsPanel, "Select a player...", UDim2.new(1, -80, 0, 60), Color3.fromRGB(200, 200, 200))
detailsText.Position = UDim2.new(0, 80, 0, 10); detailsText.TextYAlignment = Enum.TextYAlignment.Top; detailsText.TextSize = 11

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 32); btnContainer.Position = UDim2.new(0, 10, 1, -45)
btnContainer.BackgroundTransparency = 1; btnContainer.Parent = detailsPanel
local btnLayout = Instance.new("UIListLayout"); btnLayout.FillDirection = Enum.FillDirection.Horizontal; btnLayout.Padding = UDim.new(0, 6); btnLayout.Parent = btnContainer

local teleportBtn = makeButton(btnContainer, "Teleport", UDim2.new(0.2, -5, 1, 0))
local spectateBtn = makeButton(btnContainer, "Spectate", UDim2.new(0.2, -5, 1, 0))
local orbitBtn = makeButton(btnContainer, "Orbit", UDim2.new(0.2, -5, 1, 0))
local killOrbitBtn = makeButton(btnContainer, "Kill Orbit", UDim2.new(0.2, -5, 1, 0), Color3.fromRGB(200, 60, 60))
local highlightBtn = makeButton(btnContainer, "Highlight", UDim2.new(0.2, -5, 1, 0))

local function refreshPlayers()
    for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local n = 0; local query = searchBox.Text:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Name:lower():find(query) then
            n = n + 1
            local row = makeButton(pList, "  " .. p.Name, UDim2.new(1, 0, 0, 28), Color3.fromRGB(20, 20, 30), Color3.fromRGB(35, 35, 50))
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.MouseButton1Click:Connect(function()
                CFG.selectedPlayer = p
                for _, r in ipairs(pList:GetChildren()) do if r:IsA("TextButton") then r.BackgroundColor3 = Color3.fromRGB(20, 20, 30) end end
                row.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                detailsText.Text = p.Name .. " (@" .. p.DisplayName .. ")\nID: " .. p.UserId
                task.spawn(function() local ok, thumb = pcall(function() return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end); if ok then avatarImg.Image = thumb end end)
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 30)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(1); refreshPlayers() end)

teleportBtn.MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character and lp.Character then
        local hrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then lp.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
    end
end)

local function stopSpectating()
    flags.isSpectating = false
    spectateBtn.Text = "Spectate"
    spectateBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if myHum then camera.CameraSubject = myHum; camera.CameraType = Enum.CameraType.Custom end
end

spectateBtn.MouseButton1Click:Connect(function()
    if flags.isSpectating then stopSpectating()
    elseif CFG.selectedPlayer and CFG.selectedPlayer.Character then
        local hum = CFG.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then 
            flags.isSpectating = true
            camera.CameraSubject = hum
            camera.CameraType = Enum.CameraType.Custom
            spectateBtn.Text = "Stop"
            spectateBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        end
    end
end)

local isOrbiting = false
orbitBtn.MouseButton1Click:Connect(function()
    if not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
    isOrbiting = not isOrbiting
    if isOrbiting then
        orbitBtn.Text = "Orbiting..."; orbitBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        flags.orbitAngle = 0
        flags.orbitConn = RunService.Heartbeat:Connect(function(dt)
            if not isOrbiting or not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHrp then
                flags.orbitAngle = flags.orbitAngle + (dt * CFG.orbitSpeed)
                hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(math.cos(flags.orbitAngle), 0, math.sin(flags.orbitAngle)) * CFG.orbitRadius, targetHrp.Position)
            end
        end)
    else
        orbitBtn.Text = "Orbit"; orbitBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        if flags.orbitConn then flags.orbitConn:Disconnect(); flags.orbitConn = nil end
    end
end)

local function stopKillOrbit()
    if not flags.killOrbitActive then return end
    flags.killOrbitActive = false
    for _, c in ipairs(flags.killOrbitConns) do c:Disconnect() end
    flags.killOrbitConns = {}
    if flags.originalCFrame and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = flags.originalCFrame
    end
    killOrbitBtn.Text = "Kill Orbit"
    killOrbitBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end

killOrbitBtn.MouseButton1Click:Connect(function()
    if flags.killOrbitActive then stopKillOrbit(); return end
    if not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
    local target = CFG.selectedPlayer
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    flags.originalCFrame = myHrp.CFrame
    flags.killOrbitActive = true
    killOrbitBtn.Text = "Killing..."; killOrbitBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    local angle = 0
    table.insert(flags.killOrbitConns, RunService.Heartbeat:Connect(function(dt)
        if not flags.killOrbitActive then return end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local tHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tHrp then
            angle = angle + (dt * CFG.orbitSpeed * 2)
            hrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(math.cos(angle), 2, math.sin(angle)) * CFG.orbitRadius, tHrp.Position)
        end
    end))
    table.insert(flags.killOrbitConns, RunService.RenderStepped:Connect(function()
        if not flags.killOrbitActive then return end
        local head = target.Character and target.Character:FindFirstChild("Head")
        if head then camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position) end
    end))
    table.insert(flags.killOrbitConns, RunService.Heartbeat:Connect(function()
        if not flags.killOrbitActive then return end
        local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("RemoteEvent") and (child.Name:lower():find("fire") or child.Name:lower():find("shoot")) then
                    pcall(function() child:FireServer() end)
                    break
                end
            end
        end
    end))
    table.insert(flags.killOrbitConns, RunService.Heartbeat:Connect(function()
        if not flags.killOrbitActive then return end
        local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then stopKillOrbit() end
    end))
end)

highlightBtn.MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character then
        local hl = Instance.new("Highlight", CFG.selectedPlayer.Character); hl.FillColor = Color3.fromRGB(255, 200, 60); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; task.wait(2); hl:Destroy()
    end
end)

-- ============================================
-- TAB: COMBAT
-- ============================================
local combatPage = addTab("Combat")
makeToggle(combatPage, "Team Check", "teamCheck")
makeToggle(combatPage, "Aimbot (RMB)", "aimbot")
makeSlider(combatPage, "Aimbot FOV", 20, 500, "aimFov")
makeSlider(combatPage, "Aimbot Smoothness", 0.05, 1, "aimSmooth")
makeToggle(combatPage, "Triggerbot", "triggerbot")
makeSlider(combatPage, "Trigger Delay", 0.05, 1, "triggerDelay")
makeSlider(combatPage, "Trigger Range", 50, 500, "triggerRange")
makeToggle(combatPage, "Rapid Fire", "rapidFire")
makeSlider(combatPage, "Rapid Fire Rate", 0.01, 0.2, "rapidFireRate")

UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = false end end)
RunService:BindToRenderStep("OllieAim", Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.aimbot or not flags.aiming then return end
    local closest, dist = nil, CFG.aimFov
    local mouse = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and not isTeam(p) and p.Character then
            local part = getAimPart(p)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
                    if d < dist then closest, dist = part, d end
                end
            end
        end
    end
    if closest then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closest.Position), CFG.aimSmooth) end
end)
task.spawn(function()
    while task.wait(0.05) do
        if CFG.triggerbot then
            local mouse = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
            local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {lp.Character, workspace:FindFirstChild("AdminESP")}
            local result = workspace:Raycast(ray.Origin, ray.Direction * CFG.triggerRange, params)
            if result and result.Instance then
                local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
                local hitPlayer = hitModel and Players:GetPlayerFromCharacter(hitModel)
                if hitPlayer and hitPlayer ~= lp and not isTeam(hitPlayer) then
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                    task.wait(CFG.triggerDelay)
                end
            end
        end
    end
end)

-- ============================================
-- TAB: MOVEMENT
-- ============================================
local movePage = addTab("Movement")
makeSlider(movePage, "WalkSpeed", 16, 300, "walkSpeed", function(v) local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end)
makeSlider(movePage, "JumpPower", 50, 300, "jumpPower", function(v) local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v; hum.UseJumpPower = true end end)
makeSlider(movePage, "Fly Speed", 10, 300, "flySpeed")
makeToggle(movePage, "Fly", "fly", function(v)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if v and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 9e4
        flags.flyConn = RunService.RenderStepped:Connect(function()
            if not CFG.fly or not hrp.Parent then return end
            local cam = camera; local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            bv.Velocity = move * CFG.flySpeed; bg.CFrame = cam.CFrame
        end)
    elseif not v then
        if flags.flyConn then flags.flyConn:Disconnect() end
        if hrp then for _, c in ipairs(hrp:GetChildren()) do if c:IsA("BodyVelocity") or c:IsA("BodyGyro") then c:Destroy() end end end
    end
end)
makeToggle(movePage, "Noclip", "noclip", function(v)
    if v and not flags.noclipConn then
        flags.noclipConn = RunService.Stepped:Connect(function()
            if not CFG.noclip then return end
            if lp.Character then for _, p in ipairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    elseif not v and flags.noclipConn then flags.noclipConn:Disconnect(); flags.noclipConn = nil end
end)
makeToggle(movePage, "Infinite Jump", "infJump", function(v)
    if v and not flags.infJumpConn then
        flags.infJumpConn = UserInputService.JumpRequest:Connect(function()
            if CFG.infJump then local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)
    elseif not v and flags.infJumpConn then flags.infJumpConn:Disconnect(); flags.infJumpConn = nil end
end)
makeToggle(movePage, "Speed Lock", "speedLock")

-- ============================================
-- TAB: VISUALS
-- ============================================
local visPage = addTab("Visuals")
makeToggle(visPage, "Fullbright", "fullbright", function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200); Lighting.Brightness = 3
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70); Lighting.Brightness = 1
    end
end)
makeToggle(visPage, "Player ESP", "esp", function(v)
    if v then
        local folder = workspace:FindFirstChild("AdminESP") or Instance.new("Folder", workspace); folder.Name = "AdminESP"
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local hl = Instance.new("Highlight", folder); hl.Adornee = p.Character
                hl.FillColor = isTeam(p) and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(255, 60, 60)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    else
        local folder = workspace:FindFirstChild("AdminESP"); if folder then folder:ClearAllChildren() end
    end
end)

-- ============================================
-- TAB: WAYPOINTS
-- ============================================
local wpPage = addTab("Waypoints")
local wpList = Instance.new("ScrollingFrame")
wpList.Size = UDim2.new(1, 0, 1, -45); wpList.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
wpList.BorderSizePixel = 0; wpList.CanvasSize = UDim2.new(0, 0, 0, 0); wpList.ScrollBarThickness = 2; wpList.Parent = wpPage
local wplc = Instance.new("UICorner"); wplc.CornerRadius = UDim.new(0, 8); wplc.Parent = wpList
local wpLayout = Instance.new("UIListLayout"); wpLayout.Padding = UDim.new(0, 2); wpLayout.Parent = wpList
local waypoints = {}
local function addWaypoint()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local wpName = "WP #" .. (#waypoints + 1)
        local wp = {name = wpName, pos = hrp.CFrame}
        table.insert(waypoints, wp)
        local row = makeButton(wpList, "  " .. wpName .. " (Click to TP)", UDim2.new(1, -4, 0, 26), Color3.fromRGB(20, 20, 30), Color3.fromRGB(35, 35, 50))
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.MouseButton1Click:Connect(function() if lp.Character then lp.Character.HumanoidRootPart.CFrame = wp.pos end end)
        wpList.CanvasSize = UDim2.new(0, 0, 0, #waypoints * 30)
    end
end
local saveWpBtn = makeButton(wpPage, "Save Current Position", UDim2.new(1, 0, 0, 32), Color3.fromRGB(40, 90, 40))
saveWpBtn.Position = UDim2.new(0, 0, 1, -36); saveWpBtn.MouseButton1Click:Connect(addWaypoint)

-- ============================================
-- TAB: TROLL
-- ============================================
local trollPage = addTab("Troll")
local musicInput = Instance.new("TextBox")
musicInput.Size = UDim2.new(1, 0, 0, 32); musicInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
musicInput.PlaceholderText = "Roblox Audio ID (e.g. 1837832580)"; musicInput.Text = ""
musicInput.TextColor3 = Color3.fromRGB(0, 255, 200); musicInput.Font = Enum.Font.Gotham; musicInput.TextSize = 12
musicInput.BorderSizePixel = 0; musicInput.Parent = trollPage
local mic = Instance.new("UICorner"); mic.CornerRadius = UDim.new(0, 6); mic.Parent = musicInput

makeButton(trollPage, "Play Music", UDim2.new(1, 0, 0, 32), Color3.fromRGB(200, 50, 50)).MouseButton1Click:Connect(function()
    local id = musicInput.Text
    if id and tonumber(id) then
        if flags.musicInstance then flags.musicInstance:Destroy() end
        local sound = Instance.new("Sound", lp.Character.HumanoidRootPart)
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = 2
        sound.Looped = true
        sound:Play()
        flags.musicInstance = sound
    end
end)

makeButton(trollPage, "Stop Music", UDim2.new(1, 0, 0, 32), Color3.fromRGB(100, 40, 40)).MouseButton1Click:Connect(function()
    if flags.musicInstance then flags.musicInstance:Destroy(); flags.musicInstance = nil end
end)

makeButton(trollPage, "Ragdoll Self", UDim2.new(1, 0, 0, 32), Color3.fromRGB(200, 100, 50)).MouseButton1Click:Connect(function()
    if lp.Character then lp.Character:BreakJoints() end
end)

makeButton(trollPage, "Giant Me", UDim2.new(1, 0, 0, 32), Color3.fromRGB(100, 200, 100)).MouseButton1Click:Connect(function()
    if lp.Character then
        local scale = lp.Character:FindFirstChild("BodyHeightScale") or Instance.new("NumberValue", lp.Character)
        scale.Name = "BodyHeightScale"; scale.Value = 5
        local width = lp.Character:FindFirstChild("BodyWidthScale") or Instance.new("NumberValue", lp.Character)
        width.Name = "BodyWidthScale"; width.Value = 5
        local depth = lp.Character:FindFirstChild("BodyDepthScale") or Instance.new("NumberValue", lp.Character)
        depth.Name = "BodyDepthScale"; depth.Value = 5
    end
end)

makeButton(trollPage, "Reset Size", UDim2.new(1, 0, 0, 32), Color3.fromRGB(80, 80, 80)).MouseButton1Click:Connect(function()
    if lp.Character then
        local scale = lp.Character:FindFirstChild("BodyHeightScale"); if scale then scale.Value = 1 end
        local width = lp.Character:FindFirstChild("BodyWidthScale"); if width then width.Value = 1 end
        local depth = lp.Character:FindFirstChild("BodyDepthScale"); if depth then depth.Value = 1 end
    end
end)

-- ============================================
-- TAB: KEYBINDS
-- ============================================
local infoPage = addTab("Keybinds")
local function makeBindButton(parent, label, cfKey)
    local btn = makeButton(parent, "  " .. label .. ": " .. CFG[cfKey], UDim2.new(1, 0, 0, 32), Color3.fromRGB(25, 25, 35), Color3.fromRGB(40, 40, 60))
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function()
        btn.Text = "  " .. label .. ": [Press Key]"
        flags.bindingKey = {btn = btn, label = label, cfKey = cfKey}
    end)
    table.insert(flags.uiItems, {type = "bind", key = cfKey, update = function(val) btn.Text = "  " .. label .. ": " .. val end})
end
makeBindButton(infoPage, "Toggle Speed", "keySpeed")
makeBindButton(infoPage, "Toggle Jump", "keyJump")
makeBindButton(infoPage, "Toggle Aimbot", "keyAimbot")
makeBindButton(infoPage, "Toggle Triggerbot", "keyTriggerbot")

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if flags.bindingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            CFG[flags.bindingKey.cfKey] = keyName
            flags.bindingKey.btn.Text = "  " .. flags.bindingKey.label .. ": " .. keyName
            flags.bindingKey = nil
            saveConfig()
        end
    else
        if input.KeyCode.Name == CFG.keySpeed and CFG.keySpeed ~= "None" then CFG.walkSpeed = (CFG.walkSpeed == 16) and 100 or 16 end
        if input.KeyCode.Name == CFG.keyJump and CFG.keyJump ~= "None" then CFG.jumpPower = (CFG.jumpPower == 50) and 150 or 50 end
        if input.KeyCode.Name == CFG.keyAimbot and CFG.keyAimbot ~= "None" then CFG.aimbot = not CFG.aimbot end
        if input.KeyCode.Name == CFG.keyTriggerbot and CFG.keyTriggerbot ~= "None" then CFG.triggerbot = not CFG.triggerbot end
    end
end)

-- ============================================
-- TAB: SETTINGS
-- ============================================
local setPageTab = addTab("Settings")
local saveNameBox = Instance.new("TextBox")
saveNameBox.Size = UDim2.new(1, 0, 0, 32); saveNameBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
saveNameBox.PlaceholderText = "Profile Name (e.g. rage.json)"; saveNameBox.Text = ""
saveNameBox.TextColor3 = Color3.fromRGB(0, 255, 200); saveNameBox.Font = Enum.Font.Gotham; saveNameBox.TextSize = 12
saveNameBox.BorderSizePixel = 0; saveNameBox.Parent = setPageTab
local snc = Instance.new("UICorner"); snc.CornerRadius = UDim.new(0, 6); snc.Parent = saveNameBox

local saveBtn = makeButton(setPageTab, "Save New Config Profile", UDim2.new(1, 0, 0, 32), Color3.fromRGB(40, 90, 40))
saveBtn.MouseButton1Click:Connect(function()
    local name = saveNameBox.Text
    if name == "" then name = "custom_config.json" end
    saveConfig(name)
    refreshConfigList()
end)

local unloadBtn = makeButton(setPageTab, "Unload GUI", UDim2.new(1, 0, 0, 32), Color3.fromRGB(100, 40, 40))
unloadBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ============================================
-- DRAG & INIT
-- ============================================
UserInputService.InputBegan:Connect(function(i, gpe) 
    if not gpe and i.KeyCode == Enum.KeyCode.Insert then main.Visible = not main.Visible end 
end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

setPage("Players")
for _, item in ipairs(flags.uiItems) do item.update(CFG[item.key]) end
refreshConfigList()

print("[Ollie Admin PREMIUM] loaded.")
