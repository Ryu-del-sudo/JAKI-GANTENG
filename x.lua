local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

local HIT_DISTANCE = 12
local PREDICTION_FACTOR = 0.15

local function getClosestBall()
    local closest, minDst = nil, math.huge
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj:FindFirstChild("TouchInterest")) then
            local dst = (obj.Position - RootPart.Position).Magnitude
            if dst < minDst then
                minDst = dst
                closest = obj
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local ball = getClosestBall()
    if not ball then return end

    local predictedPos = ball.Position + (ball.Velocity * PREDICTION_FACTOR)
    local distance = (predictedPos - RootPart.Position).Magnitude

    if distance <= HIT_DISTANCE then
        RootPart.CFrame = CFrame.new(RootPart.Position, Vector3.new(predictedPos.X, RootPart.Position.Y, predictedPos.Z))
        mouse1click()
    end
end)
