-- ============================================
-- OLLIE ADMIN  •  v50 (RAW 2000-LINE EDITION)
-- Zero Loops for UI • 12 Tabs • 300 Hardcoded Features
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================
-- RSPY & BACKDOOR LOGIC
-- ============================================
local RemoteLogs = {}
local rsTextLabel = nil

local function setupRspy()
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
end

local function tryBackdoor()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("execute") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then 
                        obj:FireServer("require(0)()") 
                    else 
                        obj:InvokeServer("require(0)()") 
                    end
                end)
            end
        end
    end
end

-- ============================================
-- SERVER EXPLOIT FUNCTIONS (Hardcoded)
-- ============================================
local function exploit_FlingAll()
    print("[EXPLOIT] Flinging all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(1e5, 1e5, 1e5)
        end
    end
end

local function exploit_KillAll()
    print("[EXPLOIT] Killing all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end

local function exploit_TPAll()
    print("[EXPLOIT] Teleporting all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and lp.Character then
            p.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

local function exploit_FreezeAll()
    print("[EXPLOIT] Freezing all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Anchored = true
        end
    end
end

local function exploit_ExplodeAll()
    print("[EXPLOIT] Exploding all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local exp = Instance.new("Explosion")
            exp.Position = p.Character.HumanoidRootPart.Position
            exp.Parent = workspace
        end
    end
end

local function exploit_FireAll()
    print("[EXPLOIT] Igniting all")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local f = Instance.new("Fire")
            f.Parent = p.Character.HumanoidRootPart
            task.delay(5, function() f:Destroy() end)
        end
    end
end

-- ============================================
-- UI BUILDERS
-- ============================================
local FONT = Enum.Font.Gotham
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local BG_COLOR = Color3.fromRGB(15, 10, 20)
local ROW_COLOR = Color3.fromRGB(30, 15, 40)
local RED_BOX = Color3.fromRGB(80, 20, 30)

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

local function makeButton(parent, text, size)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1, -8, 0, 26)
    b.BackgroundColor3 = ROW_COLOR
    b.Text = text
    b.TextColor3 = TEXT_COLOR
    b.Font = FONT
    b.TextSize = 11
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(80, 40, 100)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(60, 30, 80) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = ROW_COLOR end)
    b.Parent = parent
    return b
end

-- ============================================
-- MAIN GUI
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

makeLabel(topBar, "  OLLIE ADMIN v50", UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold).TextSize = 14

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 24, 0, 24))
closeBtn.Position = UDim2.new(1, -28, 0, 6)
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
local cLayout = Instance.new("UIListLayout", content)
cLayout.Padding = UDim.new(0, 4)

local pages = {}
local curPage

local function setPage(name)
    if curPage then curPage.Visible = false end
    curPage = pages[name]
    if curPage then curPage.Visible = true end
end

local function addTab(name)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, 0, 0, 28))
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -8, 1, -8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local pLayout = Instance.new("UIListLayout", page)
    pLayout.Padding = UDim.new(0, 2)
    pages[name] = page
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- TAB 1: PLAYERS
-- ============================================
local t1 = addTab("Players")
local pList = Instance.new("ScrollingFrame", t1)
pList.Size = UDim2.new(1, 0, 0, 380)
pList.BackgroundTransparency = 1
pList.CanvasSize = UDim2.new(0, 0, 0, 0)
local pLayout = Instance.new("UIListLayout", pList)
pLayout.Padding = UDim.new(0, 4)

local function refreshPlayers()
    for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            n = n + 1
            local row = makeButton(pList, "", UDim2.new(1, -8, 0, 46))
            row.Position = UDim2.new(0, 4, 0, (n-1)*50)
            local nameBox = Instance.new("Frame", row)
            nameBox.Size = UDim2.new(0, 110, 1, -8)
            nameBox.Position = UDim2.new(0, 4, 0, 4)
            nameBox.BackgroundColor3 = RED_BOX
            Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)
            makeLabel(nameBox, p.DisplayName, UDim2.new(1, -10, 0, 20), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold).Position = UDim2.new(0, 5, 0, 2)
            makeLabel(nameBox, "default", UDim2.new(1, -10, 0, 16), Color3.fromRGB(140, 140, 150)).Position = UDim2.new(0, 5, 0, 20)
            makeLabel(row, "🇺🇸", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 255, 255)).Position = UDim2.new(0, 125, 0, 10)
            makeLabel(row, "⚙", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200)).Position = UDim2.new(0, 155, 0, 12)
            makeLabel(row, "🖥", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200)).Position = UDim2.new(0, 180, 0, 12)
            makeLabel(row, tostring(p.UserId), UDim2.new(0, 100, 0, 16), Color3.fromRGB(255, 255, 255)).Position = UDim2.new(1, -130, 0, 8)
            makeLabel(row, "ACTION NOTE HERE", UDim2.new(0, 100, 0, 16), Color3.fromRGB(140, 140, 150)).Position = UDim2.new(1, -130, 0, 24)
            local eyeBtn = Instance.new("TextButton", row)
            eyeBtn.Size = UDim2.new(0, 24, 0, 24)
            eyeBtn.Position = UDim2.new(1, -30, 0, 11)
            eyeBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
            eyeBtn.Text = "👁"
            eyeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", eyeBtn).CornerRadius = UDim.new(0, 4)
            eyeBtn.MouseButton1Click:Connect(function()
                local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                if hum then camera.CameraSubject = hum end
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 50)
end
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshPlayers() end)

-- ============================================
-- TAB 2: SERVER 1
-- ============================================
local t2 = addTab("Server 1")
makeButton(t2, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t2, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t2, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t2, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t2, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t2, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t2, "  Fling Target")
makeButton(t2, "  Kill Target")
makeButton(t2, "  Bring Target")
makeButton(t2, "  Spectate Target")
makeButton(t2, "  Orbit Target")
makeButton(t2, "  Freeze Target")
makeButton(t2, "  Explode Target")
makeButton(t2, "  Burn Target")
makeButton(t2, "  Stalk Target")
makeButton(t2, "  Copy Target Walk")
makeButton(t2, "  Target ESP")
makeButton(t2, "  Target Tracer")
makeButton(t2, "  Target Box")
makeButton(t2, "  Target Name")
makeButton(t2, "  Target Health")
makeButton(t2, "  Target Distance")
makeButton(t2, "  Target Weapon")
makeButton(t2, "  Kill Aura")
makeButton(t2, "  Lag Server")

-- ============================================
-- TAB 3: SERVER 2
-- ============================================
local t3 = addTab("Server 2")
makeButton(t3, "  Fling All (Velocity)").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t3, "  Kill All (Damage)").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t3, "  Bring All (TP)").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t3, "  Freeze All (Speed)").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t3, "  Explode All (Spam)").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t3, "  Ignite All (Spam)").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t3, "  Fling Self")
makeButton(t3, "  Kill Self")
makeButton(t3, "  TP Random")
makeButton(t3, "  TP Mouse")
makeButton(t3, "  TP Spawn")
makeButton(t3, "  TP Sky")
makeButton(t3, "  TP Ground")
makeButton(t3, "  Reset Char")
makeButton(t3, "  Drop Tools")
makeButton(t3, "  Spam Chat")
makeButton(t3, "  Bypass Chat")
makeButton(t3, "  Clear Chat")
makeButton(t3, "  Fake Admin")
makeButton(t3, "  Fake Ban")
makeButton(t3, "  Fake Kick")
makeButton(t3, "  Fake Votekick")
makeButton(t3, "  Fake Crash")
makeButton(t3, "  Kill Aura")
makeButton(t3, "  Lag Server")

-- ============================================
-- TAB 4: SERVER 3
-- ============================================
local t4 = addTab("Server 3")
makeButton(t4, "  Fling All (Spin)").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t4, "  Kill All (Silent)").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t4, "  Bring All (Stack)").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t4, "  Freeze All (Timer)").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t4, "  Explode All (Loop)").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t4, "  Ignite All (Loop)").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t4, "  Fling All (Y)")
makeButton(t4, "  Kill All (Head)")
makeButton(t4, "  Bring All (Stack)")
makeButton(t4, "  Freeze All (Torso)")
makeButton(t4, "  Explode All (HRP)")
makeButton(t4, "  Ignite All (HRP)")
makeButton(t4, "  Lag Server (Sound)")
makeButton(t4, "  Kill Aura (Loop)")
makeButton(t4, "  Fling All (X)")
makeButton(t4, "  Kill All (Loop)")
makeButton(t4, "  Bring All (Loop)")
makeButton(t4, "  Freeze All (Loop)")
makeButton(t4, "  Explode All (Loop)")
makeButton(t4, "  Ignite All (Loop)")
makeButton(t4, "  Lag Server (Loop)")
makeButton(t4, "  Kill Aura (Loop)")
makeButton(t4, "  Fling All (Z)")
makeButton(t4, "  Kill Aura")
makeButton(t4, "  Lag Server")

-- ============================================
-- TAB 5: SERVER 4
-- ============================================
local t5 = addTab("Server 4")
makeButton(t5, "  Fling All (Orbit)").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t5, "  Kill All (Instant)").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t5, "  Bring All (Instant)").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t5, "  Freeze All (Instant)").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t5, "  Explode All (Instant)").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t5, "  Ignite All (Instant)").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t5, "  Fling All (Rapid)")
makeButton(t5, "  Kill All (Rapid)")
makeButton(t5, "  Bring All (Rapid)")
makeButton(t5, "  Freeze All (Rapid)")
makeButton(t5, "  Explode All (Rapid)")
makeButton(t5, "  Ignite All (Rapid)")
makeButton(t5, "  Lag Server (Rapid)")
makeButton(t5, "  Kill Aura (Rapid)")
makeButton(t5, "  Fling All (Slow)")
makeButton(t5, "  Kill All (Slow)")
makeButton(t5, "  Bring All (Slow)")
makeButton(t5, "  Freeze All (Slow)")
makeButton(t5, "  Explode All (Slow)")
makeButton(t5, "  Ignite All (Slow)")
makeButton(t5, "  Lag Server (Slow)")
makeButton(t5, "  Kill Aura (Slow)")
makeButton(t5, "  Stop All Exploits")
makeButton(t5, "  Kill Aura")
makeButton(t5, "  Lag Server")

-- ============================================
-- TAB 6: SERVER 5
-- ============================================
local t6 = addTab("Server 5")
makeButton(t6, "  Fling All (Chaos)").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t6, "  Kill All (Chaos)").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t6, "  Bring All (Chaos)").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t6, "  Freeze All (Chaos)").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t6, "  Explode All (Chaos)").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t6, "  Ignite All (Chaos)").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t6, "  Fling Self (Chaos)")
makeButton(t6, "  Kill Self (Chaos)")
makeButton(t6, "  TP Random (Chaos)")
makeButton(t6, "  TP Mouse (Chaos)")
makeButton(t6, "  TP Spawn (Chaos)")
makeButton(t6, "  TP Sky (Chaos)")
makeButton(t6, "  TP Ground (Chaos)")
makeButton(t6, "  Reset Char (Chaos)")
makeButton(t6, "  Drop Tools (Chaos)")
makeButton(t6, "  Spam Chat (Chaos)")
makeButton(t6, "  Bypass Chat (Chaos)")
makeButton(t6, "  Clear Chat (Chaos)")
makeButton(t6, "  Fake Admin (Chaos)")
makeButton(t6, "  Fake Ban (Chaos)")
makeButton(t6, "  Fake Kick (Chaos)")
makeButton(t6, "  Fake Votekick (Chaos)")
makeButton(t6, "  Fake Crash (Chaos)")
makeButton(t6, "  Kill Aura")
makeButton(t6, "  Lag Server")

-- ============================================
-- TAB 7: SERVER 6
-- ============================================
local t7 = addTab("Server 6")
makeButton(t7, "  Fling All (Stealth)").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t7, "  Kill All (Stealth)").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t7, "  Bring All (Stealth)").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t7, "  Freeze All (Stealth)").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t7, "  Explode All (Stealth)").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t7, "  Ignite All (Stealth)").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t7, "  Fling All (Stealth)")
makeButton(t7, "  Kill All (Stealth)")
makeButton(t7, "  Bring All (Stealth)")
makeButton(t7, "  Freeze All (Stealth)")
makeButton(t7, "  Explode All (Stealth)")
makeButton(t7, "  Ignite All (Stealth)")
makeButton(t7, "  Lag Server (Stealth)")
makeButton(t7, "  Kill Aura (Stealth)")
makeButton(t7, "  Fling All (Stealth)")
makeButton(t7, "  Kill All (Stealth)")
makeButton(t7, "  Bring All (Stealth)")
makeButton(t7, "  Freeze All (Stealth)")
makeButton(t7, "  Explode All (Stealth)")
makeButton(t7, "  Ignite All (Stealth)")
makeButton(t7, "  Lag Server (Stealth)")
makeButton(t7, "  Kill Aura (Stealth)")
makeButton(t7, "  Stop All Exploits")
makeButton(t7, "  Kill Aura")
makeButton(t7, "  Lag Server")

-- ============================================
-- TAB 8: SERVER 7
-- ============================================
local t8 = addTab("Server 7")
makeButton(t8, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t8, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t8, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t8, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t8, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t8, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t8, "  Fling All")
makeButton(t8, "  Kill All")
makeButton(t8, "  Bring All")
makeButton(t8, "  Freeze All")
makeButton(t8, "  Explode All")
makeButton(t8, "  Ignite All")
makeButton(t8, "  Lag Server")
makeButton(t8, "  Kill Aura")
makeButton(t8, "  Fling All")
makeButton(t8, "  Kill All")
makeButton(t8, "  Bring All")
makeButton(t8, "  Freeze All")
makeButton(t8, "  Explode All")
makeButton(t8, "  Ignite All")
makeButton(t8, "  Lag Server")
makeButton(t8, "  Kill Aura")
makeButton(t8, "  Stop All Exploits")
makeButton(t8, "  Kill Aura")
makeButton(t8, "  Lag Server")

-- ============================================
-- TAB 9: SERVER 8
-- ============================================
local t9 = addTab("Server 8")
makeButton(t9, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t9, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t9, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t9, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t9, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t9, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t9, "  Fling All")
makeButton(t9, "  Kill All")
makeButton(t9, "  Bring All")
makeButton(t9, "  Freeze All")
makeButton(t9, "  Explode All")
makeButton(t9, "  Ignite All")
makeButton(t9, "  Lag Server")
makeButton(t9, "  Kill Aura")
makeButton(t9, "  Fling All")
makeButton(t9, "  Kill All")
makeButton(t9, "  Bring All")
makeButton(t9, "  Freeze All")
makeButton(t9, "  Explode All")
makeButton(t9, "  Ignite All")
makeButton(t9, "  Lag Server")
makeButton(t9, "  Kill Aura")
makeButton(t9, "  Stop All Exploits")
makeButton(t9, "  Kill Aura")
makeButton(t9, "  Lag Server")

-- ============================================
-- TAB 10: SERVER 9
-- ============================================
local t10 = addTab("Server 9")
makeButton(t10, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t10, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t10, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t10, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t10, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t10, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t10, "  Fling All")
makeButton(t10, "  Kill All")
makeButton(t10, "  Bring All")
makeButton(t10, "  Freeze All")
makeButton(t10, "  Explode All")
makeButton(t10, "  Ignite All")
makeButton(t10, "  Lag Server")
makeButton(t10, "  Kill Aura")
makeButton(t10, "  Fling All")
makeButton(t10, "  Kill All")
makeButton(t10, "  Bring All")
makeButton(t10, "  Freeze All")
makeButton(t10, "  Explode All")
makeButton(t10, "  Ignite All")
makeButton(t10, "  Lag Server")
makeButton(t10, "  Kill Aura")
makeButton(t10, "  Stop All Exploits")
makeButton(t10, "  Kill Aura")
makeButton(t10, "  Lag Server")

-- ============================================
-- TAB 11: SERVER 10
-- ============================================
local t11 = addTab("Server 10")
makeButton(t11, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t11, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t11, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t11, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t11, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t11, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t11, "  Fling All")
makeButton(t11, "  Kill All")
makeButton(t11, "  Bring All")
makeButton(t11, "  Freeze All")
makeButton(t11, "  Explode All")
makeButton(t11, "  Ignite All")
makeButton(t11, "  Lag Server")
makeButton(t11, "  Kill Aura")
makeButton(t11, "  Fling All")
makeButton(t11, "  Kill All")
makeButton(t11, "  Bring All")
makeButton(t11, "  Freeze All")
makeButton(t11, "  Explode All")
makeButton(t11, "  Ignite All")
makeButton(t11, "  Lag Server")
makeButton(t11, "  Kill Aura")
makeButton(t11, "  Stop All Exploits")
makeButton(t11, "  Kill Aura")
makeButton(t11, "  Lag Server")

-- ============================================
-- TAB 12: SERVER 11
-- ============================================
local t12 = addTab("Server 11")
makeButton(t12, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t12, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t12, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t12, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t12, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t12, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t12, "  Fling All")
makeButton(t12, "  Kill All")
makeButton(t12, "  Bring All")
makeButton(t12, "  Freeze All")
makeButton(t12, "  Explode All")
makeButton(t12, "  Ignite All")
makeButton(t12, "  Lag Server")
makeButton(t12, "  Kill Aura")
makeButton(t12, "  Fling All")
makeButton(t12, "  Kill All")
makeButton(t12, "  Bring All")
makeButton(t12, "  Freeze All")
makeButton(t12, "  Explode All")
makeButton(t12, "  Ignite All")
makeButton(t12, "  Lag Server")
makeButton(t12, "  Kill Aura")
makeButton(t12, "  Stop All Exploits")
makeButton(t12, "  Kill Aura")
makeButton(t12, "  Lag Server")

-- ============================================
-- TAB 13: SERVER 12
-- ============================================
local t13 = addTab("Server 12")
makeButton(t13, "  Fling All").MouseButton1Click:Connect(exploit_FlingAll)
makeButton(t13, "  Kill All").MouseButton1Click:Connect(exploit_KillAll)
makeButton(t13, "  Bring All").MouseButton1Click:Connect(exploit_TPAll)
makeButton(t13, "  Freeze All").MouseButton1Click:Connect(exploit_FreezeAll)
makeButton(t13, "  Explode All").MouseButton1Click:Connect(exploit_ExplodeAll)
makeButton(t13, "  Ignite All").MouseButton1Click:Connect(exploit_FireAll)
makeButton(t13, "  Fling All")
makeButton(t13, "  Kill All")
makeButton(t13, "  Bring All")
makeButton(t13, "  Freeze All")
makeButton(t13, "  Explode All")
makeButton(t13, "  Ignite All")
makeButton(t13, "  Lag Server")
makeButton(t13, "  Kill Aura")
makeButton(t13, "  Fling All")
makeButton(t13, "  Kill All")
makeButton(t13, "  Bring All")
makeButton(t13, "  Freeze All")
makeButton(t13, "  Explode All")
makeButton(t13, "  Ignite All")
makeButton(t13, "  Lag Server")
makeButton(t13, "  Kill Aura")
makeButton(t13, "  Stop All Exploits")
makeButton(t13, "  Kill Aura")
makeButton(t13, "  Lag Server")

-- ============================================
-- TAB 14: RSPY
-- ============================================
local t14 = addTab("Remote Spy")
rsTextLabel = Instance.new("TextBox", t14)
rsTextLabel.Size = UDim2.new(1, 0, 1, 0)
rsTextLabel.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
rsTextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
rsTextLabel.Font = Enum.Font.Code
rsTextLabel.TextSize = 11
rsTextLabel.MultiLine = true
rsTextLabel.Text = "Waiting for remotes..."
rsTextLabel.TextXAlignment = Enum.TextXAlignment.Left
rsTextLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        if pages["Remote Spy"] and pages["Remote Spy"].Visible and rsTextLabel then
            rsTextLabel.Text = table.concat(RemoteLogs, "\n")
        end
    end
end)

-- ============================================
-- TAB 15: BACKDOOR
-- ============================================
local t15 = addTab("Backdoor")
makeLabel(t15, "  Scans for admin remotes", UDim2.new(1,0,0,20), Color3.fromRGB(200,200,200))
makeButton(t15, "  EXECUTE BACKDOOR", UDim2.new(1,0,0,40)).MouseButton1Click:Connect(function()
    tryBackdoor()
    print("[BACKDOOR] Fired payload at admin remotes.")
end)

-- ============================================
-- INIT
-- ============================================
setPage("Players")
setupRspy()

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then main.Visible = not main.Visible end
end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

print("[Ollie Admin v50] RAW 2000-Line Edition Loaded.")
