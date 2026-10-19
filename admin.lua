-- ============================================
-- OLLIE ADMIN  •  v27 (Unlocked Admin Panel)
-- Waypoints & Keybinds UNLOCKED  •  Troll UNLOCKED
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

local isPremium = true -- UNLOCKED VERSION

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
-- RAPID FIRE LOGIC (Free)
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
-- UI BUILDERS
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

    local function updateState(state)
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
    end
    
    btn.MouseButton1Click:Connect(function()
        CFG[cfKey] = not CFG[cfKey]
        updateState(CFG[cfKey])
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
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            CFG[cfKey] = num
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
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    makeTextInput(holder, cfKey, cb)
    
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 45); bar.BorderSizePixel = 0; bar.Parent = holder
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255); fill.BorderSizePixel = 0; fill.Parent = bar
    local fcn = Instance.new("UICorner"); fcn.CornerRadius = UDim.new(1, 0); fcn.Parent = fill
    
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * rel) * 100) / 100
            CFG[cfKey] = val
            TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
            if cb then cb(val) end
        end
    end)
    table.insert(flags.uiItems, {type = "slider", key = cfKey, update = function(val) local rel = math.clamp((val - min) / (max - min), 0, 1); fill.Size = UDim2.new(rel, 0, 1, 0) end})
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

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 200, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local title = makeLabel(main, "  OLLIE ADMIN (PREMIUM)", UDim2.new(1, 0, 0, 40), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
title.TextSize = 16

local closeBtn = makeButton(main, "X", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 60, 60))
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = sidebar

local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 6); navLayout.SortOrder = Enum.SortOrder.LayoutOrder; navLayout.Parent = sidebar
local navPad = Instance.new("UIPadding"); navPad.PaddingTop = UDim.new(0, 10); navPad.PaddingLeft = UDim.new(0, 5); navPad.PaddingRight = UDim.new(0, 5); navPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -50)
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
    end
    if navButtons[name] then
        navButtons[name].BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        navButtons[name].TextColor3 = Color3.fromRGB(0, 255, 200)
    end
end

local function addTab(name, isPremiumFeature)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, 0, 0, 34), Color3.fromRGB(15, 15, 22), Color3.fromRGB(25, 25, 40), isPremiumFeature)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    navButtons[name] = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 10); pl.Parent = page
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
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
pList.Size = UDim2.new(1, 0, 0, 250); pList.Position = UDim2.new(0, 0, 0, 45)
pList.BackgroundColor3 = Color3.fromRGB(15, 15, 22); pList.BorderSizePixel = 0
pList.CanvasSize = UDim2.new(0, 0, 0, 0); pList.ScrollBarThickness = 2; pList.Parent = playersPage
local plc = Instance.new("UICorner"); plc.CornerRadius = UDim.new(0, 8); plc.Parent = pList
local pLayout = Instance.new("UIListLayout"); pLayout.Padding = UDim.new(0, 2); pLayout.Parent = pList

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
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 30)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(1); refreshPlayers() end)

makeButton(playersPage, "Teleport to Selected", UDim2.new(1, 0, 0, 32), Color3.fromRGB(40, 100, 200)).MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character and lp.Character then
        local hrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then lp.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
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
end

makeButton(playersPage, "Kill Orbit (Target)", UDim2.new(1, 0, 0, 32), Color3.fromRGB(200, 60, 60)).MouseButton1Click:Connect(function()
    if not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
    local target = CFG.selectedPlayer
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    flags.originalCFrame = myHrp.CFrame
    flags.killOrbitActive = true
    local angle = 0
    table.insert(flags.killOrbitConns, RunService.Heartbeat:Connect(function(dt)
        if not flags.killOrbitActive then return end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local tHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tHrp then
            angle = angle + (dt * 6)
            hrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(math.cos(angle), 2, math.sin(angle)) * 10, tHrp.Position)
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

makeButton(trollPage, "Fling Target", UDim2.new(1, 0, 0, 32), Color3.fromRGB(255, 60, 60)).MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character then
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -3)
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Velocity = Vector3.new(1e5, 1e5, 1e5)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.wait(0.15)
            bv:Destroy()
        end
    end
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
-- TAB: COMBAT
-- ============================================
local combatPage = addTab("Combat")
makeToggle(combatPage, "Aimbot (Hold RMB)", "aimbot")
makeToggle(combatPage, "Triggerbot", "triggerbot")
makeToggle(combatPage, "Rapid Fire", "rapidFire")
makeSlider(combatPage, "Rapid Fire Rate", 0.01, 0.2, "rapidFireRate")

UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then flags.aiming = false end end)
RunService:BindToRenderStep("OllieAim", Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.aimbot or not flags.aiming then return end
    local closest, dist = nil, 150
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
    if closest then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closest.Position), 0.2) end
end)

-- ============================================
-- TAB: MOVEMENT
-- ============================================
local movePage = addTab("Movement")
makeSlider(movePage, "WalkSpeed", 16, 300, "walkSpeed", function(v) local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end)
makeSlider(movePage, "JumpPower", 50, 300, "jumpPower", function(v) local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v; hum.UseJumpPower = true end end)
makeToggle(movePage, "Fly", "fly")
makeToggle(movePage, "Noclip", "noclip")
makeToggle(movePage, "Speed Lock", "speedLock")

-- ============================================
-- TAB: VISUALS
-- ============================================
local visPage = addTab("Visuals")
makeToggle(visPage, "Fullbright", "fullbright")
makeToggle(visPage, "Player ESP", "esp")

-- ============================================
-- INIT
-- ============================================
setPage("Players")
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and i.KeyCode == Enum.KeyCode.Insert then main.Visible = not main.Visible end end)

print("[Ollie Admin PREMIUM] loaded.")
