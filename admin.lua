-- ============================================
-- OLLIE ADMIN v54 • PLAYER LIST & ORBIT KILL
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- THEME CONFIG
local Theme = {
    BG = Color3.fromRGB(10, 10, 14),
    Sidebar = Color3.fromRGB(15, 15, 22),
    Accent = Color3.fromRGB(0, 255, 180),
    AccentHover = Color3.fromRGB(0, 200, 150),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Button = Color3.fromRGB(25, 25, 35),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

-- STATE VARIABLES
local States = {
    Fly = false,
    Noclip = false,
    InfJump = false,
    Fullbright = false,
    ChatSpam = false,
    ESP = false,
    OrbitTarget = nil,
    WalkSpeed = 16,
    JumpPower = 50,
    TargetPlayer = nil,
}

-- ============================================
-- 1. CORE UI ENGINE
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdminV54"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 700, 0, 480)
main.Position = UDim2.new(0.5, -350, 0.5, -240)
main.BackgroundColor3 = Theme.BG
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Theme.Accent
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "OLLIE ADMIN v54"
title.TextColor3 = Theme.Text
title.Font = Theme.FontBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.Text
closeBtn.Font = Theme.FontBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 4)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -50)
content.Position = UDim2.new(0, 150, 0, 45)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local activeTabBtn = nil

local function SwitchTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Theme.Button
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.Accent
    page.Parent = content
    
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    pages[name] = page

    btn.MouseEnter:Connect(function() if activeTabBtn ~= btn then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play() end end)
    btn.MouseLeave:Connect(function() if activeTabBtn ~= btn then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play() end end)
    btn.MouseButton1Click:Connect(function()
        if activeTabBtn then TweenService:Create(activeTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button, TextColor3 = Theme.TextDim}):Play() end
        activeTabBtn = btn
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.BG}):Play()
        SwitchTab(name)
    end)

    return page, list
end

local function CreateButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or Theme.Button
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentHover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Theme.Button}):Play() end)
    btn.MouseButton1Click:Connect(callback)
end

local function CreateToggle(parent, text, flag, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Button
    btn.Text = "  [OFF] " .. text
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local isToggled = false
    btn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            btn.Text = "  [ON] " .. text
            btn.TextColor3 = Theme.Accent
        else
            btn.Text = "  [OFF] " .. text
            btn.TextColor3 = Theme.TextDim
        end
        callback(isToggled)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Theme.Button
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Theme.Text
    label.Font = Theme.FontBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 28)
    bar.BackgroundColor3 = Theme.BG
    bar.Parent = frame
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
            label.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

-- ============================================
-- 2. FEATURE IMPLEMENTATIONS
-- ============================================

RunService.RenderStepped:Connect(function()
    if not lp.Character then return end
    if States.Fly then
        local moveDir = lp.Character.Humanoid.MoveDirection
        local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 2 or 0
        local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -2 or 0
        lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + (moveDir * 1.5) + Vector3.new(0, up + down, 0)
    end
    if States.Noclip then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    -- ORBIT KILL LOGIC
    if States.OrbitTarget and States.OrbitTarget.Character and States.OrbitTarget.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local time = tick()
        local targetPos = States.OrbitTarget.Character.HumanoidRootPart.Position
        local offsetX = math.cos(time * 3) * 6
        local offsetZ = math.sin(time * 3) * 6
        
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(offsetX, 3, offsetZ), targetPos)
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ============================================
-- 3. POPULATE TABS
-- ============================================

local t1 = CreateTab("Server")
CreateButton(t1, "Kill All (Client)", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end, Color3.fromRGB(150, 0, 0))

CreateButton(t1, "Fling All", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(1e5, 1e5, 1e5)
        end
    end
end)

local t2 = CreateTab("Movement")
CreateToggle(t2, "Fly", "Fly", function(v) States.Fly = v end)
CreateToggle(t2, "Noclip", "Noclip", function(v) States.Noclip = v end)
CreateToggle(t2, "Infinite Jump", "InfJump", function(v) States.InfJump = v end)
CreateSlider(t2, "WalkSpeed", 16, 250, 16, function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end)

local t3 = CreateTab("Visuals")
CreateToggle(t3, "Fullbright", "Fullbright", function(v)
    if v then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) end
end)

-- ============================================
-- PLAYER LIST TAB
-- ============================================
local t4 = CreateTab("Players")

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -40)
playerScroll.BackgroundTransparency = 1
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.ScrollBarThickness = 2
playerScroll.Parent = t4

local pLayout = Instance.new("UIListLayout", playerScroll)
pLayout.Padding = UDim.new(0, 4)

local function RefreshPlayerList()
    for _, v in ipairs(playerScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Theme.Button
        frame.Parent = playerScroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0, 150, 1, 0)
        nameLbl.Position = UDim2.new(0, 10, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = p.Name .. " (" .. p.UserId .. ")"
        nameLbl.TextColor3 = Theme.Text
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = frame
        
        local teamLbl = Instance.new("TextLabel")
        teamLbl.Size = UDim2.new(0, 100, 1, 0)
        teamLbl.Position = UDim2.new(0, 160, 0, 0)
        teamLbl.BackgroundTransparency = 1
        teamLbl.Text = p.Team and p.Team.Name or "No Team"
        teamLbl.TextColor3 = Theme.TextDim
        teamLbl.TextXAlignment = Enum.TextXAlignment.Left
        teamLbl.Parent = frame
        
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(0, 120, 1, 0)
        btnContainer.Position = UDim2.new(1, -130, 0, 0)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = frame
        local bLayout = Instance.new("UIListLayout", btnContainer)
        bLayout.FillDirection = Enum.FillDirection.Horizontal
        bLayout.Padding = UDim.new(0, 4)
        bLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        
        local function makeIconBtn(emoji, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 34, 0, 24)
            b.BackgroundColor3 = Theme.BG
            b.Text = emoji
            b.TextSize = 14
            b.Parent = btnContainer
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(callback)
        end
        
        makeIconBtn("👁️", function()
            -- Spectate
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = p.Character.Humanoid
            end
        end)
        
        makeIconBtn("✨", function()
            -- TP
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end)
        
        makeIconBtn("🌀", function()
            -- Orbit Kill
            States.OrbitTarget = (States.OrbitTarget == p) and nil or p
            if not States.OrbitTarget then
                camera.CameraSubject = lp.Character.Humanoid
            end
        end)
    end
    
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y)
end

CreateButton(t4, "Refresh Player List", RefreshPlayerList)
RefreshPlayerList()

-- ============================================
-- 4. INITIALIZATION
-- ============================================
for _, child in ipairs(sidebar:GetChildren()) do
    if child:IsA("TextButton") then
        child.MouseButton1Click:Fire()
        break
    end
end

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("[Ollie Admin v54] Loaded. Player List + Orbit Kill active.")
