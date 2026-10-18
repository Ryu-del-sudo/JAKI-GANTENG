local P,L,U,R,C=game:GetService("Players"),game:GetService("Players").LocalPlayer,game:GetService("UserInputService"),game:GetService("RunService"),workspace.CurrentCamera
local RS=game:GetService("ReplicatedStorage")
local function rStr()local t={}for i=1,math.random(5,10)do t[i]=string.char(math.random(97,122))end return table.concat(t)end
local function sWait()local t=tick()+math.random(30,80)/100 while tick()<t do end end

local G=Instance.new("ScreenGui",gethui and gethui() or L:WaitForChild("PlayerGui"))
G.Name=rStr() G.ResetOnSpawn=false
local F=Instance.new("Frame",G)F.Size=UDim2.fromOffset(170,230)F.Position=UDim2.new(0,10,0,50)F.BackgroundColor3=Color3.fromRGB(16,16,18)F.BorderSizePixel=0 F.Active=true F.Draggable=true Instance.new("UICorner",F).CornerRadius=UDim.new(0,5)
local hideBtn=Instance.new("TextButton",F)hideBtn.Size=UDim2.new(0,18,0,18)hideBtn.Position=UDim2.new(1,-20,0,2)hideBtn.BackgroundColor3=Color3.fromRGB(40,40,45)hideBtn.Text="-"hideBtn.TextColor3=Color3.fromRGB(200,200,205)hideBtn.Font=Enum.Font.Code hideBtn.TextSize=12 hideBtn.BorderSizePixel=0 Instance.new("UICorner",hideBtn).CornerRadius=UDim.new(0,3)

local S=Instance.new("ScrollingFrame",F)S.Size=UDim2.new(1,-6,1,-6)S.Position=UDim2.new(0,3,0,3)S.BackgroundTransparency=1 S.BorderSizePixel=0 S.ScrollBarThickness=2 local LL=Instance.new("UIListLayout",S)LL.Padding=UDim.new(0,2)

local function B(t,c)local b=Instance.new("TextButton",S)b.Size=UDim2.new(1,0,0,20)b.BackgroundColor3=Color3.fromRGB(28,28,32)b.BorderSizePixel=0 b.Text=t b.TextColor3=Color3.fromRGB(210,210,215)b.Font=Enum.Font.Code b.TextSize=10 b.MouseButton1Click:Connect(c)return b end
local function T(t,cb)local b=Instance.new("TextButton",S)b.Size=UDim2.new(1,0,0,20)b.BackgroundColor3=Color3.fromRGB(28,28,32)b.BorderSizePixel=0 b.Text=t..": OFF"b.TextColor3=Color3.fromRGB(210,210,215)b.Font=Enum.Font.Code b.TextSize=10 local on=false b.MouseButton1Click:Connect(function()on=not on b.Text=t..": "..(on and "ON" or "OFF")cb(on)end)return b end

local hbOn,eOn,ultOn=false,false,false
local espTable={}
local origSize=nil
local ultConn=nil

local function getBall()
	for _,v in ipairs(workspace:GetDescendants())do
		if v:IsA("BasePart")and (v.Name:lower():find("ball")or v.Name:lower():find("volley"))then return v end
	end
end

local function setHitbox(v)
	hbOn=v
	local ball=getBall()
	if not ball then return end
	if v then
		if not origSize then origSize=ball.Size end
		ball.Size=origSize*Vector3.new(3,3,3)
	elseif origSize then
		ball.Size=origSize
	end
end
R.Heartbeat:Connect(function()
	if hbOn then local ball=getBall()if ball and origSize then ball.Size=origSize*Vector3.new(3,3,3)end end
end)

local function tE(v)
	eOn=v
	for _,p in ipairs(P:GetPlayers())do
		if p~=L then
			if v and not espTable[p] then
				local h=Instance.new("Highlight")
				h.FillColor=Color3.fromRGB(255,50,50)h.OutlineColor=Color3.fromRGB(255,255,255)h.FillTransparency=0.6
				h.Adornee=p.Character or p.CharacterAdded:Wait()
				h.Name=rStr() h.Parent=G espTable[p]=h
			elseif not v and espTable[p]then
				espTable[p]:Destroy()espTable[p]=nil
			end
		end
	end
end
P.PlayerAdded:Connect(function(p)if eOn and p~=L then tE(true)end end)

local function safeFire(obj,method,...)
	if not obj then return end
	local ok=pcall(function() obj[method](obj,...) end)
	if not ok then pcall(function() obj[method](obj,L,...) end) end
end

local function addYen()
	sWait()
	local ok,svc=pcall(function() return RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.RewardService end)
	if ok and svc then
		for _,v in ipairs(svc:GetChildren())do
			if v:IsA("RemoteEvent")then safeFire(v,"FireServer")end
			if v:IsA("RemoteFunction")then safeFire(v,"InvokeServer")end
		end
	end
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteFunction")or v:IsA("RemoteEvent"))and (v.Name:lower():find("reward")or v.Name:lower():find("yen")or v.Name:lower():find("money"))then
			if v:IsA("RemoteFunction")then safeFire(v,"InvokeServer")else safeFire(v,"FireServer")end
		end
	end
end

local function addExp()
	sWait()
	for _,v in ipairs(RS:GetDescendants())do
		if (v:IsA("RemoteEvent")or v:IsA("RemoteFunction"))and (v.Name:lower():find("exp")or v.Name:lower():find("level")or v.Name:lower():find("xp"))then
			if v:IsA("RemoteEvent")then safeFire(v,"FireServer",60)else safeFire(v,"InvokeServer",60)end
		end
	end
end

local function setUlt(v)
	ultOn=v
	if v then
		ultConn=R.Heartbeat:Connect(function()
			for _,v2 in ipairs(L:GetDescendants())do
				if (v2:IsA("NumberValue")or v2:IsA("IntValue"))and (v2.Name:lower():find("ult")or v2.Name:lower():find("ability")or v2.Name:lower():find("charge")or v2.Name:lower():find("gauge"))then
					pcall(function()v2.Value=100 end)
				end
			end
		end)
	else
		if ultConn then ultConn:Disconnect()end
	end
end

T("Hitbox", setHitbox)
T("ESP", tE)
T("Ultimate", setUlt)
B("Yen +", function() task.spawn(addYen) end)
B("Exp +60", function() task.spawn(addExp) end)

local hidden=false
hideBtn.MouseButton1Click:Connect(function()
	hidden=not hidden
	S.Visible=not hidden
	F.Size=hidden and UDim2.fromOffset(170,22)or UDim2.fromOffset(170,230)
	hideBtn.Text=hidden and "+" or "-"
end)

U.InputBegan:Connect(function(k,g)
	if not g and k.KeyCode==Enum.KeyCode.RightShift then F.Visible=not F.Visible end
end)
