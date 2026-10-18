local P=game:GetService("Players")
local L=P.LocalPlayer
local R=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")

local function rStr()
	local t={}
	for i=1,math.random(5,10) do t[i]=string.char(math.random(97,122)) end
	return table.concat(t)
end

local G=Instance.new("ScreenGui")
G.Name=rStr()
G.ResetOnSpawn=false
G.Parent=L:WaitForChild("PlayerGui")
local F=Instance.new("Frame",G)
F.Size=UDim2.fromOffset(160,140)
F.Position=UDim2.new(0,10,0,50)
F.BackgroundColor3=Color3.fromRGB(20,20,20)
F.Active=true
F.Draggable=true
Instance.new("UICorner",F).CornerRadius=UDim.new(0,5)

local S=Instance.new("ScrollingFrame",F)
S.Size=UDim2.new(1,-4,1,-4)
S.Position=UDim2.new(0,2,0,2)
S.BackgroundTransparency=1
S.BorderSizePixel=0
S.CanvasSize=UDim2.new(0,0,0,0)
S.AutomaticCanvasSize=Enum.AutomaticSize.Y
local L2=Instance.new("UIListLayout",S)
L2.Padding=UDim.new(0,2)

local function Btn(t,c)
	local b=Instance.new("TextButton",S)
	b.Size=UDim2.new(1,0,0,20)
	b.BackgroundColor3=Color3.fromRGB(40,40,40)
	b.Text=t
	b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=11
	b.MouseButton1Click:Connect(c)
end

local function Tgl(t,c)
	local b=Instance.new("TextButton",S)
	b.Size=UDim2.new(1,0,0,20)
	b.BackgroundColor3=Color3.fromRGB(40,40,40)
	b.Text=t..": OFF"
	b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=11
	local on=false
	b.MouseButton1Click:Connect(function()
		on=not on
		b.Text=t..": "..(on and "ON" or "OFF")
		c(on)
	end)
end

local hb,ballEsp=false,false
local origBall=nil
local ballHighlight=nil

-- Fungsi nyari bola yang lebih luas (nyari nama yang ada 'ball' atau 'volley')
local function getBall()
	for _,v in ipairs(workspace:GetDescendants())do
		if v:IsA("BasePart") and (string.find(v.Name:lower(),"ball") or string.find(v.Name:lower(),"volley")) then
			return v
		end
	end
end

-- 1. HITBOX & AUTO SPIKE
-- Ukuran bola dibesarin 8x lipat (biar pasti kena), dan magnet bola ke kita pas deket
local function toggleHitbox(on)
	hb=on
	local b=getBall()
	if b then
		if on then
			if not origBall then origBall=b.Size end
			b.Size=origBall*Vector3.new(8,8,8)
		elseif origBall then
			b.Size=origBall
		end
	end
end

R.Heartbeat:Connect(function()
	if hb then 
		local b=getBall()
		if b and origBall then 
			b.Size=origBall*Vector3.new(8,8,8)
			local hrp=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
			-- Kalau jarak kita ke bola kurang dari 25 stud, tarik bolanya ke dada kita
			if hrp and (hrp.Position - b.Position).Magnitude < 25 then
				pcall(function() b.CFrame = hrp.CFrame end)
			end
		end 
	end
end)

-- 2. ESP BOLA
local function toggleBallESP(on)
	ballEsp=on
	local b=getBall()
	if b then
		if on and not ballHighlight then
			ballHighlight=Instance.new("Highlight")
			ballHighlight.Name="B_ESP"
			ballHighlight.FillColor=Color3.fromRGB(255,255,0)
			ballHighlight.OutlineColor=Color3.fromRGB(255,0,0)
			ballHighlight.FillTransparency=0.3
			ballHighlight.Adornee=b
			ballHighlight.Parent=G
		elseif not on and ballHighlight then
			ballHighlight:Destroy()
			ballHighlight=nil
		end
	end
end

R.Heartbeat:Connect(function()
	if ballEsp then
		local b=getBall()
		if b then
			if not ballHighlight then
				ballHighlight=Instance.new("Highlight")
				ballHighlight.Name="B_ESP"
				ballHighlight.FillColor=Color3.fromRGB(255,255,0)
				ballHighlight.OutlineColor=Color3.fromRGB(255,0,0)
				ballHighlight.FillTransparency=0.3
				ballHighlight.Parent=G
			end
			ballHighlight.Adornee=b
		elseif ballHighlight then
			ballHighlight:Destroy()
			ballHighlight=nil
		end
	end
end)

-- 3. ULTIMATE (Bypass via Knit Framework Remote)
-- Game ini pake framework Knit. Kita tembak remote AbilityService-nya.
local function doUlt()
	local success = false
	
	-- Cara 1: Cari Value Ult
	for _,v in ipairs(L:GetDescendants())do
		if string.find(v.Name:lower(),"ult") or string.find(v.Name:lower(),"ability") or string.find(v.Name:lower(),"charge") then
			pcall(function() 
				v.Value = v:IsA("NumberValue") and 100 or v.Value
				if v:IsA("BoolValue") then v.Value = true end
			end)
		end
	end
	
	-- Cara 2: Tembak Remote Framework Knit
	pcall(function()
		local knit = RS:FindFirstChild("Packages") 
		if knit then
			for _,v in ipairs(RS:GetDescendants())do
				if v:IsA("RemoteEvent") and (string.find(v.Name:lower(),"ult") or string.find(v.Name:lower(),"ability")) then
					v:FireServer("Use")
					v:FireServer()
					success = true
				end
			end
		end
	end)
end

Tgl("Hitbox + AutoSpike",toggleHitbox)
Tgl("ESP Bola",toggleBallESP)
Btn("Ulti (Klik)",doUlt)
