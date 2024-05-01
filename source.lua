--[[
    Open Aimbot
    Universal Open Source Aimbot
    Release 1.6.1
    ttwizz.su/pix
    
    Author: ttwiz_z (ttwizz)
    License: MIT
    GitHub: https://github.com/ttwizz/Open-Aimbot
]]



--! Services

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


--! Colour Handler

local function PackColour(Colour)
    return Colour and typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
end

local function UnpackColour(Colour)
    return Colour and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or Color3.fromRGB(255, 255, 255)
end


--! Importing Configuration

local ImportedConfiguration = {}

pcall(function()
    if getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
        ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
        for Key, Value in next, ImportedConfiguration do
            if Key == "AimKey" then
                ImportedConfiguration[Key] = #UserInputService:GetStringForKeyCode(Value) > 0 and UserInputService:GetStringForKeyCode(Value) or "V"
            elseif Key == "FoVColour" or Key == "ESPColour" then
                ImportedConfiguration[Key] = UnpackColour(Value)
            end
        end
    end
end)


--! Initializing Configuration

local Configuration = {}

--? Aimbot

Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
Configuration.OnePressMode = ImportedConfiguration["OnePressMode"] or false
Configuration.UseMouseMoving = ImportedConfiguration["UseMouseMoving"] or false
Configuration.AimKey = ImportedConfiguration["AimKey"] or "V"
Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false
Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
Configuration.GroupCheck = ImportedConfiguration["GroupCheck"] or false
Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
Configuration.PlayerCheck = ImportedConfiguration["PlayerCheck"] or false
Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}
Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 10
Configuration.ShowNotifications = ImportedConfiguration["ShowNotifications"] or true

--? Visuals

Configuration.ShowFoV = ImportedConfiguration["ShowFoV"] or false
Configuration.FoVThickness = ImportedConfiguration["FoVThickness"] or 2
Configuration.FoVTransparency = ImportedConfiguration["FoVTransparency"] or 0.8
Configuration.FoVColour = ImportedConfiguration["FoVColour"] or Color3.fromRGB(255, 255, 255)
Configuration.SmartESP = ImportedConfiguration["SmartESP"] or false
Configuration.ESPBox = ImportedConfiguration["ESPBox"] or false
Configuration.NameESP = ImportedConfiguration["NameESP"] or false
Configuration.NameESPSize = ImportedConfiguration["NameESPSize"] or 16
Configuration.TracerESP = ImportedConfiguration["TracerESP"] or false
Configuration.ESPThickness = ImportedConfiguration["ESPThickness"] or 2
Configuration.ESPTransparency = ImportedConfiguration["ESPTransparency"] or 0.8
Configuration.ESPColour = ImportedConfiguration["ESPColour"] or Color3.fromRGB(255, 255, 255)
Configuration.ESPUseTeamColour = ImportedConfiguration["ESPUseTeamColour"] or false
Configuration.RainbowVisuals = ImportedConfiguration["RainbowVisuals"] or false


--! Constants

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()


--! Name Handler

local function GetFullName(String)
    if String and #String >= 3 and #String <= 20 then
        for _, _Player in next, Players:GetPlayers() do
            if _Player ~= Player and string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
        return ""
    else
        return ""
    end
end


--! Fields

local Fluent = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity
local Aiming = false
local Target = nil
local Tween = nil

if RunService:IsStudio() then
    Fluent = require(script:WaitForChild("Fluent", math.huge))
else
    local Success, Result = pcall(function()
        return game:HttpGet("https://ttwizz.su/Fluent.txt", true)
    end)
    if Success and string.find(Result, "dawid") then
        Fluent = getfenv().loadstring(game:HttpGet("https://ttwizz.su/Fluent.txt", true))()
    else
        Fluent = getfenv().loadstring(game:HttpGet("https://ttwizz.pages.dev/Fluent.txt", true))()
    end
end

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Fluent then
        SensitivityChanged:Disconnect()
    elseif not Aiming or getfenv().mousemoverel and Configuration.UseMouseMoving then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)


--! Initializing UI

do
    local Window = Fluent:CreateWindow({
        Title = "Open Aimbot",
        SubTitle = "By @ttwiz_z",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Rose"
    })

    local Tabs = { Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "bot" }) }

    Tabs.Aimbot:AddParagraph({
        Title = "Open Aimbot",
        Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
    })

    local AimbotSection = Tabs.Aimbot:AddSection("Aimbot")

    local AimbotToggle = AimbotSection:AddToggle("AimbotToggle", { Title = "Aimbot Toggle", Description = "Toggles the Aimbot", Default = Configuration.Aimbot })
    AimbotToggle:OnChanged(function(Value)
        Configuration.Aimbot = Value
    end)

    local OnePressModeToggle = AimbotSection:AddToggle("OnePressModeToggle", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressMode })
    OnePressModeToggle:OnChanged(function(Value)
        Configuration.OnePressMode = Value
    end)

    if getfenv().mousemoverel then
        local UseMouseMovingToggle = AimbotSection:AddToggle("UseMouseMovingToggle", { Title = "Use Mouse Moving", Description = "Uses the Mouse Moving instead of the Camera Moving", Default = Configuration.UseMouseMoving })
        UseMouseMovingToggle:OnChanged(function(Value)
            Configuration.UseMouseMoving = Value
        end)
    end

    local AimKeybind = AimbotSection:AddKeybind("AimKeybind", {
        Title = "Aim Key",
        Description = "Changes the Aim Key",
        Mode = "Hold",
        Default = Configuration.AimKey,
        ChangedCallback = function(Value)
            Configuration.AimKey = Value
        end
    })
    Configuration.AimKey = Enum.KeyCode[AimKeybind.Value]

    local AimPartDropdown = AimbotSection:AddDropdown("AimPartDropdown", {
        Title = "Aim Part",
        Description = "Changes the Aim Part",
        Values = Configuration.AimPartDropdownValues,
        Multi = false,
        Default = Configuration.AimPart,
        Callback = function(Value)
            Configuration.AimPart = Value
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if not Fluent then
                break
            end
            if Configuration.RandomAimPart and #Configuration.AimPartDropdownValues > 0 then
                AimPartDropdown:SetValue(Configuration.AimPartDropdownValues[math.random(1, #Configuration.AimPartDropdownValues)])
            end
        end
    end)

    local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "Random Aim Part", Description = "Selects every second a Random Aim Part from Dropdown", Default = Configuration.RandomAimPart })
    RandomAimPartToggle:OnChanged(function(Value)
        Configuration.RandomAimPart = Value
    end)

    AimbotSection:AddInput("AddAimPartInput", {
        Title = "Add Aim Part",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and not table.find(Configuration.AimPartDropdownValues, Value) then
                table.insert(Configuration.AimPartDropdownValues, Value)
                AimPartDropdown:SetValue(Value)
            end
        end
    })

    AimbotSection:AddInput("RemoveAimPartInput", {
        Title = "Remove Aim Part",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and table.find(Configuration.AimPartDropdownValues, Value) then
                if #Configuration.AimPartDropdownValues == 1 then
                    Configuration.AimPartDropdownValues[1] = "--"
                    AimPartDropdown:SetValue("--")
                    Configuration.AimPart = nil
                end
                table.remove(Configuration.AimPartDropdownValues, table.find(Configuration.AimPartDropdownValues, Value))
                if Configuration.AimPart == Value then
                    AimPartDropdown:SetValue(nil)
                else
                    AimPartDropdown:BuildDropdownList()
                end
            end
        end
    })

    if getfenv().mouse1click then
        local TriggerBotToggle = AimbotSection:AddToggle("TriggerBotToggle", { Title = "TriggerBot Toggle", Description = "Toggles the TriggerBot", Default = Configuration.TriggerBot })
        TriggerBotToggle:OnChanged(function(Value)
            Configuration.TriggerBot = Value
        end)
    end

    local SimpleChecksSection = Tabs.Aimbot:AddSection("Simple Checks")

    local TeamCheckToggle = SimpleChecksSection:AddToggle("TeamCheckToggle", { Title = "Team Check", Description = "Toggles the Team Check", Default = Configuration.TeamCheck })
    TeamCheckToggle:OnChanged(function(Value)
        Configuration.TeamCheck = Value
    end)

    local FriendCheckToggle = SimpleChecksSection:AddToggle("FriendCheckToggle", { Title = "Friend Check", Description = "Toggles the Friend Check", Default = Configuration.FriendCheck })
    FriendCheckToggle:OnChanged(function(Value)
        Configuration.FriendCheck = Value
    end)

    local WallCheckToggle = SimpleChecksSection:AddToggle("WallCheckToggle", { Title = "Wall Check", Description = "Toggles the Wall Check", Default = Configuration.WallCheck })
    WallCheckToggle:OnChanged(function(Value)
        Configuration.WallCheck = Value
    end)

    local AdvancedChecksSection = Tabs.Aimbot:AddSection("Advanced Checks")

    local FoVCheckToggle = AdvancedChecksSection:AddToggle("FoVCheckToggle", { Title = "FoV Check", Description = "Toggles the FoV Check", Default = Configuration.FoVCheck })
    FoVCheckToggle:OnChanged(function(Value)
        Configuration.FoVCheck = Value
    end)

    AdvancedChecksSection:AddSlider("FoVRadiusSlider", {
        Title = "FoV Radius",
        Description = "Changes the FoV Radius",
        Default = Configuration.FoVRadius,
        Min = 10,
        Max = 1000,
        Rounding = 1,
        Callback = function(Value)
            Configuration.FoVRadius = math.round(Value)
        end
    })

    local MagnitudeCheckToggle = AdvancedChecksSection:AddToggle("MagnitudeCheckToggle", { Title = "Magnitude Check", Description = "Toggles the Magnitude Check", Default = Configuration.MagnitudeCheck })
    MagnitudeCheckToggle:OnChanged(function(Value)
        Configuration.MagnitudeCheck = Value
    end)

    AdvancedChecksSection:AddSlider("TriggerMagnitudeSlider", {
        Title = "Trigger Magnitude",
        Description = "Distance between the Native and the Target Character",
        Default = Configuration.TriggerMagnitude,
        Min = 10,
        Max = 1000,
        Rounding = 1,
        Callback = function(Value)
            Configuration.TriggerMagnitude = math.round(Value)
        end
    })

    local TransparencyCheckToggle = AdvancedChecksSection:AddToggle("TransparencyCheckToggle", { Title = "Transparency Check", Description = "Toggles the Transparency Check", Default = Configuration.TransparencyCheck })
    TransparencyCheckToggle:OnChanged(function(Value)
        Configuration.TransparencyCheck = Value
    end)

    AdvancedChecksSection:AddSlider("IgnoredTransparencySlider", {
        Title = "Ignored Transparency",
        Description = "Target is ignored if its Transparency is > than / = to the set one",
        Default = Configuration.IgnoredTransparency,
        Min = 0.1,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            Configuration.IgnoredTransparency = Value
        end
    })

    local GroupCheckToggle = AdvancedChecksSection:AddToggle("GroupCheckToggle", { Title = "Group Check", Description = "Toggles the Group Check", Default = Configuration.GroupCheck })
    GroupCheckToggle:OnChanged(function(Value)
        Configuration.GroupCheck = Value
    end)

    AdvancedChecksSection:AddInput("WhitelistedGroupInput", {
        Title = "Whitelisted Group",
        Description = "After typing, press Enter",
        Default = Configuration.WhitelistedGroup,
        Numeric = true,
        Finished = true,
        Placeholder = "Group Id",
        Callback = function(Value)
            Configuration.WhitelistedGroup = #Value > 0 and Value or 0
        end
    })

    local ExpertChecksSection = Tabs.Aimbot:AddSection("Expert Checks")

    local PlayerCheckToggle = ExpertChecksSection:AddToggle("PlayerCheckToggle", { Title = "Player Check", Description = "Toggles the Player Check", Default = Configuration.PlayerCheck })
    PlayerCheckToggle:OnChanged(function(Value)
        Configuration.PlayerCheck = Value
    end)

    local IgnoredPlayersDropdown = ExpertChecksSection:AddDropdown("IgnoredPlayersDropdown", {
        Title = "Ignored Players",
        Description = "Sets the Ignored Players",
        Values = Configuration.IgnoredPlayersDropdownValues,
        Multi = true,
        Default = Configuration.IgnoredPlayers
    })
    IgnoredPlayersDropdown:OnChanged(function(Value)
        Configuration.IgnoredPlayers = {}
        for Key, _ in next, Value do
            table.insert(Configuration.IgnoredPlayers, Key)
        end
    end)

    ExpertChecksSection:AddInput("AddIgnoredPlayerInput", {
        Title = "Add Ignored Player",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetFullName(Value) > 0 and GetFullName(Value) or Value
            if #Value >= 3 and #Value <= 20 and not table.find(Configuration.IgnoredPlayersDropdownValues, Value) then
                table.insert(Configuration.IgnoredPlayersDropdownValues, Value)
                if not table.find(Configuration.IgnoredPlayers, Value) then
                    IgnoredPlayersDropdown.Value[Value] = true
                    table.insert(Configuration.IgnoredPlayers, Value)
                end
                IgnoredPlayersDropdown:BuildDropdownList()
            end
        end
    })

    ExpertChecksSection:AddInput("RemoveIgnoredPlayerInput", {
        Title = "Remove Ignored Player",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetFullName(Value) > 0 and GetFullName(Value) or Value
            if #Value >= 3 and #Value <= 20 and table.find(Configuration.IgnoredPlayersDropdownValues, Value) then
                if table.find(Configuration.IgnoredPlayers, Value) then
                    IgnoredPlayersDropdown.Value[Value] = nil
                    table.remove(Configuration.IgnoredPlayers, table.find(Configuration.IgnoredPlayers, Value))
                end
                if #Configuration.IgnoredPlayersDropdownValues == 1 then
                    Configuration.IgnoredPlayersDropdownValues[1] = "--"
                    IgnoredPlayersDropdown:SetValue({ "--" })
                end
                table.remove(Configuration.IgnoredPlayersDropdownValues, table.find(Configuration.IgnoredPlayersDropdownValues, Value))
                IgnoredPlayersDropdown:BuildDropdownList()
            end
        end
    })

    local TargetPlayersDropdown = ExpertChecksSection:AddDropdown("TargetPlayersDropdown", {
        Title = "Target Players",
        Description = "Sets the Target Players",
        Values = Configuration.TargetPlayersDropdownValues,
        Multi = true,
        Default = Configuration.TargetPlayers
    })
    TargetPlayersDropdown:OnChanged(function(Value)
        Configuration.TargetPlayers = {}
        for Key, _ in next, Value do
            table.insert(Configuration.TargetPlayers, Key)
        end
    end)

    ExpertChecksSection:AddInput("AddTargetPlayerInput", {
        Title = "Add Target Player",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetFullName(Value) > 0 and GetFullName(Value) or Value
            if #Value >= 3 and #Value <= 20 and not table.find(Configuration.TargetPlayersDropdownValues, Value) then
                table.insert(Configuration.TargetPlayersDropdownValues, Value)
                if not table.find(Configuration.TargetPlayers, Value) then
                    TargetPlayersDropdown.Value[Value] = true
                    table.insert(Configuration.TargetPlayers, Value)
                end
                TargetPlayersDropdown:BuildDropdownList()
            end
        end
    })

    ExpertChecksSection:AddInput("RemoveTargetPlayerInput", {
        Title = "Remove Target Player",
        Description = "After typing, press Enter",
        Numeric = false,
        Finished = true,
        Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetFullName(Value) > 0 and GetFullName(Value) or Value
            if #Value >= 3 and #Value <= 20 and table.find(Configuration.TargetPlayersDropdownValues, Value) then
                if table.find(Configuration.TargetPlayers, Value) then
                    TargetPlayersDropdown.Value[Value] = nil
                    table.remove(Configuration.TargetPlayers, table.find(Configuration.TargetPlayers, Value))
                end
                if #Configuration.TargetPlayersDropdownValues == 1 then
                    Configuration.TargetPlayersDropdownValues[1] = "--"
                    TargetPlayersDropdown:SetValue({ "--" })
                end
                table.remove(Configuration.TargetPlayersDropdownValues, table.find(Configuration.TargetPlayersDropdownValues, Value))
                TargetPlayersDropdown:BuildDropdownList()
            end
        end
    })

    local SensitivitySection = Tabs.Aimbot:AddSection("Sensitivity")

    local UseSensitivityToggle = SensitivitySection:AddToggle("UseSensitivityToggle", { Title = "Use Sensitivity", Description = "Toggles the Sensitivity", Default = Configuration.UseSensitivity })
    UseSensitivityToggle:OnChanged(function(Value)
        Configuration.UseSensitivity = Value
    end)

    SensitivitySection:AddSlider("SensitivitySlider", {
        Title = "Sensitivity",
        Description = "Smoothes out the Mouse / Camera Movements when Aiming",
        Default = Configuration.Sensitivity,
        Min = 10,
        Max = 99,
        Rounding = 1,
        Callback = function(Value)
            Configuration.Sensitivity = Value
        end
    })

    if getfenv().Drawing then
        Tabs.Visuals = Window:AddTab({ Title = "Visuals", Icon = "box" })

        local FoVSection = Tabs.Visuals:AddSection("FoV")

        local ShowFoVToggle = FoVSection:AddToggle("ShowFoVToggle", { Title = "Show FoV", Description = "Toggles the FoV Show", Default = Configuration.ShowFoV })
        ShowFoVToggle:OnChanged(function(Value)
            Configuration.ShowFoV = Value
        end)

        FoVSection:AddSlider("FoVThicknessSlider", {
            Title = "FoV Thickness",
            Description = "Changes the FoV Thickness",
            Default = Configuration.FoVThickness,
            Min = 1,
            Max = 10,
            Rounding = 1,
            Callback = function(Value)
                Configuration.FoVThickness = Value
            end
        })

        FoVSection:AddSlider("FoVTransparencySlider", {
            Title = "FoV Transparency",
            Description = "Changes the FoV Transparency",
            Default = Configuration.FoVTransparency,
            Min = 0.1,
            Max = 1,
            Rounding = 1,
            Callback = function(Value)
                Configuration.FoVTransparency = Value
            end
        })

        local FoVColourPicker = FoVSection:AddColorpicker("FoVColourPicker", {
            Title = "FoV Colour",
            Description = "Changes the FoV Colour",
            Transparency = 0,
            Default = Configuration.FoVColour,
            Callback = function(Value)
                Configuration.FoVColour = Value
            end
        })

        local ESPSection = Tabs.Visuals:AddSection("ESP")

        local SmartESPToggle = ESPSection:AddToggle("SmartESPToggle", { Title = "Smart ESP", Description = "Does not ESP the Whitelisted Players", Default = Configuration.SmartESP })
        SmartESPToggle:OnChanged(function(Value)
            Configuration.SmartESP = Value
        end)

        local ESPBoxToggle = ESPSection:AddToggle("ESPBoxToggle", { Title = "ESP Box", Description = "Creates the ESP Box around the Players", Default = Configuration.ESPBox })
        ESPBoxToggle:OnChanged(function(Value)
            Configuration.ESPBox = Value
        end)

        local NameESPToggle = ESPSection:AddToggle("NameESPToggle", { Title = "Name ESP", Description = "Creates the Name ESP above the Players", Default = Configuration.NameESP })
        NameESPToggle:OnChanged(function(Value)
            Configuration.NameESP = Value
        end)

        ESPSection:AddSlider("NameESPSizeSlider", {
            Title = "Name ESP Size",
            Description = "Changes the Name ESP Size",
            Default = Configuration.NameESPSize,
            Min = 8,
            Max = 28,
            Rounding = 1,
            Callback = function(Value)
                Configuration.NameESPSize = Value
            end
        })

        local TracerESPToggle = ESPSection:AddToggle("TracerESPToggle", { Title = "Tracer ESP", Description = "Creates the Tracer ESP in the direction of the Players", Default = Configuration.TracerESP })
        TracerESPToggle:OnChanged(function(Value)
            Configuration.TracerESP = Value
        end)

        ESPSection:AddSlider("ESPThicknessSlider", {
            Title = "ESP Thickness",
            Description = "Changes the ESP Thickness",
            Default = Configuration.ESPThickness,
            Min = 1,
            Max = 10,
            Rounding = 1,
            Callback = function(Value)
                Configuration.ESPThickness = Value
            end
        })

        ESPSection:AddSlider("ESPTransparencySlider", {
            Title = "ESP Transparency",
            Description = "Changes the ESP Transparency",
            Default = Configuration.ESPTransparency,
            Min = 0.1,
            Max = 1,
            Rounding = 1,
            Callback = function(Value)
                Configuration.ESPTransparency = Value
            end
        })

        local ESPColourPicker = ESPSection:AddColorpicker("ESPColourPicker", {
            Title = "ESP Colour",
            Description = "Changes the ESP Colour",
            Transparency = 0,
            Default = Configuration.ESPColour,
            Callback = function(Value)
                Configuration.ESPColour = Value
            end
        })

        local ESPUseTeamColourToggle = ESPSection:AddToggle("ESPUseTeamColourToggle", { Title = "Use Team Colour", Description = "Makes the ESP Colour match the Target Player Team", Default = Configuration.ESPUseTeamColour })
        ESPUseTeamColourToggle:OnChanged(function(Value)
            Configuration.ESPUseTeamColour = Value
        end)

        local VisualsSection = Tabs.Visuals:AddSection("Visuals")

        local RainbowVisualsToggle = VisualsSection:AddToggle("RainbowVisualsToggle", { Title = "Rainbow Visuals", Description = "Makes the Visuals Rainbow", Default = Configuration.RainbowVisuals })
        RainbowVisualsToggle:OnChanged(function(Value)
            Configuration.RainbowVisuals = Value
        end)
        task.spawn(function()
            while task.wait() do
                for Index = 1, 230 do
                    if not Fluent then
                        break
                    elseif Configuration.RainbowVisuals then
                        FoVColourPicker:SetValue({ Index / 230, 1, 1 }, FoVColourPicker.Transparency)
                        ESPColourPicker:SetValue({ Index / 230, 1, 1 }, ESPColourPicker.Transparency)
                    end
                    task.wait()
                end
            end
        end)
    else
        Window:Dialog({
            Title = "Warning",
            Content = "Your Software does not support the Drawing Library! Access to the Visuals Tab is restricted.",
            Buttons = {
                {
                    Title = "Confirm"
                }
            }
        })
    end

    Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

    local UISection = Tabs.Settings:AddSection("UI")

    UISection:AddDropdown("InterfaceTheme", {
        Title = "Theme",
        Description = "Changes the UI Theme",
        Values = Fluent.Themes,
        Default = Fluent.Theme,
        Callback = function(Value)
            Fluent:SetTheme(Value)
        end
    })

    if Fluent.UseAcrylic then
        UISection:AddToggle("AcrylicToggle", {
            Title = "Acrylic",
            Description = "Blurred Background requires Graphic Quality >= 8",
            Default = Fluent.Acrylic,
            Callback = function(Value)
                if not Value then
                    Fluent:ToggleAcrylic(Value)
                else
                    Window:Dialog({
                        Title = "Warning",
                        Content = "This Option can be detected! Activate it anyway?",
                        Buttons = {
                            {
                                Title = "Confirm",
                                Callback = function()
                                    Fluent:ToggleAcrylic(Value)
                                end
                            },
                            {
                                Title = "Cancel",
                                Callback = function()
                                    Fluent.Options.AcrylicToggle:SetValue(false)
                                end
                            }
                        }
                    })
                end
            end
        })
    end

    UISection:AddToggle("TransparentToggle", {
        Title = "Transparency",
        Description = "Makes the UI Transparent",
        Default = Fluent.Transparency,
        Callback = function(Value)
            Fluent:ToggleTransparency(Value)
        end
    })

    UISection:AddKeybind("MinimizeKeybind", { Title = "Minimize Key", Description = "Changes the Minimize Key", Default = "RightShift" })
    Fluent.MinimizeKeybind = Fluent.Options.MinimizeKeybind

    local NotificationsSection = Tabs.Settings:AddSection("Notifications")

    local NotificationsToggle = NotificationsSection:AddToggle("NotificationsToggle", { Title = "Show Notifications", Description = "Toggles the Notifications Show", Default = Configuration.ShowNotifications })
    NotificationsToggle:OnChanged(function(Value)
        Configuration.ShowNotifications = Value
    end)

    if getfenv().isfile and getfenv().readfile and getfenv().writefile and getfenv().delfile then
        local ConfigurationManager = Tabs.Settings:AddSection("Configuration Manager")

        ConfigurationManager:AddButton({
            Title = "Export Configuration",
            Description = "Overwrites the Game Configuration File",
            Callback = function()
                xpcall(function()
                    local ExportedConfiguration = Configuration
                    for Key, Value in next, ExportedConfiguration do
                        if Key == "AimKey" then
                            ExportedConfiguration[Key] = #UserInputService:GetStringForKeyCode(Value) > 0 and UserInputService:GetStringForKeyCode(Value) or "V"
                        elseif Key == "FoVColour" or Key == "ESPColour" then
                            ExportedConfiguration[Key] = PackColour(Value)
                        end
                    end
                    ExportedConfiguration = tostring(HttpService:JSONEncode(ExportedConfiguration))
                    getfenv().writefile(string.format("%s.ttwizz", game.GameId), ExportedConfiguration)
                    Window:Dialog({
                        Title = "Configuration Manager",
                        Content = string.format("Configuration File %s.ttwizz has been successfully overwritten!", game.GameId),
                        Buttons = {
                            {
                                Title = "Confirm"
                            }
                        }
                    })
                end, function()
                    Window:Dialog({
                        Title = "Configuration Manager",
                        Content = string.format("An Error occurred when overwriting the Configuration File %s.ttwizz", game.GameId),
                        Buttons = {
                            {
                                Title = "Confirm"
                            }
                        }
                    })
                end)
            end
        })

        ConfigurationManager:AddButton({
            Title = "Delete Configuration File",
            Description = "Deletes the Game Configuration File",
            Callback = function()
                if getfenv().isfile(string.format("%s.ttwizz", game.GameId)) then
                    getfenv().delfile(string.format("%s.ttwizz", game.GameId))
                    Window:Dialog({
                        Title = "Configuration Manager",
                        Content = string.format("Configuration File %s.ttwizz has been successfully deleted!", game.GameId),
                        Buttons = {
                            {
                                Title = "Confirm"
                            }
                        }
                    })
                else
                    Window:Dialog({
                        Title = "Configuration Manager",
                        Content = string.format("Configuration File %s.ttwizz could not be found!", game.GameId),
                        Buttons = {
                            {
                                Title = "Confirm"
                            }
                        }
                    })
                end
            end
        })
    end

    local Discord = Tabs.Settings:AddSection("Discord")

    if getfenv().setclipboard then
        Discord:AddButton({
            Title = "Copy Invite Link",
            Description = "Paste it into the Browser Tab",
            Callback = function()
                getfenv().setclipboard("https://ttwizz.su/pix")
                Window:Dialog({
                    Title = "Discord",
                    Content = "Invite Link has been copied to the Clipboard!",
                    Buttons = {
                        {
                            Title = "Confirm"
                        }
                    }
                })
            end
        })
    else
        Discord:AddParagraph({
            Title = "https://ttwizz.su/pix",
            Content = "Paste it into the Browser Tab"
        })
    end

    Window:SelectTab(1)
end


--! Notification Handler

local function Notify(Message)
    if Fluent and Configuration.ShowNotifications and Message then
        Fluent:Notify({
            Title = "Open Aimbot",
            Content = Message,
            SubContent = "By @ttwiz_z",
            Duration = 1.5
        })
    end
end

Notify("Successfully initialized!")


--! Resetting Fields

local function ResetFields(SaveAiming, SaveTarget)
    Aiming = SaveAiming and Aiming or false
    Target = SaveTarget and Target or nil
    if Tween then
        Tween:Cancel()
        Tween = nil
    end
    UserInputService.MouseDeltaSensitivity = MouseSensitivity
end


--! Binding Key

local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
    if not Fluent then
        InputBegan:Disconnect()
    elseif not UserInputService:GetFocusedTextBox() and Configuration.Aimbot and Input.KeyCode == Configuration.AimKey then
        if Aiming then
            ResetFields()
            Notify("[Aiming Mode]: OFF")
        else
            Aiming = true
            Notify("[Aiming Mode]: ON")
        end
    end
end)

local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
    if not Fluent then
        InputEnded:Disconnect()
    elseif not UserInputService:GetFocusedTextBox() and Input.KeyCode == Configuration.AimKey and Aiming and not Configuration.OnePressMode then
        ResetFields()
        Notify("[Aiming Mode]: OFF")
    end
end)


--! Checking Target

local function IsReady(Target)
    if Target and Target:FindFirstChildWhichIsA("Humanoid") and Target:FindFirstChildWhichIsA("Humanoid").Health > 0 and not Target:FindFirstChildWhichIsA("ForceField") and Configuration.AimPart and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
        local _Player = Players:GetPlayerFromCharacter(Target)
        if _Player == Player then
            return false
        end
        local TargetPart = Target:FindFirstChild(Configuration.AimPart)
        local NativePart = nil
        if (Configuration.WallCheck or Configuration.MagnitudeCheck) and Player.Character and Player.Character:FindFirstChild(Configuration.AimPart) and Player.Character:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
            NativePart = Player.Character:FindFirstChild(Configuration.AimPart)
        end
        if Configuration.TeamCheck and _Player.TeamColor == Player.TeamColor then
            return false
        elseif Configuration.FriendCheck and _Player:IsFriendsWith(Player.UserId) then
            return false
        elseif Configuration.WallCheck and NativePart then
            local RayDirection = (TargetPart.Position - NativePart.Position).Unit * (TargetPart.Position - NativePart.Position).Magnitude
            local RaycastParameters = RaycastParams.new()
            RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
            RaycastParameters.FilterDescendantsInstances = { Player.Character }
            local RaycastResult = workspace:Raycast(NativePart.Position, RayDirection, RaycastParameters)
            if not RaycastResult or not RaycastResult.Instance or not RaycastResult.Instance:FindFirstAncestor(_Player.Name) then
                return false
            end
        elseif Configuration.MagnitudeCheck and NativePart then
            local Magnitude = (TargetPart.Position - NativePart.Position).Magnitude
            if Magnitude > Configuration.TriggerMagnitude then
                return false
            end
        elseif Configuration.TransparencyCheck and Target:FindFirstChild("Head") and Target:FindFirstChild("Head"):IsA("BasePart") and Target:FindFirstChild("Head").Transparency >= Configuration.IgnoredTransparency then
            return false
        elseif Configuration.GroupCheck and _Player:IsInGroup(Configuration.WhitelistedGroup) then
            return false
        elseif Configuration.PlayerCheck and table.find(Configuration.IgnoredPlayers, _Player.Name) and not table.find(Configuration.TargetPlayers, _Player.Name) then
            return false
        end
        return true, Target, _Player, { workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position) }, TargetPart.Position
    else
        return false
    end
end


--! TriggerBot Handler

local function HandleTriggerBot()
    if Fluent and getfenv().mouse1click and Configuration.TriggerBot and Mouse.Target and IsReady(Mouse.Target.Parent) then
        getfenv().mouse1click()
    end
end


--! Visuals Handler

local function Visualize(Object)
    if not Fluent or not getfenv().Drawing or not Object then
        return nil
    elseif string.lower(Object) == "fov" then
        local FoV = getfenv().Drawing.new("Circle")
        FoV.Visible = false
        if FoV.ZIndex then
            FoV.ZIndex = 2
        end
        FoV.Filled = false
        FoV.NumSides = 1000
        FoV.Radius = Configuration.FoVRadius
        FoV.Thickness = Configuration.FoVThickness
        FoV.Transparency = Configuration.FoVTransparency
        FoV.Color = Configuration.FoVColour
        return FoV
    elseif string.lower(Object) == "espbox" then
        local ESPBox = getfenv().Drawing.new("Square")
        ESPBox.Visible = false
        if ESPBox.ZIndex then
            ESPBox.ZIndex = 1
        end
        ESPBox.Filled = false
        ESPBox.Thickness = Configuration.ESPThickness
        ESPBox.Transparency = Configuration.ESPTransparency
        ESPBox.Color = Configuration.ESPColour
        return ESPBox
    elseif string.lower(Object) == "nameesp" then
        local NameESP = getfenv().Drawing.new("Text")
        NameESP.Visible = false
        if NameESP.ZIndex then
            NameESP.ZIndex = 1
        end
        NameESP.Center = true
        NameESP.Outline = true
        NameESP.Size = Configuration.NameESPSize
        NameESP.Transparency = Configuration.ESPTransparency
        NameESP.Color = Configuration.ESPColour
        return NameESP
    elseif string.lower(Object) == "traceresp" then
        local TracerESP = getfenv().Drawing.new("Line")
        TracerESP.Visible = false
        if TracerESP.ZIndex then
            TracerESP.ZIndex = 1
        end
        TracerESP.Thickness = Configuration.ESPThickness
        TracerESP.Transparency = Configuration.ESPTransparency
        TracerESP.Color = Configuration.ESPColour
        return TracerESP
    else
        return nil
    end
end

local Visuals = { FoV = Visualize("FoV") }

local function ClearVisual(Visual, Key)
    local FoundVisual = table.find(Visuals, Visual)
    if Visual and (FoundVisual or Key and Key == "FoV") then
        if Visual.Destroy then
            Visual:Destroy()
        elseif Visual.Remove then
            Visual:Remove()
        end
        if FoundVisual then
            table.remove(Visuals, FoundVisual)
        elseif Key and Key == "FoV" then
            Visuals["FoV"] = nil
        end
    end
end

local function ClearVisuals()
    for Key, Visual in next, Visuals do
        ClearVisual(Visual, Key)
    end
end

local function VisualizeFoV()
    if not Fluent then
        return ClearVisuals()
    end
    local MouseLocation = UserInputService:GetMouseLocation()
    Visuals.FoV.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
    Visuals.FoV.Radius = Configuration.FoVRadius
    Visuals.FoV.Thickness = Configuration.FoVThickness
    Visuals.FoV.Transparency = Configuration.FoVTransparency
    Visuals.FoV.Color = Configuration.FoVColour
    Visuals.FoV.Visible = Configuration.ShowFoV
end


--! ESP Library

local ESPLibrary = {}

function ESPLibrary:Initialize(Target)
    if not Fluent then
        ClearVisuals()
        return nil
    elseif not Target then
        return nil
    end
    local self = setmetatable({}, { __index = ESPLibrary })
    self.Player = Players:GetPlayerFromCharacter(Target)
    self.Character = Target
    self.ESPBox = Visualize("ESPBox")
    self.NameESP = Visualize("NameESP")
    self.TracerESP = Visualize("TracerESP")
    table.insert(Visuals, self.ESPBox)
    table.insert(Visuals, self.NameESP)
    table.insert(Visuals, self.TracerESP)
    local Head = self.Character:FindFirstChild("Head")
    local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    if Head and HumanoidRootPart then
        local IsCharacterReady = true
        if Configuration.SmartESP then
            IsCharacterReady = IsReady(self.Character)
        end
        local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
        local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        if IsInViewport then
            self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
            self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            self.NameESP.Text = string.format("@%s", self.Player.Name)
            self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, (HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2) - 25)
            self.TracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            self.TracerESP.To = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            if Configuration.ESPUseTeamColour and not Configuration.RainbowVisuals then
                local TeamColour = self.Player.TeamColor.Color
                self.ESPBox.Color = TeamColour
                self.NameESP.Color = TeamColour
                self.TracerESP.Color = TeamColour
            end
        end
        self.ESPBox.Visible = Configuration.ESPBox and IsCharacterReady and IsInViewport
        self.NameESP.Visible = Configuration.NameESP and IsCharacterReady and IsInViewport
        self.TracerESP.Visible = Configuration.TracerESP and IsCharacterReady and IsInViewport
    end
    return self
end

function ESPLibrary:Visualize()
    if not Fluent then
        return ClearVisuals()
    elseif not self.Character then
        return self:Disconnect()
    end
    local Head = self.Character:FindFirstChild("Head")
    local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    if Head and HumanoidRootPart then
        local IsCharacterReady = true
        if Configuration.SmartESP then
            IsCharacterReady = IsReady(self.Character)
        end
        local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
        local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        if IsInViewport then
            self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
            self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            self.ESPBox.Thickness = Configuration.ESPThickness
            self.ESPBox.Transparency = Configuration.ESPTransparency
            self.NameESP.Text = string.format("@%s", self.Player.Name)
            self.NameESP.Size = Configuration.NameESPSize
            self.NameESP.Transparency = Configuration.ESPTransparency
            self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, (HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2) - 25)
            self.TracerESP.Thickness = Configuration.ESPThickness
            self.TracerESP.Transparency = Configuration.ESPTransparency
            self.TracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            self.TracerESP.To = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            if Configuration.ESPUseTeamColour and not Configuration.RainbowVisuals then
                local TeamColour = self.Player.TeamColor.Color
                self.ESPBox.Color = TeamColour
                self.NameESP.Color = TeamColour
                self.TracerESP.Color = TeamColour
            else
                self.ESPBox.Color = Configuration.ESPColour
                self.NameESP.Color = Configuration.ESPColour
                self.TracerESP.Color = Configuration.ESPColour
            end
        end
        self.ESPBox.Visible = Configuration.ESPBox and IsCharacterReady and IsInViewport
        self.NameESP.Visible = Configuration.NameESP and IsCharacterReady and IsInViewport
        self.TracerESP.Visible = Configuration.TracerESP and IsCharacterReady and IsInViewport
    else
        self.ESPBox.Visible = false
        self.NameESP.Visible = false
        self.TracerESP.Visible = false
    end
end

function ESPLibrary:Disconnect()
    self.Player = nil
    self.Character = nil
    ClearVisual(self.ESPBox)
    ClearVisual(self.NameESP)
    ClearVisual(self.TracerESP)
end


--! Tracking Handler

local Tracking = {}
local Connections = {}

local function VisualizeESP()
    for _, Tracked in next, Tracking do
        Tracked:Visualize()
    end
end

local function DisconnectTracking(Key)
    if Key and Tracking[Key] then
        Tracking[Key]:Disconnect()
        table.remove(Tracking, Key)
    end
end

local function DisconnectConnection(Key)
    if Key and Connections[Key] then
        for _, Connection in next, Connections[Key] do
            Connection:Disconnect()
        end
        table.remove(Connections, Key)
    end
end

local function DisconnectConnections()
    for Key, _ in next, Connections do
        DisconnectConnection(Key)
    end
    for Key, _ in next, Tracking do
        DisconnectTracking(Key)
    end
end

local function DisconnectAimbot()
    ResetFields()
    DisconnectConnections()
    ClearVisuals()
end

local function CharacterAdded(_Character)
    if _Character then
        local _Player = Players:GetPlayerFromCharacter(_Character)
        Tracking[_Player.UserId] = ESPLibrary:Initialize(_Character)
    end
end

local function CharacterRemoving(_Character)
    if _Character then
        for Key, Tracked in next, Tracking do
            if Tracked.Character == _Character then
                DisconnectTracking(Key)
            end
        end
    end
end

local function InitializePlayers()
    if getfenv().Drawing then
        for _, _Player in next, Players:GetPlayers() do
            if _Player ~= Player and _Player.Character then
                local _Character = _Player.Character
                CharacterAdded(_Character)
                Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded), _Player.CharacterRemoving:Connect(CharacterRemoving) }
            end
        end
    end
end

task.spawn(InitializePlayers)


--! Player Events

local OnTeleport; OnTeleport = Player.OnTeleport:Connect(function()
    if not Fluent or not getfenv().queue_on_teleport then
        OnTeleport:Disconnect()
    else
        getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ttwizz/Open-Aimbot/master/source.lua\", true))()")
        OnTeleport:Disconnect()
    end
end)

local PlayerAdded; PlayerAdded = Players.PlayerAdded:Connect(function(_Player)
    if not Fluent or not getfenv().Drawing then
        PlayerAdded:Disconnect()
    elseif _Player ~= Player then
        Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded), _Player.CharacterRemoving:Connect(CharacterRemoving) }
    end
end)

local PlayerRemoving; PlayerRemoving = Players.PlayerRemoving:Connect(function(_Player)
    if Fluent then
        if _Player == Player then
            Fluent:Destroy()
            DisconnectAimbot()
            PlayerRemoving:Disconnect()
        else
            DisconnectConnection(_Player.UserId)
            DisconnectTracking(_Player.UserId)
        end
    else
        PlayerRemoving:Disconnect()
    end
end)


--! Aimbot Loop

local AimbotLoop; AimbotLoop = RunService.RenderStepped:Connect(function()
    if Fluent.Unloaded then
        Fluent = nil
        DisconnectAimbot()
        AimbotLoop:Disconnect()
    elseif not Configuration.Aimbot then
        if Aiming then
            Notify("[Aiming Mode]: OFF")
        end
        ResetFields()
    end
    HandleTriggerBot()
    if getfenv().Drawing then
        VisualizeFoV()
        VisualizeESP()
    end
    if Aiming then
        local OldTarget = Target
        local Closest = math.huge
        if not IsReady(OldTarget) then
            for _, _Player in next, Players:GetPlayers() do
                local IsCharacterReady, Character, _, PartViewportPosition = IsReady(_Player.Character)
                if IsCharacterReady and PartViewportPosition[2] then
                    local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(PartViewportPosition[1].X, PartViewportPosition[1].Y)).Magnitude
                    if Magnitude <= Closest and Magnitude <= (Configuration.FoVCheck and Configuration.FoVRadius or Closest) then
                        Target = Character
                        Closest = Magnitude
                    end
                end
            end
        end
        local IsTargetReady, _, _Player, PartViewportPosition, PartWorldPosition = IsReady(Target)
        if IsTargetReady then
            if OldTarget ~= Target then
                Notify(string.format("[Target]: @%s", _Player.Name))
            end
            if getfenv().mousemoverel and Configuration.UseMouseMoving then
                if PartViewportPosition[2] then
                    ResetFields(true, true)
                    local MouseLocation = UserInputService:GetMouseLocation()
                    local Sensitivity = Configuration.UseSensitivity and Configuration.Sensitivity / 10 or 1
                    getfenv().mousemoverel((PartViewportPosition[1].X - MouseLocation.X) * Sensitivity, (PartViewportPosition[1].Y - MouseLocation.Y) * Sensitivity)
                else
                    ResetFields(true)
                end
            else
                UserInputService.MouseDeltaSensitivity = 0
                if Configuration.UseSensitivity then
                    Tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(Configuration.Sensitivity / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition) })
                    Tween:Play()
                else
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition)
                end
            end
        else
            ResetFields(true)
        end
    end
end)