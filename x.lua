-- language: Lua, file: volleyball_engine.lua, target: Roblox Client / Exploit Executor
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

print("=== VOLLEYBALL LEGENDS OPTIMIZED ENGINE LOADED ===")

-- 1. Caching exact RemoteEvents for volleyball action handling
local cachedRemotes = {}
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
    if descendant:IsA("RemoteEvent") then
        local nameLower = descendant.Name:lower()
        if nameLower:find("spike") or nameLower:find("hit") or nameLower:find("volley") or nameLower:find("touch") or nameLower:find("action") then
            table.insert(cachedRemotes, descendant)
        end
    end
end

-- Fallback if specific remotes are obfuscated or named differently
if #cachedRemotes == 0 then
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            table.insert(cachedRemotes, descendant)
        end
    end
end

print("Cached actionable remotes:", #cachedRemotes)

-- 2. Optimized Ball Snapper with Prediction & Assembly Stabilization
local function locateAndAttractBall()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            -- Identify standard volleyball instances by naming or physical characteristics
            if name == "ball" or name == "volleyball" or name == "nil" or (obj.Shape == Enum.PartType.Ball and obj.Size.Magnitude < 10) then
                pcall(function()
                    -- Zero out velocity to prevent physics glitching, snap smoothly in front of character
                    obj.AssemblyLinearVelocity = Vector3.zero
                    obj.AssemblyAngularVelocity = Vector3.zero
                    obj.Velocity = Vector3.zero
                    
                    -- Position right in front of character's hit zone (offset forward by 3 studs, height offset 0)
                    local targetCFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    obj.CFrame = targetCFrame
                end)
            end
        end
    end
end

-- 3. Controlled High-Frequency Trigger Loop
local triggerToggle = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Equals then
        triggerToggle = not triggerToggle
        print("Engine Status:", triggerToggle and "ACTIVE" or "PAUSED")
    end
end)

RunService.Heartbeat:Connect(function()
    if not triggerToggle then return end
    
    locateAndAttractBall()
    
    -- Fire cached action remotes with standard sport payload arguments
    for _, remote in ipairs(cachedRemotes) do
        pcall(function()
            remote:FireServer()
            remote:FireServer("Spike")
            remote:FireServer("Hit")
            remote:FireServer(HumanoidRootPart.Position)
        end)
    end
end)
