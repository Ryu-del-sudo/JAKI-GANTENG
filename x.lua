local P=game:GetService("Players")
local L=P.LocalPlayer
local R=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")

-- UI Sederhana
local G=Instance.new("ScreenGui")
G.Name="x"
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

-- Fitur
local hb,esp,ult=false,false,false
local oriBall=nil

local function getBall()
	for _,v in ipairs(workspace:GetDescendants())do
		if v:IsA("BasePart")and string.find(v.Name:lower(),"ball")then return v end
	end
end

local function toggleHitbox(on)
	hb=on
	local b=getBall()
	if b then
		if on then
			if not oriBall then oriBall=b.Size end
			b.Size=oriBall*3
		elseif oriBall then
			b.Size=oriBall
		end
	end
end
R.Heartbeat:Connect(function()
	if hb then local b=getBall() if b and oriBall then b.Size=oriBall*3 end end
end)

local function toggleESP(on)
	esp=on
	for _,p in ipairs(P:GetPlayers())do
		if p~=L then
			local char=p.Character
			if char then
				local hrp=char:FindFirstChild("HumanoidRootPart")
				if hrp then
					if on and not hrp:FindFirstChild("ESPBox") then
						local box=Instance.new("BoxHandleAdornment",hrp)
						box.Name="ESPBox"
						box.Size=Vector3.new(4,6,4)
						box.Adornee=hrp
						box.AlwaysOnTop=true
						box.ZIndex=5
						box.Transparency=0.5
						box.Color3=Color3.fromRGB(255,0,0)
					elseif not on and hrp:FindFirstChild("ESPBox") then
						hrp.ESPBox:Destroy()
					end
				end
			end
		end
	end
end

local function toggleUlt(on)
	ult=on
	if on then
		task.spawn(function()
			while ult do
				for _,v in ipairs(L:GetDescendants())do
					if string.find(v.Name:lower(),"ult") or string.find(v.Name:lower(),"charge") then
						pcall(function() v.Value=100 end)
					end
				end
				task.wait(0.1)
			end
		end)
	end
end

local function safeFire(remote,...)
	pcall(function() remote:FireServer(...) end)
end

local function doYen()
	task.wait(math.random(3,8)/10)
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteEvent")or v:IsA("RemoteFunction"))and (string.find(v.Name:lower(),"yen")or string.find(v.Name:lower(),"money")or string.find(v.Name:lower(),"reward"))then
			if v:IsA("RemoteEvent")then safeFire(v)else pcall(function() v:InvokeServer() end)end
		end
	end
end

local function doExp()
	task.wait(math.random(3,8)/10)
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteEvent")or v:IsA("RemoteFunction"))and (string.find(v.Name:lower(),"exp")or string.find(v.Name:lower(),"level"))then
			if v:IsA("RemoteEvent")then safeFire(v,60)else pcall(function() v:InvokeServer(60) end)end
		end
	end
end

Tgl("Hitbox",toggleHitbox)
Tgl("ESP",toggleESP)
Tgl("Ultimate",toggleUlt)
Btn("Yen +",function() task.spawn(doYen) end)
Btn("Exp +60",function() task.spawn(doExp) end)
