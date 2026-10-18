local P,L,U,R,C=game:GetService("Players"),game:GetService("Players").LocalPlayer,game:GetService("UserInputService"),game:GetService("RunService"),workspace.CurrentCamera
local G=Instance.new("ScreenGui",gethui and gethui() or L:WaitForChild("PlayerGui"))G.Name="\0"G.ResetOnSpawn=false
local F=Instance.new("Frame",G)F.Size=UDim2.fromOffset(150,190)F.Position=UDim2.new(0,10,0,50)F.BackgroundColor3=Color3.fromRGB(16,16,18)F.BorderSizePixel=0 F.Active=true F.Draggable=true Instance.new("UICorner",F).CornerRadius=UDim.new(0,5)
local S=Instance.new("ScrollingFrame",F)S.Size=UDim2.new(1,-4,1,-4)S.Position=UDim2.new(0,2,0,2)S.BackgroundTransparency=1 S.BorderSizePixel=0 S.ScrollBarThickness=0 local LL=Instance.new("UIListLayout",S)LL.Padding=UDim.new(0,2)
local function B(t,c)local b=Instance.new("TextButton",S)b.Size=UDim2.new(1,0,0,18)b.BackgroundColor3=Color3.fromRGB(28,28,32)b.BorderSizePixel=0 b.Text=t b.TextColor3=Color3.fromRGB(210,210,215)b.Font=Enum.Font.Code b.TextSize=10 b.MouseButton1Click:Connect(c)end

local fly,fs,nc,spd,eOn=false,60,false,16,false
local bv, bg, fc

-- Speed Dasar
R.Heartbeat:Connect(function()
	local h=L.Character and L.Character:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed = spd end
end)

-- Noclip Dasar
R.Stepped:Connect(function()
	if nc and L.Character then 
		for _,v in ipairs(L.Character:GetDescendants())do 
			if v:IsA("BasePart")and v.CanCollide then v.CanCollide=false end 
		end 
	end 
end)

-- ESP
local E={}
local function tE(v)
	eOn=v 
	for _,p in ipairs(P:GetPlayers())do 
		if p~=L then 
			if v then 
				local h=Instance.new("Highlight")
				h.FillColor=Color3.fromRGB(255,50,50)h.OutlineColor=Color3.new(1,1,1)h.FillTransparency=0.6 
				h.Adornee=p.Character or p.CharacterAdded:Wait()
				h.Parent=G E[p]=h 
				p.CharacterAdded:Connect(function(c)if E[p]then E[p].Adornee=c end end)
			elseif E[p]then 
				E[p]:Destroy()E[p]=nil 
			end 
		end 
	end 
end
P.PlayerAdded:Connect(function(p) if eOn and p ~= L then tE(true) end end)

-- Fly (BodyVelocity + BodyGyro)
B("fly",function()
	fly=not fly
	local hrp=L.Character and L.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if fly then
		bv=Instance.new("BodyVelocity",hrp) bv.MaxForce=Vector3.new(1e5,1e5,1e5) bv.Velocity=Vector3.zero
		bg=Instance.new("BodyGyro",hrp) bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.P=1e3
		fc=R.RenderStepped:Connect(function()
			if not hrp.Parent then return end
			bg.CFrame=C.CFrame
			local d=Vector3.zero
			if U:IsKeyDown(Enum.KeyCode.W)then d+=C.CFrame.LookVector end
			if U:IsKeyDown(Enum.KeyCode.S)then d-=C.CFrame.LookVector end
			if U:IsKeyDown(Enum.KeyCode.A)then d-=C.CFrame.RightVector end
			if U:IsKeyDown(Enum.KeyCode.D)then d+=C.CFrame.RightVector end
			if U:IsKeyDown(Enum.KeyCode.Space)then d+=Vector3.yAxis end
			if U:IsKeyDown(Enum.KeyCode.LeftControl)then d-=Vector3.yAxis end
			bv.Velocity = d.Unit * fs * (d.Magnitude > 0 and 1 or 0)
		end)
	else
		if fc then fc:Disconnect() end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

B("fly+",function()fs=math.min(fs+20,400)end)
B("fly-",function()fs=math.max(fs-20,20)end)
B("noclip",function()nc=not nc end)
B("esp",function()tE(not eOn)end)
B("spd16",function()spd=16 end)
B("spd60",function()spd=60 end)
B("spd120",function()spd=120 end)
B("spd250",function()spd=250 end)
B("$+1M",function()local s=L:FindFirstChild("leaderstats")if s then for _,v in ipairs(s:GetChildren())do pcall(function()v.Value=v.Value+1e6 end)end end end)
B("sword",function()for _,p in ipairs(P:GetPlayers())do if p~=L and p.Character then local t=Instance.new("Tool",p.Character)t.Name="Sword"t.RequiresHandle=false t.CanBeDropped=false end end end)

U.InputBegan:Connect(function(k,g)if not g and k.KeyCode==Enum.KeyCode.RightShift then F.Visible=not F.Visible end end)
