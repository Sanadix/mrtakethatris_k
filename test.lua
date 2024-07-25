local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local workspace = game:GetService("Workspace")
local storm_related = workspace:WaitForChild("storm_related")
local storms = storm_related:WaitForChild("storms")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local userInputService = game:GetService("UserInputService")

local defaultWalkSpeed = humanoid.WalkSpeed
local speedBoost = 130
local bodyVelocity

local function updateLabelSize(label, distance)
    local minSize = 14
    local maxSize = 48
    
    local size = minSize + (maxSize - minSize) * (distance / 10000) 
    size = math.clamp(size, minSize, maxSize)
    
    label.TextSize = size
end

local function applyFullbright()
    lighting.Ambient = Color3.new(1, 1, 1)
    lighting.Brightness = 10
    lighting.ExposureCompensation = 0
    lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

applyFullbright()

runService.RenderStepped:Connect(function()
    applyFullbright()
end)

local function getNearestWallcloud()
    local nearestWallcloud = nil
    local minDistance = math.huge
    
    for _, storm in ipairs(storms:GetChildren()) do
        local rotation = storm:FindFirstChild("rotation")
        if rotation then
            local wallcloud = rotation:FindFirstChild("wallcloud")
            if wallcloud then
                local playerPos = player.Character.PrimaryPart.Position
                local wallcloudPos = wallcloud.Position
                local horizontalDistance = Vector3.new(playerPos.X, 0, playerPos.Z) - Vector3.new(wallcloudPos.X, 0, wallcloudPos.Z)
                local distance = horizontalDistance.Magnitude
                
                if distance < minDistance then
                    minDistance = distance
                    nearestWallcloud = wallcloud
                end
            end
        end
    end
    
    return nearestWallcloud, minDistance
end

local isVKeyPressed = false
userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        isVKeyPressed = true
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = char.PrimaryPart.CFrame.LookVector * speedBoost
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.P = 1250
            bodyVelocity.Parent = char.PrimaryPart
        end
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        isVKeyPressed = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

for _, storm in ipairs(storms:GetChildren()) do
    local rotation = storm:FindFirstChild("rotation")
    if rotation then
        local wallcloud = rotation:FindFirstChild("wallcloud")
        if wallcloud then
            local billboardGui = Instance.new("BillboardGui", wallcloud)
            billboardGui.Adornee = wallcloud
            billboardGui.Size = UDim2.new(0, 200, 0, 100)
            billboardGui.StudsOffset = Vector3.new(0, 2, 0)
            billboardGui.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel", billboardGui)
            textLabel.Size = UDim2.new(1, 0, 0.5, 0)
            textLabel.Position = UDim2.new(0, 0, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Tornado"
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.TextStrokeTransparency = 0.5

            local distanceLabel = Instance.new("TextLabel", billboardGui)
            distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.TextStrokeTransparency = 0.5

            runService.RenderStepped:Connect(function()
                local playerPos = player.Character.PrimaryPart.Position
                local wallcloudPos = wallcloud.Position
                local horizontalDistance = Vector3.new(playerPos.X, 0, playerPos.Z) - Vector3.new(wallcloudPos.X, 0, wallcloudPos.Z)
                local distance = horizontalDistance.Magnitude
                
                updateLabelSize(textLabel, distance)
                distanceLabel.TextSize = textLabel.TextSize * 0.75
                distanceLabel.Text = string.format("Distance: %.2f studs", distance)
            end)
        end
    end
end
