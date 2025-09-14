local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "AktusHUB v1.0",
   Icon = 0,
   LoadingTitle = "AktusHUB v 1.0 - loading",
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
   KeySystem = false,
   KeySettings = {
      Title = "AktusHUB | Key",
      Subtitle = "Key on discord",
      Note = "Join the discord to get the key!",
      FileName = "qwertyabcd",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/mYbw328T"}
   }
})

-- Load ESP Library
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

local MainTab = Window:CreateTab("🏠 Main", nil)
local MainSection = MainTab:CreateSection("🏃 Player")

-- Variables
local infiniteJumpConnection = nil
local aimbotConnection = nil
local fovUpdateConnection = nil
local triggerBotConnection = nil
local infAmmoConnection = nil
local silentAimConnection = nil
local aimbotEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local aimbotFOV = 90
local aimbotSmoothing = 1
local targetPart = "Head"
local fovCircle = nil
local originalWalkSpeed = 16
local customSpeed = 50
local wallCheck = false
local teamCheck = false
local infAmmoEnabled = false

local InfiniteJumpToggle = MainTab:CreateToggle({
   Name = "🚀 Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      if Value then
         infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
               game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
         end)
      else
         if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
         end
      end
   end,
})

local SpeedToggle = MainTab:CreateToggle({
   Name = "⚡ Speed Hack",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         if Value then
            originalWalkSpeed = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = customSpeed
         else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
         end
      end
   end,
})

local SpeedSlider = MainTab:CreateSlider({
   Name = "⚡ Walk Speed",
   Range = {16, 200},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "WalkSpeed",
   Callback = function(Value)
      customSpeed = Value
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         if SpeedToggle.CurrentValue then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
         end
      end
   end,
})

local JumpPowerSlider = MainTab:CreateSlider({
   Name = "🦘 Jump Power",
   Range = {50, 200},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

local MainSection2 = MainTab:CreateSection("👁️ Visuals")

-- Helper function to refresh ESP
local function refreshESP()
   if ESP.Enabled then
      ESP.Enabled = false
      wait(0.1)
      ESP.Enabled = true
   end
end

local ESPToggle = MainTab:CreateToggle({
   Name = "👁️ ESP Master",
   CurrentValue = false,
   Flag = "ESPMaster",
   Callback = function(Value)
      ESP.Enabled = Value
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

local DistanceToggle = MainTab:CreateToggle({
   Name = "📏 Show Distance",
   CurrentValue = false,
   Flag = "ESPDistance",
   Callback = function(Value)
      ESP.ShowDistance = Value
   end,
})

-- Color Pickers
local BoxColorPicker = MainTab:CreateColorPicker({
   Name = "🎨 Box Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "BoxColor",
   Callback = function(Value)
      ESP.BoxColor = Value
      refreshESP()
   end
})

local TracerColorPicker = MainTab:CreateColorPicker({
   Name = "🎨 Tracer Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "TracerColor",
   Callback = function(Value)
      ESP.TracerColor = Value
      refreshESP()
   end
})

local NameColorPicker = MainTab:CreateColorPicker({
   Name = "🎨 Name Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "NameColor",
   Callback = function(Value)
      ESP.NameColor = Value
      refreshESP()
   end
})

-- Combat Section
local CombatSection = MainTab:CreateSection("⚔️ Combat")

-- Team Detection Function
local function isOnSameTeam(player1, player2)
   if not teamCheck then return false end
   
   -- Method 1: Check Team property
   if player1.Team and player2.Team then
      return player1.Team == player2.Team
   end
   
   -- Method 2: Check TeamColor property
   if player1.TeamColor and player2.TeamColor then
      return player1.TeamColor == player2.TeamColor
   end
   
   -- Method 3: Check shirt color/template (main team detection method)
   if player1.Character and player2.Character then
      local shirt1 = player1.Character:FindFirstChild("Shirt")
      local shirt2 = player2.Character:FindFirstChild("Shirt")
      
      -- If both have shirts, compare the shirt templates
      if shirt1 and shirt2 then
         return shirt1.ShirtTemplate == shirt2.ShirtTemplate
      end
      
      -- If one has a shirt and the other doesn't, they're enemies
      if (shirt1 and not shirt2) or (not shirt1 and shirt2) then
         return false
      end
      
      -- Method 4: Check body colors as fallback
      local bodyColors1 = player1.Character:FindFirstChild("Body Colors")
      local bodyColors2 = player2.Character:FindFirstChild("Body Colors")
      if bodyColors1 and bodyColors2 then
         return bodyColors1.TorsoColor3 == bodyColors2.TorsoColor3
      end
   end
   
   return false
end

-- Wall Detection Function (ONLY for aimbot)
local function canSeeTarget(targetPlayer)
   if not wallCheck then return true end
   
   local localPlayer = game.Players.LocalPlayer
   if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Head") then
      return false
   end
   
   if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild(targetPart) then
      return false
   end
   
   local origin = localPlayer.Character.Head.Position
   local targetPosition = targetPlayer.Character[targetPart].Position
   local direction = (targetPosition - origin).Unit * (targetPosition - origin).Magnitude
   
   local raycastParams = RaycastParams.new()
   raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
   raycastParams.FilterDescendantsInstances = {localPlayer.Character, targetPlayer.Character}
   
   local raycastResult = workspace:Raycast(origin, direction, raycastParams)
   
   return raycastResult == nil
end

-- FOV Circle creation
local function createFOVCircle()
   if fovCircle then
      fovCircle:Remove()
   end
   
   fovCircle = Drawing.new("Circle")
   fovCircle.Color = Color3.fromRGB(255, 255, 255)
   fovCircle.Thickness = 2
   fovCircle.Transparency = 1
   fovCircle.Filled = false
   fovCircle.Visible = false
   fovCircle.Radius = aimbotFOV
end

-- Update FOV Circle
local function updateFOVCircle()
   if fovCircle then
      local mousePosition = game:GetService("UserInputService"):GetMouseLocation()
      fovCircle.Position = mousePosition
      fovCircle.Radius = aimbotFOV
   end
end

-- Aimbot functions
local function getClosestPlayer()
   local closestPlayer = nil
   local shortestDistance = math.huge
   local localPlayer = game.Players.LocalPlayer
   local camera = workspace.CurrentCamera
   
   for _, player in pairs(game.Players:GetPlayers()) do
      if player ~= localPlayer and player.Character and player.Character:FindFirstChild(targetPart) then
         -- Check team detection first
         if isOnSameTeam(localPlayer, player) then
            continue
         end
         
         -- Check wall detection (ONLY for aimbot)
         if not canSeeTarget(player) then
            continue
         end
         
         local targetPosition = player.Character[targetPart].Position
         local screenPoint, onScreen = camera:WorldToScreenPoint(targetPosition)
         
         if onScreen then
            local mousePosition = game:GetService("UserInputService"):GetMouseLocation()
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
            
            if distance < aimbotFOV and distance < shortestDistance then
               shortestDistance = distance
               closestPlayer = player
            end
         end
      end
   end
   
   return closestPlayer
end

-- Get target at crosshair (for triggerbot)
local function getTargetAtCrosshair()
   local localPlayer = game.Players.LocalPlayer
   local camera = workspace.CurrentCamera
   
   if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Head") then
      return nil
   end
   
   local origin = camera.CFrame.Position
   local direction = camera.CFrame.LookVector * 1000
   
   local raycastParams = RaycastParams.new()
   raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
   raycastParams.FilterDescendantsInstances = {localPlayer.Character}
   
   local raycastResult = workspace:Raycast(origin, direction, raycastParams)
   
   if raycastResult and raycastResult.Instance then
      local hitPart = raycastResult.Instance
      local character = hitPart.Parent
      
      if character:FindFirstChild("Humanoid") then
         local player = game.Players:GetPlayerFromCharacter(character)
         if player and player ~= localPlayer then
            -- Check team detection for triggerbot too
            if not isOnSameTeam(localPlayer, player) then
               return player
            end
         end
      end
   end
   
   return nil
end

local function aimAtPlayer(player)
   if player and player.Character and player.Character:FindFirstChild(targetPart) then
      local camera = workspace.CurrentCamera
      local targetPosition = player.Character[targetPart].Position
      local currentCFrame = camera.CFrame
      local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
      
      -- Smooth aiming
      camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / aimbotSmoothing)
   end
end

-- Simulate mouse click for triggerbot
local function clickMouse()
   local VirtualInputManager = game:GetService("VirtualInputManager")
   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
   wait(0.01)
   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local AimbotToggle = MainTab:CreateToggle({
   Name = "🎯 Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      aimbotEnabled = Value
      if Value then
         createFOVCircle()
         
         aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then -- Right mouse button
               local target = getClosestPlayer()
               if target then
                  aimAtPlayer(target)
               end
            end
         end)
         
         fovUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
            updateFOVCircle()
         end)
      else
         if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
         end
         if fovUpdateConnection then
            fovUpdateConnection:Disconnect()
            fovUpdateConnection = nil
         end
         if fovCircle then
            fovCircle:Remove()
            fovCircle = nil
         end
      end
   end,
})

local TeamCheckToggle = MainTab:CreateToggle({
   Name = "👥 Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
      teamCheck = Value
      -- Apply team check to ESP as well
      ESP.Teamcheck = Value
   end,
})

local WallCheckToggle = MainTab:CreateToggle({
   Name = "🧱 Wall Check (Aimbot Only)",
   CurrentValue = false,
   Flag = "WallCheck",
   Callback = function(Value)
      wallCheck = Value
   end,
})

local ShowFOVToggle = MainTab:CreateToggle({
   Name = "👁️ Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOV",
   Callback = function(Value)
      if fovCircle then
         fovCircle.Visible = Value
      end
   end,
})

local FOVColorPicker = MainTab:CreateColorPicker({
   Name = "🎨 FOV Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "FOVColor",
   Callback = function(Value)
      if fovCircle then
         fovCircle.Color = Value
      end
   end
})

local AimbotFOVSlider = MainTab:CreateSlider({
   Name = "🎯 Aimbot FOV",
   Range = {10, 360},
   Increment = 5,
   Suffix = "°",
   CurrentValue = 90,
   Flag = "AimbotFOV",
   Callback = function(Value)
      aimbotFOV = Value
   end,
})

local AimbotSmoothSlider = MainTab:CreateSlider({
   Name = "🎯 Aimbot Smoothing",
   Range = {1, 10},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "AimbotSmooth",
   Callback = function(Value)
      aimbotSmoothing = Value
   end,
})

local TargetPartDropdown = MainTab:CreateDropdown({
   Name = "🎯 Target Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "TargetPart",
   Callback = function(Option)
      targetPart = Option[1]
   end,
})

local InfAmmoToggle = MainTab:CreateToggle({
   Name = "🔫 Infinite Ammo",
   CurrentValue = false,
   Flag = "InfAmmo",
   Callback = function(Value)
      infAmmoEnabled = Value
      if Value then
         infAmmoConnection = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function()
               -- Method 1: Try GUI.Client.Variables path
               if game.Players.LocalPlayer.PlayerGui:FindFirstChild("GUI") then
                  local gui = game.Players.LocalPlayer.PlayerGui.GUI
                  if gui:FindFirstChild("Client") and gui.Client:FindFirstChild("Variables") then
                     local vars = gui.Client.Variables
                     if vars:FindFirstChild("ammocount") then
                        vars.ammocount.Value = 999
                     end
                     if vars:FindFirstChild("ammocount2") then
                        vars.ammocount2.Value = 999
                     end
                  end
               end
               
               -- Method 2: Try Vitals.Ammo path
               if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Vitals") then
                  local vitals = game.Players.LocalPlayer.PlayerGui.Vitals
                  if vitals:FindFirstChild("Ammo") and vitals.Ammo:FindFirstChild("AmmoLeft") then
                     vitals.Ammo.AmmoLeft.Value = 999
                  end
               end
            end)
            wait(0.5) -- Run every 0.5 seconds to reduce lag
         end)
      else
         if infAmmoConnection then
            infAmmoConnection:Disconnect()
            infAmmoConnection = nil
         end
      end
   end,
})

local TriggerBotToggle = MainTab:CreateToggle({
   Name = "🔫 Trigger Bot",
   CurrentValue = false,
   Flag = "TriggerBot",
   Callback = function(Value)
      triggerBotEnabled = Value
      if Value then
         triggerBotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local target = getTargetAtCrosshair()
            if target then
               clickMouse()
               wait(0.1) -- Prevent spam clicking
            end
         end)
      else
         if triggerBotConnection then
            triggerBotConnection:Disconnect()
            triggerBotConnection = nil
         end
      end
   end,
})

local SilentAimToggle = MainTab:CreateToggle({
   Name = "🤫 Silent Aim",
   CurrentValue = false,
   Flag = "SilentAim",
   Callback = function(Value)
      silentAimEnabled = Value
      if Value then
         silentAimConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
               local target = getClosestPlayer()
               if target and target.Character and target.Character:FindFirstChild(targetPart) then
                  -- Silent aim - redirect shot to target without moving camera
                  local mouse = game.Players.LocalPlayer:GetMouse()
                  local targetPosition = target.Character[targetPart].Position
                  
                  -- Hook mouse.Hit temporarily
                  spawn(function()
                     local originalHit = mouse.Hit
                     mouse.Hit = CFrame.new(targetPosition)
                     wait(0.1)
                     mouse.Hit = originalHit
                  end)
               end
            end
         end)
      else
         if silentAimConnection then
            silentAimConnection:Disconnect()
            silentAimConnection = nil
         end
      end
   end,
})

local NoRecoilToggle = MainTab:CreateToggle({
   Name = "🎯 No Recoil",
   CurrentValue = false,
   Flag = "NoRecoil",
   Callback = function(Value)
      -- No recoil implementation would go here
      print("No Recoil:", Value)
   end,
})

local NoSpreadToggle = MainTab:CreateToggle({
   Name = "🎯 No Spread",
   CurrentValue = false,
   Flag = "NoSpread",
   Callback = function(Value)
      -- No spread implementation would go here
      print("No Spread:", Value)
   end,
})

-- Set default ESP settings
ESP.BoxType = "Corner Box Esp"
ESP.TracerPosition = "Bottom"
