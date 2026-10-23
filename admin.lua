-- ============================================
-- OLLIE ADMIN  •  v39 (Tracker + Full Features)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================
-- CONFIG STATE
-- ============================================
local CFG = {
    teamCheck = true, aimbot = false, aimPart = "Head", aimFov = 150, aimSmooth = 0.2,
    silentAim = false, triggerbot = false, triggerDelay = 0.1, triggerRange = 200,
    rapidFire = false, rapidFireRate = 0.04, hitboxExpand = false, hitboxSize = 5,
    noRecoil = false, noSpread = false, infAmmo = false,
    walkSpeed = 16, jumpPower = 50, fly = false, flySpeed = 50, noclip = false, infJump = false,
    speedLock = true, autoClicker = false, bunnyhop = false,
    esp = false, fullbright = false, tracers = false,
    keySpeed = "None", keyJump = "None", keyAimbot = "None", keyTriggerbot = "None",
}

local flags = {
    flyConn = nil, isSpectating = false, oldCamSubject = nil,
    noclipConn = nil, infJumpConn = nil, savedLighting = {},
    aiming = false, uiItems = {}, configScroll = nil,
    bindingKey = nil, orbitConn = nil, orbitAngle = 0,
    isMouseDown = false, lastFireTime = 0, musicInstance = nil,
    killOrbitActive = false, originalCFrame = nil, killOrbitConns = {},
    espFolder = nil, tracerFolder = nil, espObjects = {}, tracerObjects = {},
    activeTab = "ALL"
}

-- ============================================
-- HELPERS
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

-- ============================================
-- LOGIC
-- ============================================
if getrawmetatable and hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if CFG.silentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
            local args = {...}
            local ray = args[1]
            local closest, dist = nil, 200
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and not isTeammate(p) and p.Character then
                    local part = getAimPart(p)
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 then
                        local d = (part.Position - ray.Origin).Magnitude
                        if d < dist then closest, dist = part, d end
                    end
                end
            end
            if closest then args[1] = Ray.new(ray.Origin, closest.Position - ray.Origin) end
            return oldNamecall(self, table.unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

local function applyHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if CFG.hitboxExpand then
                        part.Size = Vector3.new(CFG.hitboxSize, CFG.hitboxSize, CFG.hitboxSize)
                        part.Transparency = 0.7
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end

local function applyWeaponMods()
    local char = lp.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") then
            local n = v.Name:lower()
            if CFG.noRecoil and n:find("recoil") then v.Value = 0 end
            if CFG.noSpread and n:find("spread") then v.Value = 0 end
            if CFG.infAmmo and n:find("ammo") then v.Value = 999 end
        end
    end
end

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

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then flags.isMouseDown = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then flags.isMouseDown = false end
end)

RunService.RenderStepped:Connect(function()
    if CFG.rapidFire and flags.isMouseDown then
        local char = lp.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
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
-- ESP & TRACERS
-- ============================================
local function clearESP()
    if flags.espFolder then flags.espFolder:ClearAllChildren() end
    if flags.tracerFolder then flags.tracerFolder:ClearAllChildren() end
    flags.espObjects = {}
    flags.tracerObjects = {}
end

local function updateESP()
    if not CFG.esp and not CFG.tracers then clearESP(); return end
    if not flags.espFolder then flags.espFolder = Instance.new("Folder", workspace); flags.espFolder.Name = "AdminESP" end
    if not flags.tracerFolder then flags.tracerFolder = Instance.new("Folder", pg); flags.tracerFolder.Name = "AdminTracers" end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                if CFG.esp and not flags.espObjects[p] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = p.Character
                    hl.FillColor = isTeammate(p) and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(255, 60, 60)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = flags.espFolder
                    flags.espObjects[p] = hl
                end
                
                if CFG.tracers then
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not flags.tracerObjects[p] then
                            local line = Instance.new("Frame")
                            line.BackgroundColor3 = isTeammate(p) and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(255, 60, 60)
                            line.BorderSizePixel = 0
                            line.Parent = flags.tracerFolder
                            flags.tracerObjects[p] = line
                        end
                        local line = flags.tracerObjects[p]
                        local startX = camera.ViewportSize.X / 2
                        local startY = camera.ViewportSize.Y
                        local endX, endY = screenPos.X, screenPos.Y
                        local length = math.sqrt((endX - startX)^2 + (endY - startY)^2)
                        local angle = math.atan2(endY - startY, endX - startX)
                        line.Size = UDim2.new(0, length, 0, 1)
                        line.Position = UDim2.new(0, startX, 0, startY)
                        line.Rotation = math.deg(angle)
                        line.Visible = true
                    else
                        if flags.tracerObjects[p] then flags.tracerObjects[p].Visible = false end
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- ============================================
-- UI BUILDERS (Tracker + Sidebar)
-- ============================================
local FONT = Enum.Font.Gotham
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local SUB_COLOR = Color3.fromRGB(160, 160, 160)
local BG_COLOR = Color3.fromRGB(35, 25, 45)
local HOVER_COLOR = Color3.fromRGB(55, 40, 70)

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
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(60, 40, 80); stroke.Thickness = 1; stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor or HOVER_COLOR}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = bgColor or BG_COLOR}):Play()
    end)
    return btn
end

local function makeToggle(parent, label, cfKey, cb)
    local default = CFG[cfKey]
    local btn = makeButton(parent, "  " .. label, UDim2.new(1, 0, 0, 32))
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

local function makeSlider(parent, label, min, max, cfKey, cb)
    local default = CFG[cfKey]
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 44)
    holder.BackgroundColor3 = BG_COLOR
    holder.BorderSizePixel = 0
    holder.Parent = parent
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 4); hc.Parent = holder
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 20)
    box.Position = UDim2.new(1, -55, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = tostring(CFG[cfKey])
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.Parent = holder
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 3); bc.Parent = box
    
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
    
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -20, 0, 4); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 30, 50); bar.BorderSizePixel = 0; bar.Parent = holder
    local barc = Instance.new("UICorner"); barc.CornerRadius = UDim.new(1, 0); barc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 0, 255); fill.BorderSizePixel = 0; fill.Parent = bar
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
-- MAIN GUI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "OllieAdmin"
gui.ResetOnSpawn = false
gui.Parent = pg

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 720, 0, 450)
main.Position = UDim2.new(0.5, -360, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(100, 50, 150); ms.Thickness = 1; ms.Transparency = 0.5; ms.Parent = main

-- Top Bar (Search + JOIN + X)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 40); topBar.Position = UDim2.new(0, 10, 0, 10)
topBar.BackgroundTransparency = 1; topBar.Parent = main

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 200, 1, 0); searchFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
searchFrame.BorderSizePixel = 0; searchFrame.Parent = topBar
local sfc = Instance.new("UICorner"); sfc.CornerRadius = UDim.new(0, 6); sfc.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 1, 0); searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "USER ID"
searchBox.Text = ""; searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchFrame

local searchIcon = makeLabel(searchFrame, "🔍", UDim2.new(0, 24, 1, 0), Color3.fromRGB(150, 150, 160), FONT, 14)
searchIcon.Position = UDim2.new(1, -30, 0, 0)

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 24, 0, 24), Color3.fromRGB(40, 20, 50))
closeBtn.Position = UDim2.new(1, -24, 0, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local joinBtn = makeButton(topBar, "JOIN", UDim2.new(0, 60, 0, 24), Color3.fromRGB(40, 20, 50))
joinBtn.Position = UDim2.new(1, -90, 0, 8)

-- Sidebar (Navigation for the old tabs)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -60); sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 10, 22); sidebar.BorderSizePixel = 0; sidebar.Parent = main
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 6); sc.Parent = sidebar
local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 2); navLayout.Parent = sidebar
local navPad = Instance.new("UIPadding"); navPad.PaddingTop = UDim.new(0, 10); navPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -140, 1, -110); content.Position = UDim2.new(0, 130, 0, 50)
content.BackgroundTransparency = 1; content.Parent = main

local pages = {}
local currentPage
local navButtons = {}

local function setPage(name)
    if currentPage then currentPage.Visible = false end
    currentPage = pages[name]
    if currentPage then currentPage.Visible = true end
    
    for _, btn in pairs(navButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(18, 10, 22)
        btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
    if navButtons[name] then
        navButtons[name].BackgroundColor3 = Color3.fromRGB(35, 20, 45)
        navButtons[name].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function addTab(name)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, -8, 0, 28), Color3.fromRGB(18, 10, 22), Color3.fromRGB(35, 20, 45))
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.UIStroke.Transparency = 1
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
-- TAB: PLAYERS (Exact Tracker)
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
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = subTabsFrame
    subTabBtns[name] = btn
end
subTabBtns["ALL"].TextColor3 = Color3.fromRGB(255, 255, 255)

local pList = Instance.new("ScrollingFrame")
pList.Size = UDim2.new(1, 0, 1, -30); pList.Position = UDim2.new(0, 0, 0, 30)
pList.BackgroundColor3 = Color3.fromRGB(15, 10, 20); pList.BorderSizePixel = 0
pList.CanvasSize = UDim2.new(0, 0, 0, 0); pList.ScrollBarThickness = 2; pList.Parent = playersPage
local plc = Instance.new("UICorner"); plc.CornerRadius = UDim.new(0, 6); plc.Parent = pList
local pLayout = Instance.new("UIListLayout", pList); pLayout.Padding = UDim.new(0, 4)

local function refreshPlayers()
    for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            n = n + 1
            local row = makeButton(pList, "", UDim2.new(1, -8, 0, 46), Color3.fromRGB(30, 20, 40))
            row.Position = UDim2.new(0, 4, 0, (n-1)*50)
            
            local nameLbl = makeLabel(row, p.DisplayName, UDim2.new(0, 100, 0, 20), Color3.fromRGB(255, 255, 255), FONT, 12)
            nameLbl.Position = UDim2.new(0, 10, 0, 4); nameLbl.Font = Enum.Font.GothamBold
            local subLbl = makeLabel(row, "Premium", UDim2.new(0, 100, 0, 16), Color3.fromRGB(150, 150, 160), FONT, 9)
            subLbl.Position = UDim2.new(0, 10, 0, 22)
            
            local flag = makeLabel(row, "🇺🇸", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 255, 255), FONT, 14)
            flag.Position = UDim2.new(0, 110, 0, 10)
            local gear = makeLabel(row, "⚙", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
            gear.Position = UDim2.new(0, 140, 0, 12)
            local discord = makeLabel(row, "💬", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
            discord.Position = UDim2.new(0, 165, 0, 12)
            
            local idLbl = makeLabel(row, tostring(p.UserId), UDim2.new(0, 100, 0, 20), Color3.fromRGB(150, 150, 160), FONT, 10)
            idLbl.Position = UDim2.new(1, -130, 0, 4)
            local actionNote = makeLabel(row, "ACTION NOTE HERE", UDim2.new(0, 100, 0, 20), Color3.fromRGB(150, 150, 160), FONT, 9)
            actionNote.Position = UDim2.new(1, -130, 0, 20)
            
            local eyeBtn = Instance.new("TextButton")
            eyeBtn.Size = UDim2.new(0, 24, 0, 24); eyeBtn.Position = UDim2.new(1, -30, 0, 11)
            eyeBtn.BackgroundColor3 = Color3.fromRGB(20, 10, 25); eyeBtn.Text = "👁"
            eyeBtn.TextColor3 = Color3.fromRGB(200, 200, 200); eyeBtn.Font = Enum.Font.Gotham; eyeBtn.TextSize = 12
            eyeBtn.Parent = row
            local ebc = Instance.new("UICorner"); ebc.CornerRadius = UDim.new(0, 4); ebc.Parent = eyeBtn
            
            row.MouseButton1Click:Connect(function()
                CFG.selectedPlayer = p
                for _, r in ipairs(pList:GetChildren()) do if r:IsA("TextButton") then r.BackgroundColor3 = Color3.fromRGB(30, 20, 40) end end
                row.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 50)
end
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(1); refreshPlayers() end)

-- Bottom Action Bar
local actionBar = Instance.new("Frame")
actionBar.Size = UDim2.new(1, -120, 0, 40); actionBar.Position = UDim2.new(0, 10, 1, -50)
actionBar.BackgroundColor3 = Color3.fromRGB(30, 20, 40); actionBar.Parent = main
local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(0, 6); abc.Parent = actionBar

local actionTitle = makeLabel(actionBar, "Dynamic", UDim2.new(0, 100, 0, 20), Color3.fromRGB(255, 255, 255), FONT, 12)
actionTitle.Position = UDim2.new(0, 10, 0, 4); actionTitle.Font = Enum.Font.GothamBold
local actionSub = makeLabel(actionBar, "Premium", UDim2.new(0, 100, 0, 16), Color3.fromRGB(150, 150, 160), FONT, 9)
actionSub.Position = UDim2.new(0, 10, 0, 20)
local aFlag = makeLabel(actionBar, "🇺🇸", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 255, 255), FONT, 14)
aFlag.Position = UDim2.new(0, 110, 0, 8)
local aGear = makeLabel(actionBar, "⚙", UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 200, 200), FONT, 12)
aGear.Position = UDim2.new(0, 140, 0, 10)
local aNote = makeLabel(actionBar, "ACTION NOTE HERE", UDim2.new(0, 100, 0, 20), Color3.fromRGB(150, 150, 160), FONT, 9)
aNote.Position = UDim2.new(1, -130, 0, 4)
local aID = makeLabel(actionBar, "2456939876", UDim2.new(0, 100, 0, 20), Color3.fromRGB(150, 150, 160), FONT, 10)
aID.Position = UDim2.new(1, -130, 0, 20)
local aEye = Instance.new("TextButton")
aEye.Size = UDim2.new(0, 24, 0, 24); aEye.Position = UDim2.new(1, -30, 0, 8)
aEye.BackgroundColor3 = Color3.fromRGB(20, 10, 25); aEye.Text = "👁"
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
makeToggle(combatPage, "Silent Aim", "silentAim")
makeToggle(combatPage, "Triggerbot", "triggerbot")
makeToggle(combatPage, "Rapid Fire", "rapidFire")
makeToggle(combatPage, "Hitbox Expander", "hitboxExpand")
makeSlider(combatPage, "Hitbox Size", 1, 20, "hitboxSize")

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

-- ============================================
-- TAB: MOVEMENT
-- ============================================
local movePage = addTab("Movement")
makeSlider(movePage, "WalkSpeed", 16, 300, "walkSpeed", function(v) local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end)
makeSlider(movePage, "JumpPower", 50, 300, "jumpPower", function(v) local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v; hum.UseJumpPower = true end end)
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
            bv.Velocity = move * 50; bg.CFrame = cam.CFrame
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

-- ============================================
-- TAB: VISUALS
-- ============================================
local visPage = addTab("Visuals")
makeToggle(visPage, "Fullbright", "fullbright")
makeToggle(visPage, "ESP", "esp")
makeToggle(visPage, "Tracers", "tracers")

-- ============================================
-- INIT
-- ============================================
setPage("Players")
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and i.KeyCode == Enum.KeyCode.Insert then main.Visible = not main.Visible end end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

for _, item in ipairs(flags.uiItems) do item.update(CFG[item.key]) end

print("[Ollie Admin] Tracker + Features loaded.")
