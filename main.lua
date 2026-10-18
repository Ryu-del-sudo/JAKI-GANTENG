-- Volleyball Legends — rework
-- Knit-aware ability resolver, adaptive hitbox, ESP with range guard,
-- drag UI with collapse, panic key, zero hardcoded remote names.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ── utils ────────────────────────────────────────────────
local function findKnit()
    local p = ReplicatedStorage:FindFirstChild("Packages")
    if p then
        for _, v in ipairs(p:GetChildren()) do
            if v.Name == "Knit" then return v end
        end
    end
    local k = ReplicatedStorage:FindFirstChild("Knit")
    if k then return k end
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "Knit" and v:IsA("ModuleScript") then return v end
    end
end

local function getSignal(remote, name)
    local ok, sig = pcall(function() return remote[name] end)
    if ok and sig then return sig end
    return remote
end

local function safeFire(remote, method, ...)
    if not remote then return false end
    local sig = getSignal(remote, method)
    local ok = pcall(function() sig:FireServer(...) end)
    if not ok then
        ok = pcall(function() remote:FireServer(...) end)
    end
    return ok
end

-- probe AbilityService-like remotes once, cache map
local abilityRemotes = {}
local function indexAbilities()
    abilityRemotes = {}
    local root = ReplicatedStorage
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("abilit") or n:find("ult") or n:find("charge") or n:find("special") then
                table.insert(abilityRemotes, v)
            end
        end
    end
end

-- ── ball discovery (no cache) ───────────────────────────
local function findBall()
    local candidates = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("ball") or n:find("volley") or n:find("sphere") then
                -- filter: skip parts parented to our own character
                if not (LP.Character and v:IsDescendantOf(LP.Character)) then
                    table.insert(candidates, v)
                end
            end
        end
    end
    -- pick nearest to character if multiple
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and #candidates > 1 then
        table.sort(candidates, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
    end
    return candidates[1]
end

-- ── UI ───────────────────────────────────────────────────
local function rStr(n)
    local t = {}
    for i = 1, n or math.random(6, 10) do
        t[i] = string.char(math.random(97, 122))
    end
    return table.concat(t)
end

local GUI = Instance.new("ScreenGui")
GUI.Name = rStr()
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(200, 44)
Main.Position = UDim2.new(0, 12, 0, 60)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -12, 0, 40)
Header.Position = UDim2.new(0, 6, 0, 2)
Header.BackgroundTransparency = 1
Header.Text = "  ▼  " .. GUI.Name
Header.TextColor3 = Color3.fromRGB(200, 220, 255)
Header.TextSize = 12
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.Code
Header.Parent = Main

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 0, 0)
Body.Position = UDim2.new(0, 0, 0, 44)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -8)
Scroll.Position = UDim2.new(0, 4, 0, 4)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 100, 140)
Scroll.Parent = Body
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 3)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local function row(text, toggleColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = toggleColor or Color3.fromRGB(28, 28, 34)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 235)
    b.TextSize = 12
    b.Font = Enum.Font.Code
    b.AutoButtonColor = true
    b.Parent = Scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local function toggleRow(name, initial, cb)
    local on = initial or false
    local b = row(name .. ": " .. (on and "ON" or "OFF"))
    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = name .. ": " .. (on and "ON" or "OFF")
        b.BackgroundColor3 = on and Color3.fromRGB(30, 70, 50) or Color3.fromRGB(28, 28, 34)
        cb(on)
    end)
    return b
end

local function buttonRow(name, cb)
    local b = row(name)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- collapse
local expanded = false
local function setExpanded(v)
    expanded = v
    local h = expanded and 320 or 0
    TweenService:Create(Body, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, h) }).:Play()
    Header.Text = (expanded and "  ▲  " or "  ▼  ") .. GUI.Name
end
Header.InputBeganPlaceholder = nil
local headerBtn = Instance.new("TextButton")
headerBtn.Size = UDim2.new(1, 0, 1, 0)
headerBtn.BackgroundTransparency = 1
headerBtn.Text = ""
headerBtn.Parent = Header
headerBtn.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

-- ── features ─────────────────────────────────────────────
local state = {
    hitbox = false,
    magnet = false,
    esp = false,
    autoSpike = false,
    trail = false,
}

local savedSizes = setmetatable({}, { __mode = "k" })

local highlight = nil
local trailPart = nil
local trailObj = nil

local function nearestBall()
    return findBall()
end

local function onHitbox(v)
    state.hitbox = v
    if not v then
        for part, sz in pairs(savedSizes) do
            pcall(function() part.Size = sz end)
        end
        savedSizes = setmetatable({}, { __mode = "k" })
    end
end

local function onMagnet(v) state.magnet = v end
local function onTrail(v) state.trail = v end

local function onEsp(v)
    state.esp = v
    if not v and highlight then
        highlight:Destroy()
        highlight = nil
    end
end

local function onAutoSpike(v) state.autoSpike = v end

-- heart loop
RunService.Heartbeat:Connect(function()
    local ball = nearestBall()
    if not ball then return end

    -- adaptive hitbox: query original every frame if not stored
    if state.hitbox then
        if not savedSizes[ball] then
            savedSizes[ball] = ball.Size
        end
        pcall(function()
            ball.Size = savedSizes[ball] * Vector3.new(8, 8, 8)
        end)
    end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    if state.magnet and hrp then
        local d = (hrp.Position - ball.Position).Magnitude
        if d < 30 then
            pcall(function()
                ball.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 2) * (ball.CFrame - ball.CFrame.Position)
            end)
        end
    end

    if state.autoSpike and hrp then
        local d = (hrp.Position - ball.Position).Magnitude
        if d < 12 then
            for _, v in ipairs(abilityRemotes) do
                safeFire(v, "Use", "Spike")
                safeFire(v, "Spike")
            end
        end
    end

    if state.esp and not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = rStr()
        highlight.FillColor = Color3.fromRGB(255, 220, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
        highlight.FillTransparency = 0.4
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = GUI
    end
    if highlight then highlight.Adornee = ball end

    if state.trail then
        if not trailPart or trailPart ~= ball then
            if trailObj then trailObj:Destroy() end
            trailPart = ball
            trailObj = Instance.new("Trail")
            local a0 = Instance.new("Attachment", ball)
            local a1 = Instance.new("Attachment", ball)
            a0.Position = Vector3.new(0, 1, 0)
            a1.Position = Vector3.new(0, -1, 0)
            trailObj.Attachment0 = a0
            trailObj.Attachment1 = a1
            trailObj.Lifetime = 0.6
            trailObj.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
            trailObj.Parent = ball
        end
    elseif trailObj then
        trailObj:Destroy()
        trailObj = nil
        trailPart = nil
    end
end)

-- ── ability resolver ────────────────────────────────────
local function useUlt()
    indexAbilities()
    if #abilityRemotes == 0 then return end
    for _, r in ipairs(abilityRemotes) do
        safeFire(r, "Use")
        safeFire(r, "Activate")
        safeFire(r, "Trigger")
        safeFire(r, "Ultimate")
        safeFire(r, "Cast")
        task.wait(0.03)
    end
end

-- ── build menu ───────────────────────────────────────────
toggleRow("Hitbox x8", false, onHitbox)
toggleRow("Magnet", false, onMagnet)
toggleRow("Ball ESP", false, onEsp)
toggleRow("Auto Spike", false, onAutoSpike)
toggleRow("Ball Trail", false, onTrail)
buttonRow("Ultimate (probe)", useUlt)
buttonRow("Re-index Abilities", function()
    indexAbilities()
    local b = row("indexed: " .. #abilityRemotes)
    task.delay(1.5, function() if b then b:Destroy() end end)
end)

indexAbilities()

-- panic key: right shift toggles hitbox off + restore
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        onHitbox(false)
        onMagnet(false)
        onEsp(false)
        onAutoSpike(false)
        onTrail(false)
    end
end)
