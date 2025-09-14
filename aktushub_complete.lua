local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "AktusHUB v1.1",
   Icon = 0,
   LoadingTitle = "AktusHUB v 1.1 - loading",
   LoadingSubtitle = "by Aktus1_1",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "Insert",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = true,
      Invite = "HjCxZ4jyxr",
      RememberJoins = true
   },
   KeySystem = false
})

-- Load ESP Library
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainTab = Window:CreateTab("🏠 Main", nil)
local MovementTab = Window:CreateTab("🏃 Movement", nil)
local CombatTab = Window:CreateTab("⚔️ Combat", nil)
local MiscTab = Window:CreateTab("🔧 Misc", nil)

-- Variables
local LocalPlayer = Players.LocalPlayer
local connections = {}
local settings = {
    aimbot = {
        enabled = false,
        fov = 90,
        smoothing = 1,
        targetPart = "Head",
        wallCheck = false,
        teamCheck = false
    },
    movement = {
        speed = 50,
        jumpPower = 50,
        fly = false,
        noclip = false
    },
    visuals = {
        esp = false,
        showFOV = false
    },
    combat = {
        triggerBot = false,
        silentAim = false,
        rapidFire = false,
        infAmmo = false
    }
}

local fovCircle = nil
local originalValues = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error: " .. tostring(result))
    end
    return success, result
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChild("Humanoid")
end

local function getRootPart()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Movement Section
local MovementSection = MovementTab:CreateSection("🏃 Basic Movement")

local InfiniteJumpToggle = MovementTab:CreateToggle({
   Name = "🚀 Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      if Value then
         connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            local humanoid = getHumanoid()
            if humanoid then
               humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
         end)
      else
         if connections.infiniteJump then
            connections.infiniteJump:Disconnect()
            connections.infiniteJump = nil
         end
      end
   end,
})

local SpeedToggle = MovementTab:CreateToggle({
   Name = "⚡ Speed Hack",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      local humanoid = getHumanoid()
      if humanoid then
         if Value then
            originalValues.walkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = settings.movement.speed
         else
            humanoid.WalkSpeed = originalValues.walkSpeed or 16
         end
      end
   end,
})

local SpeedSlider = MovementTab:CreateSlider({
   Name = "⚡ Walk Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "WalkSpeed",
   Callback = function(Value)
      settings.movement.speed = Value
      local humanoid = getHumanoid()
      if humanoid and SpeedToggle.CurrentValue then
         humanoid.WalkSpeed = Value
      end
   end,
})

local JumpPowerSlider = MovementTab:CreateSlider({
   Name = "🦘 Jump Power",
   Range = {50, 500},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      settings.movement.jumpPower = Value
      local humanoid = getHumanoid()
      if humanoid then
         humanoid.JumpPower = Value
      end
   end,
})

-- Advanced Movement Section
local AdvancedMovementSection = MovementTab:CreateSection("🚁 Advanced Movement")

local FlyToggle = MovementTab:CreateToggle({
   Name = "🚁 Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      settings.movement.fly = Value
      if Value then
         local rootPart = getRootPart()
         if rootPart then
            -- Create BodyVelocity for fly
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            connections.fly = RunService.Heartbeat:Connect(function()
               if not settings.movement.fly then return end
               local camera = workspace.CurrentCamera
               local moveVector = getHumanoid().MoveDirection
               
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
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                  velocity = velocity - Vector3.new(0, 1, 0)
               end
               
               bodyVelocity.Velocity = velocity * settings.movement.speed
            end)
         end
      else
         if connections.fly then
            connections.fly:Disconnect()
            connections.fly = nil
         end
         local rootPart = getRootPart()
         if rootPart then
            local bodyVelocity = rootPart:FindFirstChild("BodyVelocity")
            if bodyVelocity then
               bodyVelocity:Destroy()
            end
         end
      end
   end,
})

local NoClipToggle = MovementTab:CreateToggle({
   Name = "👻 NoClip",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value)
      settings.movement.noclip = Value
      if Value then
         connections.noclip = RunService.Stepped:Connect(function()
            local character = getCharacter()
            if character then
               for _, part in pairs(character:GetChildren()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = false
                  end
               end
            end
         end)
      else
         if connections.noclip then
            connections.noclip:Disconnect()
            connections.noclip = nil
         end
         local character = getCharacter()
         if character then
            for _, part in pairs(character:GetChildren()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                  part.CanCollide = true
               end
            end
         end
      end
   end,
})

-- Visuals Section (Main Tab)
local MainSection = MainTab:CreateSection("👁️ Visuals")

local ESPToggle = MainTab:CreateToggle({
   Name = "👁️ ESP Master",
   CurrentValue = false,
   Flag = "ESPMaster",
   Callback = function(Value)
      ESP.Enabled = Value
      settings.visuals.esp = Value
   end,
})

local BoxToggle = MainTab:CreateToggle({
   Name = "📦 ESP Boxes",
   CurrentValue = false,
   Flag = "ESPBoxes",
   Callback = function(Value)
      ESP.ShowBox = Value
   end,
})

local NameToggle = MainTab:CreateToggle({
   Name = "🏷️ Show Names",
   CurrentValue = false,
   Flag = "ESPNames",
   Callback = function(Value)
      ESP.ShowName = Value
   end,
})

local HealthToggle = MainTab:CreateToggle({
   Name = "❤️ Health Bars",
   CurrentValue = false,
   Flag = "ESPHealth",
   Callback = function(Value)
      ESP.ShowHealth = Value
   end,
})

local TracerToggle = MainTab:CreateToggle({
   Name = "📍 Tracers",
   CurrentValue = false,
   Flag = "ESPTracers",
   Callback = function(Value)
      ESP.ShowTracer = Value
   end,
})

-- Combat Section
local CombatSection = CombatTab:CreateSection("⚔️ Combat")

-- Team Detection Function
local function isOnSameTeam(player1, player2)
   if not settings.aimbot.teamCheck then return false end
   
   if player1.Team and player2.Team then
      return player1.Team == player2.Team
   end
   
   if player1.TeamColor and player2.TeamColor then
      return player1.TeamColor == player2.TeamColor
   end
   
   return false
end

-- Wall Detection Function
local function canSeeTarget(targetPlayer)
   if not settings.aimbot.wallCheck then return true end
   
   local character = getCharacter()
   if not character or not character:FindFirstChild("Head") then
      return false
   end
   
   if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild(settings.aimbot.targetPart) then
      return false
   end
   
   local origin = character.Head.Position
   local targetPosition = targetPlayer.Character[settings.aimbot.targetPart].Position
   local direction = (targetPosition - origin)
   
   local raycastParams = RaycastParams.new()
   raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
   raycastParams.FilterDescendantsInstances = {character, targetPlayer.Character}
   
   local raycastResult = workspace:Raycast(origin, direction, raycastParams)
   
   return raycastResult == nil
end

-- FOV Circle
local function createFOVCircle()
   if fovCircle then
      fovCircle:Remove()
   end
   
   fovCircle = Drawing.new("Circle")
   fovCircle.Color = Color3.fromRGB(255, 255, 255)
   fovCircle.Thickness = 2
   fovCircle.Transparency = 1
   fovCircle.Filled = false
   fovCircle.Visible = settings.visuals.showFOV
   fovCircle.Radius = settings.aimbot.fov
end

local function updateFOVCircle()
   if fovCircle then
      local mousePosition = UserInputService:GetMouseLocation()
      fovCircle.Position = mousePosition
      fovCircle.Radius = settings.aimbot.fov
   end
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
         
         if not canSeeTarget(player) then
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

-- Combat Toggles
local AimbotToggle = CombatTab:CreateToggle({
   Name = "🎯 Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      settings.aimbot.enabled = Value
      if Value then
         createFOVCircle()
         
         connections.aimbot = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
               local target = getClosestPlayer()
               if target then
                  aimAtPlayer(target)
               end
            end
         end)
         
         connections.fovUpdate = RunService.RenderStepped:Connect(updateFOVCircle)
      else
         if connections.aimbot then
            connections.aimbot:Disconnect()
            connections.aimbot = nil
         end
         if connections.fovUpdate then
            connections.fovUpdate:Disconnect()
            connections.fovUpdate = nil
         end
         if fovCircle then
            fovCircle:Remove()
            fovCircle = nil
         end
      end
   end,
})

local TriggerBotToggle = CombatTab:CreateToggle({
   Name = "🔫 Trigger Bot",
   CurrentValue = false,
   Flag = "TriggerBot",
   Callback = function(Value)
      settings.combat.triggerBot = Value
      if Value then
         connections.triggerBot = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local origin = camera.CFrame.Position
            local direction = camera.CFrame.LookVector * 1000
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {getCharacter()}
            
            local raycastResult = workspace:Raycast(origin, direction, raycastParams)
            
            if raycastResult and raycastResult.Instance then
               local hitPart = raycastResult.Instance
               local character = hitPart.Parent
               
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
         end)
      else
         if connections.triggerBot then
            connections.triggerBot:Disconnect()
            connections.triggerBot = nil
         end
      end
   end,
})

-- Improved Silent Aim using remote hooking
local function hookRemotes()
   local mt = getrawmetatable(game)
   local oldNamecall = mt.__namecall
   
   setreadonly(mt, false)
   mt.__namecall = function(self, ...)
      local method = getnamecallmethod()
      local args = {...}
      
      if method == "FireServer" and settings.combat.silentAim then
         local target = getClosestPlayer()
         if target and target.Character and target.Character:FindFirstChild(settings.aimbot.targetPart) then
            -- Modify the first Vector3 argument (usually the target position)
            for i, arg in ipairs(args) do
               if typeof(arg) == "Vector3" then
                  args[i] = target.Character[settings.aimbot.targetPart].Position
                  break
               end
            end
         end
      end
      
      return oldNamecall(self, unpack(args))
   end
   setreadonly(mt, true)
end

local SilentAimToggle = CombatTab:CreateToggle({
   Name = "🤫 Silent Aim",
   CurrentValue = false,
   Flag = "SilentAim",
   Callback = function(Value)
      settings.combat.silentAim = Value
      if Value then
         safeCall(hookRemotes)
      end
   end,
})

local InfAmmoToggle = CombatTab:CreateToggle({
   Name = "🔫 Infinite Ammo",
   CurrentValue = false,
   Flag = "InfAmmo",
   Callback = function(Value)
      settings.combat.infAmmo = Value
      if Value then
         connections.infAmmo = RunService.Heartbeat:Connect(function()
            safeCall(function()
               -- Multiple methods to find ammo values
               local playerGui = LocalPlayer.PlayerGui
               
               -- Method 1: Common GUI paths
               for _, guiName in pairs({"GUI", "Vitals", "HUD", "Interface"}) do
                  local gui = playerGui:FindFirstChild(guiName)
                  if gui then
                     for _, ammoName in pairs({"ammocount", "ammo", "Ammo", "AmmoLeft", "currentAmmo"}) do
                        local ammoObj = gui:FindFirstChild(ammoName, true)
                        if ammoObj and ammoObj.Value then
                           ammoObj.Value = 999
                        end
                     end
                  end
               end
               
               -- Method 2: Check ReplicatedStorage for ammo values
               for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                  if obj.Name:lower():find("ammo") and obj:IsA("IntValue") or obj:IsA("NumberValue") then
                     obj.Value = 999
                  end
               end
            end)
            wait(0.5)
         end)
      else
         if connections.infAmmo then
            connections.infAmmo:Disconnect()
            connections.infAmmo = nil
         end
      end
   end,
})

-- Settings Section
local SettingsSection = CombatTab:CreateSection("⚙️ Aimbot Settings")

local TeamCheckToggle = CombatTab:CreateToggle({
   Name = "👥 Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
      settings.aimbot.teamCheck = Value
      ESP.Teamcheck = Value
   end,
})

local WallCheckToggle = CombatTab:CreateToggle({
   Name = "🧱 Wall Check",
   CurrentValue = false,
   Flag = "WallCheck",
   Callback = function(Value)
      settings.aimbot.wallCheck = Value
   end,
})

local ShowFOVToggle = CombatTab:CreateToggle({
   Name = "👁️ Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOV",
   Callback = function(Value)
      settings.visuals.showFOV = Value
      if fovCircle then
         fovCircle.Visible = Value
      end
   end,
})

local AimbotFOVSlider = CombatTab:CreateSlider({
   Name = "🎯 Aimbot FOV",
   Range = {10, 360},
   Increment = 5,
   Suffix = "°",
   CurrentValue = 90,
   Flag = "AimbotFOV",
   Callback = function(Value)
      settings.aimbot.fov = Value
   end,
})

local AimbotSmoothSlider = CombatTab:CreateSlider({
   Name = "🎯 Aimbot Smoothing",
   Range = {1, 20},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "AimbotSmooth",
   Callback = function(Value)
      settings.aimbot.smoothing = Value
   end,
})

local TargetPartDropdown = CombatTab:CreateDropdown({
   Name = "🎯 Target Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "TargetPart",
   Callback = function(Option)
      settings.aimbot.targetPart = Option[1]
   end,
})

-- Misc Section
local MiscSection = MiscTab:CreateSection("🔧 Miscellaneous")

local AntiKickToggle = MiscTab:CreateToggle({
   Name = "🛡️ Anti Kick",
   CurrentValue = false,
   Flag = "AntiKick",
   Callback = function(Value)
      if Value then
         connections.antiKick = LocalPlayer.Kicking:Connect(function()
            return false
         end)
      else
         if connections.antiKick then
            connections.antiKick:Disconnect()
            connections.antiKick = nil
         end
      end
   end,
})

local AutoRespawnToggle = MiscTab:CreateToggle({
   Name = "🔄 Auto Respawn",
   CurrentValue = false,
   Flag = "AutoRespawn",
   Callback = function(Value)
      if Value then
         connections.autoRespawn = LocalPlayer.CharacterRemoving:Connect(function()
            wait(0.1)
            LocalPlayer:LoadCharacter()
         end)
      else
         if connections.autoRespawn then
            connections.autoRespawn:Disconnect()
            connections.autoRespawn = nil
         end
      end
   end,
})

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
   
   -- Restore original values
   local humanoid = getHumanoid()
   if humanoid then
      if originalValues.walkSpeed then
         humanoid.WalkSpeed = originalValues.walkSpeed
      end
      if originalValues.jumpPower then
         humanoid.JumpPower = originalValues.jumpPower
      end
   end
end

-- Cleanup on game close
game:GetService("Players").PlayerRemoving:Connect(function(player)
   if player == LocalPlayer then
      cleanup()
   end
end)

-- Set default ESP settings
ESP.BoxType = "Corner Box Esp"
ESP.TracerPosition = "Bottom"

print("AktusHUB v1.1 loaded successfully!")
