-- ============================================
-- OLLIE ADMIN  •  v34 (Aimbot & Team Fix)
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
    teamCheck = true, -- Simple boolean now
    aimbot = false, aimPart = "Head", aimFov = 150, aimSmooth = 0.2,
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
    espFolder = nil, tracerFolder = nil, espObjects = {}, tracerObjects = {}
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
-- LOGIC (Silent Aim, Hitbox, Weapon Mods)
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
    if CFG.bunnyhop then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
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

task.spawn(function()
    while task.wait(0.05) do
        if CFG.autoClicker then
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, true, game, 1)
            task.wait(0.02)
            vim:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, false, game, 1)
        end
        applyWeaponMods()
        applyHitbox()
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

local function makeButton(parent, text, size, bgColor, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(80, 100, 255); stroke.Thickness = 1; stroke.Transparency = 0.7; stroke.Parent = btn

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
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    makeTextInput(holder, cfKey, cb)
    
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 45); bar.BorderSizePixel = 0; bar.Parent = holder
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255); fill.BorderSizePixel = 0; fill.Parent = bar
    local fcn = Instance.new("UICorner"); fcn.CornerRadius = UDim.new(1, 0); fcn.Parent = fill
    
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
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(0, 200, 255); ms.Thickness = 1.5; ms.Transparency = 0.5; ms.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main
local title = makeLabel(topBar, "  OLLIE ADMIN PREMIUM", UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
title.TextSize = 16

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 60, 60))
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = sidebar

local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 4); navLayout.SortOrder = Enum.SortOrder.LayoutOrder; navLayout.Parent = sidebar
local navPad = Instance.new("UIPadding"); navPad.PaddingTop = UDim.new(0, 10); navPad.PaddingLeft = UDim.new(0, 5); navPad.PaddingRight = UDim.new(0, 5); navPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -280, 1, -50)
content.Position = UDim2.new(0, 150, 0, 50)
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

local function addTab(name)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, 0, 0, 30))
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
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 8); pl.Parent = page
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- SAVED CONFIGS BOX
-- ============================================
local configBoxFrame = Instance.new("Frame")
configBoxFrame.Size = UDim2.new(0, 130, 1, -50)
configBoxFrame.Position = UDim2.new(1, -140, 0, 50)
configBoxFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
configBoxFrame.BorderSizePixel = 0
configBoxFrame.Parent = main
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 8); cbc.Parent = configBoxFrame

local configTitle = makeLabel(configBoxFrame, "  CONFIGS", UDim2.new(1, 0, 0, 20), Color3.fromRGB(0, 255, 200))
configTitle.Position = UDim2.new(0, 10, 0, 10)
configTitle.TextSize = 10
configTitle.Font = Enum.Font.GothamBold

flags.configScroll = Instance.new("ScrollingFrame")
flags.configScroll.Size = UDim2.new(1, -20, 1, -40)
flags.configScroll.Position = UDim2.new(0, 10, 0, 35)
flags.configScroll.BackgroundTransparency = 1
flags.configScroll.BorderSizePixel = 0
flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
flags.configScroll.Parent = configBoxFrame

local cfgListLayout = Instance.new("UIListLayout"); cfgListLayout.Padding = UDim.new(0, 4); cfgListLayout.Parent = flags.configScroll

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
                    local btn = makeButton(flags.configScroll, "  " .. f, UDim2.new(1, 0, 0, 24), Color3.fromRGB(20, 20, 30))
                    btn.TextSize = 10
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.MouseButton1Click:Connect(function() loadConfig(f) end)
                end
            end
        end
    end)
    flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end

-- ============================================
-- TAB: PLAYERS
-- ============================================
local playersPage = addTab("Players")
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 30); searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
searchBox.PlaceholderText = "Search players..."; searchBox.Text = ""; searchBox.TextColor3 = Color3.fromRGB(0, 255, 200)
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.BorderSizePixel = 0; searchBox.Parent = playersPage
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 6); sbc.Parent = searchBox

local pList = Instance.new("ScrollingFrame")
pList.Size = UDim2.new(1, 0, 0, 130); pList.Position = UDim2.new(0, 0, 0, 40)
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

local btnRow1 = Instance.new("Frame"); btnRow1.Size = UDim2.new(1, -20, 0, 26); btnRow1.Position = UDim2.new(0, 10, 1, -65); btnRow1.BackgroundTransparency = 1; btnRow1.Parent = detailsPanel
local l1 = Instance.new("UIListLayout", btnRow1); l1.FillDirection = Enum.FillDirection.Horizontal; l1.Padding = UDim.new(0, 4)

local btnRow2 = Instance.new("Frame"); btnRow2.Size = UDim2.new(1, -20, 0, 26); btnRow2.Position = UDim2.new(0, 10, 1, -35); btnRow2.BackgroundTransparency = 1; btnRow2.Parent = detailsPanel
local l2 = Instance.new("UIListLayout", btnRow2); l2.FillDirection = Enum.FillDirection.Horizontal; l2.Padding = UDim.new(0, 4)

local tBtn = makeButton(btnRow1, "Teleport", UDim2.new(0.33, -3, 1, 0))
local bBtn = makeButton(btnRow1, "Bring", UDim2.new(0.33, -3, 1, 0))
local kBtn = makeButton(btnRow1, "Kill", UDim2.new(0.33, -3, 1, 0))
local sBtn = makeButton(btnRow2, "Spectate", UDim2.new(0.33, -3, 1, 0))
local oBtn = makeButton(btnRow2, "Orbit", UDim2.new(0.33, -3, 1, 0))
local koBtn = makeButton(btnRow2, "Kill Orbit", UDim2.new(0.33, -3, 1, 0))

local function refreshPlayers()
    for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local n = 0; local query = searchBox.Text:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Name:lower():find(query) then
            n = n + 1
            local row = makeButton(pList, "  " .. p.Name, UDim2.new(1, 0, 0, 28), Color3.fromRGB(20, 20, 30))
            row.TextXAlignment = Enum.TextXAlignment.Left
            
            local statusLbl = Instance.new("TextLabel")
            statusLbl.Size = UDim2.new(0, 100, 1, 0)
            statusLbl.Position = UDim2.new(1, -110, 0, 0)
            statusLbl.BackgroundTransparency = 1
            statusLbl.Text = p.Team and p.Team.Name or "No Team"
            statusLbl.TextColor3 = isTeammate(p) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
            statusLbl.Font = Enum.Font.Gotham
            statusLbl.TextSize = 11
            statusLbl.TextXAlignment = Enum.TextXAlignment.Right
            statusLbl.Parent = row
            
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

tBtn.MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character and lp.Character then
        local hrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then lp.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
    end
end)

bBtn.MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character and lp.Character then
        local hrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) end
    end
end)

kBtn.MouseButton1Click:Connect(function()
    if CFG.selectedPlayer and CFG.selectedPlayer.Character then
        local hum = CFG.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

local function stopSpectating()
    flags.isSpectating = false
    sBtn.Text = "Spectate"
    sBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if myHum then camera.CameraSubject = myHum; camera.CameraType = Enum.CameraType.Custom end
end

sBtn.MouseButton1Click:Connect(function()
    if flags.isSpectating then stopSpectating()
    elseif CFG.selectedPlayer and CFG.selectedPlayer.Character then
        local hum = CFG.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then 
            flags.isSpectating = true
            camera.CameraSubject = hum
            camera.CameraType = Enum.CameraType.Custom
            sBtn.Text = "Stop"
            sBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        end
    end
end)

local isOrbiting = false
oBtn.MouseButton1Click:Connect(function()
    if not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
    isOrbiting = not isOrbiting
    if isOrbiting then
        oBtn.Text = "Orbiting..."; oBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        flags.orbitAngle = 0
        flags.orbitConn = RunService.Heartbeat:Connect(function(dt)
            if not isOrbiting or not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = CFG.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHrp then
                flags.orbitAngle = flags.orbitAngle + (dt * 3)
                hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(math.cos(flags.orbitAngle), 0, math.sin(flags.orbitAngle)) * 10, targetHrp.Position)
            end
        end)
    else
        oBtn.Text = "Orbit"; oBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
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
    koBtn.Text = "Kill Orbit"
    koBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end

koBtn.MouseButton1Click:Connect(function()
    if flags.killOrbitActive then stopKillOrbit(); return end
    if not CFG.selectedPlayer or not CFG.selectedPlayer.Character then return end
    local target = CFG.selectedPlayer
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    flags.originalCFrame = myHrp.CFrame
    flags.killOrbitActive = true
    koBtn.Text = "Killing..."; koBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
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
-- TAB: COMBAT
-- ============================================
local combatPage = addTab("Combat")
makeToggle(combatPage, "Team Check (Skip Teammates)", "teamCheck")
makeToggle(combatPage, "Aimbot (Hold RMB)", "aimbot")
makeSlider(combatPage, "Aimbot FOV", 20, 500, "aimFov")
makeSlider(combatPage, "Aimbot Smoothness", 0.05, 1, "aimSmooth")
makeToggle(combatPage, "Silent Aim", "silentAim")
makeToggle(combatPage, "Triggerbot", "triggerbot")
makeSlider(combatPage, "Trigger Range", 50, 500, "triggerRange")
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
-- TAB: WAYPOINTS
-- ============================================
local wpPage = addTab("Waypoints")
local wpList = Instance.new("ScrollingFrame")
wpList.Size = UDim2.new(1, 0, 1, -40); wpList.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
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
        local row = makeButton(wpList, "  " .. wpName .. " (Click to TP)", UDim2.new(1, -4, 0, 26), Color3.fromRGB(20, 20, 30))
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.MouseButton1Click:Connect(function() if lp.Character then lp.Character.HumanoidRootPart.CFrame = wp.pos end end)
        wpList.CanvasSize = UDim2.new(0, 0, 0, #waypoints * 30)
    end
end
local saveWpBtn = makeButton(wpPage, "Save Current Position", UDim2.new(1, 0, 0, 32), Color3.fromRGB(40, 90, 40))
saveWpBtn.Position = UDim2.new(0, 0, 1, -36); saveWpBtn.MouseButton1Click:Connect(addWaypoint)

-- ============================================
-- TAB: SERVER
-- ============================================
local serverPage = addTab("Server")
local jidBox = Instance.new("TextBox")
jidBox.Size = UDim2.new(1, 0, 0, 32); jidBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
jidBox.PlaceholderText = "Target Job ID..."; jidBox.Text = ""
jidBox.TextColor3 = Color3.fromRGB(0, 255, 200); jidBox.Font = Enum.Font.Gotham; jidBox.TextSize = 12
jidBox.BorderSizePixel = 0; jidBox.Parent = serverPage
local jic = Instance.new("UICorner"); jic.CornerRadius = UDim.new(0, 6); jic.Parent = jidBox

makeButton(serverPage, "Join Server", UDim2.new(1, 0, 0, 32)).MouseButton1Click:Connect(function()
    if jidBox.Text ~= "" then pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jidBox.Text, lp) end) end
end)

makeButton(serverPage, "Copy Job ID", UDim2.new(1, 0, 0, 32)).MouseButton1Click:Connect(function()
    pcall(function() setclipboard(game.JobId) end)
end)

makeButton(serverPage, "Server Hop", UDim2.new(1, 0, 0, 32)).MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in ipairs(servers.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
            break
        end
    end
end)

-- ============================================
-- TAB: TROLL
-- ============================================
local trollPage = addTab("Troll")
makeButton(trollPage, "Ragdoll Self", UDim2.new(1, 0, 0, 32)).MouseButton1Click:Connect(function()
    if lp.Character then lp.Character:BreakJoints() end
end)

makeButton(trollPage, "Giant Me", UDim2.new(1, 0, 0, 32)).MouseButton1Click:Connect(function()
    if lp.Character then
        local s = Instance.new("NumberValue", lp.Character); s.Name = "BodyHeightScale"; s.Value = 5
    end
end)

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
refreshConfigList()

print("[Ollie Admin PREMIUM] loaded.")
