-- ============================================
-- OLLIE ADMIN v60 • DRAG & SHIFT LOCK FIX
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()

-- THEME CONFIG
local Theme = {
    BG = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(28, 28, 32),
    Accent = Color3.fromRGB(255, 66, 161),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

local States = {
    KillAura = false, Aimbot = false, Triggerbot = false, HitboxExpander = false, TeamCheck = false, VisibleCheck = false,
    AuraRange = 15, FOVSize = 90, HitboxSize = 10, AimSmoothness = 0.2,
    Fly = false, Noclip = false, InfJump = false, LockMouse = false,
    WalkSpeed = 16, JumpPower = 50, FlySpeed = 50,
    Fullbright = false, SpectateTarget = nil, OrbitTarget = nil
}

-- ============================================
-- 1. CORE UI ENGINE
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdminV60"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 640, 0, 420)
main.Position = UDim2.new(0.5, -320, 0.5, -210)
main.BackgroundColor3 = Theme.BG
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 40, 1, 0)
logo.Position = UDim2.new(0, 15, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "O"
logo.TextColor3 = Theme.Accent
logo.Font = Theme.FontBold
logo.TextSize = 18
logo.Parent = topBar

-- Invisible Drag Button (Fixes the drag issue)
local dragBtn = Instance.new("TextButton")
dragBtn.Size = UDim2.new(1, -60, 1, 0)
dragBtn.Position = UDim2.new(0, 50, 0, 0)
dragBtn.BackgroundTransparency = 1
dragBtn.Text = ""
dragBtn.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.TextDim
closeBtn.Font = Theme.FontBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 50, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundTransparency = 1
sidebar.Parent = main
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 8)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -80, 1, -50)
content.Position = UDim2.new(0, 70, 0, 45)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local activeTabBtn = nil

local function CreateTab(name, iconEmoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.BackgroundColor3 = Theme.BG
    btn.Text = iconEmoji
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
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

    local leftCol = Instance.new("Frame", page)
    leftCol.Size = UDim2.new(0.5, -10, 1, 0)
    leftCol.BackgroundTransparency = 1
    local lList = Instance.new("UIListLayout", leftCol)
    lList.Padding = UDim.new(0, 8)

    local rightCol = Instance.new("Frame", page)
    rightCol.Size = UDim2.new(0.5, -10, 1, 0)
    rightCol.Position = UDim2.new(0.5, 10, 0, 0)
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

local function AddToggle(parent, text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BackgroundColor3 = Theme.Panel
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
        callback(isOn)
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
    valLbl.Font = Theme.Font
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = Theme.Panel
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

local function AddButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Theme.Panel
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
    b.MouseEnter:Connect(function() stroke.Transparency = 0 end)
    b.MouseLeave:Connect(function() stroke.Transparency = 0.5 end)
    b.MouseButton1Click:Connect(callback)
end

-- ============================================
-- 2. TABS
-- ============================================

local cLeft, cRight = CreateTab("Combat", "⚔️")
AddSection(cLeft, "Combat Features")
AddToggle(cLeft, "Kill Aura", function(v) States.KillAura = v end)
AddToggle(cLeft, "Aimbot (Hold RMB)", function(v) States.Aimbot = v end)
AddToggle(cLeft, "Triggerbot", function(v) States.Triggerbot = v end)
AddToggle(cLeft, "Hitbox Expander", function(v) States.HitboxExpander = v end)
AddToggle(cLeft, "Team Check", function(v) States.TeamCheck = v end)

AddSection(cRight, "Settings")
AddSlider(cRight, "Aura Range", 5, 50, 15, function(v) States.AuraRange = v end)
AddSlider(cRight, "FOV Size", 10, 360, 90, function(v) States.FOVSize = v end)
AddSlider(cRight, "Hitbox Size", 1, 20, 10, function(v) States.HitboxSize = v end)
AddSlider(cRight, "Aim Smoothness", 0.01, 1, 0.2, function(v) States.AimSmoothness = v end)

local mLeft, mRight = CreateTab("Movement", "🏃")
AddSection(mLeft, "Movement Mods")
AddToggle(mLeft, "Fly", function(v) States.Fly = v end)
AddToggle(mLeft, "Noclip", function(v) States.Noclip = v end)
AddToggle(mLeft, "Infinite Jump", function(v) States.InfJump = v end)
AddToggle(mLeft, "Lock Mouse (Aimbot)", function(v) 
    States.LockMouse = v 
    -- ONLY change mouse behavior when toggled
    if v then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

AddSection(mRight, "Speed Settings")
AddSlider(mRight, "WalkSpeed", 16, 250, 16, function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end)
AddSlider(mRight, "JumpPower", 50, 250, 50, function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = v end end)
AddSlider(mRight, "Fly Speed", 10, 150, 50, function(v) States.FlySpeed = v end)

local vLeft, vRight = CreateTab("Visuals", "👁️")
AddSection(vLeft, "World")
AddToggle(vLeft, "Fullbright", function(v)
    if v then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) end
end)

local sLeft, sRight = CreateTab("Misc", "⚙️")
AddSection(sLeft, "Server Actions")
AddButton(sLeft, "Kill All (Client)", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.Health = 0 end
    end
end)
AddButton(sLeft, "Fling All (Client)", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(1e5, 1e5, 1e5) end
    end
end)

AddSection(sRight, "Utility")
AddButton(sRight, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, lp) end)
AddButton(sRight, "Unload UI", function() gui:Destroy() end)

local pLeft, pRight = CreateTab("Players", "👥")
pLeft.Size = UDim2.new(1, 0, 1, 0)
pRight.Visible = false

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, 0)
playerScroll.BackgroundTransparency = 1
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.ScrollBarThickness = 2
playerScroll.Parent = pLeft
local pLayout = Instance.new("UIListLayout", playerScroll)
pLayout.Padding = UDim.new(0, 4)

local function RefreshPlayerList()
    for _, v in ipairs(playerScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Theme.Panel
        frame.Parent = playerScroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0, 200, 1, 0)
        nameLbl.Position = UDim2.new(0, 10, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = p.Name .. " | " .. (p.Team and p.Team.Name or "No Team")
        nameLbl.TextColor3 = Theme.Text
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = frame
        
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(0, 100, 1, 0)
        btnContainer.Position = UDim2.new(1, -110, 0, 0)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = frame
        local bLayout = Instance.new("UIListLayout", btnContainer)
        bLayout.FillDirection = Enum.FillDirection.Horizontal
        bLayout.Padding = UDim.new(0, 4)
        bLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        
        local function makeIconBtn(emoji, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 28, 0, 24)
            b.BackgroundColor3 = Theme.BG
            b.Text = emoji
            b.TextSize = 12
            b.Parent = btnContainer
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(callback)
        end
        
        makeIconBtn("👁️", function()
            if States.SpectateTarget == p then
                States.SpectateTarget = nil
                if lp.Character then camera.CameraSubject = lp.Character.Humanoid end
            else
                States.SpectateTarget = p
                if p.Character then camera.CameraSubject = p.Character.Humanoid end
            end
        end)
        makeIconBtn("✨", function()
            if p.Character and lp.Character then lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
        end)
        makeIconBtn("🌀", function()
            States.OrbitTarget = (States.OrbitTarget == p) and nil or p
            if not States.OrbitTarget then camera.CameraSubject = lp.Character.Humanoid end
        end)
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y)
end
RefreshPlayerList()

-- ============================================
-- 3. RENDER & DRAG LOGIC
-- ============================================
RunService.RenderStepped:Connect(function()
    if not lp.Character then return end
    
    if States.Fly then
        local move = lp.Character.Humanoid.MoveDirection
        local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 2 or 0
        local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -2 or 0
        lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + (move * (States.FlySpeed/50)) + Vector3.new(0, up + down, 0)
    end
    if States.Noclip then
        for _, v in pairs(lp.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    
    if States.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    
    if States.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                if not States.TeamCheck or (lp.Team ~= p.Team) then
                    if (p.Character.Head.Position - camera.CFrame.Position).Magnitude < 200 then
                        local targetCFrame = CFrame.new(camera.CFrame.Position, p.Character.Head.Position)
                        camera.CFrame = camera.CFrame:Lerp(targetCFrame, States.AimSmoothness)
                    end
                end
            end
        end
    end
    
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
    
    if States.OrbitTarget and States.OrbitTarget.Character then
        local pos = States.OrbitTarget.Character.HumanoidRootPart.Position
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.cos(tick()*3)*6, 3, math.sin(tick()*3)*6), pos)
        camera.CFrame = CFrame.new(camera.CFrame.Position, pos)
    end
end)

mouse.Button1Down:Connect(function()
    if States.Triggerbot and mouse.Target then
        local model = mouse.Target:FindFirstAncestorOfClass("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player and player ~= lp then
                if not States.TeamCheck or (lp.Team ~= player.Team) then
                    local tool = lp.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Select first tab
for _, child in ipairs(sidebar:GetChildren()) do
    if child:IsA("TextButton") then child.MouseButton1Click:Fire() break end
end

-- Drag Logic using the invisible dragBtn
local dragging = false
local dragStart, startPos

dragBtn.InputBegan:Connect(function(input)
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

print("[Ollie Admin v60] Loaded. Drag & Shift Lock fixed.")
