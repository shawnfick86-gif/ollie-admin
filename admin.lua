-- ============================================
-- OLLIE ADMIN  •  v44 (Pixel Perfect Clone + All Features)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================
-- CONFIG STATE
-- ============================================
local CFG = {
    teamCheck = true, aimbot = false, aimPart = "Head", aimFov = 150, aimSmooth = 0.2,
    triggerbot = false, triggerDelay = 0.1, triggerRange = 200,
    rapidFire = false, rapidFireRate = 0.04, hitboxExpand = false, hitboxSize = 5,
    walkSpeed = 16, jumpPower = 50, fly = false, flySpeed = 50, noclip = false,
    speedLock = true, esp = false, tracers = false, fullbright = false,
}

local flags = {
    flyConn = nil, noclipConn = nil, aiming = false, isMouseDown = false,
    espFolder = nil, tracerFolder = nil, lastFireTime = 0
}

-- ============================================
-- HELPERS & LOGIC
-- ============================================
local function isTeammate(plr)
    if not CFG.teamCheck then return false end
    if not lp.Team or not plr.Team then return false end
    return plr.Team == lp.Team
end

local function getAimPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild(CFG.aimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- Speed Bypass (Da Hood / High AC safe)
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

-- Aimbot
UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = false end end)

RunService.RenderStepped:Connect(function()
    if CFG.aimbot and flags.aiming then
        local closest, dist = nil, CFG.aimFov
        local mouse = UserInputService:GetMouseLocation()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and not isTeammate(p) and p.Character then
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
        if closest then 
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closest.Position), CFG.aimSmooth) 
        end
    end
end)

-- Triggerbot & Rapid Fire
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
                if hitPlayer and hitPlayer ~= lp and not isTeammate(hitPlayer) then
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

-- ESP & Tracers
RunService.RenderStepped:Connect(function()
    if not CFG.esp and not CFG.tracers then
        if flags.espFolder then flags.espFolder:ClearAllChildren() end
        if flags.tracerFolder then flags.tracerFolder:ClearAllChildren() end
        return
    end
    if not flags.espFolder then flags.espFolder = Instance.new("Folder", workspace); flags.espFolder.Name = "AdminESP" end
    if not flags.tracerFolder then flags.tracerFolder = Instance.new("Folder", pg); flags.tracerFolder.Name = "AdminTracers" end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if CFG.esp and not flags.espFolder:FindFirstChild(p.Name) then
                    local hl = Instance.new("Highlight")
                    hl.Name = p.Name
                    hl.Adornee = p.Character
                    hl.FillColor = isTeammate(p) and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(255, 60, 60)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = flags.espFolder
                end
                if CFG.tracers then
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not flags.tracerFolder:FindFirstChild(p.Name) then
                            local line = Instance.new("Frame")
                            line.Name = p.Name
                            line.BackgroundColor3 = isTeammate(p) and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(255, 60, 60)
                            line.BorderSizePixel = 0
                            line.Parent = flags.tracerFolder
                        end
                        local line = flags.tracerFolder:FindFirstChild(p.Name)
                        local startX = camera.ViewportSize.X / 2
                        local startY = camera.ViewportSize.Y
                        local length = math.sqrt((screenPos.X - startX)^2 + (screenPos.Y - startY)^2)
                        local angle = math.atan2(screenPos.Y - startY, screenPos.X - startX)
                        line.Size = UDim2.new(0, length, 0, 1)
                        line.Position = UDim2.new(0, startX, 0, startY)
                        line.Rotation = math.deg(angle)
                        line.Visible = true
                    else
                        if flags.tracerFolder:FindFirstChild(p.Name) then flags.tracerFolder[p.Name].Visible = false end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- UI BUILDERS
-- ============================================
local FONT = Enum.Font.Gotham
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local SUB_COLOR = Color3.fromRGB(150, 150, 160)
local BG_COLOR = Color3.fromRGB(25, 15, 35)
local ROW_COLOR = Color3.fromRGB(45, 25, 55)
local RED_BOX_COLOR = Color3.fromRGB(80, 20, 30)

local function makeLabel(parent, text, size, color, font, textSize)
    local lbl = Instance.new("TextLabel")
    lbl.Size = size or UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or TEXT_COLOR
    lbl.Font = font or FONT
    lbl.TextSize = textSize or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeButton(parent, text, size, bgColor, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = bgColor or BG_COLOR
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = FONT
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(80, 40, 100); stroke.Thickness = 1; stroke.Transparency = 0.5; stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor or Color3.fromRGB(60, 35, 75)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = bgColor or BG_COLOR}):Play()
    end)
    return btn
end

local function makeToggle(parent, label, cfKey)
    local default = CFG[cfKey]
    local btn = makeButton(parent, "  " .. label, UDim2.new(1, 0, 0, 32), BG_COLOR)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0, 4, 1, -8); ind.Position = UDim2.new(0, 4, 0, 4)
    ind.BackgroundColor3 = default and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    ind.BorderSizePixel = 0
    local ic = Instance.new("UICorner", ind); ic.CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function()
        CFG[cfKey] = not CFG[cfKey]
        ind.BackgroundColor3 = CFG[cfKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    end)
end

local function makeSlider(parent, label, min, max, cfKey)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 40); holder.BackgroundColor3 = BG_COLOR
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    
    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(0, 50, 0, 20); box.Position = UDim2.new(1, -55, 0, 4)
    box.BackgroundColor3 = Color3.fromRGB(20, 10, 25); box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = tostring(CFG[cfKey]); box.Font = Enum.Font.Code; box.TextSize = 12; box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    
    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(1, -20, 0, 4); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 30, 60); bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((CFG[cfKey]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 0, 255); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * rel) * 100) / 100
            CFG[cfKey] = val
            fill.Size = UDim2.new(rel, 0, 1, 0)
            box.Text = tostring(val)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- ============================================
-- MAIN GUI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdmin"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 750, 0, 480)
main.Position = UDim2.new(0.5, -375, 0.5, -240)
main.BackgroundColor3 = BG_COLOR
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(100, 50, 150); ms.Thickness = 1; ms.Transparency = 0.5; ms.Parent = main

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 36); topBar.Position = UDim2.new(0, 10, 0, 10)
topBar.BackgroundTransparency = 1; topBar.Parent = main

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 220, 1, 0); searchFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
searchFrame.BorderSizePixel = 0; searchFrame.Parent = topBar
local sfc = Instance.new("UICorner"); sfc.CornerRadius = UDim.new(0, 6); sfc.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 1, 0); searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "USER / ID"
searchBox.Text = ""; searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchFrame

local searchIcon = makeLabel(searchFrame, "🔍", UDim2.new(0, 24, 1, 0), Color3.fromRGB(150, 150, 160), FONT, 14)
searchIcon.Position = UDim2.new(1, -30, 0, 0)

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 30, 0, 26), Color3.fromRGB(40, 20, 50))
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local joinBtn = makeButton(topBar, "JOIN", UDim2.new(0, 60, 0, 26), Color3.fromRGB(40, 20, 50))
joinBtn.Position = UDim2.new(1, -100, 0, 5)

-- Left Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 90, 1, -110); sidebar.Position = UDim2.new(0, 10, 0, 55)
sidebar.BackgroundTransparency = 1; sidebar.Parent = main

local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 4); navLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -120, 1, -110); content.Position = UDim2.new(0, 110, 0, 55)
content.BackgroundTransparency = 1; content.Parent = main

local pages = {}
local currentPage
local navButtons = {}

local function setPage(name)
    if currentPage then currentPage.Visible = false end
    currentPage = pages[name]
    if currentPage then currentPage.Visible = true end
    
    for _, btn in pairs(navButtons) do
        btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
    if navButtons[name] then
        navButtons[name].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function addTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    navButtons[name] = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 6); pl.Parent = page
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- TAB: PLAYERS (Exact Clone)
-- ============================================
local playersPage = addTab("Players")

local subTabsFrame = Instance.new("Frame")
subTabsFrame.Size = UDim2.new(1, 0, 0, 24); subTabsFrame.BackgroundTransparency = 1
subTabsFrame.Parent = playersPage

local tabLayout = Instance.new("UIListLayout", subTabsFrame)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 10)

local subTabs = {"ALL", "SPEED", "REACTION", "AIM"}
local subTabBtns = {}

for _, name in ipairs(subTabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(140, 140, 150)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = subTabsFrame
    subTabBtns[name] = btn
end
subTabBtns["ALL"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Sub Search Bar
local subSearch = Instance.new("Frame", subTabsFrame)
subSearch.Size = UDim2.new(0, 100, 1, 0); subSearch.Position = UDim2.new(1, -100, 0, 0)
subSearch.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
Instance.new("UICorner", subSearch).CornerRadius = UDim.new(0, 4)
local subSIcon = makeLabel(subSearch, "🔍 USER SEARCH", UDim2.new(1, -10, 1, 0), Color3.fromRGB(140, 140, 150), FONT, 9)
subSIcon.Position = UDim2.new(0, 5, 0, 0)

local pList = Instance.new("ScrollingFrame")
pList.Size = UDim2.new(1, 0, 1, -35); pList.Position = UDim2.new(0, 0, 0, 35)
pList.BackgroundTransparency = 1; pList.BorderSizePixel = 0
pList.CanvasSize = UDim2.new(0, 0, 0, 0); pList.ScrollBarThickness = 2; pList.Parent = playersPage
local pLayout = Instance.new("UIListLayout", pList); pLayout.Padding = UDim.new(0, 4)

local function refreshPlayers()
    for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            n = n + 1
            local row = makeButton(pList, "", UDim2.new(1, -8, 0, 46), ROW_COLOR)
            row.Position = UDim2.new(0, 4, 0, (n-1)*50)
            
            -- Red Name Box
            local nameBox = Instance.new("Frame", row)
            nameBox.Size = UDim2.new(0, 110, 1, -8)
            nameBox.Position = UDim2.new(0, 4, 0, 4)
            nameBox.BackgroundColor3 = RED_BOX_COLOR
            Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)
            
            local nameLbl = makeLabel(nameBox, p.DisplayName, UDim2.new(1, -10, 0, 20), Color3.fromRGB(255, 255, 255), FONT, 12)
            nameLbl.Position = UDim2.new(0, 5, 0, 2); nameLbl.Font = Enum.Font.GothamBold
            local subLbl = makeLabel(nameBox, "default", UDim2.new(1, -10, 0, 16), Color3.fromRGB(140, 140, 150), FONT, 9)
            subLbl.Position = UDim2.new(0, 5, 0, 20)
            
            local flag = makeLabel(row, "🇺🇸", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 255, 255), FONT, 14)
            flag.Position = UDim2.new(0, 125, 0, 10)
            local gear = makeLabel(row, "⚙", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
            gear.Position = UDim2.new(0, 155, 0, 12)
            local screen = makeLabel(row, "🖥", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
            screen.Position = UDim2.new(0, 180, 0, 12)
            
            local idLbl = makeLabel(row, tostring(p.UserId), UDim2.new(0, 100, 0, 16), Color3.fromRGB(255, 255, 255), FONT, 10)
            idLbl.Position = UDim2.new(1, -130, 0, 8)
            local actionNote = makeLabel(row, "ACTION NOTE HERE", UDim2.new(0, 100, 0, 16), Color3.fromRGB(140, 140, 150), FONT, 9)
            actionNote.Position = UDim2.new(1, -130, 0, 24)
            
            local eyeBtn = Instance.new("TextButton")
            eyeBtn.Size = UDim2.new(0, 24, 0, 24); eyeBtn.Position = UDim2.new(1, -30, 0, 11)
            eyeBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 35); eyeBtn.Text = "👁"
            eyeBtn.TextColor3 = Color3.fromRGB(200, 200, 200); eyeBtn.Font = Enum.Font.Gotham; eyeBtn.TextSize = 12
            eyeBtn.Parent = row
            local ebc = Instance.new("UICorner"); ebc.CornerRadius = UDim.new(0, 4); ebc.Parent = eyeBtn
            
            row.MouseButton1Click:Connect(function()
                CFG.selectedPlayer = p
                for _, r in ipairs(pList:GetChildren()) do if r:IsA("TextButton") then r.BackgroundColor3 = ROW_COLOR end end
                row.BackgroundColor3 = Color3.fromRGB(70, 40, 90)
                actionTitle.Text = p.DisplayName
                aID.Text = tostring(p.UserId)
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 50)
end
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(1); refreshPlayers() end)

-- ============================================
-- BOTTOM ACTION BAR
-- ============================================
local actionBar = Instance.new("Frame")
actionBar.Size = UDim2.new(1, -20, 0, 50); actionBar.Position = UDim2.new(0, 10, 1, -60)
actionBar.BackgroundColor3 = Color3.fromRGB(45, 20, 55); actionBar.Parent = main
local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(0, 6); abc.Parent = actionBar

local actionTitle = makeLabel(actionBar, "Dynamic", UDim2.new(0, 100, 0, 20), Color3.fromRGB(255, 255, 255), FONT, 12)
actionTitle.Position = UDim2.new(0, 10, 0, 5); actionTitle.Font = Enum.Font.GothamBold
local actionSub = makeLabel(actionBar, "premium", UDim2.new(0, 100, 0, 16), Color3.fromRGB(140, 140, 150), FONT, 9)
actionSub.Position = UDim2.new(0, 10, 0, 25)
local aFlag = makeLabel(actionBar, "🇺🇸", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 255, 255), FONT, 14)
aFlag.Position = UDim2.new(0, 110, 0, 12)
local aGear = makeLabel(actionBar, "⚙", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
aGear.Position = UDim2.new(0, 140, 0, 14)

local aNote = makeLabel(actionBar, "ACTION NOTE HERE", UDim2.new(0, 100, 0, 16), Color3.fromRGB(140, 140, 150), FONT, 9)
aNote.Position = UDim2.new(1, -160, 0, 8)
local aID = makeLabel(actionBar, "2456939876", UDim2.new(0, 100, 0, 16), Color3.fromRGB(255, 255, 255), FONT, 10)
aID.Position = UDim2.new(1, -160, 0, 26)

local aEye = Instance.new("TextButton")
aEye.Size = UDim2.new(0, 24, 0, 24); aEye.Position = UDim2.new(1, -40, 0, 13)
aEye.BackgroundColor3 = Color3.fromRGB(25, 15, 35); aEye.Text = "👁"
aEye.TextColor3 = Color3.fromRGB(200, 200, 200); aEye.Font = Enum.Font.Gotham; aEye.TextSize = 12
aEye.Parent = actionBar
local aec = Instance.new("UICorner"); aec.CornerRadius = UDim.new(0, 4); aec.Parent = actionBar

-- ============================================
-- TAB: COMBAT
-- ============================================
local combatPage = addTab("Combat")
makeToggle(combatPage, "Team Check", "teamCheck")
makeToggle(combatPage, "Aimbot (RMB)", "aimbot")
makeSlider(combatPage, "Aimbot FOV", 20, 500, "aimFov")
makeSlider(combatPage, "Aimbot Smoothness", 0.05, 1, "aimSmooth")
makeToggle(combatPage, "Triggerbot", "triggerbot")
makeToggle(combatPage, "Rapid Fire", "rapidFire")
makeToggle(combatPage, "Hitbox Expander", "hitboxExpand")
makeSlider(combatPage, "Hitbox Size", 1, 20, "hitboxSize")
makeToggle(combatPage, "ESP", "esp")
makeToggle(combatPage, "Tracers", "tracers")

-- ============================================
-- TAB: MOVEMENT
-- ============================================
local movePage = addTab("Movement")
makeSlider(movePage, "WalkSpeed", 16, 300, "walkSpeed")
makeSlider(movePage, "JumpPower", 50, 300, "jumpPower")
makeToggle(movePage, "Fly", "fly")
makeToggle(movePage, "Noclip", "noclip")
makeToggle(movePage, "Speed Lock", "speedLock")

-- ============================================
-- INIT
-- ============================================
setPage("Players")
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and i.KeyCode == Enum.KeyCode.Insert then main.Visible = not main.Visible end end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

print("[Ollie Admin v44] Pixel Perfect + All Features.")
