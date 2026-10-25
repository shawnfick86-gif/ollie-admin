-- ============================================
-- OLLIE ADMIN  •  v51 (Real Backdoor Scan + Compact UI)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================
-- 1. REAL BACKDOOR SCANNER
-- ============================================
local function scanForBackdoors()
    local found = {}
    -- Look for RemoteFunctions/Events that might accept Lua execution
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("execute") or n:find("eval") or n:find("run") or n:find("load") then
                table.insert(found, obj:GetFullName())
            end
        end
    end
    return found
end

local function fireBackdoor(path, payload)
    local obj = ReplicatedStorage:FindFirstChild(path, true)
    if obj then
        pcall(function()
            if obj:IsA("RemoteEvent") then 
                obj:FireServer(payload) 
            else 
                obj:InvokeServer(payload) 
            end
        end)
        print("[BACKDOOR] Fired:", path, "with:", payload)
    end
end

-- ============================================
-- 2. EXPLOIT FUNCTIONS
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
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and lp.Character then
            p.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

-- ============================================
-- 3. UI BUILDERS (COMPACT)
-- ============================================
local FONT = Enum.Font.Gotham
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local BG_COLOR = Color3.fromRGB(15, 10, 20)
local ROW_COLOR = Color3.fromRGB(30, 15, 40)

local function makeLabel(parent, text, size, color, font)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or TEXT_COLOR
    l.Font = font or FONT
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -2, 0, 24) -- HALF WIDTH, SMALLER HEIGHT
    b.BackgroundColor3 = ROW_COLOR
    b.Text = text
    b.TextColor3 = TEXT_COLOR
    b.Font = FONT
    b.TextSize = 10 -- Smaller text to fit
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(60, 30, 80) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = ROW_COLOR end)
    b.Parent = parent
    return b
end

-- ============================================
-- 4. MAIN GUI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdmin"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 700, 0, 480)
main.Position = UDim2.new(0.5, -350, 0.5, -240)
main.BackgroundColor3 = BG_COLOR
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", main).Color = Color3.fromRGB(180, 0, 255)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 36)
topBar.Position = UDim2.new(0, 10, 0, 10)
topBar.BackgroundColor3 = Color3.fromRGB(25, 10, 35)
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)
makeLabel(topBar, "  OLLIE ADMIN v51", UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold).TextSize = 14

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)
local navLayout = Instance.new("UIListLayout", sidebar)
navLayout.Padding = UDim.new(0, 2)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -130, 1, -60)
content.Position = UDim2.new(0, 130, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 6)

local pages = {}
local curPage

local function setPage(name)
    if curPage then curPage.Visible = false end
    curPage = pages[name]
    if curPage then curPage.Visible = true end
end

local function addTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = ROW_COLOR
    btn.Text = "  " .. name
    btn.TextColor3 = TEXT_COLOR
    btn.Font = FONT
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1, -8, 1, -8)
    page.BackgroundTransparency = 1
    page.Visible = false
    
    -- Grid Layout for compact buttons
    local grid = Instance.new("UIGridLayout", page)
    grid.CellSize = UDim2.new(0.5, -2, 0, 24)
    grid.CellPadding = UDim2.new(0, 4, 0, 4)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    pages[name] = page
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- 5. TABS & FEATURES
-- ============================================
local t2 = addTab("Server 1")
makeButton(t2, "Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t2, "Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t2, "TP All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t2, "Explode All")
makeButton(t2, "Freeze All")
makeButton(t2, "Ignite All")
makeButton(t2, "Lag Server")
makeButton(t2, "Spam Effects")

local t3 = addTab("Server 2")
makeButton(t3, "Drop Tools")
makeButton(t3, "Spam Chat")
makeButton(t3, "Clear Chat")
makeButton(t3, "Fake Admin")
makeButton(t3, "Fake Ban")
makeButton(t3, "Fake Kick")
makeButton(t3, "Fake Crash")
makeButton(t3, "Fling Self")

local t4 = addTab("Server 3")
makeButton(t4, "TP Random")
makeButton(t4, "TP Mouse")
makeButton(t4, "TP Spawn")
makeButton(t4, "TP Sky")
makeButton(t4, "Reset Char")
makeButton(t4, "Explode Self")
makeButton(t4, "God Mode")
makeButton(t4, "NoClip")

-- ============================================
-- 6. BACKDOOR TAB
-- ============================================
local bdPage = addTab("Backdoor")
local bdScroll = Instance.new("ScrollingFrame", bdPage)
bdScroll.Size = UDim2.new(1, 0, 1, -40)
bdScroll.BackgroundTransparency = 1
bdScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local bdList = Instance.new("UIListLayout", bdScroll)
bdList.Padding = UDim.new(0, 2)

local scanBtn = makeButton(bdPage, "SCAN FOR BACKDOORS")
scanBtn.Size = UDim2.new(1, 0, 0, 30)
scanBtn.Position = UDim2.new(0, 0, 1, -30)
scanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
scanBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(bdScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local paths = scanForBackdoors()
    if #paths == 0 then
        local lbl = Instance.new("TextLabel", bdScroll)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No obvious admin remotes found."
        lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        lbl.Font = FONT
        lbl.TextSize = 12
    else
        for i, path in ipairs(paths) do
            local btn = makeButton(bdScroll, path)
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.MouseButton1Click:Connect(function()
                fireBackdoor(path, "require(0)()")
            end)
        end
    end
    bdScroll.CanvasSize = UDim2.new(0, 0, 0, #paths * 28 + 40)
end)

-- ============================================
-- 7. RSPY
-- ============================================
local rsPage = addTab("Remote Spy")
local rsText = Instance.new("TextBox", rsPage)
rsText.Size = UDim2.new(1, 0, 1, 0)
rsText.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
rsText.TextColor3 = Color3.fromRGB(0, 255, 0)
rsText.Font = Enum.Font.Code
rsText.TextSize = 10
rsText.MultiLine = true
rsText.Text = "Waiting for remotes..."
rsText.TextXAlignment = Enum.TextXAlignment.Left
rsText.TextYAlignment = Enum.TextYAlignment.Top

local RemoteLogs = {}
if getrawmetatable and hookmetamethod and newcclosure then
    local oldNamecall = getrawmetatable(game).__namecall
    setreadonly(getrawmetatable(game), false)
    getrawmetatable(game).__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local log = "[" .. method .. "] " .. self:GetFullName()
            table.insert(RemoteLogs, 1, log)
            if #RemoteLogs > 50 then table.remove(RemoteLogs) end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(getrawmetatable(game), true)
end

task.spawn(function()
    while task.wait(1) do
        if pages["Remote Spy"] and pages["Remote Spy"].Visible then
            rsText.Text = table.concat(RemoteLogs, "\n")
        end
    end
end)

-- ============================================
-- INIT
-- ============================================
setPage("Server 1")

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

print("[Ollie Admin v51] Loaded. Compact UI + Real Backdoor Scan.")
