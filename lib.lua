local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local maxDistance = 1000  -- Maximum distance to show ESP boxes
local updateInterval = 0.1  -- Update interval in seconds

-- Function to create a new Drawing object for a box
local function createBox()
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    return box
end

local boxes = {}

local function isTeammate(player)
    if LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    else
        return false
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if rootPart and humanoid and humanoid.Health > 0 then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance < maxDistance then
                    
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        
                        local size = Vector2.new(1000 / screenPosition.Z, 2000 / screenPosition.Z)
                        local position = Vector2.new(screenPosition.X - size.X / 2, screenPosition.Y - size.Y / 2)
                        
                        
                        if not boxes[player] then
                            boxes[player] = createBox()
                        end
                        local box = boxes[player]
                        box.Size = size
                        box.Position = position
                        box.Visible = true
                    elseif boxes[player] then
                        boxes[player].Visible = false
                    end
                elseif boxes[player] then
                    boxes[player].Visible = false
                end
            elseif boxes[player] then
                boxes[player].Visible = false
            end
        elseif boxes[player] then
            boxes[player].Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
    wait(updateInterval)
end)

Players.PlayerRemoving:Connect(function(player)
    if boxes[player] then
        boxes[player]:Remove()
        boxes[player] = nil
    end
end)
