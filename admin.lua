-- ============================================
-- OLLIE ADMIN v52 • CUSTOM UI OVERHAUL
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- THEME CONFIGURATION
local Theme = {
    BG = Color3.fromRGB(12, 10, 16),
    Sidebar = Color3.fromRGB(18, 15, 24),
    Accent = Color3.fromRGB(160, 32, 240), -- Purple
    AccentHover = Color3.fromRGB(190, 60, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    Button = Color3.fromRGB(25, 20, 35),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

-- ============================================
-- 1. CORE EXPLOITS
-- ============================================
local function exploit_FlingAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(1e5, 1e5, 1e5)
        end
    end
end

local function exploit_KillAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end

local function exploit_TPAll()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

local function exploit_GodMode()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.MaxHealth = math.huge
        lp.Character.Humanoid.Health = math.huge
    end
end

-- ============================================
-- 2. UI BUILDER FUNCTIONS
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdminV52"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 640, 0, 440)
main.Position = UDim2.new(0.5, -320, 0.5, -220)
main.BackgroundColor3 = Theme.BG
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "OLLIE ADMIN"
title.TextColor3 = Theme.Text
title.Font = Theme.FontBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.Text
closeBtn.Font = Theme.FontBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sideCorner = Instance.new("UICorner", sidebar)
sideCorner.CornerRadius = UDim.new(0, 6)
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 4)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -150, 1, -50)
content.Position = UDim2.new(0, 140, 0, 45)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local activeTabBtn = nil

local function SwitchTab(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
end

local function CreateTab(name, isScrolling)
    -- Sidebar Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Theme.Button
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)

    -- Page
    local page = Instance.new(isScrolling and "ScrollingFrame" or "Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content
    if isScrolling then
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Theme.Accent
    end

    pages[name] = page

    -- Hover & Click
    btn.MouseEnter:Connect(function()
        if activeTabBtn ~= btn then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 30, 50)}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if activeTabBtn ~= btn then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play() end
    end)
    btn.MouseButton1Click:Connect(function()
        if activeTabBtn then
            TweenService:Create(activeTabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button, TextColor3 = Theme.TextDim}):Play()
        end
        activeTabBtn = btn
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}):Play()
        SwitchTab(name)
    end)

    -- Grid Layout for Page (3 columns)
    if not isScrolling then
        local grid = Instance.new("UIGridLayout", page)
        grid.CellSize = UDim2.new(0.33, -6, 0, 30)
        grid.CellPadding = UDim2.new(0, 6, 0, 6)
    end

    return page
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Theme.Button
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Font
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentHover}):Play()
        stroke.Transparency = 0.3
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play()
        stroke.Transparency = 0.8
    end)
    btn.MouseButton1Click:Connect(function()
        task.spawn(callback)
    end)
end

-- ============================================
-- 3. POPULATE TABS
-- ============================================
local t1 = CreateTab("Server Exploits")
CreateButton(t1, "Fling All", exploit_FlingAll)
CreateButton(t1, "Kill All", exploit_KillAll)
CreateButton(t1, "TP All", exploit_TPAll)
CreateButton(t1, "God Mode", exploit_GodMode)
CreateButton(t1, "Spam Effect", function() print("Need game remote") end)

local t2 = CreateTab("Player Mods")
local flyOn = false
local noclipOn = false

CreateButton(t2, "Toggle Fly", function()
    flyOn = not flyOn
    local bg = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
    bg.MaxForce = Vector3.new(0,0,0)
    RunService.RenderStepped:Connect(function()
        if flyOn and lp.Character then
            local move = lp.Character.Humanoid.MoveDirection
            lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + (move * 1.5) + Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1.5 or 0), 0)
        end
    end)
end)

CreateButton(t2, "Toggle Noclip", function()
    noclipOn = not noclipOn
    RunService.Stepped:Connect(function()
        if noclipOn and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end)

CreateButton(t2, "Speed 100", function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 100
    end
end)

local t3 = CreateTab("Backdoor Scanner", true)
local bdLayout = Instance.new("UIListLayout", t3)
bdLayout.Padding = UDim.new(0, 4)

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, 0, 0, 34)
scanBtn.BackgroundColor3 = Theme.Accent
scanBtn.Text = "SCAN FOR BACKDOORS"
scanBtn.TextColor3 = Theme.Text
scanBtn.Font = Theme.FontBold
scanBtn.Parent = t3
local sc = Instance.new("UICorner", scanBtn)
sc.CornerRadius = UDim.new(0, 4)
scanBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(t3:GetChildren()) do
        if c:IsA("TextButton") and c ~= scanBtn then c:Destroy() end
    end
    local found = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("execute") or n:find("eval") or n:find("run") or n:find("load") then
                found = found + 1
                CreateButton(t3, obj.Name, function()
                    pcall(function()
                        if obj:IsA("RemoteEvent") then obj:FireServer("require(0)()") else obj:InvokeServer("require(0)()") end
                    end)
                    print("Fired payload to: " .. obj.Name)
                end)
            end
        end
    end
    t3.CanvasSize = UDim2.new(0, 0, 0, found * 34 + 50)
end)

-- ============================================
-- 4. REMOTE SPY (REAL-TIME)
-- ============================================
local t4 = CreateTab("Remote Spy", true)
local spyLayout = Instance.new("UIListLayout", t4)
spyLayout.Padding = UDim.new(0, 2)

local function AddSpyLog(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundColor3 = Theme.Button
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(0, 255, 100) -- Green text for spy
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = t4
    local corner = Instance.new("UICorner", label)
    corner.CornerRadius = UDim.new(0, 3)

    t4.CanvasSize = UDim2.new(0, 0, 0, spyLayout.AbsoluteContentSize.Y)

    -- Auto scroll to bottom
    t4.CanvasPosition = Vector2.new(0, t4.CanvasSize.Y.Offset)

    -- Keep log size in check (delete oldest if > 100)
    if #t4:GetChildren() > 100 then
        t4:GetChildren()[1]:Destroy()
    end
end

local oldNamecall = getrawmetatable(game).__namecall
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        local text = "[" .. method .. "] " .. self.Name
        AddSpyLog(text)
    end
    return oldNamecall(self, ...)
end)
setreadonly(getrawmetatable(game), true)

-- ============================================
-- 5. INITIALIZATION
-- ============================================
if sidebar:FindFirstChild("TextButton") then
    sidebar:FindFirstChild("TextButton"):GetPropertyChangedSignal("Text"):Wait() -- Dummy wait to ensure loaded
    -- Programmatically click the first tab
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.MouseButton1Click:Fire()
            break
        end
    end
end

-- Dragging Logic
local dragging, dragStart, startPos
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("[Ollie Admin v52] Loaded. Custom Premium UI.")
