-- Load Fluent UI Library with improved error handling
local function loadLibrary()
    -- Try to load the library with pcall for safe error handling
    local success, result = pcall(function()
        -- Try to fetch and execute the external script
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    -- If there was an error during loading, handle it
    if not success then
        warn("Failed to load UI library:", result)
        -- Send a notification to the user with the error message
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Failed to load UI library. Please try again.",
            Duration = 5
        })
        -- Optionally, log the error for further debugging
        print("Error loading Fluent UI Library:", result)
        return nil
    end

    -- Return the successfully loaded library
    return result
end

local Fluent = loadLibrary()
if not Fluent then return end

-- Initialize core services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Core variables
local player = Players.LocalPlayer
if not player then return end

-- Save Manager setup
local SaveManager = {
    Folder = "LovelyHub",
    ConfigName = "AgeOfTitansConfig"
}

-- Game validation
local SUPPORTED_GAMES = {
    [17188326828] = "Age of Titans"
}

if not SUPPORTED_GAMES[game.PlaceId] then
    StarterGui:SetCore("SendNotification", {
        Title = "Game Not Supported",
        Text = "Only Age of Titans is supported!",
        Duration = 5
    })
    return
end

-- Create window
local Window = Fluent:CreateWindow({
    Title = "LovelyHub - Age Of Titans",
    SubTitle = "by LovelyTeam",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 440),
    Acrylic = false,
    Theme = "Dark"
})

-- Initialize tabs
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local KaijuTab = Window:AddTab({ Title = "Kaiju", Icon = "dragon" })
local MiscTab = Window:AddTab({ Title = "Misc", Icon = "settings" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Settings
local Settings = {
    autoTarget = false,
    attackRange = 50,
    speedBoost = 16,
    infiniteBreath = false,
    antiRagdoll = false,
    autoRoar = false,
    glowActive = false,
    soundsActive = false,
    visualEffectsActive = false,
    espActive = false,
    selectedSounds = {},
    soundFrequency = 0.5
}

-- Main Tab
local MainSection = MainTab:AddSection("Main Features")

MainTab:AddParagraph({
    Title = "Welcome to LovelyHub",
    Content = "Nah I'd cheat 💀."
})

MainTab:AddButton({
    Title = "Infinite Yield",
    Description = "Load Infinite Yield admin commands",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end
})

MainTab:AddButton({
    Title = "Unlock Dev Things",
    Description = "Unlocks developer-only kaijus",
    Callback = function()
        local speaker = game.Players.LocalPlayer
        local creatorId = game.CreatorId
        
        if game.CreatorType == Enum.CreatorType.User then
            speaker.UserId = creatorId
        else
            local groupInfo = game:GetService("GroupService"):GetGroupInfoAsync(creatorId)
            speaker.UserId = groupInfo.Owner.Id
        end
        
        StarterGui:SetCore("SendNotification", {
            Title = "Success!",
            Text = "Consider yourself a dev noob!",
            Duration = 3
        })
    end
})

MainTab:AddButton({
    Title = "Unlock All Skins",
    Description = "Unlocks all kaiju skins",
    Callback = function()
        local kaijusFolder = player:FindFirstChild("Kaijus")
        local kaijusList = {
            "Dagon", "EvolvedGodzilla", "Godzilla2014", "Kong", "Shimo", "ShowaGigan"
        }
        
        local function activateAllBooleans(folder)
            if folder then
                for _, item in pairs(folder:GetChildren()) do
                    if item:IsA("BoolValue") then
                        item.Value = true
                    elseif item:IsA("Folder") then
                        activateAllBooleans(item)
                    end
                end
            end
        end
        
        if kaijusFolder then
            for _, kaijuName in pairs(kaijusList) do
                local kaiju = kaijusFolder:FindFirstChild(kaijuName)
                if kaiju then
                    activateAllBooleans(kaiju)
                end
            end
        end
        
        StarterGui:SetCore("SendNotification", {
            Title = "Success!",
            Text = "Now you can be that lemon xd",
            Duration = 3
        })
    end
})

-- Auto target
MainTab:AddToggle({
    Title = "Auto Target",
    Default = false,
    Callback = function(Value)
        Settings.autoTarget = Value
        
        if Value then
            Settings.autoTargetConnection = RunService.Heartbeat:Connect(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local closest = nil
                local minDist = Settings.attackRange
                
                for _, model in ipairs(workspace:GetChildren()) do
                    if model:IsA("Model") 
                        and model:FindFirstChild("Humanoid") 
                        and model:FindFirstChild("HumanoidRootPart") 
                        and (model.Name:lower():find("titan") or model.Name:lower():find("kaiju")) then
                        
                        local dist = (character.HumanoidRootPart.Position - model.HumanoidRootPart.Position).magnitude
                        if dist < minDist then
                            closest = model
                            minDist = dist
                        end
                    end
                end
                
                if closest and character:FindFirstChild("RemoteEvent") then
                    character.RemoteEvent:FireServer("Target", closest)
                end
            end)
        else
            if Settings.autoTargetConnection then
                Settings.autoTargetConnection:Disconnect()
                Settings.autoTargetConnection = nil
            end
        end
    end
})

MainTab:AddSlider({
    Title = "Attack Range",
    Default = 50,
    Min = 10,
    Max = 100,
    Callback = function(Value)
        Settings.attackRange = Value
    end
})

MainTab:AddDropdown({
    Title = "Attack Mode",
    Default = "Balanced",
    Values = {"Aggressive", "Balanced", "Defensive", "Stealth", "Berserk"},
    Multi = false,
    Callback = function(Value)
        Settings.attackMode = Value
        
        if Value == "Aggressive" then
            Settings.attackRange = 70
        elseif Value == "Defensive" then
            Settings.attackRange = 30
        elseif Value == "Stealth" then
            Settings.attackRange = 20
        elseif Value == "Berserk" then
            Settings.attackRange = 100
        else
            Settings.attackRange = 50
        end
        
        -- Update attack range slider
        for _, element in pairs(MainTab:GetElements()) do
            if element.Title == "Attack Range" then
                element:Set(Settings.attackRange)
                break
            end
        end
        
        StarterGui:SetCore("SendNotification", {
            Title = "Attack Mode",
            Text = "Set to " .. Value .. " mode!",
            Duration = 2
        })
    end
})

-- Find titan zones
local titanZones = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name:lower():find("titan") and (obj:IsA("Part") or obj:IsA("SpawnLocation") or obj:IsA("Model")) then
        table.insert(titanZones, obj)
    end
end

if #titanZones == 0 then
    table.insert(titanZones, {Name = "Titan Zone 1", Position = Vector3.new(0, 50, 0)})
    table.insert(titanZones, {Name = "Titan Zone 2", Position = Vector3.new(100, 50, 100)})
    table.insert(titanZones, {Name = "Titan Zone 3", Position = Vector3.new(-100, 50, -100)})
end

local teleportLocations = {}
for i, zone in ipairs(titanZones) do
    if typeof(zone) == "Instance" then
        table.insert(teleportLocations, zone.Name)
    else
        table.insert(teleportLocations, zone.Name)
    end
end

MainTab:AddDropdown({
    Title = "Teleport Location",
    Default = teleportLocations[1],
    Values = teleportLocations,
    Multi = false,
    Callback = function(Value)
        Settings.selectedTeleportLocation = Value
    end
})

MainTab:AddButton({
    Title = "Teleport to Selected Zone",
    Description = "Instantly teleports to the selected zone",
    Callback = function()
        local selectedLocation = Settings.selectedTeleportLocation or teleportLocations[1]
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        for _, zone in ipairs(titanZones) do
            if typeof(zone) == "Instance" and zone.Name == selectedLocation then
                if zone:IsA("Model") and zone:FindFirstChild("HumanoidRootPart") then
                    character:SetPrimaryPartCFrame(zone.HumanoidRootPart.CFrame + Vector3.new(10, 5, 10))
                elseif zone:IsA("BasePart") then
                    character:SetPrimaryPartCFrame(zone.CFrame + Vector3.new(0, 5, 0))
                end
                break
            elseif typeof(zone) == "table" and zone.Name == selectedLocation then
                character:SetPrimaryPartCFrame(CFrame.new(zone.Position))
                break
            end
        end
        
        StarterGui:SetCore("SendNotification", {
            Title = "Teleported",
            Text = "Teleported to " .. selectedLocation,
            Duration = 2
        })
    end
})

-- Kaiju Tab Features
local KaijuSection = KaijuTab:AddSection("Kaiju Features")

-- Speed boost with Left Shift
local selectedSpeed = 50
local originalSpeed = 16
local speedActive = false

KaijuTab:AddSlider({
    Title = "Speed Boost Value",
    Default = 50,
    Min = 16,
    Max = 200,
    Callback = function(Value)
        selectedSpeed = Value
        Settings.speedBoost = Value
    end
})

-- Set up the speed boost key detection
local function setupSpeedBoost()
    if Settings.speedBoostConnection then
        Settings.speedBoostConnection:Disconnect()
    end
    
    Settings.speedBoostConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift and not gameProcessed then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                originalSpeed = character.Humanoid.WalkSpeed
                speedActive = true
                
                spawn(function()
                    wait(0.5)
                    if speedActive then
                        character.Humanoid.WalkSpeed = selectedSpeed
                        StarterGui:SetCore("SendNotification", {
                            Title = "Speed Boost",
                            Text = "Speed increased to " .. selectedSpeed,
                            Duration = 1
                        })
                    end
                end)
            end
        end
    end)
    
    Settings.speedBoostEndConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift and not gameProcessed then
            speedActive = false
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = originalSpeed
                StarterGui:SetCore("SendNotification", {
                    Title = "Speed Boost",
                    Text = "Speed returned to normal",
                    Duration = 1
                })
            end
        end
    end)
end

setupSpeedBoost()

-- Infinite Breath Toggle
KaijuTab:AddToggle({
    Title = "Infinite Breath",
    Default = false,
    Callback = function(Value)
        Settings.infiniteBreath = Value
        local character = player.Character
        
        if character and character:FindFirstChild("RemoteEvent") then
            character.RemoteEvent:FireServer(Value and "Attack5BeamStart" or "Attack5BeamEnd")
            
            StarterGui:SetCore("SendNotification", {
                Title = "Infinite Breath",
                Text = Value and "Infinite breath activated!" or "Infinite breath deactivated!",
                Duration = 3
            })
        end
    end
})

-- Add H keybind for Infinite Breath
local function setupInfiniteBreathKeybind()
    if Settings.infiniteBreathKeybind then
        Settings.infiniteBreathKeybind:Disconnect()
    end
    
    Settings.infiniteBreathKeybind = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.H and not gameProcessed then
            Settings.infiniteBreath = not Settings.infiniteBreath
            
            -- Update the UI toggle
            for _, element in pairs(KaijuTab:GetElements()) do
                if element.Title == "Infinite Breath" then
                    element:Set(Settings.infiniteBreath)
                    break
                end
            end
        end
    end)
end

setupInfiniteBreathKeybind()

-- Auto roar feature
KaijuTab:AddToggle({
    Title = "Auto Roar",
    Default = false,
    Callback = function(Value)
        Settings.autoRoar = Value
        
        if Value then
            Settings.autoRoarLoop = spawn(function()
                while Settings.autoRoar do
                    local character = player.Character
                    if character and character:FindFirstChild("RemoteEvent") then
                        character.RemoteEvent:FireServer("Roar")
                        character.RemoteEvent:FireServer("Roar2")
                    end
                    wait(5)
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Auto Roar",
                Text = "Auto roar activated!",
                Duration = 3
            })
        else
            Settings.autoRoar = false
            Settings.autoRoarLoop = nil
            
            StarterGui:SetCore("SendNotification", {
                Title = "Auto Roar",
                Text = "Auto roar deactivated!",
                Duration = 3
            })
        end
    end
})

-- Anti-Ragdoll feature
KaijuTab:AddToggle({
    Title = "Anti-Ragdoll",
    Default = false,
    Callback = function(Value)
        Settings.antiRagdoll = Value
        
        if Value then
            Settings.antiRagdollConnection = RunService.Heartbeat:Connect(function()
                local character = player.Character
                if character then
                    for _, descendant in pairs(character:GetDescendants()) do
                        if descendant:IsA("Script") and (descendant.Name:lower():find("ragdoll") or descendant.Name:lower():find("fall")) then
                            descendant.Disabled = true
                        elseif descendant:IsA("BoolValue") and (descendant.Name:lower():find("ragdoll") or descendant.Name:lower():find("falling")) then
                            descendant.Value = false
                        end
                    end
                    
                    if character:FindFirstChild("Humanoid") and character.Humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                        character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Anti-Ragdoll",
                Text = "You will no longer ragdoll!",
                Duration = 3
            })
        else
            if Settings.antiRagdollConnection then
                Settings.antiRagdollConnection:Disconnect()
                Settings.antiRagdollConnection = nil
            end
            
            local character = player.Character
            if character then
                for _, descendant in pairs(character:GetDescendants()) do
                    if descendant:IsA("Script") and (descendant.Name:lower():find("ragdoll") or descendant.Name:lower():find("fall")) then
                        descendant.Disabled = false
                    end
                end
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = "Anti-Ragdoll",
                Text = "Anti-Ragdoll deactivated!",
                Duration = 3
            })
        end
    end
})

-- Ability spam feature
KaijuTab:AddToggle({
    Title = "Ability Spam",
    Default = false,
    Callback = function(Value)
        Settings.abilitySpam = Value
        
        if Value then
            Settings.abilitySpamLoop = spawn(function()
                while Settings.abilitySpam do
                    local character = player.Character
                    if character and character:FindFirstChild("RemoteEvent") then
                        for i = 1, 5 do
                            character.RemoteEvent:FireServer("Attack" .. i)
                            wait(0.2)
                        end
                    end
                    wait(1)
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Ability Spam",
                Text = "Ability spam activated!",
                Duration = 3
            })
        else
            Settings.abilitySpam = false
            Settings.abilitySpamLoop = nil
            
            StarterGui:SetCore("SendNotification", {
                Title = "Ability Spam",
                Text = "Ability spam deactivated!",
                Duration = 3
            })
        end
    end
})

-- Jump power boost
KaijuTab:AddSlider({
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 250,
    Callback = function(Value)
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
            Settings.jumpPower = Value
            
            StarterGui:SetCore("SendNotification", {
                Title = "Jump Power",
                Text = "Jump power set to " .. Value,
                Duration = 2
            })
        end
    end
})

-- Misc Tab Features
local MiscSection = MiscTab:AddSection("Misc Features")

-- Glow toggle
MiscTab:AddToggle({
    Title = "Attack Glow",
    Default = false,
    Callback = function(Value)
        Settings.glowActive = Value
        local character = player.Character
        
        if character and character:FindFirstChild("RemoteEvent") then
            character.RemoteEvent:FireServer(Value and "Attack5GlowStart" or "Attack5GlowEnd")
            
            StarterGui:SetCore("SendNotification", {
                Title = "Attack Glow",
                Text = Value and "Attack glow activated!" or "Attack glow deactivated!",
                Duration = 3
            })
        end
    end
})

-- Sound types
local soundTypes = {"Attack1", "Attack2", "Attack3", "Attack4", "Attack5", "Roar", "Roar2"}

MiscTab:AddDropdown({
    Title = "Sound Types",
    Default = soundTypes,
    Values = soundTypes,
    Multi = true,
    Callback = function(Value)
        Settings.selectedSounds = {}
        for _, sound in ipairs(Value) do
            Settings.selectedSounds[sound] = true
        end
    end
})

MiscTab:AddToggle({
    Title = "Attack Sounds",
    Default = false,
    Callback = function(Value)
        Settings.soundsActive = Value
        
        if Value then
            Settings.soundsLoop = spawn(function()
                while Settings.soundsActive do
                    local character = player.Character
                    if character and character:FindFirstChild("RemoteEvent") then
                        for sound, enabled in pairs(Settings.selectedSounds) do
                            if enabled then
                                character.RemoteEvent:FireServer(sound, 9.333333015441895)
                            end
                        end
                    end
                    wait(Settings.soundFrequency or 0.5)
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Attack Sounds",
                Text = "Attack sounds activated!",
                Duration = 3
            })
        else
            Settings.soundsActive = false
            Settings.soundsLoop = nil
            
            StarterGui:SetCore("SendNotification", {
                Title = "Attack Sounds",
                Text = "Attack sounds deactivated!",
                Duration = 3
            })
        end
    end
})

MiscTab:AddSlider({
    Title = "Sound Frequency",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Callback = function(Value)
        Settings.soundFrequency = Value
    end
})

-- Visual effects toggle
MiscTab:AddToggle({
    Title = "Visual Effects",
    Default = false,
    Callback = function(Value)
        Settings.visualEffectsActive = Value
        
        if Value then
            Settings.visualEffectsLoop = spawn(function()
                while Settings.visualEffectsActive do
                    local character = player.Character
                    if character and character:FindFirstChild("RemoteEvent") then
                        local effectTypes = {"Attack5Charge", "Attack5GlowStart", "Attack3"}
                        for _, effect in ipairs(effectTypes) do
                            character.RemoteEvent:FireServer(effect)
                        end
                    end
                    wait(0.5)
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Visual Effects",
                Text = "Visual effects activated!",
                Duration = 3
            })
        else
            Settings.visualEffectsActive = false
            Settings.visualEffectsLoop = nil
            
            local character = player.Character
            if character and character:FindFirstChild("RemoteEvent") then
                character.RemoteEvent:FireServer("Attack5GlowEnd")
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = "Visual Effects",
                Text = "Visual effects deactivated!",
                Duration = 3
            })
        end
    end
})

-- Player ESP
MiscTab:AddToggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(Value)
        Settings.espActive = Value
        
        if Value then
            Settings.espLoop = RunService.RenderStepped:Connect(function()
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player then
                        local character = target.Character
                        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                            local rootPart = character.HumanoidRootPart
                            
                            local esp = rootPart:FindFirstChild("ESP")
                            if not esp then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "ESP"
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 200, 0, 50)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.Parent = rootPart
                                
                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Name = "NameLabel"
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                nameLabel.Font = Enum.Font.GothamBold
                                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                nameLabel.TextStrokeTransparency = 0
                                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                nameLabel.TextSize = 14
                                nameLabel.Parent = billboard
                                
                                local distanceLabel = Instance.new("TextLabel")
                                distanceLabel.Name = "DistanceLabel"
                                distanceLabel.BackgroundTransparency = 1
                                distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                distanceLabel.Font = Enum.Font.Gotham
                                distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                distanceLabel.TextStrokeTransparency = 0
                                distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                distanceLabel.TextSize = 12
                                distanceLabel.Parent = billboard
                            end
                            
                            local esp = rootPart:FindFirstChild("ESP")
                            if esp then
                                local myRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                local distance = myRootPart and (myRootPart.Position - rootPart.Position).Magnitude or 0
                                
                                local nameLabel = esp:FindFirstChild("NameLabel")
                                if nameLabel then
                                    nameLabel.Text = target.Name
                                end
                                
                                local distanceLabel = esp:FindFirstChild("DistanceLabel")
                                if distanceLabel then
                                    distanceLabel.Text = math.floor(distance) .. " studs"
                                end
                            end
                        end
                    end
                end
            end)
            
            StarterGui:SetCore("SendNotification", {
                Title = "Player ESP",
                Text = "ESP activated!",
                Duration = 3
            })
        else
            if Settings.espLoop then
                Settings.espLoop:Disconnect()
                Settings.espLoop = nil
            end
            
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player then
                    local character = target.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local esp = character.HumanoidRootPart:FindFirstChild("ESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = "Player ESP",
                Text = "ESP deactivated!",
                Duration = 3
            })
        end
    end
})

-- Settings Tab
local SettingsSection = SettingsTab:AddSection("Settings")

-- Create a folder for configs if it doesn't exist
if not isfolder(SaveManager.Folder) then
    makefolder(SaveManager.Folder)
end

-- Save settings function
function SaveManager:Save(name, data)
    if not name then name = self.ConfigName end
    writefile(self.Folder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(data))
end

-- Load settings function
function SaveManager:Load(name)
    if not name then name = self.ConfigName end
    if isfile(self.Folder .. "/" .. name .. ".json") then
        return game:GetService("HttpService"):JSONDecode(readfile(self.Folder .. "/" .. name .. ".json"))
    end
end

SettingsTab:AddButton({
    Title = "Save Settings",
    Description = "Saves your current settings",
    Callback = function()
        SaveManager:Save(SaveManager.ConfigName, Settings)
        
        StarterGui:SetCore("SendNotification", {
            Title = "Settings Saved",
            Text = "Your settings have been saved!",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Load Settings",
    Description = "Loads your saved settings",
    Callback = function()
        local savedSettings = SaveManager:Load(SaveManager.ConfigName)
        
        if savedSettings then
            -- Apply saved settings to all elements
            for _, tab in pairs({MainTab, KaijuTab, MiscTab}) do
                for _, element in pairs(tab:GetElements()) do
                    local settingName = element.Title:gsub("%s+", ""):lower()
                    if savedSettings[settingName] ~= nil then
                        element:Set(savedSettings[settingName])
                    end
                end
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = "Settings Loaded",
                Text = "Your settings have been loaded!",
                Duration = 3
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "No Settings Found",
                Text = "No saved settings found!",
                Duration = 3
            })
        end
    end
})

-- UI Customization
local UISection = SettingsTab:AddSection("UI Customization")

local themeColors = {
    "Default",
    "Purple",
    "Blue",
    "Green",
    "Red"
}

SettingsTab:AddDropdown({
    Title = "Theme Color",
    Default = "Purple",
    Values = themeColors,
    Multi = false,
    Callback = function(Value)
        local themes = {
            Default = "Default",
            Purple = "Purple",
            Blue = "Aqua",
            Green = "Green",
            Red = "Red"
        }
        
        Window:SetTheme(themes[Value])
        Settings.theme = Value
        
        StarterGui:SetCore("SendNotification", {
            Title = "Theme Changed",
            Text = "Theme set to " .. Value,
            Duration = 3
        })
    end
})

-- Reset settings
SettingsTab:AddButton({
    Title = "Reset All Settings",
    Description = "Resets all settings to default",
    Callback = function()
        StarterGui:SetCore("SendNotification", {
            Title = "Warning",
            Text = "Are you sure? Click Reset again to confirm.",
            Duration = 5
        })
        
        Settings.resetConfirmation = true
        spawn(function()
            wait(5)
            Settings.resetConfirmation = false
        end)
    end
})

SettingsTab:AddButton({
    Title = "Confirm Reset",
    Description = "Click to confirm reset",
    Callback = function()
        if Settings.resetConfirmation then
            -- Reset all settings to default
            for _, tab in pairs({MainTab, KaijuTab, MiscTab}) do
                for _, element in pairs(tab:GetElements()) do
                    if element.Type == "Toggle" then
                        element:Set(false)
                    elseif element.Type == "Slider" then
                        element:Set(element.Default)
                    elseif element.Type == "Dropdown" and not element.Multi then
                        element:Set(element.Default)
                    end
                end
            end
            
            -- Reset all settings
            for key in pairs(Settings) do
                if type(Settings[key]) == "boolean" then
                    Settings[key] = false
                elseif type(Settings[key]) == "number" then
                    Settings[key] = 0
                elseif type(Settings[key]) == "table" then
                    Settings[key] = {}
                end
            end
            
            -- Reset specific defaults
            Settings.attackRange = 50
            Settings.speedBoost = 16
            Settings.soundFrequency = 0.5
            
            -- Delete saved config
            if isfile(SaveManager.Folder .. "/" .. SaveManager.ConfigName .. ".json") then
                delfile(SaveManager.Folder .. "/" .. SaveManager.ConfigName .. ".json")
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = "Reset Complete",
                Text = "All settings reset to default!",
                Duration = 3
            })
            
            Settings.resetConfirmation = false
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Reset Cancelled",
                Text = "Click Reset All Settings first!",
                Duration = 3
            })
        end
    end
})

-- Credits section
SettingsTab:AddParagraph({
    Title = "Credits",
    Content = "LovelyHub created by LovelyTeam\nFluent UI Library by dawid-scripts"
})

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    local humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- Reapply speed
    if Settings.speedBoost ~= 16 then
        humanoid.WalkSpeed = Settings.speedBoost
    end
    
    -- Reapply jump power
    if Settings.jumpPower then
        humanoid.JumpPower = Settings.jumpPower
    end
    
    -- Set up speed boost again
    setupSpeedBoost()
    
    -- Set up infinite breath keybind again
    setupInfiniteBreathKeybind()
    
    -- Reapply infinite breath
    if Settings.infiniteBreath and newCharacter:FindFirstChild("RemoteEvent") then
        newCharacter.RemoteEvent:FireServer("Attack5BeamStart")
    end
    
    -- Reapply anti-ragdoll
    if Settings.antiRagdoll then
        Settings.antiRagdollConnection = RunService.Heartbeat:Connect(function()
            for _, item in ipairs(newCharacter:GetDescendants()) do
                if item:IsA("Script") and item.Name:lower():match("ragdoll") then
                    item.Disabled = true
                end
            end
            
            if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end)

-- Initialize window
Window:SelectTab(1)

-- Success notification
StarterGui:SetCore("SendNotification", {
    Title = "LovelyHub Loaded",
    Text = "Welcome to LovelyHub! Enjoy!",
    Duration = 5
})
