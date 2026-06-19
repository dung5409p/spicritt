-- GUI chính
local ScreenGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local TweenService = game:GetService("TweenService")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.106, 0, 0.162, 0)
ImageButton.Size = UDim2.new(0, 40, 0, 40)
ImageButton.Draggable = true
ImageButton.Image = "http://www.roblox.com/asset/?id=83190276951914"

UICorner.CornerRadius = UDim.new(1, 10) 
UICorner.Parent = ImageButton

-- Gradient nền cho nút
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
}
UIGradient.Parent = ImageButton

-- Hover animation
ImageButton.MouseEnter:Connect(function()
    TweenService:Create(ImageButton, TweenInfo.new(0.3), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end)
ImageButton.MouseLeave:Connect(function()
    TweenService:Create(ImageButton, TweenInfo.new(0.3), {Size = UDim2.new(0, 40, 0, 40)}):Play()
end)

-- Hotkey mở GUI
ImageButton.MouseButton1Down:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.End, false, game)
end)

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
repeat wait() until game:IsLoaded()
local Window = Fluent:CreateWindow({
    Title = "TBoy Roblox Tổng Hợp",
    SubTitle = "Blox Fruit",
    TabWidth = 157,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.End
})

-- Tabs
local Tabs = {
    Main0 = Window:AddTab({ Title="Thông Tin" }),
    Farm  = Window:AddTab({ Title="⚔️ Farm" }),
    Boss  = Window:AddTab({ Title="👑 Boss" }),
    Raid  = Window:AddTab({ Title="⚡ Raid" }),
    Fruit = Window:AddTab({ Title="🍎 Fruit" }),
    ESP   = Window:AddTab({ Title="👁 ESP" }),
    Move  = Window:AddTab({ Title="🚀 Move" }),
    Misc  = Window:AddTab({ Title="⚙️ Misc" }),
    Settings = Window:AddTab({ Title="Cài Đặt" }),
}

-- Hàm thông báo popup
local function showNotification(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Thông báo",
        Text = text,
        Duration = 3
    })
end

-- Tab Thông tin
Tabs.Main0:AddButton({
    Title = "Discord",
    Description = "TBoyRoblox Community",
    Callback = function()
        setclipboard("https://discord.gg/tboyroblox-community-1253927333920899153")
        showNotification("Đã copy link Discord!")
    end
})
Tabs.Main0:AddButton({
    Title = "Youtuber",
    Description = "TBoy Roblox",
    Callback = function()
        setclipboard("https://www.youtube.com/@TBoyRoblox08")
        showNotification("Đã copy kênh TBoy Roblox!")
    end
})
Tabs.Main0:AddButton({
    Title = "Youtuber",
    Description = "TBoy Gamer",
    Callback = function()
        setclipboard("https://www.youtube.com/@TBoyGamer08")
        showNotification("Đã copy kênh TBoy Gamer!")
    end
})

-- Tab Farm
Tabs.Farm:AddToggle("AutoFarm", {Title="Auto Farm", Default=false, Callback=function(v) CFG.AutoFarm=v; showNotification("Auto Farm "..(v and "ON" or "OFF")) end})
Tabs.Farm:AddToggle("KillAura", {Title="KillAura", Default=false, Callback=function(v) CFG.KillAura=v; showNotification("KillAura "..(v and "ON" or "OFF")) end})
Tabs.Farm:AddSlider("AuraRange", {Title="Aura Range", Min=5, Max=50, Default=20, Callback=function(v) CFG.AuraRange=v; showNotification("Aura Range: "..v) end})

-- Tab Boss
Tabs.Boss:AddToggle("AutoBoss", {Title="Auto Boss", Default=false, Callback=function(v) CFG.AutoBoss=v; showNotification("Auto Boss "..(v and "ON" or "OFF")) end})
Tabs.Boss:AddDropdown("BossName", {Title="Chọn Boss", Values={"Yeti","Vice Admiral","Diamond","Jeremy","Cake Queen"}, Default="Yeti", Callback=function(v) CFG.BossName=v; showNotification("Đã chọn Boss: "..v) end})

-- Tab Raid
Tabs.Raid:AddToggle("AutoRaid", {Title="Auto Raid", Default=false, Callback=function(v) CFG.AutoRaid=v; showNotification("Auto Raid "..(v and "ON" or "OFF")) end})
Tabs.Raid:AddDropdown("RaidIsland", {Title="Chọn Đảo Raid", Values={"Flower","Magma","Ice","Sand","Dark","Light","Phoenix","Gravity"}, Default="Flower", Callback=function(v) CFG.RaidIsland=v; showNotification("Đã chọn đảo Raid: "..v) end})

-- Tab Fruit
Tabs.Fruit:AddToggle("FruitESP", {Title="Fruit ESP", Default=false, Callback=function(v) CFG.FruitESP=v; showNotification("Fruit ESP "..(v and "ON" or "OFF")) end})
Tabs.Fruit:AddToggle("AutoSnipe", {Title="Auto Snipe", Default=false, Callback=function(v) CFG.AutoSnipe=v; showNotification("Auto Snipe "..(v and "ON" or "OFF")) end})
Tabs.Fruit:AddToggle("FruitNotify", {Title="Rare Fruit Notify", Default=false, Callback=function(v) CFG.FruitNotify=v; showNotification("Rare Fruit Notify "..(v and "ON" or "OFF")) end})

-- Tab ESP
Tabs.ESP:AddToggle("PlayerESP", {Title="Player ESP", Default=false, Callback=function(v) CFG.PlayerESP=v; showNotification("Player ESP "..(v and "ON" or "OFF")) end})

-- Tab Move
Tabs.Move:AddToggle("Fly", {Title="Fly", Default=false, Callback=function(v) CFG.Fly=v; showNotification("Fly "..(v and "ON" or "OFF")) end})
Tabs.Move:AddToggle("NoClip", {Title="NoClip", Default=false, Callback=function(v) CFG.NoClip=v; showNotification("NoClip "..(v and "ON" or "OFF")) end})
Tabs.Move:AddSlider("Speed", {Title="Walk Speed", Min=16, Max=100, Default=16, Callback=function(v) CFG.Speed=v; showNotification("Walk Speed: "..v) end})

-- Tab Misc
Tabs.Misc:AddToggle("AntiAFK", {Title="Anti AFK", Default=true, Callback=function(v) CFG.AntiAFK=v; showNotification("Anti AFK "..(v and "ON" or "OFF")) end})
Tabs.Misc:AddToggle("GodMode", {Title="God Mode", Default=false, Callback=function(v) CFG.GodMode=v; showNotification("God Mode "..(v and "ON" or "OFF")) end})
Tabs.Misc:AddDropdown("StatType", {Title="Auto Stat", Values={"Melee","Defense","Sword","Gun","Fruit"}, Default="Melee", Callback=function(v) CFG.StatType=v; CFG.AutoStat=true; showNotification("Auto Stat: "..v) end})

-- Tab Cài đặt
Tabs.Settings:AddDropdown("Theme", {Title="Chọn Theme", Values={"Amethyst","Emerald","Dark","Light"}, Default="Amethyst", Callback=function(v) Window:SetTheme(v); showNotification("Đã đổi theme sang "..v) end})
Tabs.Settings:AddButton({Title="Kiểm tra cập nhật", Description="Tự động tải phiên bản mới", Callback=function() showNotification("Đang kiểm tra bản cập nhật...") end})

