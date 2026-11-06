-- ============================================
-- OLLIE ADMIN v64 • FIXED CORE & POLISHED UI
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()

-- THEME CONFIG
local Theme = {
    BG = Color3.fromRGB(15, 15, 18),
    Panel = Color3.fromRGB(22, 22, 28),
    PanelHover = Color3.fromRGB(30, 30, 38),
    Accent = Color3.fromRGB(255, 66, 161),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(130, 130, 140),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

local States = {
    KillAura = false, Aimbot = false, Triggerbot = false, HitboxExpander = false, TeamCheck = false,
    AuraRange = 15, FOVSize = 150, HitboxSize = 10, AimSmoothness = 0.2,
    Fly = false, Noclip = false, InfJump = false,
    WalkSpeed = 16, JumpPower = 50, FlySpeed = 50,
    Fullbright = false, 
    SpectateTarget = nil, OrbitTarget = nil, OrbitSpeed = 1.5
}

local Waypoints = {}
local bvFly = nil

-- ============================================
-- 1. CORE UI ENGINE
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdminV64"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 600, 0, 420)
main.Position = UDim2.new(0.5, -300, 0.5, -210)
main.BackgroundColor3 = Theme.BG
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1
mainStroke.Transparency = 0.5

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundTransparency = 1
topBar.Active = true
topBar.Parent = main

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 50, 1, 0)
logo.Position = UDim2.new(0, 15, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "OLLIE"
logo.TextColor3 = Theme.Accent
logo.Font = Theme.FontBold
logo.TextSize = 16
logo.Active = false
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.TextDim
closeBtn.Font = Theme.FontBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 55, 1, -55)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundTransparency = 1
sidebar.Parent = main
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 8)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -85, 1, -60)
content.Position = UDim2.new(0, 75, 0, 50)
content.BackgroundColor3 = Theme.Panel
content.BorderSizePixel = 0
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 6)

local pages = {}
local activeTabBtn = nil
local firstPage = nil
local firstBtn = nil

local function CreateTab(name, iconEmoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.BackgroundColor3 = Theme.BG
    btn.Text = iconEmoji
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.Accent
    page.Parent = content
    pages[name] = page

    if not firstPage then
        firstPage = page
        firstBtn = btn
    end

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)

    local leftCol = Instance.new("Frame", page)
    leftCol.Size = UDim2.new(0.5, -5, 1, 0)
    leftCol.BackgroundTransparency = 1
    local lList = Instance.new("UIListLayout", leftCol)
    lList.Padding = UDim.new(0, 8)

    local rightCol = Instance.new("Frame", page)
    rightCol.Size = UDim2.new(0.5, -5, 1, 0)
    rightCol.Position = UDim2.new(0.5, 5, 0, 0)
    rightCol.BackgroundTransparency = 1
    local rList = Instance.new("UIListLayout", rightCol)
    rList.Padding = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        if activeTabBtn then
            TweenService:Create(activeTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BG, TextColor3 = Theme.TextDim}):Play()
        end
        activeTabBtn = btn
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Accent}):Play()
        for n, p in pairs(pages) do p.Visible = (n == name) end
    end)

    return leftCol, rightCol
end

-- BUILDERS
local function AddSection(parent, title)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Theme.Text
    t.Font = Theme.FontBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f
end

local function AddToggle(parent, text, stateKey, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BackgroundColor3 = Theme.BG
    box.Text = ""
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Theme.TextDim
    stroke.Thickness = 1

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 10, 0, 10)
    fill.Position = UDim2.new(0.5, -5, 0.5, -5)
    fill.BackgroundColor3 = Theme.Accent
    fill.Visible = false
    fill.Parent = box
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local isOn = false
    box.MouseButton1Click:Connect(function()
        isOn = not isOn
        fill.Visible = isOn
        stroke.Color = isOn and Theme.Accent or Theme.TextDim
        lbl.TextColor3 = isOn and Theme.Text or Theme.TextDim
        if stateKey then States[stateKey] = isOn end
        if callback then callback(isOn) end
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.Font
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 16)
    valLbl.Position = UDim2.new(1, -50, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Theme.Text
    valLbl.Font = Theme.FontBold
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = Theme.BG
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            local val = math.floor(min + (max - min) * relX)
            valLbl.Text = tostring(val)
            callback(val)
        end
    end)
end

local function AddButton(parent, text, callback, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = color or Theme.BG
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Theme.FontBold
    b.TextSize = 11
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    b.MouseEnter:Connect(function() TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play() end)
    b.MouseButton1Click:Connect(callback)
end

local function AddTextBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 28)
    box.BackgroundColor3 = Theme.BG
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextDim
    box.Font = Theme.Font
    box.TextSize = 11
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    return box
end

-- ============================================
-- 2. TABS & FEATURES
-- ============================================

local cLeft, cRight = CreateTab("Combat", "⚔️")
AddSection(cLeft, "Combat Features")
AddToggle(cLeft, "Kill Aura", "KillAura")
AddToggle(cLeft, "Aimbot (Hold RMB)", "Aimbot")
AddToggle(cLeft, "Triggerbot", "Triggerbot")
AddToggle(cLeft, "Hitbox Expander", "HitboxExpander")
AddToggle(cLeft, "Team Check", "TeamCheck")

AddSection(cRight, "Settings")
AddSlider(cRight, "Aura Range", 5, 50, 15, function(v) States.AuraRange = v end)
AddSlider(cRight, "Aimbot FOV", 50, 500, 150, function(v) States.FOVSize = v end)
AddSlider(cRight, "Hitbox Size", 1, 20, 10, function(v) States.HitboxSize = v end)
AddSlider(cRight, "Aim Smoothness", 0.05, 1, 0.3, function(v) States.AimSmoothness = v end)

local mLeft, mRight = CreateTab("Movement", "🏃")
AddSection(mLeft, "Movement Mods")
AddToggle(mLeft, "Fly", "Fly", function(v)
    if v then
        if not bvFly then
            bvFly = Instance.new("BodyVelocity")
            bvFly.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bvFly.Parent = lp.Character.HumanoidRootPart
        end
    else
        if bvFly then bvFly:Destroy(); bvFly = nil end
    end
end)
AddToggle(mLeft, "Noclip", "Noclip")
AddToggle(mLeft, "Infinite Jump", "InfJump")

AddSection(mRight, "Speed Settings")
AddSlider(mRight, "WalkSpeed", 16, 250, 16, function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end)
AddSlider(mRight, "JumpPower", 50, 500, 50, function(v) 
    States.JumpPower = v
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = v end 
end)
AddSlider(mRight, "Fly Speed", 10, 200, 50, function(v) States.FlySpeed = v end)

local vLeft, vRight = CreateTab("Visuals", "👁️")
AddSection(vLeft, "World")
AddToggle(vLeft, "Fullbright", "Fullbright", function(v)
    if v then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) end
end)

local wLeft, wRight = CreateTab("Waypoints", "📍")
AddSection(wLeft, "Create Waypoint")
local wpNameBox = AddTextBox(wLeft, "Waypoint Name")
AddButton(wLeft, "Add Current Position", function()
    if wpNameBox.Text ~= "" and lp.Character then
        Waypoints[wpNameBox.Text] = lp.Character.HumanoidRootPart.CFrame
        wpNameBox.Text = ""
        RefreshWaypoints()
    end
end, Color3.fromRGB(30, 100, 30))

AddSection(wRight, "Saved Waypoints")
local wpScroll = Instance.new("ScrollingFrame")
wpScroll.Size = UDim2.new(1, 0, 0, 200)
wpScroll.BackgroundTransparency = 1
wpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
wpScroll.ScrollBarThickness = 2
wpScroll.Parent = wRight
local wpLayout = Instance.new("UIListLayout", wpScroll)
wpLayout.Padding = UDim.new(0, 4)

function RefreshWaypoints()
    for _, v in ipairs(wpScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for name, cf in pairs(Waypoints) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = Theme.BG
        btn.Text = "TP: " .. name
        btn.TextColor3 = Theme.Text
        btn.Font = Theme.Font
        btn.TextSize = 11
        btn.Parent = wpScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if lp.Character then lp.Character.HumanoidRootPart.CFrame = cf end
        end)
    end
end

local vmLeft, vmRight = CreateTab("Luau VM", "📜")
vmLeft.Size = UDim2.new(1, 0, 1, 0) 
vmRight.Visible = false

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, 0, 1, -40)
scriptBox.BackgroundColor3 = Theme.BG
scriptBox.Text = "-- Paste Luau script here"
scriptBox.TextColor3 = Theme.Text
scriptBox.Font = Enum.Font.Code
scriptBox.TextSize = 12
scriptBox.MultiLine = true
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.ClearTextOnFocus = false
scriptBox.Parent = vmLeft
Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 4)

AddButton(vmLeft, "EXECUTE SCRIPT", function()
    local code = scriptBox.Text
    local func, err = loadstring(code)
    if func then
        local success, runtimeErr = pcall(func)
        if not success then print("[Luau VM Error]:", runtimeErr) end
    else
        print("[Luau VM Compile Error]:", err)
    end
end, Color3.fromRGB(150, 50, 50))

-- ============================================
-- 3. RENDER LOGIC & FIXES
-- ============================================
RunService.RenderStepped:Connect(function()
    if not lp.Character then return end
    local hum = lp.Character:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- FLY (BodyVelocity)
    if States.Fly and bvFly then
        local moveDir = hum.MoveDirection
        local camCF = workspace.CurrentCamera.CFrame
        local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and States.FlySpeed or 0
        local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -States.FlySpeed or 0
        
        local flyVector = (camCF.LookVector * (moveDir.Z * -1)) + (camCF.RightVector * moveDir.X) + Vector3.new(0, (up + down), 0)
        if flyVector.Magnitude > 0 then
            bvFly.Velocity = flyVector.Unit * States.FlySpeed
        else
            bvFly.Velocity = Vector3.new(0,0,0)
        end
    end
    
    -- AIMBOT (Standard Camera CFrame)
    if States.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest = nil
        local dist = math.huge
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not States.TeamCheck or (lp.Team ~= p.Team) then
                    local head = p.Character.Head
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                        local distanceToMouse = (screenVec - mousePos).Magnitude
                        if distanceToMouse < dist and distanceToMouse < States.FOVSize then
                            dist = distanceToMouse
                            closest = head
                        end
                    end
                end
            end
        end
        
        if closest then
            local targetCFrame = CFrame.new(camera.CFrame.Position, closest.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, States.AimSmoothness)
        end
    end
    
    -- KILL AURA
    if States.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not States.TeamCheck or (lp.Team ~= p.Team) then
                    if (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude <= States.AuraRange then
                        lp.Character.HumanoidRootPart.CFrame = CFrame.lookAt(lp.Character.HumanoidRootPart.Position, p.Character.HumanoidRootPart.Position)
                        local tool = lp.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
    end
    
    -- HITBOX EXPANDER
    if States.HitboxExpander then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = Vector3.new(States.HitboxSize, States.HitboxSize, States.HitboxSize)
                        part.Transparency = 0.5
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- NOCLIP & JUMPPOWER (Stepped is more reliable than RenderStepped for collisions)
RunService.Stepped:Connect(function()
    if not lp.Character then return end
    
    if States.Noclip then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    local hum = lp.Character:FindFirstChild("Humanoid")
    if hum and hum.JumpPower ~= States.JumpPower then
        hum.JumpPower = States.JumpPower
    end
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ============================================
-- 4. INIT & DRAG
-- ============================================
if firstPage and firstBtn then
    firstPage.Visible = true
    activeTabBtn = firstBtn
    firstBtn.BackgroundColor3 = Theme.Panel
    firstBtn.TextColor3 = Theme.Accent
end

local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[Ollie Admin v64] Loaded. Core Fixed.")
