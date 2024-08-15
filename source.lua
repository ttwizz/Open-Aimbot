--[[
    Open Aimbot
    Universal Open Source Aimbot
    Release 1.8.11

    twix.cyou/pix
    twix.cyou/OpenAimbotV3rm

    Author: ttwiz_z (ttwizz)
    License: MIT
    GitHub: https://github.com/ttwizz/Open-Aimbot

    Issues: https://github.com/ttwizz/Open-Aimbot/issues
    Pull requests: https://github.com/ttwizz/Open-Aimbot/pulls
    Discussions: https://github.com/ttwizz/Open-Aimbot/discussions

    Wiki: https://moderka.org/Open-Aimbot
]]


--! Debugger

local DEBUG = false

if DEBUG then
    getfenv().getfenv = function()
        return setmetatable({}, {
            __index = function()
                return function() return true end
            end
        })
    end
end


--! Services

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


--! Colors Handler

local function PackColour(Colour)
    return typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
end

local function UnpackColour(Colour)
    return typeof(Colour) == "table" and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or typeof(Colour) == "Color3" and Colour or Color3.fromRGB(255, 255, 255)
end


--! Configuration Importer

local ImportedConfiguration = {}

pcall(function()
    if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
        ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
        for Key, Value in next, ImportedConfiguration do
            if Key == "FoVColour" or Key == "ESPColour" then
                ImportedConfiguration[Key] = UnpackColour(Value)
            end
        end
    end
end)


--! Configuration Initializer

local Configuration = {}

--? Aimbot

Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
Configuration.OnePressAimingMode = ImportedConfiguration["OnePressAimingMode"] or false
Configuration.AimMode = ImportedConfiguration["AimMode"] or "Camera"
Configuration.SilentAimMethod = ImportedConfiguration["SilentAimMethod"] or "Mouse.Hit / Mouse.Target"
Configuration.SilentAimChance = ImportedConfiguration["SilentAimChance"] or 100
Configuration.OffAfterKill = ImportedConfiguration["OffAfterKill"] or false
Configuration.AimKey = ImportedConfiguration["AimKey"] or "RMB"
Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false

Configuration.UseOffset = ImportedConfiguration["UseOffset"] or false
Configuration.OffsetType = ImportedConfiguration["OffsetType"] or "Static"
Configuration.StaticOffsetIncrement = ImportedConfiguration["StaticOffsetIncrement"] or 10
Configuration.DynamicOffsetIncrement = ImportedConfiguration["DynamicOffsetIncrement"] or 10
Configuration.AutoOffset = ImportedConfiguration["AutoOffset"] or false
Configuration.MaxAutoOffset = ImportedConfiguration["MaxAutoOffset"] or 50

Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 100
Configuration.UseNoise = ImportedConfiguration["UseNoise"] or false

--? TriggerBot

Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
Configuration.OnePressTriggeringMode = ImportedConfiguration["OnePressTriggeringMode"] or false
Configuration.SmartTriggerBot = ImportedConfiguration["SmartTriggerBot"] or false
Configuration.TriggerKey = ImportedConfiguration["TriggerKey"] or "V"

--? Checks

Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
Configuration.WaterCheck = ImportedConfiguration["WaterCheck"] or false

Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
Configuration.WhitelistedGroupCheck = ImportedConfiguration["WhitelistedGroupCheck"] or false
Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
Configuration.BlacklistedGroupCheck = ImportedConfiguration["BlacklistedGroupCheck"] or false
Configuration.BlacklistedGroup = ImportedConfiguration["BlacklistedGroup"] or 0

Configuration.IgnoredPlayersCheck = ImportedConfiguration["IgnoredPlayersCheck"] or false
Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
Configuration.TargetPlayersCheck = ImportedConfiguration["TargetPlayersCheck"] or false
Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}

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


--! Names Handler

local function GetFullName(String)
    if typeof(String) == "string" and #String >= 3 and #String <= 20 then
        for _, _Player in next, Players:GetPlayers() do
            if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
    end
    return ""
end


--! Fields

local Fluent = nil
local ShowWarning = false
local MouseSensitivity = UserInputService.MouseDeltaSensitivity
local Aiming = false
local Triggering = false
local Target = nil
local Tween = nil

if typeof(script) == "Instance" and script:FindFirstChild("Fluent") and script:FindFirstChild("Fluent"):IsA("ModuleScript") then
    Fluent = require(script:FindFirstChild("Fluent"))
else
    local Success, Result = pcall(function()
        return game:HttpGet("https://twix.cyou/Fluent.txt", true)
    end)
    if Success and typeof(Result) == "string" and string.find(Result, "dawid") then
        Fluent = getfenv().loadstring(Result)()
    else
        Fluent = getfenv().loadstring(game:HttpGet("https://ttwizz.pages.dev/Fluent.txt", true))()
    end
end

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Fluent then
        SensitivityChanged:Disconnect()
    elseif not Aiming or not DEBUG and (getfenv().mousemoverel and Configuration.AimMode == "Mouse" or getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod and Configuration.AimMode == "Silent") then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)


--! Interface Manager

local UISettings = {
    TabWidth = 160,
    Size = { 580, 460 },
    Theme = "Amethyst",
    Acrylic = false,
    Transparency = true,
    MinimizeKey = "RightShift",
    ShowNotifications = true,
    ShowWarnings = true
}

local InterfaceManager = {}

function InterfaceManager:ImportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile("UISettings.ttwizz") and getfenv().readfile("UISettings.ttwizz") then
            for Key, Value in next, HttpService:JSONDecode(getfenv().readfile("UISettings.ttwizz")) do
                UISettings[Key] = Value
            end
        end
    end)
end

function InterfaceManager:ExportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().writefile then
            getfenv().writefile("UISettings.ttwizz", HttpService:JSONEncode(UISettings))
        end
    end)
end

InterfaceManager:ImportSettings()

UISettings.__LAST_RUN__ = os.date()
InterfaceManager:ExportSettings()


--! UI Initializer

do
    local Window = Fluent:CreateWindow({
        Title = "Open Aimbot",
        SubTitle = "By @ttwiz_z",
        TabWidth = UISettings.TabWidth,
        Size = UDim2.fromOffset(table.unpack(UISettings.Size)),
        Theme = UISettings.Theme,
        Acrylic = UISettings.Acrylic,
        MinimizeKey = UISettings.MinimizeKey
    })

    local Tabs = { Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }) }

    Window:SelectTab(1)

    Tabs.Aimbot:AddParagraph({
        Title = "Open Aimbot",
        Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
    })

    local AimbotSection = Tabs.Aimbot:AddSection("Aimbot")

    local AimbotToggle = AimbotSection:AddToggle("AimbotToggle", { Title = "Aimbot Toggle", Description = "Toggles the Aimbot", Default = Configuration.Aimbot })
    AimbotToggle:OnChanged(function(Value)
        Configuration.Aimbot = Value
    end)

    local OnePressAimingModeToggle = AimbotSection:AddToggle("OnePressAimingModeToggle", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressAimingMode })
    OnePressAimingModeToggle:OnChanged(function(Value)
        Configuration.OnePressAimingMode = Value
    end)

    local AimModeDropdown = AimbotSection:AddDropdown("AimModeDropdown", {
        Title = "Aim Mode",
        Description = "Changes the Aim Mode",
        Values = { "Camera" },
        Default = Configuration.AimMode,
        Callback = function(Value)
            Configuration.AimMode = Value
        end
    })
    if getfenv().mousemoverel then
        table.insert(AimModeDropdown.Values, "Mouse")
        AimModeDropdown:BuildDropdownList()
    else
        ShowWarning = true
    end
    if getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod then
        table.insert(AimModeDropdown.Values, "Silent")
        AimModeDropdown:BuildDropdownList()
        AimbotSection:AddDropdown("SilentAimMethodDropdown", {
            Title = "Silent Aim Method",
            Description = "Changes the Silent Aim Method",
            Values = { "Mouse.Hit / Mouse.Target", "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist" },
            Default = Configuration.SilentAimMethod,
            Callback = function(Value)
                Configuration.SilentAimMethod = Value
            end
        })
        AimbotSection:AddSlider("SilentAimChanceSlider", {
            Title = "Silent Aim Chance",
            Description = "Changes the Hit Chance for Silent Aim",
            Default = Configuration.SilentAimChance,
            Min = 1,
            Max = 100,
            Rounding = 1,
            Callback = function(Value)
                Configuration.SilentAimChance = Value
            end
        })
    else
        ShowWarning = true
    end

    local OffAfterKillToggle = AimbotSection:AddToggle("OffAfterKillToggle", { Title = "Off After Kill", Description = "Disables the Aiming Mode after killing a Target", Default = Configuration.OffAfterKill })
    OffAfterKillToggle:OnChanged(function(Value)
        Configuration.OffAfterKill = Value
    end)

    local AimKeybind = AimbotSection:AddKeybind("AimKeybind", {
        Title = "Aim Key",
        Description = "Changes the Aim Key",
        Default = Configuration.AimKey,
        ChangedCallback = function(Value)
            Configuration.AimKey = Value
        end
    })
    if AimKeybind.Value == "RMB" then
        Configuration.AimKey = Enum.UserInputType.MouseButton2
    else
        Configuration.AimKey = Enum.KeyCode[AimKeybind.Value]
    end

    local AimPartDropdown = AimbotSection:AddDropdown("AimPartDropdown", {
        Title = "Aim Part",
        Description = "Changes the Aim Part",
        Values = Configuration.AimPartDropdownValues,
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
                AimPartDropdown:SetValue(Configuration.AimPartDropdownValues[Random.new():NextInteger(1, #Configuration.AimPartDropdownValues)])
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

    local AimOffsetSection = Tabs.Aimbot:AddSection("Aim Offset")

    local UseOffsetToggle = AimOffsetSection:AddToggle("UseOffsetToggle", { Title = "Use Offset", Description = "Toggles the Offset", Default = Configuration.UseOffset })
    UseOffsetToggle:OnChanged(function(Value)
        Configuration.UseOffset = Value
    end)

    AimOffsetSection:AddDropdown("OffsetTypeDropdown", {
        Title = "Offset Type",
        Description = "Changes the Offset Type",
        Values = { "Static", "Dynamic", "Static & Dynamic" },
        Default = Configuration.OffsetType,
        Callback = function(Value)
            Configuration.OffsetType = Value
        end
    })

    AimOffsetSection:AddSlider("StaticOffsetIncrementSlider", {
        Title = "Static Offset Increment",
        Description = "Changes the Static Offset Increment",
        Default = Configuration.StaticOffsetIncrement,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            Configuration.StaticOffsetIncrement = Value
        end
    })

    AimOffsetSection:AddSlider("DynamicOffsetIncrementSlider", {
        Title = "Dynamic Offset Increment",
        Description = "Changes the Dynamic Offset Increment",
        Default = Configuration.DynamicOffsetIncrement,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            Configuration.DynamicOffsetIncrement = Value
        end
    })

    local AutoOffsetToggle = AimOffsetSection:AddToggle("AutoOffsetToggle", { Title = "Auto Offset", Description = "Toggles the Auto Offset", Default = Configuration.AutoOffset })
    AutoOffsetToggle:OnChanged(function(Value)
        Configuration.AutoOffset = Value
    end)

    AimOffsetSection:AddSlider("MaxAutoOffsetSlider", {
        Title = "Max Auto Offset",
        Description = "Changes the Max Auto Offset",
        Default = Configuration.MaxAutoOffset,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            Configuration.MaxAutoOffset = Value
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
        Min = 1,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            Configuration.Sensitivity = Value
        end
    })

    local UseNoiseToggle = SensitivitySection:AddToggle("UseNoiseToggle", { Title = "Use Noise", Description = "Toggles the Camera Shaking when Aiming", Default = Configuration.UseNoise })
    UseNoiseToggle:OnChanged(function(Value)
        Configuration.UseNoise = Value
    end)

    if getfenv().mouse1click then
        Tabs.TriggerBot = Window:AddTab({ Title = "TriggerBot", Icon = "target" })

        Tabs.TriggerBot:AddParagraph({
            Title = "Open Aimbot",
            Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
        })

        local TriggerBotSection = Tabs.TriggerBot:AddSection("TriggerBot")

        local TriggerBotToggle = TriggerBotSection:AddToggle("TriggerBotToggle", { Title = "TriggerBot Toggle", Description = "Toggles the TriggerBot", Default = Configuration.TriggerBot })
        TriggerBotToggle:OnChanged(function(Value)
            Configuration.TriggerBot = Value
        end)

        local OnePressTriggeringModeToggle = TriggerBotSection:AddToggle("OnePressTriggeringModeToggle", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressTriggeringMode })
        OnePressTriggeringModeToggle:OnChanged(function(Value)
            Configuration.OnePressTriggeringMode = Value
        end)

        local SmartTriggerBotToggle = TriggerBotSection:AddToggle("SmartTriggerBotToggle", { Title = "Smart TriggerBot", Description = "Uses the TriggerBot only when Aiming", Default = Configuration.SmartTriggerBot })
        SmartTriggerBotToggle:OnChanged(function(Value)
            Configuration.SmartTriggerBot = Value
        end)

        local TriggerKeybind = TriggerBotSection:AddKeybind("TriggerKeybind", {
            Title = "Trigger Key",
            Description = "Changes the Trigger Key",
            Default = Configuration.TriggerKey,
            ChangedCallback = function(Value)
                Configuration.TriggerKey = Value
            end
        })
        if TriggerKeybind.Value == "RMB" then
            Configuration.TriggerKey = Enum.UserInputType.MouseButton2
        else
            Configuration.TriggerKey = Enum.KeyCode[TriggerKeybind.Value]
        end
    else
        ShowWarning = true
    end

    Tabs.Checks = Window:AddTab({ Title = "Checks", Icon = "list-checks" })

    Tabs.Checks:AddParagraph({
        Title = "Open Aimbot",
        Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
    })

    local SimpleChecksSection = Tabs.Checks:AddSection("Simple Checks")

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

    local WaterCheckToggle = SimpleChecksSection:AddToggle("WaterCheckToggle", { Title = "Water Check", Description = "Toggles the Water Check if Wall Check is enabled", Default = Configuration.WaterCheck })
    WaterCheckToggle:OnChanged(function(Value)
        Configuration.WaterCheck = Value
    end)

    local AdvancedChecksSection = Tabs.Checks:AddSection("Advanced Checks")

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
            Configuration.FoVRadius = Value
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
            Configuration.TriggerMagnitude = Value
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

    local WhitelistedGroupCheckToggle = AdvancedChecksSection:AddToggle("WhitelistedGroupCheckToggle", { Title = "Whitelisted Group Check", Description = "Toggles the Whitelisted Group Check", Default = Configuration.WhitelistedGroupCheck })
    WhitelistedGroupCheckToggle:OnChanged(function(Value)
        Configuration.WhitelistedGroupCheck = Value
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

    local BlacklistedGroupCheckToggle = AdvancedChecksSection:AddToggle("BlacklistedGroupCheckToggle", { Title = "Blacklisted Group Check", Description = "Toggles the Blacklisted Group Check", Default = Configuration.BlacklistedGroupCheck })
    BlacklistedGroupCheckToggle:OnChanged(function(Value)
        Configuration.BlacklistedGroupCheck = Value
    end)

    AdvancedChecksSection:AddInput("BlacklistedGroupInput", {
        Title = "Blacklisted Group",
        Description = "After typing, press Enter",
        Default = Configuration.BlacklistedGroup,
        Numeric = true,
        Finished = true,
        Placeholder = "Group Id",
        Callback = function(Value)
            Configuration.BlacklistedGroup = #Value > 0 and Value or 0
        end
    })

    local ExpertChecksSection = Tabs.Checks:AddSection("Expert Checks")

    local IgnoredPlayersCheckToggle = ExpertChecksSection:AddToggle("IgnoredPlayersCheckToggle", { Title = "Ignored Players Check", Description = "Toggles the Ignored Players Check", Default = Configuration.IgnoredPlayersCheck })
    IgnoredPlayersCheckToggle:OnChanged(function(Value)
        Configuration.IgnoredPlayersCheck = Value
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

    ExpertChecksSection:AddButton({
        Title = "Clear Unselected Items",
        Description = "Removes Unselected Players",
        Callback = function()
            local Items = 0
            for Index, Value in next, Configuration.IgnoredPlayersDropdownValues do
                if not IgnoredPlayersDropdown.Value[Value] then
                    table.remove(Configuration.IgnoredPlayersDropdownValues, Index)
                    Items = Items + 1
                end
            end
            IgnoredPlayersDropdown:BuildDropdownList()
            Window:Dialog({
                Title = "Open Aimbot",
                Content = Items == 0 and "Nothing has been cleared!" or Items == 1 and "1 item has been cleared!" or string.format("%s items have been cleared!", Items),
                Buttons = {
                    {
                        Title = "Confirm"
                    }
                }
            })
        end
    })

    local TargetPlayersCheckToggle = ExpertChecksSection:AddToggle("TargetPlayersCheckToggle", { Title = "Target Players Check", Description = "Toggles the Target Players Check", Default = Configuration.TargetPlayersCheck })
    TargetPlayersCheckToggle:OnChanged(function(Value)
        Configuration.TargetPlayersCheck = Value
    end)

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

    ExpertChecksSection:AddButton({
        Title = "Clear Unselected Items",
        Description = "Removes Unselected Players",
        Callback = function()
            local Items = 0
            for Index, Value in next, Configuration.TargetPlayersDropdownValues do
                if not TargetPlayersDropdown.Value[Value] then
                    table.remove(Configuration.TargetPlayersDropdownValues, Index)
                    Items = Items + 1
                end
            end
            TargetPlayersDropdown:BuildDropdownList()
            Window:Dialog({
                Title = "Open Aimbot",
                Content = Items == 0 and "Nothing has been cleared!" or Items == 1 and "1 item has been cleared!" or string.format("%s items have been cleared!", Items),
                Buttons = {
                    {
                        Title = "Confirm"
                    }
                }
            })
        end
    })

    if getfenv().Drawing then
        Tabs.Visuals = Window:AddTab({ Title = "Visuals", Icon = "box" })

        Tabs.Visuals:AddParagraph({
            Title = "Open Aimbot",
            Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
        })

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
        ShowWarning = true
    end

    Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

    Tabs.Settings:AddParagraph({
        Title = "Open Aimbot",
        Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
    })

    local UISection = Tabs.Settings:AddSection("UI")

    UISection:AddDropdown("ThemeDropdown", {
        Title = "Theme",
        Description = "Changes the UI Theme",
        Values = Fluent.Themes,
        Default = Fluent.Theme,
        Callback = function(Value)
            Fluent:SetTheme(Value)
            UISettings.Theme = Value
            InterfaceManager:ExportSettings()
        end
    })

    if Fluent.UseAcrylic then
        UISection:AddToggle("AcrylicToggle", {
            Title = "Acrylic",
            Description = "Blurred Background requires Graphic Quality >= 8",
            Default = Fluent.Acrylic,
            Callback = function(Value)
                if not Value or not UISettings.ShowWarnings then
                    Fluent:ToggleAcrylic(Value)
                elseif UISettings.ShowWarnings then
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

    UISection:AddToggle("TransparencyToggle", {
        Title = "Transparency",
        Description = "Makes the UI Transparent",
        Default = UISettings.Transparency,
        Callback = function(Value)
            Fluent:ToggleTransparency(Value)
            UISettings.Transparency = Value
            InterfaceManager:ExportSettings()
        end
    })

    UISection:AddKeybind("MinimizeKeybind", {
        Title = "Minimize Key",
        Description = "Changes the Minimize Key",
        Default = Fluent.MinimizeKey,
        ChangedCallback = function(Value)
            UISettings.MinimizeKey = Value ~= Enum.UserInputType.MouseButton2 and UserInputService:GetStringForKeyCode(Value) or "RMB"
            InterfaceManager:ExportSettings()
        end
    })
    Fluent.MinimizeKeybind = Fluent.Options.MinimizeKeybind

    local NotificationsSection = Tabs.Settings:AddSection("Notifications")

    local NotificationsToggle = NotificationsSection:AddToggle("NotificationsToggle", { Title = "Show Notifications", Description = "Toggles the Notifications Show", Default = UISettings.ShowNotifications })
    NotificationsToggle:OnChanged(function(Value)
        Fluent.ShowNotifications = Value
        UISettings.ShowNotifications = Value
        InterfaceManager:ExportSettings()
    end)

    local WarningsToggle = NotificationsSection:AddToggle("WarningsToggle", { Title = "Show Warnings", Description = "Toggles the Security Warnings Show", Default = UISettings.ShowWarnings })
    WarningsToggle:OnChanged(function(Value)
        UISettings.ShowWarnings = Value
        InterfaceManager:ExportSettings()
    end)

    if getfenv().isfile and getfenv().readfile and getfenv().writefile and getfenv().delfile then
        local ConfigurationManager = Tabs.Settings:AddSection("Configuration Manager")

        ConfigurationManager:AddButton({
            Title = "Export Configuration",
            Description = "Overwrites the Game Configuration File",
            Callback = function()
                xpcall(function()
                    local ExportedConfiguration = { __LAST_UPDATED__ = os.date() }
                    for Key, Value in next, Configuration do
                        if Key == "AimKey" or Key == "TriggerKey" then
                            ExportedConfiguration[Key] = Value ~= Enum.UserInputType.MouseButton2 and UserInputService:GetStringForKeyCode(Value) or "RMB"
                        elseif Key == "FoVColour" or Key == "ESPColour" then
                            ExportedConfiguration[Key] = PackColour(Value)
                        else
                            ExportedConfiguration[Key] = Value
                        end
                    end
                    ExportedConfiguration = HttpService:JSONEncode(ExportedConfiguration)
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
    else
        ShowWarning = true
    end

    local DiscordWikiSection = Tabs.Settings:AddSection("Discord & Wiki")

    if getfenv().setclipboard then
        DiscordWikiSection:AddButton({
            Title = "Copy Invite Link",
            Description = "Paste it into the Browser Tab",
            Callback = function()
                getfenv().setclipboard("https://twix.cyou/pix")
                Window:Dialog({
                    Title = "Open Aimbot",
                    Content = "Invite Link has been copied to the Clipboard!",
                    Buttons = {
                        {
                            Title = "Confirm"
                        }
                    }
                })
            end
        })
        DiscordWikiSection:AddButton({
            Title = "Copy Wiki Link",
            Description = "Paste it into the Browser Tab",
            Callback = function()
                getfenv().setclipboard("https://moderka.org/Open-Aimbot")
                Window:Dialog({
                    Title = "Open Aimbot",
                    Content = "Wiki Link has been copied to the Clipboard!",
                    Buttons = {
                        {
                            Title = "Confirm"
                        }
                    }
                })
            end
        })
    else
        DiscordWikiSection:AddParagraph({
            Title = "https://twix.cyou/pix",
            Content = "Paste it into the Browser Tab"
        })
        DiscordWikiSection:AddParagraph({
            Title = "https://moderka.org/Open-Aimbot",
            Content = "Paste it into the Browser Tab"
        })
    end

    if UISettings.ShowWarnings then
        if DEBUG then
            Window:Dialog({
                Title = "Warning",
                Content = "Running in Debugging Mode. Some Features may not work properly.",
                Buttons = {
                    {
                        Title = "Confirm"
                    }
                }
            })
        elseif ShowWarning then
            Window:Dialog({
                Title = "Warning",
                Content = "Your Software does not support all the Features of Open Aimbot!",
                Buttons = {
                    {
                        Title = "Confirm"
                    }
                }
            })
        end
    end
end


--! Notifications Handler

local function Notify(Message)
    if Fluent and typeof(Message) == "string" then
        Fluent:Notify({
            Title = "Open Aimbot",
            Content = Message,
            SubContent = "By @ttwiz_z",
            Duration = 1.5
        })
    end
end

Notify("Successfully initialized!")


--! Fields Handler

local function ResetAimbotFields(SaveAiming, SaveTarget)
    Aiming = SaveAiming and Aiming or false
    Target = SaveTarget and Target or nil
    if Tween then
        Tween:Cancel()
        Tween = nil
    end
    UserInputService.MouseDeltaSensitivity = MouseSensitivity
end


--! Input Handler

local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
    if not Fluent then
        InputBegan:Disconnect()
    elseif not UserInputService:GetFocusedTextBox() then
        if Configuration.Aimbot and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
            if Aiming then
                ResetAimbotFields()
                Notify("[Aiming Mode]: OFF")
            else
                Aiming = true
                Notify("[Aiming Mode]: ON")
            end
        elseif Configuration.TriggerBot and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
            if Triggering then
                Triggering = false
                Notify("[Triggering Mode]: OFF")
            else
                Triggering = true
                Notify("[Triggering Mode]: ON")
            end
        end
    end
end)

local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
    if not Fluent then
        InputEnded:Disconnect()
    elseif not UserInputService:GetFocusedTextBox() then
        if Aiming and not Configuration.OnePressAimingMode and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
            ResetAimbotFields()
            Notify("[Aiming Mode]: OFF")
        elseif Triggering and not Configuration.OnePressTriggeringMode and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
            Triggering = false
            Notify("[Triggering Mode]: OFF")
        end
    end
end)


--! Math Handler

local function CalculateDirection(Origin, Position, Magnitude)
    return typeof(Origin) == "Vector3" and typeof(Position) == "Vector3" and typeof(Magnitude) == "number" and (Position - Origin).Unit * Magnitude or Vector3.zero
end

local function CalculateChance(Percentage)
    return typeof(Percentage) == "number" and math.round(math.clamp(Percentage, 1, 100)) / 100 >= math.round(Random.new():NextNumber() * 100) / 100 or false
end

local function Abbreviate(Number)
    if typeof(Number) == "number" then
        local Abbreviations = {
            N = 10 ^ 30,
            O = 10 ^ 27,
            Sp = 10 ^ 24,
            Sx = 10 ^ 21,
            Qn = 10 ^ 18,
            Qd = 10 ^ 15,
            T = 10 ^ 12,
            B = 10 ^ 9,
            M = 10 ^ 6,
            K = 10 ^ 3
        }
        local Selected = 0
        local Result = tostring(math.round(Number))
        for Key, Value in next, Abbreviations do
            if math.abs(Number) >= Value and Value > Selected then
                Selected = Value
                Result = string.format("%s%s", tostring(math.round(Number / Value)), Key)
            end
        end
        return Result
    end
    return Number
end


--! Targets Handler

local function IsReady(Target)
    if Target and Target:FindFirstChildWhichIsA("Humanoid") and Target:FindFirstChildWhichIsA("Humanoid").Health > 0 and not Target:FindFirstChildWhichIsA("ForceField") and Configuration.AimPart and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") and Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid") and Player.Character:FindFirstChildWhichIsA("Humanoid").Health > 0 and Player.Character:FindFirstChild(Configuration.AimPart) and Player.Character:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
        local _Player = Players:GetPlayerFromCharacter(Target)
        if _Player == Player then
            return false
        end
        local TargetPart = Target:FindFirstChild(Configuration.AimPart)
        local NativePart = Player.Character:FindFirstChild(Configuration.AimPart)
        if Configuration.TeamCheck and _Player.TeamColor == Player.TeamColor then
            return false
        elseif Configuration.FriendCheck and _Player:IsFriendsWith(Player.UserId) then
            return false
        elseif Configuration.WallCheck then
            local RayDirection = CalculateDirection(NativePart.Position, TargetPart.Position, (TargetPart.Position - NativePart.Position).Magnitude)
            local RaycastParameters = RaycastParams.new()
            RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
            RaycastParameters.FilterDescendantsInstances = { Player.Character }
            RaycastParameters.IgnoreWater = not Configuration.WaterCheck
            local RaycastResult = workspace:Raycast(NativePart.Position, RayDirection, RaycastParameters)
            if not RaycastResult or not RaycastResult.Instance or not RaycastResult.Instance:FindFirstAncestor(_Player.Name) then
                return false
            end
        elseif Configuration.MagnitudeCheck and (TargetPart.Position - NativePart.Position).Magnitude > Configuration.TriggerMagnitude then
            return false
        elseif Configuration.TransparencyCheck and Target:FindFirstChild("Head") and Target:FindFirstChild("Head"):IsA("BasePart") and Target:FindFirstChild("Head").Transparency >= Configuration.IgnoredTransparency then
            return false
        elseif Configuration.WhitelistedGroupCheck and _Player:IsInGroup(Configuration.WhitelistedGroup) or Configuration.BlacklistedGroupCheck and not _Player:IsInGroup(Configuration.BlacklistedGroup) then
            return false
        elseif Configuration.IgnoredPlayersCheck and table.find(Configuration.IgnoredPlayers, _Player.Name) or Configuration.TargetPlayersCheck and not table.find(Configuration.TargetPlayers, _Player.Name) then
            return false
        end
        local OffsetIncrement = Configuration.UseOffset and (Configuration.AutoOffset and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 <= Configuration.MaxAutoOffset and TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 or Configuration.MaxAutoOffset, 0) + Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Configuration.OffsetType == "Static" and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) or Configuration.OffsetType == "Dynamic" and Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) + Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10) or Vector3.zero
        local NoiseFrequency = Configuration.UseNoise and Vector3.new(Random.new():NextNumber(0.5, 1), Random.new():NextNumber(0.5, 1), Random.new():NextNumber(0.5, 1)) or Vector3.zero
        return true, Target, { workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position + OffsetIncrement + NoiseFrequency) }, TargetPart.Position + OffsetIncrement + NoiseFrequency, (TargetPart.Position + OffsetIncrement + NoiseFrequency - NativePart.Position).Magnitude, CFrame.new(TargetPart.Position + OffsetIncrement + NoiseFrequency) * CFrame.fromEulerAnglesYXZ(math.rad(TargetPart.Orientation.X), math.rad(TargetPart.Orientation.Y), math.rad(TargetPart.Orientation.Z)), TargetPart
    end
    return false
end


--! Arguments Handler

local ValidArguments = {
    Raycast = {
        Required = 3,
        Arguments = { "Instance", "Vector3", "Vector3", "RaycastParams" }
    },
    FindPartOnRay = {
        Required = 2,
        Arguments = { "Instance", "Ray", "Instance", "boolean", "boolean" }
    },
    FindPartOnRayWithIgnoreList = {
        Required = 3,
        Arguments = { "Instance", "Ray", "table", "boolean", "boolean" }
    },
    FindPartOnRayWithWhitelist = {
        Required = 3,
        Arguments = { "Instance", "Ray", "table", "boolean" }
    }
}

local function ValidateArguments(Arguments, Method)
    if typeof(Arguments) ~= "table" or typeof(Method) ~= "table" or #Arguments < Method.Required then
        return false
    end
    local Matches = 0
    for Index, Argument in next, Arguments do
        if typeof(Argument) == Method.Arguments[Index] then
            Matches = Matches + 1
        end
    end
    return Matches >= Method.Required
end


--! Silent Aim Handler

do
    if not DEBUG and getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod then
        local OldIndex; OldIndex = getfenv().hookmetamethod(game, "__index", getfenv().newcclosure(function(self, Index)
            if Fluent and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and Configuration.SilentAimMethod == "Mouse.Hit / Mouse.Target" and Aiming and IsReady(Target) and select(3, IsReady(Target))[2] and CalculateChance(Configuration.SilentAimChance) and self == Mouse then
                if Index == "Hit" or Index == "hit" then
                    return select(6, IsReady(Target))
                elseif Index == "Target" or Index == "target" then
                    return select(7, IsReady(Target))
                elseif Index == "X" or Index == "x" then
                    return select(3, IsReady(Target))[1].X
                elseif Index == "Y" or Index == "y" then
                    return select(3, IsReady(Target))[1].Y
                elseif Index == "UnitRay" or Index == "unitRay" then
                    return Ray.new(self.Origin, (select(6, IsReady(Target)) - self.Origin).Unit)
                end
            end
            return OldIndex(self, Index)
        end))

        local OldNameCall; OldNameCall = getfenv().hookmetamethod(game, "__namecall", getfenv().newcclosure(function(...)
            local Method = getfenv().getnamecallmethod()
            local Arguments = { ... }
            local self = Arguments[1]
            if Fluent and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and Aiming and IsReady(Target) and select(3, IsReady(Target))[2] and CalculateChance(Configuration.SilentAimChance) and self == workspace then
                if Configuration.SilentAimMethod == "Raycast" and (Method == "Raycast" or Method == "raycast") and ValidateArguments(Arguments, ValidArguments.Raycast) then
                    Arguments[3] = CalculateDirection(Arguments[2], select(4, IsReady(Target)), select(5, IsReady(Target)))
                    return OldNameCall(table.unpack(Arguments))
                elseif Configuration.SilentAimMethod == "FindPartOnRay" and (Method == "FindPartOnRay" or Method == "findPartOnRay") and ValidateArguments(Arguments, ValidArguments.FindPartOnRay) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                elseif Configuration.SilentAimMethod == "FindPartOnRayWithIgnoreList" and (Method == "FindPartOnRayWithIgnoreList" or Method == "findPartOnRayWithIgnoreList") and ValidateArguments(Arguments, ValidArguments.FindPartOnRayWithIgnoreList) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                elseif Configuration.SilentAimMethod == "FindPartOnRayWithWhitelist" and (Method == "FindPartOnRayWithWhitelist" or Method == "findPartOnRayWithWhitelist") and ValidateArguments(Arguments, ValidArguments.FindPartOnRayWithWhitelist) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                end
            end
            return OldNameCall(...)
        end))
    end
end


--! TriggerBot Handler

local function HandleTriggerBot()
    if not DEBUG and Fluent and getfenv().mouse1click and Triggering and (Configuration.SmartTriggerBot and Aiming or not Configuration.SmartTriggerBot) and Mouse.Target and IsReady(Mouse.Target:FindFirstAncestorWhichIsA("Model")) then
        getfenv().mouse1click()
    end
end


--! Visuals Handler

local function Visualize(Object)
    if not DEBUG and Fluent and getfenv().Drawing and typeof(Object) == "string" then
        if string.lower(Object) == "fov" then
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
        end
    end
    return nil
end

local Visuals = { FoV = Visualize("FoV") }

local function ClearVisual(Visual, Key)
    local FoundVisual = table.find(Visuals, Visual)
    if Visual and (FoundVisual or Key == "FoV") then
        if Visual.Destroy then
            Visual:Destroy()
        elseif Visual.Remove then
            Visual:Remove()
        end
        if FoundVisual then
            table.remove(Visuals, FoundVisual)
        elseif Key == "FoV" then
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
    elseif typeof(Target) ~= "Instance" then
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
    local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
    if Head and Head:IsA("BasePart") and HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and Humanoid then
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
            self.NameESP.Text = string.format("@%s | %s%% | %sm", self.Player.Name, Abbreviate(Humanoid.Health), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character:FindFirstChild("Head"):IsA("BasePart") and Abbreviate((Head.Position - Player.Character:FindFirstChild("Head").Position).Magnitude) or "?")
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
    local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
    if Head and Head:IsA("BasePart") and HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and Humanoid then
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
            self.NameESP.Text = string.format("@%s | %s%% | %sm", self.Player.Name, Abbreviate(Humanoid.Health), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character:FindFirstChild("Head"):IsA("BasePart") and Abbreviate((Head.Position - Player.Character:FindFirstChild("Head").Position).Magnitude) or "?")
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
    ResetAimbotFields()
    Triggering = false
    DisconnectConnections()
    ClearVisuals()
end

local function CharacterAdded(_Character)
    if typeof(_Character) == "Instance" then
        local _Player = Players:GetPlayerFromCharacter(_Character)
        Tracking[_Player.UserId] = ESPLibrary:Initialize(_Character)
    end
end

local function CharacterRemoving(_Character)
    if typeof(_Character) == "Instance" then
        for Key, Tracked in next, Tracking do
            if Tracked.Character == _Character then
                DisconnectTracking(Key)
            end
        end
    end
end

local function InitializePlayers()
    if not DEBUG and getfenv().Drawing then
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


--! Player Events Handler

local OnTeleport; OnTeleport = Player.OnTeleport:Connect(function()
    if DEBUG or not Fluent or not getfenv().queue_on_teleport then
        OnTeleport:Disconnect()
    else
        getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ttwizz/Open-Aimbot/master/source.lua\", true))()")
        OnTeleport:Disconnect()
    end
end)

local PlayerAdded; PlayerAdded = Players.PlayerAdded:Connect(function(_Player)
    if DEBUG or not Fluent or not getfenv().Drawing then
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


--! Aimbot Handler

local AimbotLoop; AimbotLoop = RunService.RenderStepped:Connect(function()
    if Fluent.Unloaded then
        Fluent = nil
        DisconnectAimbot()
        AimbotLoop:Disconnect()
    elseif not Configuration.Aimbot then
        ResetAimbotFields()
    elseif not Configuration.TriggerBot then
        Triggering = false
    end
    HandleTriggerBot()
    if not DEBUG and getfenv().Drawing then
        VisualizeFoV()
        VisualizeESP()
    end
    if Aiming then
        local OldTarget = Target
        local Closest = math.huge
        if not IsReady(OldTarget) then
            if OldTarget and not Configuration.OffAfterKill or not OldTarget then
                for _, _Player in next, Players:GetPlayers() do
                    local IsCharacterReady, Character, PartViewportPosition = IsReady(_Player.Character)
                    if IsCharacterReady and PartViewportPosition[2] then
                        local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(PartViewportPosition[1].X, PartViewportPosition[1].Y)).Magnitude
                        if Magnitude <= Closest and Magnitude <= (Configuration.FoVCheck and Configuration.FoVRadius or Closest) then
                            Target = Character
                            Closest = Magnitude
                        end
                    end
                end
            else
                ResetAimbotFields()
            end
        end
        local IsTargetReady, _, PartViewportPosition, PartWorldPosition = IsReady(Target)
        if IsTargetReady then
            if not DEBUG and getfenv().mousemoverel and Configuration.AimMode == "Mouse" then
                if PartViewportPosition[2] then
                    ResetAimbotFields(true, true)
                    local MouseLocation = UserInputService:GetMouseLocation()
                    local Sensitivity = Configuration.UseSensitivity and Configuration.Sensitivity / 10 or 10
                    getfenv().mousemoverel((PartViewportPosition[1].X - MouseLocation.X) / Sensitivity, (PartViewportPosition[1].Y - MouseLocation.Y) / Sensitivity)
                else
                    ResetAimbotFields(true)
                end
            elseif Configuration.AimMode == "Camera" then
                UserInputService.MouseDeltaSensitivity = 0
                if Configuration.UseSensitivity then
                    Tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(math.clamp(Configuration.Sensitivity, 9, 99) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition) })
                    Tween:Play()
                else
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition)
                end
            end
        else
            ResetAimbotFields(true)
        end
    end
end)