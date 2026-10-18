local P=game:GetService("Players")
local L=P.LocalPlayer
local U=game:GetService("UserInputService")
local R=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")

local function rStr()
	local t={}
	for i=1,math.random(5,10) do t[i]=string.char(math.random(97,122)) end
	return table.concat(t)
end
local function sWait() local t=tick()+(math.random(40,90)/100) while tick()<t do end end

local G=Instance.new("ScreenGui")
G.Name=rStr()
G.ResetOnSpawn=false
G.Parent=L:WaitForChild("PlayerGui")
local F=Instance.new("Frame",G)
F.Size=UDim2.fromOffset(160,200)
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
local oriBall=nil
local ballHighlight=nil

local function getBall()
	for _,v in ipairs(workspace:GetDescendants())do
		if v:IsA("BasePart")and string.find(v.Name:lower(),"ball")then return v end
	end
end

-- Hitbox Gede + Auto Spike
local function toggleHitbox(on)
	hb=on
	local b=getBall()
	if b then
		if on then
			if not oriBall then oriBall=b.Size end
			b.Size=oriBall*Vector3.new(5,5,5)
		elseif oriBall then
			b.Size=oriBall
		end
	end
end
R.Heartbeat:Connect(function()
	if hb then 
		local b=getBall()
		if b and oriBall then 
			b.Size=oriBall*Vector3.new(5,5,5)
			-- Auto Spike kalau bola nempel
			local hrp=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - b.Position).Magnitude < 15 then
				pcall(function() b.CFrame = hrp.CFrame end)
			end
		end 
	end
end)

-- ESP Khusus Bola
local function toggleBallESP(on)
	ballEsp=on
	local b=getBall()
	if b then
		if on and not ballHighlight then
			ballHighlight=Instance.new("Highlight")
			ballHighlight.Name=rStr()
			ballHighlight.FillColor=Color3.fromRGB(255,255,0)
			ballHighlight.OutlineColor=Color3.fromRGB(255,0,0)
			ballHighlight.FillTransparency=0.2
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
				ballHighlight.Name=rStr()
				ballHighlight.FillColor=Color3.fromRGB(255,255,0)
				ballHighlight.OutlineColor=Color3.fromRGB(255,0,0)
				ballHighlight.FillTransparency=0.2
				ballHighlight.Parent=G
			end
			ballHighlight.Adornee=b
		elseif ballHighlight then
			ballHighlight:Destroy()
			ballHighlight=nil
		end
	end
end)

-- Ultimate Per Klik
local function doUlt()
	for _,v in ipairs(L:GetDescendants())do
		if string.find(v.Name:lower(),"ult") or string.find(v.Name:lower(),"charge") then
			pcall(function() v.Value=100 end)
		end
	end
end

-- Nyedot Reward / Exp (Spam Remote)
local function doYen()
	sWait()
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteEvent")or v:IsA("RemoteFunction"))and (string.find(v.Name:lower(),"yen")or string.find(v.Name:lower(),"money")or string.find(v.Name:lower(),"reward")or string.find(v.Name:lower(),"cash"))then
			if v:IsA("RemoteEvent")then 
				pcall(function() v:FireServer() end)
				pcall(function() v:FireServer("Reward") end)
			else 
				pcall(function() v:InvokeServer() end)
			end
		end
	end
end

local function doExp()
	sWait()
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteEvent")or v:IsA("RemoteFunction"))and (string.find(v.Name:lower(),"exp")or string.find(v.Name:lower(),"level")or string.find(v.Name:lower(),"xp"))then
			if v:IsA("RemoteEvent")then 
				pcall(function() v:FireServer(60) end)
				pcall(function() v:FireServer("Add", 60) end)
			else 
				pcall(function() v:InvokeServer(60) end)
			end
		end
	end
end

Tgl("Hitbox + AutoSpike",toggleHitbox)
Tgl("ESP Bola",toggleBallESP)
Btn("Ulti (Klik)",doUlt)
Btn("Sedot Yen",function() spawn(doYen) end)
Btn("Sedot Exp",function() spawn(doExp) end)
