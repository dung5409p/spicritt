-- ================================================================
--         BLOX FRUITS ULTIMATE — FLUENT UI EDITION
--         Tác giả: TBoy Roblox | Version: 5.0
--         Executor: Synapse X / KRNL / Fluxus / Delta / Xeno
-- ================================================================

if game.PlaceId ~= 2753915549 then
    warn("[BF] Chỉ dành cho Blox Fruits!")
    return
end

-- ================================================================
-- SERVICES
-- ================================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local StarterGui         = game:GetService("StarterGui")
local HttpService        = game:GetService("HttpService")

local LP  = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

-- ================================================================
-- UTILS
-- ================================================================
local function try(fn) return pcall(fn) end

local function getChar()  return LP.Character end
local function getRoot()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive()  local h=getHum(); return h and h.Health > 0 end

local function getLevel()
    local ok, v = try(function()
        return LP.leaderstats.Level.Value
    end)
    return ok and v or 0
end

local function getBeli()
    local ok, v = try(function()
        return LP.leaderstats.Beli.Value
    end)
    return ok and v or 0
end

local function getBounty()
    local ok, v = try(function()
        return LP.leaderstats.Bounty.Value
    end)
    return ok and v or 0
end

local function formatNum(n)
    local s = tostring(math.floor(n))
    local r, c = "", 0
    for i = #s, 1, -1 do
        if c > 0 and c % 3 == 0 then r = "," .. r end
        r = s:sub(i,i) .. r
        c = c + 1
    end
    return r
end

local function tpTo(pos)
    local r = getRoot()
    if r then r.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end
end

local function notify(title, text, duration)
    try(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text  = tostring(text),
            Duration = duration or 3,
        })
    end)
end

local function distTo(pos)
    local r = getRoot(); if not r then return math.huge end
    return (r.Position - pos).Magnitude
end

-- ================================================================
-- CONFIG
-- ================================================================
local CFG = {
    -- FARM
    AutoFarm=false, KillAura=false, AuraRange=20, MobTarget="",
    AutoQuest=false, SeaBeast=false, MasteryFarm=false, MasteryType="Fruit",
    ChestFarm=false, ChestRange=300, AutoRespawn=true, FarmDelay=0.1,
    AutoSell=false,
    -- BOSS
    AutoBoss=false, BossName="Yeti", BossLoop=true,
    -- RAID
    AutoRaid=false, RaidIsland="Flower",
    -- DUNGEON
    AutoDungeon=false, DungeonFloor=1,
    -- ELITE
    EliteHunter=false, EliteTarget="",
    -- FRUIT
    FruitESP=false, AutoSnipe=false, SnipeDelay=2,
    ESPMaxDist=5000, FruitNotify=false,
    AutoEat=false, AutoStore=false,
    AutoCollect=false, CollectRange=10,
    -- PLAYER ESP
    PlayerESP=false, ShowName=true, ShowHP=true,
    ShowDist=true, ShowTeam=true, ShowBounty=false,
    -- MOVEMENT
    Speed=16, Fly=false, FlySpeed=80,
    NoClip=false, InfiniteJump=false, JumpPower=50,
    AutoDodge=false, DodgeRange=15,
    -- PLAYER
    GodMode=false, AutoStat=false, StatType="Melee",
    -- MISC
    AntiAFK=true, ShowHUD=true,
}

local function saveConfig()
    if not writefile or not makefolder or not isfolder then return end
    try(function()
        if not isfolder("BFScript") then makefolder("BFScript") end
        writefile("BFScript/cfg_v5.json", HttpService:JSONEncode(CFG))
    end)
end

local function loadConfig()
    if not readfile or not isfile then return end
    try(function()
        if isfile("BFScript/cfg_v5.json") then
            local d = HttpService:JSONDecode(readfile("BFScript/cfg_v5.json"))
            for k,v in pairs(d) do if CFG[k]~=nil then CFG[k]=v end end
        end
    end)
end
loadConfig()

task.spawn(function()
    while true do task.wait(30); saveConfig() end
end)

-- ================================================================
-- DATABASES
-- ================================================================
local Islands = {
    -- SEA 1
    ["Starter Island"]    = {pos=Vector3.new(977,127,1440),  sea=1,minLvl=0},
    ["Marine Fortress"]   = {pos=Vector3.new(-1600,127,-120),sea=1,minLvl=30},
    ["Desert"]            = {pos=Vector3.new(929,127,-1600), sea=1,minLvl=60},
    ["Frozen Village"]    = {pos=Vector3.new(1025,127,-3000),sea=1,minLvl=90},
    ["Marine HQ"]         = {pos=Vector3.new(-4900,127,1090),sea=1,minLvl=120},
    ["Skylands 1"]        = {pos=Vector3.new(-5200,2050,-1000),sea=1,minLvl=150},
    ["Colosseum"]         = {pos=Vector3.new(-1350,127,-3800),sea=1,minLvl=100},
    ["Magma Village"]     = {pos=Vector3.new(3380,127,3310), sea=1,minLvl=300},
    ["Underwater City"]   = {pos=Vector3.new(61484,-4500,1819),sea=1,minLvl=375},
    ["Fountain City"]     = {pos=Vector3.new(-1147,127,-4553),sea=1,minLvl=625},
    -- SEA 2
    ["Kingdom of Rose"]   = {pos=Vector3.new(-270,15,-2700), sea=2,minLvl=700},
    ["Green Zone"]        = {pos=Vector3.new(4310,35,-3600), sea=2,minLvl=875},
    ["Graveyard"]         = {pos=Vector3.new(3700,10,-3650), sea=2,minLvl=950},
    ["Snow Mountain"]     = {pos=Vector3.new(1015,265,-3000),sea=2,minLvl=1000},
    ["Hot & Cold"]        = {pos=Vector3.new(-2955,115,-4145),sea=2,minLvl=1100},
    ["Cursed Ship"]       = {pos=Vector3.new(-4900,30,-4880),sea=2,minLvl=1250},
    ["Ice Castle"]        = {pos=Vector3.new(-5200,130,-5300),sea=2,minLvl=1400},
    ["Forgotten Island"]  = {pos=Vector3.new(55000,30,55000),sea=2,minLvl=1475},
    ["Upper Skylands"]    = {pos=Vector3.new(-5000,4050,-1000),sea=2,minLvl=1500},
    -- SEA 3
    ["Port Town"]         = {pos=Vector3.new(-2350,15,-2300),sea=3,minLvl=1500},
    ["Hydra Island"]      = {pos=Vector3.new(4750,35,-4750), sea=3,minLvl=1575},
    ["Great Tree"]        = {pos=Vector3.new(700,900,4800),  sea=3,minLvl=1700},
    ["Floating Turtle"]   = {pos=Vector3.new(-9000,300,3600),sea=3,minLvl=1775},
    ["Sea of Treats"]     = {pos=Vector3.new(-13000,15,1100),sea=3,minLvl=1875},
    ["Icy Grid"]          = {pos=Vector3.new(-9900,85,1300), sea=3,minLvl=1975},
    ["Mansion"]           = {pos=Vector3.new(-11500,15,1050),sea=3,minLvl=2000},
    ["Castle on the Sea"] = {pos=Vector3.new(5980,449,5925), sea=3,minLvl=2050},
    ["Flame Ship"]        = {pos=Vector3.new(-2000,20,-6000),sea=3,minLvl=2100},
    ["Haunted Castle"]    = {pos=Vector3.new(-3500,800,-4000),sea=3,minLvl=2150},
    ["Tiki Outpost"]      = {pos=Vector3.new(-13800,10,-100),sea=3,minLvl=2375},
}

local Bosses = {
    -- Sea 1
    ["Gorilla King"]   = {pos=Vector3.new(1269,127,-577),  sea=1},
    ["Bobby"]          = {pos=Vector3.new(-698,127,-1505), sea=1},
    ["Yeti"]           = {pos=Vector3.new(1143,352,-3115), sea=1},
    ["Mob Leader"]     = {pos=Vector3.new(342,127,-1614),  sea=1},
    ["Vice Admiral"]   = {pos=Vector3.new(-4939,127,994),  sea=1},
    ["Warden"]         = {pos=Vector3.new(61529,-4496,1830),sea=1},
    ["Chief Warden"]   = {pos=Vector3.new(61500,-4496,1850),sea=1},
    ["Swan"]           = {pos=Vector3.new(-4847,127,1078), sea=1},
    ["Smoke Admiral"]  = {pos=Vector3.new(-4847,127,1078), sea=1},
    ["Wysper"]         = {pos=Vector3.new(-5179,2084,-954),sea=1},
    ["Thunder God"]    = {pos=Vector3.new(-5179,2084,-954),sea=1},
    ["Shank"]          = {pos=Vector3.new(-1314,127,-4606),sea=1},
    ["Saber Expert"]   = {pos=Vector3.new(-1350,127,-3800),sea=1},
    ["Magma Admiral"]  = {pos=Vector3.new(3380,127,3310),  sea=1},
    -- Sea 2
    ["Diamond"]        = {pos=Vector3.new(1003,127,-2780), sea=2},
    ["Jeremy"]         = {pos=Vector3.new(1559,270,-3115), sea=2},
    ["Fajita"]         = {pos=Vector3.new(-3269,115,-4132),sea=2},
    ["Don Swan"]       = {pos=Vector3.new(-4779,35,-4869), sea=2},
    ["Pilot Shark"]    = {pos=Vector3.new(-4900,30,-4880), sea=2},
    ["Ice Admiral"]    = {pos=Vector3.new(-5200,130,-5300),sea=2},
    -- Sea 3
    ["Longma"]         = {pos=Vector3.new(5928,449,5925),  sea=3},
    ["Cake Queen"]     = {pos=Vector3.new(-12934,15,1046), sea=3},
    ["rip_indra"]      = {pos=Vector3.new(-1500,380,-1500),sea=3},
    ["Kilo Admiral"]   = {pos=Vector3.new(-2319,8,-2273),  sea=3},
    ["Terrorshark"]    = {pos=Vector3.new(-9062,300,3616), sea=3},
    ["Darkbeard"]      = {pos=Vector3.new(-1350,127,-3800),sea=3},
    ["Dough King"]     = {pos=Vector3.new(-12000,15,1500), sea=3},
    ["Stone"]          = {pos=Vector3.new(-9000,300,3600), sea=3},
    ["Soul Reaper"]    = {pos=Vector3.new(-11500,15,1050), sea=3},
    ["Island Empress"] = {pos=Vector3.new(4750,35,-4750),  sea=3},
    ["Tide Keeper"]    = {pos=Vector3.new(-9900,85,1300),  sea=3},
    ["Cursed Captain"] = {pos=Vector3.new(-4900,30,-4880), sea=3},
}

local RaidIslands = {
    Flower=Vector3.new(-1314,127,-4606),Magma=Vector3.new(3380,127,3310),
    Ice=Vector3.new(1025,127,-3000),Sand=Vector3.new(929,127,-1600),
    Dark=Vector3.new(-4900,127,1090),Light=Vector3.new(-5179,2084,-954),
    Rubber=Vector3.new(-1350,127,-3800),Barrier=Vector3.new(-270,15,-2700),
    Phoenix=Vector3.new(4750,35,-4750),Gravity=Vector3.new(-9000,300,3600),
    Quake=Vector3.new(-2955,115,-4145),Dough=Vector3.new(-12934,15,1046),
    Shadow=Vector3.new(-11500,15,1050),Venom=Vector3.new(-9062,300,3616),
    Control=Vector3.new(5928,449,5925),Soul=Vector3.new(-2319,8,-2273),
    Spirit=Vector3.new(-13000,15,1100),Dragon=Vector3.new(-3500,800,-4000),
}

local RareFruits = {
    Dragon=true,Leopard=true,Kitsune=true,Dough=true,Soul=true,
    Venom=true,Control=true,Spirit=true,Mammoth=true,
    ["T-Rex"]=true,Gravity=true,Phoenix=true,Rumble=true,Blizzard=true,
}

-- Boss list for dropdowns
local BossListSea1 = {"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Swan","Smoke Admiral","Wysper","Thunder God","Shank","Saber Expert","Magma Admiral"}
local BossListSea2 = {"Diamond","Jeremy","Fajita","Don Swan","Pilot Shark","Ice Admiral"}
local BossListSea3 = {"Longma","Cake Queen","rip_indra","Kilo Admiral","Terrorshark","Darkbeard","Dough King","Stone","Soul Reaper","Island Empress","Tide Keeper","Cursed Captain"}
local AllBosses = {}
for _,v in ipairs(BossListSea1) do table.insert(AllBosses,v) end
for _,v in ipairs(BossListSea2) do table.insert(AllBosses,v) end
for _,v in ipairs(BossListSea3) do table.insert(AllBosses,v) end

local Sea1Islands = {"Starter Island","Marine Fortress","Desert","Frozen Village","Marine HQ","Skylands 1","Colosseum","Magma Village","Underwater City","Fountain City"}
local Sea2Islands = {"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain","Hot & Cold","Cursed Ship","Ice Castle","Forgotten Island","Upper Skylands"}
local Sea3Islands = {"Port Town","Hydra Island","Great Tree","Floating Turtle","Sea of Treats","Icy Grid","Mansion","Castle on the Sea","Flame Ship","Haunted Castle","Tiki Outpost"}

-- ================================================================
-- ANTI-AFK
-- ================================================================
if CFG.AntiAFK then
    try(function()
        local VU = game:GetService("VirtualUser")
        LP.Idled:Connect(function()
            VU:Button2Down(Vector2.zero, Cam.CFrame)
            task.wait(0.1)
            VU:Button2Up(Vector2.zero, Cam.CFrame)
        end)
    end)
end

-- ================================================================
-- FLY
-- ================================================================
local flyConn, flyBV, flyBG
local function enableFly()
    if flyConn then return end
    local root = getRoot(); if not root then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e6,1e6,1e6)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent   = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e6,1e6,1e6)
    flyBG.P = 1e4
    flyBG.Parent = root
    flyConn = RunService.Heartbeat:Connect(function()
        if not CFG.Fly then
            if flyBV and flyBV.Parent then flyBV:Destroy() end
            if flyBG and flyBG.Parent then flyBG:Destroy() end
            flyConn:Disconnect(); flyConn=nil; return
        end
        local r = getRoot(); if not r then return end
        local d = Vector3.zero; local cf = Cam.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
        local spd = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and CFG.FlySpeed*2 or CFG.FlySpeed
        flyBV.Velocity = d.Magnitude>0 and d.Unit*spd or Vector3.zero
        flyBG.CFrame   = Cam.CFrame
    end)
end

-- ================================================================
-- NO-CLIP
-- ================================================================
local ncConn
local function enableNoclip()
    if ncConn then return end
    ncConn = RunService.Stepped:Connect(function()
        if not CFG.NoClip then ncConn:Disconnect(); ncConn=nil; return end
        local c = getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end)
end

-- ================================================================
-- INFINITE JUMP
-- ================================================================
UserInputService.JumpRequest:Connect(function()
    if CFG.InfiniteJump and isAlive() then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ================================================================
-- GOD MODE
-- ================================================================
local godConn
local function enableGodMode()
    if godConn then return end
    godConn = RunService.Heartbeat:Connect(function()
        if not CFG.GodMode then godConn:Disconnect(); godConn=nil; return end
        local h = getHum(); if h then h.Health=h.MaxHealth end
    end)
end

-- ================================================================
-- AUTO DODGE
-- ================================================================
local dodgeConn
local function enableAutoDodge()
    if dodgeConn then return end
    dodgeConn = RunService.Heartbeat:Connect(function()
        if not CFG.AutoDodge then dodgeConn:Disconnect(); dodgeConn=nil; return end
        if not isAlive() then return end
        local root = getRoot(); if not root then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr==LP then continue end
            local pc = plr.Character
            local prp = pc and pc:FindFirstChild("HumanoidRootPart")
            if prp then
                local d = (prp.Position-root.Position).Magnitude
                if d<=CFG.DodgeRange then
                    local dir = (root.Position-prp.Position).Unit
                    root.CFrame = root.CFrame + dir*20
                end
            end
        end
    end)
end

-- ================================================================
-- SPEED + JUMP
-- ================================================================
RunService.Heartbeat:Connect(function()
    if not isAlive() then return end
    local h = getHum()
    if h then
        if h.WalkSpeed ~= CFG.Speed    then h.WalkSpeed=CFG.Speed end
        if h.JumpPower ~= CFG.JumpPower then h.JumpPower=CFG.JumpPower end
    end
end)

-- ================================================================
-- AUTO STAT
-- ================================================================
local statMap={Melee="strength",Defense="defense",Sword="sword",Gun="gun",Fruit="blox_fruit"}
RunService.Heartbeat:Connect(function()
    if not CFG.AutoStat then return end
    if math.random(1,500)~=1 then return end
    try(function()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("AddStat")
        if rem then rem:FireServer(statMap[CFG.StatType] or "strength") end
    end)
end)

-- ================================================================
-- MOB FINDER + ATTACKER
-- ================================================================
local MOB_FOLDERS = {"Enemies","Mobs","_Mobs","NPCs","Map"}

local function getNearestMob(targetName)
    local root=getRoot(); if not root then return nil,math.huge end
    local best,bestD=nil,math.huge
    for _,fn in ipairs(MOB_FOLDERS) do
        local f=Workspace:FindFirstChild(fn,true)
        if f then
            for _,mob in ipairs(f:GetDescendants()) do
                if mob:IsA("Model") then
                    local h=mob:FindFirstChildOfClass("Humanoid")
                    local mrp=mob:FindFirstChild("HumanoidRootPart")
                    if h and mrp and h.Health>0 then
                        local nm=targetName or CFG.MobTarget
                        local match=(nm=="" or mob.Name:lower():find(nm:lower()))
                        if match then
                            local d=(mrp.Position-root.Position).Magnitude
                            if d<bestD then best=mob;bestD=d end
                        end
                    end
                end
            end
        end
    end
    return best,bestD
end

local function attackMob(mob)
    if not mob or not mob.Parent then return end
    local mrp=mob:FindFirstChild("HumanoidRootPart"); if not mrp then return end
    try(function()
        local c=getChar()
        local hit=c and c:FindFirstChild("HumanoidRootPart")
        if hit and firetouchinterest then
            firetouchinterest(hit,mrp,0)
            task.wait(0.05)
            firetouchinterest(hit,mrp,1)
        end
    end)
end

-- ================================================================
-- AUTO FARM
-- ================================================================
local function doAutoFarm()
    if not CFG.AutoFarm or not isAlive() then return end
    local mob,dist=getNearestMob()
    if not mob then return end
    local mrp=mob:FindFirstChild("HumanoidRootPart"); if not mrp then return end
    if dist>CFG.AuraRange then tpTo(mrp.Position) end
    if CFG.KillAura and dist<=CFG.AuraRange then attackMob(mob) end
end

-- ================================================================
-- SEA BEAST
-- ================================================================
local function doSeaBeast()
    if not CFG.SeaBeast or not isAlive() then return end
    local root=getRoot(); if not root then return end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        local n=obj.Name:lower()
        if n:find("seabeast") or n:find("sea beast") then
            if obj:IsA("Model") then
                local h=obj:FindFirstChildOfClass("Humanoid")
                local mrp=obj:FindFirstChild("HumanoidRootPart")
                if h and mrp and h.Health>0 then
                    local d=(mrp.Position-root.Position).Magnitude
                    if d>20 then tpTo(mrp.Position) end
                    attackMob(obj); return
                end
            end
        end
    end
end

-- ================================================================
-- AUTO BOSS
-- ================================================================
local function doAutoBoss()
    if not CFG.AutoBoss or not isAlive() then return end
    if CFG.BossName=="" then return end
    local bd=Bosses[CFG.BossName]; if not bd then return end
    local d=distTo(bd.pos)
    if d>50 then tpTo(bd.pos); return end
    local mob,md=getNearestMob(CFG.BossName)
    if mob then
        local mrp=mob:FindFirstChild("HumanoidRootPart")
        if mrp then
            if md>CFG.AuraRange then tpTo(mrp.Position)
            else attackMob(mob) end
        end
    end
end

-- ================================================================
-- AUTO RAID
-- ================================================================
local function doAutoRaid()
    if not CFG.AutoRaid or not isAlive() then return end
    local pos=RaidIslands[CFG.RaidIsland]; if not pos then return end
    local root=getRoot(); if not root then return end
    if distTo(pos)>80 then tpTo(pos); return end
    local mob,d=getNearestMob()
    if mob then
        local mrp=mob:FindFirstChild("HumanoidRootPart")
        if mrp then
            if d>CFG.AuraRange then tpTo(mrp.Position)
            else attackMob(mob) end
        end
    end
end

-- ================================================================
-- MASTERY FARM
-- ================================================================
local mastIdx=1
local mastMoves={Fruit={Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C,Enum.KeyCode.V},Sword={Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C},Gun={Enum.KeyCode.Z,Enum.KeyCode.X}}
local function doMasteryFarm()
    if not CFG.MasteryFarm or not isAlive() then return end
    local mob,dist=getNearestMob()
    if not mob then return end
    local mrp=mob:FindFirstChild("HumanoidRootPart"); if not mrp then return end
    if dist>15 then tpTo(mrp.Position); return end
    local moves=mastMoves[CFG.MasteryType] or mastMoves.Fruit
    try(function()
        local vim=game:GetService("VirtualInputManager")
        if vim then
            vim:SendKeyEvent(true,moves[mastIdx],false,game)
            task.wait(0.1)
            vim:SendKeyEvent(false,moves[mastIdx],false,game)
        end
    end)
    mastIdx=(mastIdx%#moves)+1
    attackMob(mob)
end

-- ================================================================
-- DUNGEON
-- ================================================================
local Dungeons={{floor=1,pos=Vector3.new(-1350,127,-3800)},{floor=2,pos=Vector3.new(-4900,127,1090)},{floor=3,pos=Vector3.new(-5200,2050,-1000)}}
local function doDungeon()
    if not CFG.AutoDungeon or not isAlive() then return end
    local data=Dungeons[math.clamp(CFG.DungeonFloor,1,#Dungeons)]
    if not data then return end
    if distTo(data.pos)>60 then tpTo(data.pos); return end
    local mob,d=getNearestMob()
    if mob then
        local mrp=mob:FindFirstChild("HumanoidRootPart")
        if mrp then
            if d>CFG.AuraRange then tpTo(mrp.Position)
            else attackMob(mob) end
        end
    end
end

-- ================================================================
-- ELITE HUNTER
-- ================================================================
local function doEliteHunter()
    if not CFG.EliteHunter or not isAlive() then return end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n=obj.Name:lower()
            local isElite=n:find("elite") or n:find("legendary")
            local match=CFG.EliteTarget=="" or n:find(CFG.EliteTarget:lower())
            if isElite and match then
                local h=obj:FindFirstChildOfClass("Humanoid")
                local mrp=obj:FindFirstChild("HumanoidRootPart")
                if h and mrp and h.Health>0 then
                    local d=distTo(mrp.Position)
                    if d>CFG.AuraRange then tpTo(mrp.Position)
                    else attackMob(obj) end
                    return
                end
            end
        end
    end
end

-- ================================================================
-- AUTO QUEST
-- ================================================================
local lastQuestT=0
local function doAutoQuest()
    if not CFG.AutoQuest then return end
    local now=os.clock()
    if now-lastQuestT<5 then return end
    lastQuestT=now
    try(function()
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local p=obj.Parent
                if p then
                    local n=p.Name:lower()
                    if n:find("quest") or n:find("trainer") then
                        try(function() fireproximityprompt(obj) end)
                    end
                end
            end
        end
    end)
end

-- ================================================================
-- CHEST FARM
-- ================================================================
local chestCD={}
local function doChestFarm()
    if not CFG.ChestFarm or not isAlive() then return end
    local root=getRoot(); if not root then return end
    local now=os.clock()
    for _,obj in ipairs(Workspace:GetDescendants()) do
        local n=obj.Name:lower()
        if (n:find("chest") or n:find("box") or n:find("crate")) and not chestCD[obj] then
            local pos
            try(function()
                pos=obj:IsA("Model") and obj:GetModelCFrame().Position or (obj:IsA("BasePart") and obj.Position)
            end)
            if pos and (pos-root.Position).Magnitude<=CFG.ChestRange then
                chestCD[obj]=now+30
                tpTo(pos); task.wait(0.2)
                local pr=obj:FindFirstChildOfClass("ProximityPrompt",true)
                if pr then try(function() fireproximityprompt(pr) end) end
                return
            end
        end
        if chestCD[obj] and chestCD[obj]<now then chestCD[obj]=nil end
    end
end

-- ================================================================
-- FRUIT ESP + SNIPER
-- ================================================================
local fruitSniped={};local fruitNotified={}

local function makeFruitESP(obj)
    if obj:FindFirstChild("BF_FESP") then return end
    local bb=Instance.new("BillboardGui",obj)
    bb.Name="BF_FESP";bb.AlwaysOnTop=true
    bb.Size=UDim2.new(0,160,0,60);bb.StudsOffset=Vector3.new(0,6,0)
    local bg=Instance.new("Frame",bb)
    bg.Size=UDim2.new(1,0,1,0);bg.BackgroundColor3=Color3.new(0,0,0)
    bg.BackgroundTransparency=0.5;bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
    local isRare=RareFruits[obj.Name]
    local nl=Instance.new("TextLabel",bg)
    nl.Name="N";nl.Size=UDim2.new(1,-4,0.55,0);nl.Position=UDim2.new(0,2,0,2)
    nl.BackgroundTransparency=1;nl.Font=Enum.Font.GothamBold;nl.TextSize=13
    nl.TextColor3=isRare and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,215,0)
    nl.TextStrokeTransparency=0.4;nl.Text=obj.Name..(isRare and " ⭐" or "")
    local dl=Instance.new("TextLabel",bg)
    dl.Name="D";dl.Size=UDim2.new(1,-4,0.38,0);dl.Position=UDim2.new(0,2,0.57,0)
    dl.BackgroundTransparency=1;dl.Font=Enum.Font.Gotham;dl.TextSize=11
    dl.TextColor3=Color3.new(1,1,1);dl.TextStrokeTransparency=0.4
end

local function updateFruitESP()
    if not CFG.FruitESP and not CFG.AutoSnipe and not CFG.FruitNotify then return end
    local root=getRoot(); if not root then return end
    for _,fn in ipairs({"Drops","FruitDrops","_Fruits","Fruits"}) do
        local folder=Workspace:FindFirstChild(fn)
        if not folder then continue end
        for _,obj in ipairs(folder:GetChildren()) do
            local pos
            try(function()
                pos=obj:IsA("Model") and obj:GetModelCFrame().Position or (obj:IsA("BasePart") and obj.Position)
            end)
            if not pos then continue end
            local dist=math.floor((pos-root.Position).Magnitude)
            local key=tostring(obj)..obj.Name
            if CFG.FruitNotify and RareFruits[obj.Name] and not fruitNotified[key] then
                fruitNotified[key]=true
                notify("🍎 QUẢ HIẾM!",obj.Name.." | "..dist.." studs",8)
            end
            if CFG.FruitESP then
                makeFruitESP(obj)
                local bb=obj:FindFirstChild("BF_FESP")
                if bb then
                    local fr=bb:FindFirstChildOfClass("Frame")
                    local dl=fr and fr:FindFirstChild("D")
                    if dl then dl.Text=dist.." studs" end
                    bb.Enabled=dist<=CFG.ESPMaxDist
                end
            end
            if CFG.AutoSnipe and dist<=CFG.ESPMaxDist and not fruitSniped[key] then
                fruitSniped[key]=true
                task.delay(CFG.SnipeDelay/10,function()
                    if obj and obj.Parent then
                        local p2
                        try(function()
                            p2=obj:IsA("Model") and obj:GetModelCFrame().Position or (obj:IsA("BasePart") and obj.Position)
                        end)
                        if p2 then
                            tpTo(p2)
                            notify("🎯 Snipe",obj.Name)
                            local pr=obj:FindFirstChildOfClass("ProximityPrompt",true)
                            if pr then try(function() fireproximityprompt(pr) end) end
                        end
                    end
                end)
            end
            if CFG.AutoCollect and dist<=CFG.CollectRange then
                tpTo(pos)
                local pr=obj:FindFirstChildOfClass("ProximityPrompt",true)
                if pr then try(function() fireproximityprompt(pr) end) end
            end
        end
    end
    if math.random(1,200)==1 then fruitSniped={};fruitNotified={} end
end

-- ================================================================
-- PLAYER ESP
-- ================================================================
local function makePlayerESP(player)
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    if head:FindFirstChild("BF_PESP") then return end
    local bb=Instance.new("BillboardGui",head)
    bb.Name="BF_PESP";bb.AlwaysOnTop=true
    bb.Size=UDim2.new(0,180,0,75);bb.StudsOffset=Vector3.new(0,2.5,0)
    local bg=Instance.new("Frame",bb)
    bg.Size=UDim2.new(1,0,1,0);bg.BackgroundColor3=Color3.new(0,0,0)
    bg.BackgroundTransparency=0.45;bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
    local function mkLbl(nm,sy,py,fs,clr)
        local l=Instance.new("TextLabel",bg)
        l.Name=nm;l.Size=UDim2.new(1,-4,0,sy);l.Position=UDim2.new(0,3,0,py)
        l.BackgroundTransparency=1;l.Font=Enum.Font.Gotham
        l.TextSize=fs;l.TextColor3=clr;l.TextStrokeTransparency=0.4
        l.TextXAlignment=Enum.TextXAlignment.Left
        return l
    end
    mkLbl("N",18,3,13,Color3.fromRGB(100,160,255))
    local hpBg=Instance.new("Frame",bg)
    hpBg.Size=UDim2.new(1,-8,0,5);hpBg.Position=UDim2.new(0,4,0,24)
    hpBg.BackgroundColor3=Color3.fromRGB(50,50,50);hpBg.BorderSizePixel=0
    Instance.new("UICorner",hpBg).CornerRadius=UDim.new(0,3)
    local hpF=Instance.new("Frame",hpBg)
    hpF.Name="HPF";hpF.Size=UDim2.new(1,0,1,0)
    hpF.BackgroundColor3=Color3.fromRGB(80,220,80);hpF.BorderSizePixel=0
    Instance.new("UICorner",hpF).CornerRadius=UDim.new(0,3)
    mkLbl("H",14,32,10,Color3.fromRGB(160,255,160))
    mkLbl("D",14,48,10,Color3.fromRGB(200,200,200))
    mkLbl("B",14,62,10,Color3.fromRGB(255,215,0))
end

local function updatePlayerESP()
    local root=getRoot()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        local char=plr.Character; if not char then continue end
        local head=char:FindFirstChild("Head")
        local prp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not head or not prp then continue end
        if not CFG.PlayerESP then
            local bb=head:FindFirstChild("BF_PESP")
            if bb then bb:Destroy() end
            continue
        end
        makePlayerESP(plr)
        local bb=head:FindFirstChild("BF_PESP"); if not bb then continue end
        local bg=bb:FindFirstChildOfClass("Frame"); if not bg then continue end
        local dist=root and math.floor((prp.Position-root.Position).Magnitude) or 0
        local nl=bg:FindFirstChild("N")
        if nl and CFG.ShowName then nl.Text=plr.Name end
        local hl=bg:FindFirstChild("H")
        if hl and CFG.ShowHP and hum then
            hl.Text="HP: "..formatNum(math.floor(hum.Health)).."/"..formatNum(math.floor(hum.MaxHealth))
        end
        local hpF=bg:FindFirstChild("HPF",true)
        if hpF and hum and hum.MaxHealth>0 then
            local pct=hum.Health/hum.MaxHealth
            hpF.Size=UDim2.new(pct,0,1,0)
            hpF.BackgroundColor3=pct>0.5 and Color3.fromRGB(80,220,80) or (pct>0.25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,60,60))
        end
        local dl=bg:FindFirstChild("D")
        if dl and CFG.ShowDist then dl.Text="📍 "..dist.." studs" end
        local bl=bg:FindFirstChild("B")
        if bl and CFG.ShowBounty then
            try(function()
                local bv=plr.leaderstats and plr.leaderstats:FindFirstChild("Bounty")
                bl.Text=bv and ("💰 "..formatNum(bv.Value)) or ""
            end)
        end
    end
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
local loopT=0
RunService.Heartbeat:Connect(function()
    local now=os.clock()
    if now-loopT<(CFG.FarmDelay or 0.1) then return end
    loopT=now
    doAutoFarm(); doAutoBoss(); doAutoRaid()
    doSeaBeast(); doMasteryFarm(); doDungeon(); doEliteHunter()
    if math.random(1,5)==1 then updateFruitESP(); updatePlayerESP() end
    if math.random(1,20)==1 then doAutoQuest(); doChestFarm() end
end)

-- ================================================================
-- TRAY BUTTON (từ source gốc của bạn)
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner_btn = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.106,0,0.162,0)
ImageButton.Size = UDim2.new(0,40,0,40)
ImageButton.Draggable = true
ImageButton.Image = "http://www.roblox.com/asset/?id=83190276951914"

UICorner_btn.CornerRadius = UDim.new(1,10)
UICorner_btn.Parent = ImageButton

UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,80,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(120,0,255)),
}
UIGradient.Parent = ImageButton

ImageButton.MouseEnter:Connect(function()
    TweenService:Create(ImageButton,TweenInfo.new(0.3),{Size=UDim2.new(0,52,0,52)}):Play()
end)
ImageButton.MouseLeave:Connect(function()
    TweenService:Create(ImageButton,TweenInfo.new(0.3),{Size=UDim2.new(0,40,0,40)}):Play()
end)
ImageButton.MouseButton1Down:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.End,false,game)
end)

-- ================================================================
-- FLUENT UI
-- ================================================================
local Fluent
local ok, err = try(function()
    Fluent = loadstring(game:HttpGet(
        "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    ))()
end)

if not ok or not Fluent then
    warn("[BF] Không tải được Fluent UI: " .. tostring(err))
    warn("[BF] Các tính năng game vẫn hoạt động bình thường.")
    notify("BF v5.0","Fluent UI không tải được. Script vẫn chạy!")
else

repeat task.wait() until game:IsLoaded()

local Window = Fluent:CreateWindow({
    Title     = "🍎 BF Ultimate v5.0",
    SubTitle  = "TBoy Roblox | Blox Fruit",
    TabWidth  = 157,
    Size      = UDim2.fromOffset(580, 420),
    Acrylic   = true,
    Theme     = "Amethyst",
    MinimizeKey = Enum.KeyCode.End,
})

-- Helper
local function showNotif(text, title)
    Fluent:Notify({Title=title or "Thông Báo", Content=text, Duration=3})
end

local Tabs = {
    Info    = Window:AddTab({Title="📋 Info",    Icon="info"}),
    Farm    = Window:AddTab({Title="⚔️ Farm",    Icon="sword"}),
    Boss    = Window:AddTab({Title="👑 Boss",    Icon="crown"}),
    Raid    = Window:AddTab({Title="⚡ Raid",    Icon="zap"}),
    Fruit   = Window:AddTab({Title="🍎 Fruit",   Icon="apple"}),
    ESP     = Window:AddTab({Title="👁 ESP",     Icon="eye"}),
    Move    = Window:AddTab({Title="🚀 Move",    Icon="rocket"}),
    TP      = Window:AddTab({Title="🗺️ TP",     Icon="map"}),
    Misc    = Window:AddTab({Title="⚙️ Misc",   Icon="settings"}),
}

-- ── TAB INFO ──────────────────────────────────────────────────
Tabs.Info:AddParagraph({Title="🍎 BF Ultimate v5.0", Content="Script tổng hợp đầy đủ cho Blox Fruits\nTác giả: TBoy Roblox"})

Tabs.Info:AddButton({Title="📋 Discord",Description="Copy link Discord Community",Callback=function()
    setclipboard("https://discord.gg/tboyroblox-community-1253927333920899153")
    showNotif("Đã copy link Discord!")
end})
Tabs.Info:AddButton({Title="▶️ YouTube TBoy Roblox",Description="Kênh chính",Callback=function()
    setclipboard("https://www.youtube.com/@TBoyRoblox08")
    showNotif("Đã copy link YouTube!")
end})
Tabs.Info:AddButton({Title="▶️ YouTube TBoy Gamer",Description="Kênh game",Callback=function()
    setclipboard("https://www.youtube.com/@TBoyGamer08")
    showNotif("Đã copy link YouTube!")
end})

task.spawn(function()
    while true do
        task.wait(3)
        try(function()
            -- cập nhật thông tin nhân vật vào paragraph nếu Fluent hỗ trợ
        end)
    end
end)

-- ── TAB FARM ──────────────────────────────────────────────────
Tabs.Farm:AddToggle("AutoFarm",{Title="Auto Farm",Default=false,Callback=function(v)
    CFG.AutoFarm=v; showNotif("Auto Farm "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("KillAura",{Title="Kill Aura",Default=false,Callback=function(v)
    CFG.KillAura=v; showNotif("Kill Aura "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("AutoQuest",{Title="Auto Quest",Default=false,Callback=function(v)
    CFG.AutoQuest=v; showNotif("Auto Quest "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("SeaBeast",{Title="Sea Beast Farm",Default=false,Callback=function(v)
    CFG.SeaBeast=v; showNotif("Sea Beast "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("MasteryFarm",{Title="Mastery Farm",Default=false,Callback=function(v)
    CFG.MasteryFarm=v; showNotif("Mastery Farm "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("ChestFarm",{Title="Chest Farm",Default=false,Callback=function(v)
    CFG.ChestFarm=v; showNotif("Chest Farm "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("EliteHunter",{Title="Elite Hunter",Default=false,Callback=function(v)
    CFG.EliteHunter=v; showNotif("Elite Hunter "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddToggle("AutoDungeon",{Title="Auto Dungeon",Default=false,Callback=function(v)
    CFG.AutoDungeon=v; showNotif("Dungeon "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Farm:AddSlider("AuraRange",{Title="Aura Range",Min=5,Max=80,Default=20,Callback=function(v)
    CFG.AuraRange=v
end})
Tabs.Farm:AddSlider("ChestRange",{Title="Chest Range",Min=50,Max=600,Default=300,Callback=function(v)
    CFG.ChestRange=v
end})
Tabs.Farm:AddSlider("DungeonFloor",{Title="Dungeon Floor",Min=1,Max=3,Default=1,Callback=function(v)
    CFG.DungeonFloor=v
end})
Tabs.Farm:AddInput("MobTarget",{Title="Mob Target",Default="",Placeholder="Để trống = tất cả",Callback=function(v)
    CFG.MobTarget=v
end})
Tabs.Farm:AddInput("EliteTarget",{Title="Elite Target",Default="",Placeholder="Tên elite...",Callback=function(v)
    CFG.EliteTarget=v
end})
Tabs.Farm:AddDropdown("MasteryType",{Title="Mastery Type",Values={"Fruit","Sword","Gun"},Default="Fruit",Callback=function(v)
    CFG.MasteryType=v; showNotif("Mastery: "..v)
end})

-- ── TAB BOSS ──────────────────────────────────────────────────
Tabs.Boss:AddToggle("AutoBoss",{Title="Auto Boss Farm",Default=false,Callback=function(v)
    CFG.AutoBoss=v; showNotif("Boss Farm "..(v and "✅ ON | "..CFG.BossName or "❌ OFF"))
end})
Tabs.Boss:AddToggle("BossLoop",{Title="Boss Loop",Default=true,Callback=function(v)
    CFG.BossLoop=v
end})
Tabs.Boss:AddDropdown("BossName",{Title="Chọn Boss",Values=AllBosses,Default="Yeti",Callback=function(v)
    CFG.BossName=v
    if Bosses[v] then tpTo(Bosses[v].pos) end
    showNotif("Boss: "..v)
end})
Tabs.Boss:AddParagraph({Title="Sea 1 Bosses",Content=table.concat(BossListSea1,", ")})
Tabs.Boss:AddParagraph({Title="Sea 2 Bosses",Content=table.concat(BossListSea2,", ")})
Tabs.Boss:AddParagraph({Title="Sea 3 Bosses",Content=table.concat(BossListSea3,", ")})

-- ── TAB RAID ──────────────────────────────────────────────────
Tabs.Raid:AddToggle("AutoRaid",{Title="Auto Raid",Default=false,Callback=function(v)
    CFG.AutoRaid=v; showNotif("Raid "..(v and "✅ ON | "..CFG.RaidIsland or "❌ OFF"))
end})
local raidList={}
for k in pairs(RaidIslands) do table.insert(raidList,k) end
table.sort(raidList)
Tabs.Raid:AddDropdown("RaidIsland",{Title="Chọn Raid Island",Values=raidList,Default="Flower",Callback=function(v)
    CFG.RaidIsland=v
    local pos=RaidIslands[v]
    if pos then tpTo(pos) end
    showNotif("Raid Island: "..v)
end})
Tabs.Raid:AddButton({Title="TP đến Raid Island",Description="Teleport ngay",Callback=function()
    local pos=RaidIslands[CFG.RaidIsland]
    if pos then tpTo(pos); showNotif("TP → "..CFG.RaidIsland) end
end})

-- ── TAB FRUIT ──────────────────────────────────────────────────
Tabs.Fruit:AddToggle("FruitESP",{Title="Fruit ESP",Default=false,Callback=function(v)
    CFG.FruitESP=v; showNotif("Fruit ESP "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Fruit:AddToggle("FruitNotify",{Title="Rare Fruit Notify",Default=false,Callback=function(v)
    CFG.FruitNotify=v; showNotif("Rare Notify "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Fruit:AddToggle("AutoSnipe",{Title="Auto Snipe",Default=false,Callback=function(v)
    CFG.AutoSnipe=v; showNotif("Auto Snipe "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Fruit:AddToggle("AutoCollect",{Title="Auto Collect",Default=false,Callback=function(v)
    CFG.AutoCollect=v
end})
Tabs.Fruit:AddToggle("AutoEat",{Title="Auto Eat Fruit",Default=false,Callback=function(v)
    CFG.AutoEat=v
end})
Tabs.Fruit:AddToggle("AutoStore",{Title="Auto Store Fruit",Default=false,Callback=function(v)
    CFG.AutoStore=v
end})
Tabs.Fruit:AddSlider("SnipeDelay",{Title="Snipe Delay (x100ms)",Min=0,Max=30,Default=2,Callback=function(v)
    CFG.SnipeDelay=v
end})
Tabs.Fruit:AddSlider("ESPMaxDist",{Title="ESP Max Distance",Min=200,Max=10000,Default=5000,Callback=function(v)
    CFG.ESPMaxDist=v
end})
Tabs.Fruit:AddSlider("CollectRange",{Title="Collect Range",Min=5,Max=50,Default=10,Callback=function(v)
    CFG.CollectRange=v
end})
Tabs.Fruit:AddParagraph({Title="⭐ Quả Hiếm",Content="Dragon • Leopard • Kitsune • Dough • Soul\nVenom • Control • Spirit • Mammoth • T-Rex\nGravity • Phoenix • Rumble • Blizzard"})

-- ── TAB ESP ──────────────────────────────────────────────────
Tabs.ESP:AddToggle("PlayerESP",{Title="Player ESP",Default=false,Callback=function(v)
    CFG.PlayerESP=v
    if not v then updatePlayerESP() end
    showNotif("Player ESP "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.ESP:AddToggle("ShowName",{Title="Hiện Tên",Default=true,Callback=function(v) CFG.ShowName=v end})
Tabs.ESP:AddToggle("ShowHP",{Title="Hiện HP",Default=true,Callback=function(v) CFG.ShowHP=v end})
Tabs.ESP:AddToggle("ShowDist",{Title="Hiện Khoảng Cách",Default=true,Callback=function(v) CFG.ShowDist=v end})
Tabs.ESP:AddToggle("ShowTeam",{Title="Hiện Team",Default=true,Callback=function(v) CFG.ShowTeam=v end})
Tabs.ESP:AddToggle("ShowBounty",{Title="Hiện Bounty",Default=false,Callback=function(v) CFG.ShowBounty=v end})

-- ── TAB MOVE ──────────────────────────────────────────────────
Tabs.Move:AddToggle("Fly",{Title="Fly",Default=false,Callback=function(v)
    CFG.Fly=v; if v then enableFly() end
    showNotif("Fly "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Move:AddToggle("NoClip",{Title="No-Clip",Default=false,Callback=function(v)
    CFG.NoClip=v; if v then enableNoclip() end
    showNotif("NoClip "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Move:AddToggle("InfiniteJump",{Title="Infinite Jump",Default=false,Callback=function(v)
    CFG.InfiniteJump=v
end})
Tabs.Move:AddToggle("AutoDodge",{Title="Auto Dodge",Default=false,Callback=function(v)
    CFG.AutoDodge=v; if v then enableAutoDodge() end
end})
Tabs.Move:AddToggle("GodMode",{Title="God Mode",Default=false,Callback=function(v)
    CFG.GodMode=v; if v then enableGodMode() end
    showNotif("God Mode "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Move:AddSlider("WalkSpeed",{Title="Walk Speed",Min=16,Max=500,Default=16,Callback=function(v)
    CFG.Speed=v
end})
Tabs.Move:AddSlider("FlySpeed",{Title="Fly Speed",Min=20,Max=600,Default=80,Callback=function(v)
    CFG.FlySpeed=v
end})
Tabs.Move:AddSlider("JumpPower",{Title="Jump Power",Min=10,Max=300,Default=50,Callback=function(v)
    CFG.JumpPower=v
end})
Tabs.Move:AddSlider("DodgeRange",{Title="Dodge Range",Min=5,Max=50,Default=15,Callback=function(v)
    CFG.DodgeRange=v
end})

-- ── TAB TELEPORT ──────────────────────────────────────────────
Tabs.TP:AddDropdown("Sea1TP",{Title="Sea 1 — Chọn Đảo",Values=Sea1Islands,Default="Starter Island",Callback=function(v)
    local d=Islands[v]; if d then tpTo(d.pos); showNotif("TP → "..v) end
end})
Tabs.TP:AddButton({Title="Teleport Sea 1",Callback=function()
    -- dùng giá trị dropdown hiện tại
    showNotif("Chọn đảo từ dropdown rồi nó sẽ tự TP!")
end})

Tabs.TP:AddDropdown("Sea2TP",{Title="Sea 2 — Chọn Đảo",Values=Sea2Islands,Default="Kingdom of Rose",Callback=function(v)
    local d=Islands[v]; if d then tpTo(d.pos); showNotif("TP → "..v) end
end})
Tabs.TP:AddDropdown("Sea3TP",{Title="Sea 3 — Chọn Đảo",Values=Sea3Islands,Default="Port Town",Callback=function(v)
    local d=Islands[v]; if d then tpTo(d.pos); showNotif("TP → "..v) end
end})
Tabs.TP:AddDropdown("BossTP",{Title="TP đến Boss",Values=AllBosses,Default="Yeti",Callback=function(v)
    local d=Bosses[v]; if d then tpTo(d.pos); showNotif("TP Boss → "..v) end
end})
Tabs.TP:AddDropdown("RaidTP",{Title="TP đến Raid Island",Values=raidList,Default="Flower",Callback=function(v)
    local pos=RaidIslands[v]; if pos then tpTo(pos); showNotif("TP Raid → "..v) end
end})

-- ── TAB MISC ──────────────────────────────────────────────────
Tabs.Misc:AddToggle("AntiAFK",{Title="Anti AFK",Default=true,Callback=function(v)
    CFG.AntiAFK=v; showNotif("Anti AFK "..(v and "✅ ON" or "❌ OFF"))
end})
Tabs.Misc:AddToggle("AutoSell",{Title="Auto Sell",Default=false,Callback=function(v)
    CFG.AutoSell=v
end})
Tabs.Misc:AddToggle("AutoRespawn",{Title="Auto Respawn",Default=true,Callback=function(v)
    CFG.AutoRespawn=v
end})
Tabs.Misc:AddDropdown("StatType",{Title="Auto Stat",Values={"Melee","Defense","Sword","Gun","Fruit"},Default="Melee",Callback=function(v)
    CFG.StatType=v; CFG.AutoStat=true; showNotif("Auto Stat: "..v)
end})
Tabs.Misc:AddToggle("AutoStat",{Title="Bật Auto Stat",Default=false,Callback=function(v)
    CFG.AutoStat=v
end})
Tabs.Misc:AddButton({Title="💾 Lưu Config",Description="Lưu cấu hình hiện tại",Callback=function()
    saveConfig(); showNotif("✅ Đã lưu config!")
end})
Tabs.Misc:AddButton({Title="📂 Tải Config",Description="Tải lại cấu hình",Callback=function()
    loadConfig(); showNotif("✅ Đã tải config!")
end})
Tabs.Misc:AddButton({Title="📋 Rejoin Server",Description="Kết nối lại server",Callback=function()
    try(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)
end})
Tabs.Misc:AddButton({Title="🔄 Reset về mặc định",Description="Xóa config và reset",Callback=function()
    for k,v in pairs({AutoFarm=false,KillAura=false,AutoBoss=false,AutoRaid=false,FruitESP=false,AutoSnipe=false,PlayerESP=false,Fly=false,NoClip=false,GodMode=false,Speed=16,FlySpeed=80,JumpPower=50}) do
        CFG[k]=v
    end
    saveConfig()
    showNotif("✅ Đã reset config!")
end})

-- SaveManager / InterfaceManager nếu Fluent hỗ trợ
try(function()
    local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"Theme"})
    InterfaceManager:SetFolder("BFScript")
    SaveManager:SetFolder("BFScript/saves")
    InterfaceManager:BuildInterfaceSection(Tabs.Misc)
    SaveManager:BuildConfigSection(Tabs.Misc)
    SaveManager:LoadAutoloadConfig()
end)

Window:SelectTab(1)
notify("🍎 BF Ultimate v5.0","✅ Đã tải! Nhấn End để ẩn/hiện GUI.",5)

end -- end if Fluent loaded

-- ================================================================
-- CONSOLE API
-- ================================================================
local BF={}
function BF.farm(s,mob)  CFG.AutoFarm=s;if mob then CFG.MobTarget=mob end end
function BF.aura(s,r)    CFG.KillAura=s;if r then CFG.AuraRange=r end end
function BF.boss(s,nm)   CFG.AutoBoss=s;if nm then CFG.BossName=nm end;if nm and Bosses[nm] then tpTo(Bosses[nm].pos) end end
function BF.raid(s,isl)  CFG.AutoRaid=s;if isl then CFG.RaidIsland=isl end end
function BF.sea(s)       CFG.SeaBeast=s end
function BF.chest(s,r)   CFG.ChestFarm=s;if r then CFG.ChestRange=r end end
function BF.mastery(s,t) CFG.MasteryFarm=s;if t then CFG.MasteryType=t end end
function BF.esp(s)       CFG.FruitESP=s end
function BF.snipe(s,d)   CFG.AutoSnipe=s;if d then CFG.SnipeDelay=d end end
function BF.pesp(s)      CFG.PlayerESP=s end
function BF.fly(s,sp)    CFG.Fly=s;if sp then CFG.FlySpeed=sp end;if s then enableFly() end end
function BF.noclip(s)    CFG.NoClip=s;if s then enableNoclip() end end
function BF.god(s)       CFG.GodMode=s;if s then enableGodMode() end end
function BF.speed(n)     CFG.Speed=n or 16 end
function BF.jump(n)      CFG.JumpPower=n or 50 end
function BF.ijump(s)     CFG.InfiniteJump=s end
function BF.stat(t)      CFG.AutoStat=true;CFG.StatType=t or "Melee" end
function BF.tp(name)
    if Islands[name] then tpTo(Islands[name].pos); notify("TP","→ "..name)
    elseif Bosses[name] then tpTo(Bosses[name].pos); notify("Boss TP","→ "..name)
    else print("[BF] Không tìm thấy: "..name) end
end
function BF.save()  saveConfig(); print("[BF] ✅ Đã lưu") end
function BF.load()  loadConfig(); print("[BF] ✅ Đã tải") end
function BF.info()
    print("Level: "..getLevel().." | Beli: "..formatNum(getBeli()).." | Bounty: "..formatNum(getBounty()))
    print("Farm: "..tostring(CFG.AutoFarm).." | Boss: "..CFG.BossName.." | Raid: "..CFG.RaidIsland)
end
function BF.help()
    print([[
╔═══════════════════════════════════════════════════╗
║      🍎 BF ULTIMATE v5.0 — CONSOLE COMMANDS       ║
╠═══════════════════════════════════════════════════╣
║ BF.farm(true[,"Mob"])    Auto Farm                ║
║ BF.aura(true[,range])    Kill Aura                ║
║ BF.boss(true,"Name")     Boss Farm + TP           ║
║ BF.raid(true[,"Island"]) Auto Raid                ║
║ BF.sea(true)             Sea Beast Farm           ║
║ BF.chest(true[,range])   Chest Farm               ║
║ BF.mastery(true[,"Type"])Mastery Farm             ║
║ BF.esp(true)             Fruit ESP                ║
║ BF.snipe(true[,delay])   Auto Snipe               ║
║ BF.pesp(true)            Player ESP               ║
║ BF.fly(true[,speed])     Fly                      ║
║ BF.noclip(true)          No-Clip                  ║
║ BF.god(true)             God Mode                 ║
║ BF.speed(n)              Walk Speed               ║
║ BF.jump(n)               Jump Power               ║
║ BF.ijump(true)           Infinite Jump            ║
║ BF.stat("Melee")         Auto Stat                ║
║ BF.tp("Tên đảo/boss")    Teleport                 ║
║ BF.info()                Thông tin nhân vật       ║
║ BF.save() / BF.load()    Lưu / Tải config         ║
╚═══════════════════════════════════════════════════╝
    ]])
end
getgenv().BF=BF

-- ================================================================
print("╔══════════════════════════════════════════════╗")
print("║  🍎 BF ULTIMATE v5.0 — TBoy Roblox          ║")
print("║  GUI: Nhấn [End] để ẩn/hiện                 ║")
print("║  Console: BF.help() để xem lệnh             ║")
print("╚══════════════════════════════════════════════╝")
