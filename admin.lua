-- ============================================
-- OLLIE ADMIN  •  v29 (Ultimate Premium)
-- Silent Aim  •  Hitbox  •  Auto-Farm  •  Troll
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
    -- Combat
    teamCheck = true, aimbot = false, aimPart = "Head", aimFov = 150, aimSmooth = 0.2,
    silentAim = false, triggerbot = false, triggerDelay = 0.1, triggerRange = 200,
    rapidFire = false, rapidFireRate = 0.04, hitboxExpand = false, hitboxSize = 5,
    noRecoil = false, noSpread = false, infAmmo = false,
    
    -- Movement
    walkSpeed = 16, jumpPower = 50, fly = false, flySpeed = 50, noclip = false, infJump = false,
    speedLock = true, autoClicker = false,
    
    -- Visuals
    esp = false, fullbright = false,
    
    -- Orbit
    orbitEnabled = false, orbitRadius = 10, orbitSpeed = 3,
    
    -- Keybinds
    keySpeed = "None", keyJump = "None", keyAimbot = "None", keyTriggerbot = "None",
}

local flags = {
    flyConn = nil, isSpectating = false, oldCamSubject = nil,
    noclipConn = nil, infJumpConn = nil, savedLighting = {},
    aiming = false, uiItems = {}, configScroll = nil,
    bindingKey = nil, orbitConn = nil, orbitAngle = 0,
    isMouseDown = false, lastFireTime = 0, musicInstance = nil,
    killOrbitActive = false, originalCFrame = nil, killOrbitConns = {},
    hitboxConn = nil, autoClickConn = nil, silentAimHook = nil
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
-- SILENT AIM
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
                if p ~= lp and not isTeam(p) and p.Character then
                    local part = getAimPart(p)
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 then
                        local d = (part.Position - ray.Origin).Magnitude
                        if d < dist then closest, dist = part, d end
                    end
                end
            end
            if closest then
                args[1] = Ray.new(ray.Origin, closest.Position - ray.Origin)
            end
            return oldNamecall(self, table.unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

-- ============================================
-- HITBOX EXPANDER
-- ============================================
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

-- ============================================
-- WEAPON MODS (Recoil/Spread/Ammo)
-- ============================================
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
-- AUTO CLICKER & RAPID FIRE
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
    local ig = Instance.new("UIGradient"); ig.Color = ColorSequence.new(indicator.BackgroundColor3); ig.Parent = indicator

    local function updateState(state)
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
        ig.Color = ColorSequence.new(indicator.BackgroundColor3)
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
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(0, 255, 150); s.Transparency = 0.5; s.Parent = box
    
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
    local hs = Instance.new("UIStroke"); hs.Color = Color3.fromRGB(60, 60, 90); hs.Parent = holder
    
    local lbl = makeLabel(holder, label, UDim2.new(1, -60, 0, 20)); lbl.Position = UDim2.new(0, 10, 0, 4)
    makeTextInput(holder, cfKey, cb)
    
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 45); bar.BorderSizePixel = 0; bar.Parent = holder
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255); fill.BorderSizePixel = 0; fill.Parent = bar
    local fcn = Instance.new("UICorner"); fcn.CornerRadius = UDim.new(1, 0); fcn.Parent = fill
    local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new(Color3.fromRGB(0, 255, 200), Color3.fromRGB(0, 100, 255)); fg.Parent = fill
    
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

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 30), Color3.fromRGB(10, 10, 15))
mainGrad.Rotation = 45
mainGrad.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 200, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main
local title = makeLabel(topBar, "  OLLIE ADMIN PREMIUM", UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
title.TextSize = 16

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new(Color3.fromRGB(0, 255, 200), Color3.fromRGB(0, 100, 255))
titleGrad.Parent = title

local closeBtn = makeButton(topBar, "X", UDim2.new(0, 24, 0, 24), Color3.fromRGB(255, 60, 60))
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.TextSize = 12
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = sidebar
local ss = Instance.new("UIStroke"); ss.Color = Color3.fromRGB(40, 40, 60); ss.Parent = sidebar

local navLayout = Instance.new("UIListLayout"); navLayout.Padding = UDim.new(0, 6); navLayout.SortOrder = Enum.SortOrder.LayoutOrder; navLayout.Parent = sidebar
local navPad = Instance.new("UIPadding"); navPad.PaddingTop = UDim.new(0, 10); navPad.PaddingLeft = UDim.new(0, 5); navPad.PaddingRight = UDim.new(0, 5); navPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -300, 1, -50)
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
        btn.UIStroke.Transparency = 1
    end
    if navButtons[name] then
        navButtons[name].BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        navButtons[name].TextColor3 = Color3.fromRGB(0, 255, 200)
        navButtons[name].UIStroke.Transparency = 0
    end
end

local function addTab(name)
    local btn = makeButton(sidebar, "  " .. name, UDim2.new(1, 0, 0, 34), Color3.fromRGB(15, 15, 22), Color3.fromRGB(25, 25, 40))
    btn.TextXAlignment = Enum.TextXAlignment.Left
    navButtons[name] = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 10); pl.Parent = page
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function() setPage(name) end)
    return page
end

-- ============================================
-- CLICKABLE SAVED CONFIGS BOX
-- ============================================
local configBoxFrame = Instance.new("Frame")
configBoxFrame.Size = UDim2.new(0, 140, 1, -50)
configBoxFrame.Position = UDim2.new(1, -150, 0, 50)
configBoxFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
configBoxFrame.BorderSizePixel = 0
configBoxFrame.Parent = main
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 8); cbc.Parent = configBoxFrame
local cbs = Instance.new("UIStroke"); cbs.Color = Color3.fromRGB(40, 40, 60); cbs.Parent = configBoxFrame

local configTitle = makeLabel(configBoxFrame, "  SAVED CONFIGS", UDim2.new(1, 0, 0, 20), Color3.fromRGB(0, 255, 200))
configTitle.Position = UDim2.new(0, 10, 0, 10)
configTitle.TextSize = 11
configTitle.Font = Enum.Font.GothamBold

flags.configScroll = Instance.new("ScrollingFrame")
flags.configScroll.Size = UDim2.new(1, -20, 1, -40)
flags.configScroll.Position = UDim2.new(0, 10, 0, 35)
flags.configScroll.BackgroundTransparency = 1
flags.configScroll.BorderSizePixel = 0
flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
flags.configScroll.ScrollBarThickness = 2
flags.configScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
flags.configScroll.Parent = configBoxFrame

local cfgListLayout = Instance.new("UIListLayout")
cfgListLayout.Padding = UDim.new(0, 4)
cfgListLayout.Parent = flags.configScroll

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
                    local btn = makeButton(flags.configScroll, "  " .. f, UDim2.new(1, 0, 0, 26), Color3.fromRGB(20, 20, 30), Color3.fromRGB(35, 35, 55))
                    btn.TextSize = 11
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.MouseButton1Click:Connect(function() loadConfig(f) end)
                end
            end
        end
    end)
    flags.configScroll.CanvasSize = UDim2.new(0, 0, 0, count * 30)
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
pList.Size = UDim2.new(1, 0, 0, 130); pList.Position = UDim2.new(0, 0, 0, 45)
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

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 32); btnContainer.Position = UDim2.new(0, 10, 1, -45)
btnContainer.BackgroundTransparency = 1; btnContainer.Parent = detailsPanel
local btnLayout = Instance.new("UIListLayout"); btnLayout.FillDirection = Enum.FillDirection.Horizontal; btnLayout.Padding = UDim.new(0, 6); btnLayout.Parent = btnContainer

local teleportBtn = makeButton(btnContainer, "Teleport", UDim2.new(0.2, -5, 1, 0))
local spectateBtn = makeButton(btnContainer, "Spectate", UDim2.new(0.2, -5, 1, 0))
local orbitBtn = makeButton(btnContainer, "Orbit", UDim2.new(0.2, -5, 1, 0))
local killOrbitBtn = makeButton(btnContainer, "Kill Orbit", UDim2.new(0.2, -5, 1, 0), Color3.fromRGB(200, 60, 60))
local highlightBtn = makeButton(btnContainer, "Highlight", UDim2.new(0.2, -5, 1, 0))

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
                detailsText.Text = p.Name .. " (@" .. p.DisplayName .. ")\nID: " .. p.UserId
                task.spawn(function() local ok, thumb = pcall(function() return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end); if ok then avatarImg.Image = thumb end end)
            end)
        end
    end
    pList.CanvasSize = UDim2.new(0, 0, 0, n * 30)
end

search
