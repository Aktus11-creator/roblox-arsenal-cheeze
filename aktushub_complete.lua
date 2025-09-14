-- Simple FPS Cheat Hub (No External Dependencies)
-- Basic GUI approach to avoid compatibility issues

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local connections = {}
local gui = {}
local settings = {
    aimbot = {
        enabled = false,
        fov = 90,
        smoothing = 5,
        targetPart = "Head",
        wallCheck = false,
        teamCheck = false,
        showFOV = false
    },
    movement = {
        speed = 50,
        jumpPower = 50,
        infiniteJump = false,
        speedHack = false,
        fly = false,
        noclip = false
    },
    combat = {
        triggerBot = false,
        silentAim = false,
        infAmmo = false
    }
}

local fovCircle = nil
local originalValues = {
    walkSpeed = 16,
    jumpPower = 50
}

-- Utility Functions
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Simple GUI Creation
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CheatGUI"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Make it draggable
    local dragStart, startPos = nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = nil
        end
    end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = "FPS Cheat Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.BorderSizePixel = 0
    title.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame
    
    return scrollFrame
end

-- Create Toggle Function
local function createToggle(parent, name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 25)
    button.Position = UDim2.new(0, 5, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = name .. ": OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.SourceSans
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(80, 80, 80)
    button.Parent = parent
    
    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = name .. ": " .. (enabled and "ON" or "OFF")
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(enabled)
    end)
    
    return button
end

-- FOV Circle
local function createFOVCircle()
    if fovCircle then
        fovCircle:Remove()
    end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 2
    fovCircle.Transparency = 0.5
    fovCircle.Filled = false
    fovCircle.Visible = settings.aimbot.showFOV
    fovCircle.Radius = settings.aimbot.fov
end

local function updateFOVCircle()
    if fovCircle and settings.aimbot.showFOV then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = settings.aimbot.fov
        fovCircle.Visible = true
    elseif fovCircle then
        fovCircle.Visible = false
    end
end

-- Team Detection
local function isOnSameTeam(player1, player2)
    if not settings.aimbot.teamCheck then return false end
    return player1.Team == player2.Team
end

-- Aimbot Functions
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local camera = workspace.CurrentCamera
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(settings.aimbot.targetPart) then
            if isOnSameTeam(LocalPlayer, player) then
                continue
            end
            
            local targetPosition = player.Character[settings.aimbot.targetPart].Position
            local screenPoint, onScreen = camera:WorldToScreenPoint(targetPosition)
            
            if onScreen then
                local mousePosition = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
                
                if distance < settings.aimbot.fov and distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(player)
    if player and player.Character and player.Character:FindFirstChild(settings.aimbot.targetPart) then
        local camera = workspace.CurrentCamera
        local targetPosition = player.Character[settings.aimbot.targetPart].Position
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        
        camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / settings.aimbot.smoothing)
    end
end

-- Main Functions
local function setupMovement()
    -- Speed Hack
    connections.speedUpdate = RunService.Heartbeat:Connect(function()
        if settings.movement.speedHack then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = settings.movement.speed
            end
        end
    end)
    
    -- Infinite Jump
    connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if settings.movement.infiniteJump then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    -- Fly
    connections.flyUpdate = RunService.Heartbeat:Connect(function()
        if settings.movement.fly then
            local rootPart = getRootPart()
            if rootPart then
                local bodyVelocity = rootPart:FindFirstChild("FlyVelocity")
                if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "FlyVelocity"
                    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                    bodyVelocity.Parent = rootPart
                end
                
                local camera = workspace.CurrentCamera
                local velocity = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    velocity = velocity - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = velocity * settings.movement.speed
            end
        else
            local rootPart = getRootPart()
            if rootPart then
                local bodyVelocity = rootPart:FindFirstChild("FlyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end)
    
    -- NoClip
    connections.noclipUpdate = RunService.Stepped:Connect(function()
        if settings.movement.noclip then
            local character = getCharacter()
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

local function setupCombat()
    -- Aimbot
    connections.aimbotUpdate = RunService.RenderStepped:Connect(function()
        if settings.aimbot.enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target then
                aimAtPlayer(target)
            end
        end
    end)
    
    connections.fovUpdate = RunService.RenderStepped:Connect(updateFOVCircle)
    
    -- Trigger Bot
    connections.triggerBot = RunService.RenderStepped:Connect(function()
        if settings.combat.triggerBot then
            local camera = workspace.CurrentCamera
            local origin = camera.CFrame.Position
            local direction = camera.CFrame.LookVector * 1000
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {getCharacter()}
            
            local result = workspace:Raycast(origin, direction, raycastParams)
            
            if result and result.Instance then
                local character = result.Instance.Parent
                if character:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player and player ~= LocalPlayer and not isOnSameTeam(LocalPlayer, player) then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        wait(0.1)
                    end
                end
            end
        end
    end)
    
    -- Infinite Ammo
    connections.infAmmo = RunService.Heartbeat:Connect(function()
        if settings.combat.infAmmo then
            local playerGui = LocalPlayer.PlayerGui
            for _, gui in pairs(playerGui:GetChildren()) do
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj.Name:lower():find("ammo") and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                        obj.Value = 999
                    end
                end
            end
        end
        wait(0.5)
    end)
end

-- Create GUI and Setup
local function main()
    local mainGui = createGUI()
    createFOVCircle()
    
    -- Movement Toggles
    createToggle(mainGui, "Speed Hack", 0, function(enabled)
        settings.movement.speedHack = enabled
        if not enabled then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = originalValues.walkSpeed
            end
        end
    end)
    
    createToggle(mainGui, "Infinite Jump", 30, function(enabled)
        settings.movement.infiniteJump = enabled
    end)
    
    createToggle(mainGui, "Fly", 60, function(enabled)
        settings.movement.fly = enabled
    end)
    
    createToggle(mainGui, "NoClip", 90, function(enabled)
        settings.movement.noclip = enabled
    end)
    
    -- Combat Toggles
    createToggle(mainGui, "Aimbot", 130, function(enabled)
        settings.aimbot.enabled = enabled
    end)
    
    createToggle(mainGui, "Show FOV", 160, function(enabled)
        settings.aimbot.showFOV = enabled
    end)
    
    createToggle(mainGui, "Trigger Bot", 190, function(enabled)
        settings.combat.triggerBot = enabled
    end)
    
    createToggle(mainGui, "Infinite Ammo", 220, function(enabled)
        settings.combat.infAmmo = enabled
    end)
    
    createToggle(mainGui, "Team Check", 250, function(enabled)
        settings.aimbot.teamCheck = enabled
    end)
    
    -- Setup systems
    setupMovement()
    setupCombat()
    
    mainGui.CanvasSize = UDim2.new(0, 0, 0, 300)
    
    print("Simple FPS Cheat Hub loaded!")
end

-- Cleanup function
local function cleanup()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    if fovCircle then
        fovCircle:Remove()
    end
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild("CheatGUI")
    if gui then
        gui:Destroy()
    end
end

-- Initialize
main()

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)
