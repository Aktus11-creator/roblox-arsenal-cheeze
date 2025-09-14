-- Simple FPS Cheat Script - Built from scratch
-- No external dependencies or complex libraries

-- Get essential services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Get local player
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Script state variables
local cheats = {
    speedHack = false,
    infiniteJump = false,
    aimbot = false,
    triggerbot = false,
    fly = false,
    noclip = false
}

local aimbotSettings = {
    fov = 100,
    smoothness = 5,
    targetPart = "Head"
}

-- Store original values
local originalSpeed = 16
local flyBodyVelocity = nil

-- Utility functions
local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get closest enemy player for aimbot
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local targetPart = otherPlayer.Character:FindFirstChild(aimbotSettings.targetPart)
            if targetPart then
                local screenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < aimbotSettings.fov and distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot function
local function aimAt(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetPart = targetPlayer.Character:FindFirstChild(aimbotSettings.targetPart)
    if not targetPart then return end
    
    local camera = workspace.CurrentCamera
    local targetPos = targetPart.Position
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    
    -- Smooth aiming
    camera.CFrame = currentCFrame:lerp(targetCFrame, 1 / aimbotSettings.smoothness)
end

-- Main update loop
local function onUpdate()
    local humanoid = getHumanoid()
    local rootPart = getRootPart()
    
    -- Speed hack
    if cheats.speedHack and humanoid then
        humanoid.WalkSpeed = 100
    end
    
    -- Aimbot
    if cheats.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy()
        if target then
            aimAt(target)
        end
    end
    
    -- Triggerbot
    if cheats.triggerbot then
        local camera = workspace.CurrentCamera
        local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {getCharacter()}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        
        if result then
            local hit = result.Instance
            local hitCharacter = hit.Parent
            if hitCharacter:FindFirstChild("Humanoid") then
                local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
                if hitPlayer and hitPlayer ~= player then
                    -- Simulate mouse click
                    mouse1press()
                    wait(0.01)
                    mouse1release()
                    wait(0.1) -- Prevent spam
                end
            end
        end
    end
    
    -- Fly
    if cheats.fly and rootPart then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            flyBodyVelocity.Parent = rootPart
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
        
        flyBodyVelocity.Velocity = velocity * 50
        
    elseif flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    -- NoClip
    if cheats.noclip then
        local character = getCharacter()
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- Infinite jump handler
local function onJumpRequest()
    if cheats.infiniteJump then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Key bindings
local function onKeyPress(key)
    if key.KeyCode == Enum.KeyCode.F1 then
        cheats.speedHack = not cheats.speedHack
        print("Speed Hack:", cheats.speedHack and "ON" or "OFF")
        
        if not cheats.speedHack then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = originalSpeed
            end
        end
        
    elseif key.KeyCode == Enum.KeyCode.F2 then
        cheats.infiniteJump = not cheats.infiniteJump
        print("Infinite Jump:", cheats.infiniteJump and "ON" or "OFF")
        
    elseif key.KeyCode == Enum.KeyCode.F3 then
        cheats.aimbot = not cheats.aimbot
        print("Aimbot:", cheats.aimbot and "ON" or "OFF")
        
    elseif key.KeyCode == Enum.KeyCode.F4 then
        cheats.triggerbot = not cheats.triggerbot
        print("Triggerbot:", cheats.triggerbot and "ON" or "OFF")
        
    elseif key.KeyCode == Enum.KeyCode.F5 then
        cheats.fly = not cheats.fly
        print("Fly:", cheats.fly and "ON" or "OFF")
        
    elseif key.KeyCode == Enum.KeyCode.F6 then
        cheats.noclip = not cheats.noclip
        print("NoClip:", cheats.noclip and "ON" or "OFF")
        
    elseif key.KeyCode == Enum.KeyCode.F7 then
        -- Toggle target part
        if aimbotSettings.targetPart == "Head" then
            aimbotSettings.targetPart = "HumanoidRootPart"
        else
            aimbotSettings.targetPart = "Head"
        end
        print("Aimbot target:", aimbotSettings.targetPart)
    end
end

-- Connect events
RunService.Heartbeat:Connect(onUpdate)
UserInputService.JumpRequest:Connect(onJumpRequest)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        onKeyPress(input)
    end
end)

-- Print controls
print("=== FPS CHEAT CONTROLS ===")
print("F1 - Speed Hack")
print("F2 - Infinite Jump") 
print("F3 - Aimbot (hold right-click)")
print("F4 - Triggerbot")
print("F5 - Fly (WASD + Space/Ctrl)")
print("F6 - NoClip")
print("F7 - Change aimbot target")
print("==========================")
