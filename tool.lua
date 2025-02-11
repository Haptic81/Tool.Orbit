-- Made By Nerdy Coder Here is Source Code
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local orbitRadius = 50
local orbitSpeed = 5
local orbitHeight = 4
local waitBeforeOrbit = 2
local toolSpacing = math.pi / 3

local orbitData = {}

local function dropTools()
    local backpack = player:FindFirstChildOfClass("Backpack")
    local dropped = {}

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = character
            RunService.Heartbeat:Wait()
            tool.Parent = workspace

            local mainPart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            if mainPart and not mainPart.Anchored then
                dropped[tool] = mainPart
            end
        end
    end
    return dropped
end

local function setupOrbit(droppedTools)
    local toolIndex = 0
    for tool, part in pairs(droppedTools) do
        if part then
            part.Anchored = false
            part.Massless = true

            local bodyPos = Instance.new("BodyPosition")
            bodyPos.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bodyPos.P = 5000
            bodyPos.Parent = part

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro.CFrame = part.CFrame
            bodyGyro.Parent = part

            orbitData[part] = {
                tool = tool,
                bodyPos = bodyPos,
                bodyGyro = bodyGyro,
                angle = toolIndex * toolSpacing,
            }
            toolIndex = toolIndex + 1
        end
    end
end

local function startOrbit()
    RunService.Heartbeat:Connect(function(deltaTime)
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local center = hrp.Position
            local index = 0

            for part, data in pairs(orbitData) do
                if part and part.Parent then
                    data.angle = data.angle + orbitSpeed * deltaTime
                    local spacing = toolSpacing * index
                    local newX = center.X + math.cos(data.angle + spacing) * orbitRadius
                    local newZ = center.Z + math.sin(data.angle + spacing) * orbitRadius
                    local newY = center.Y + orbitHeight

                    data.bodyPos.Position = Vector3.new(newX, newY, newZ)
                    data.bodyGyro.CFrame = CFrame.lookAt(part.Position, center)
                    index = index + 1
                else
                    orbitData[part] = nil
                end
            end
        end
    end)
end

local droppedTools = dropTools()
wait(waitBeforeOrbit)
setupOrbit(droppedTools)
startOrbit()
