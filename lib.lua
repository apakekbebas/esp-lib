local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local maxDistance = 1000
local updateInterval = 0.1

_G.ShowNames = _G.ShowNames or true
_G.ShowDistance = _G.ShowDistance or true

local function createBox()
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    return box
end

local function createText()
    local text = Drawing.new("Text")
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Color = Color3.fromRGB(255, 255, 255)
    return text
end

local espElements = {}

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
                        
                        if not espElements[player] then
                            espElements[player] = {
                                box = createBox(),
                                name = createText(),
                                distance = createText()
                            }
                        end
                        local elements = espElements[player]

                        elements.box.Size = size
                        elements.box.Position = position
                        elements.box.Visible = true

                        if _G.ShowNames then
                            elements.name.Text = player.Name
                            elements.name.Position = Vector2.new(screenPosition.X, screenPosition.Y - size.Y / 2 - 20)
                            elements.name.Visible = true
                        else
                            elements.name.Visible = false
                        end

                        if _G.ShowDistance then
                            elements.distance.Text = string.format("%.0f studs", distance)
                            elements.distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + size.Y / 2 + 10)
                            elements.distance.Visible = true
                        else
                            elements.distance.Visible = false
                        end
                    elseif espElements[player] then
                        espElements[player].box.Visible = false
                        espElements[player].name.Visible = false
                        espElements[player].distance.Visible = false
                    end
                elseif espElements[player] then
                    espElements[player].box.Visible = false
                    espElements[player].name.Visible = false
                    espElements[player].distance.Visible = false
                end
            elseif espElements[player] then
                espElements[player].box.Visible = false
                espElements[player].name.Visible = false
                espElements[player].distance.Visible = false
            end
        elseif espElements[player] then
            espElements[player].box.Visible = false
            espElements[player].name.Visible = false
            espElements[player].distance.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
    wait(updateInterval)
end)

Players.PlayerRemoving:Connect(function(player)
    if espElements[player] then
        espElements[player].box:Remove()
        espElements[player].name:Remove()
        espElements[player].distance:Remove()
        espElements[player] = nil
    end
end)
