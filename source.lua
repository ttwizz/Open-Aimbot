--[[
    Open Aimbot
    Universal Open Source Aimbot
    Release 1.3
    
    Author: ttwiz_z (ttwizz)
    License: MIT
    GitHub: https://github.com/ttwizz/Open-Aimbot
--]]



--// Configuration

local Configuration = {}

Configuration.Aimbot = false
Configuration.AimKey = "V"
Configuration.AimPart = "HumanoidRootPart"
Configuration.ESP = false
Configuration.TeamCheck = false
Configuration.FriendCheck = false
Configuration.WallCheck = false
Configuration.DistanceCheck = false
Configuration.TriggerDistance = 100
Configuration.MagnitudeCheck = false
Configuration.TriggerMagnitude = 500
Configuration.TransparencyCheck = false
Configuration.IgnoredTransparency = 0.5
Configuration.UseSensitivity = false
Configuration.Sensitivity = 0.1
Configuration.ShowNotifications = true


--// Services

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")


--// Constants

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera


--// Fields

local Fluent = nil
local Aiming = false
local Target = nil

if RunService:IsStudio() then
    Fluent = require(script:WaitForChild("Fluent", math.huge))
else
    local Success, Result = pcall(function()
        return game:HttpGet("https://ttwizz.su/Fluent.txt", true)
    end)
    if Success and string.find(Result, "dawid") then
        Fluent = loadstring(game:HttpGet("https://ttwizz.su/Fluent.txt", true))()
    else
        Fluent = loadstring(game:HttpGet("https://ttwizz.pages.dev/Fluent.txt", true))()
    end
end


--// UI Initialization

do
    local Window = Fluent:CreateWindow({
        Title = "Open Aimbot",
        SubTitle = "By @ttwiz_z",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Rose"
    })

    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "box" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    Tabs.Aimbot:AddParagraph({
        Title = "Open Aimbot",
        Content = "Universal Open Source Aimbot\nhttps://github.com/ttwizz/Open-Aimbot"
    })

    local AimbotSection = Tabs.Aimbot:AddSection("Aimbot")

    local AimbotToggle = AimbotSection:AddToggle("AimbotToggle", { Title = "Aimbot Toggle", Description = "Toggles the Aimbot", Default = Configuration.Aimbot })
    AimbotToggle:OnChanged(function(Value)
        Configuration.Aimbot = Value
    end)

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
        Values = {"Head", "HumanoidRootPart", "Random"},
        Multi = false,
        Default = 2,
        Callback = function(Value)
            if Value ~= "Random" then
                Configuration.AimPart = Value
            end
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if not Fluent then
                break
            end
            if AimPartDropdown.Value == "Random" then
                Configuration.AimPart = AimPartDropdown.Values[math.random(1, 2)]
            end
        end
    end)

    local ESPSection = Tabs.Aimbot:AddSection("ESP")

    local ESPToggle = ESPSection:AddToggle("ESPToggle", { Title = "ESP", Description = "ESPs the Target", Default = Configuration.ESP })
    ESPToggle:OnChanged(function(Value)
        if not Value then
            Configuration.ESP = Value
        else
            Window:Dialog({
                Title = "Warning",
                Content = "This option can be detected! Activate it anyway?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            Configuration.ESP = Value
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            ESPToggle:SetValue(false)
                        end
                    }
                }
            })
        end
    end)

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

    local DistanceCheckToggle = AdvancedChecksSection:AddToggle("DistanceCheckToggle", { Title = "Distance Check", Description = "Toggles the Distance Check", Default = Configuration.DistanceCheck })
    DistanceCheckToggle:OnChanged(function(Value)
        Configuration.DistanceCheck = Value
    end)

    local TriggerDistanceSlider = AdvancedChecksSection:AddSlider("TriggerDistanceSlider", {
        Title = "Trigger Distance",
        Description = "Distance between the Mouse and the Aim Part",
        Default = Configuration.TriggerDistance,
        Min = 10,
        Max = 1000,
        Rounding = 1,
        Callback = function(Value)
            Configuration.TriggerDistance = math.round(Value)
        end
    })

    local MagnitudeCheckToggle = AdvancedChecksSection:AddToggle("MagnitudeCheckToggle", { Title = "Magnitude Check", Description = "Toggles the Magnitude Check", Default = Configuration.MagnitudeCheck })
    MagnitudeCheckToggle:OnChanged(function(Value)
        Configuration.MagnitudeCheck = Value
    end)

    local TriggerMagnitudeSlider = AdvancedChecksSection:AddSlider("TriggerMagnitudeSlider", {
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

    local IgnoredTransparencySlider = AdvancedChecksSection:AddSlider("IgnoredTransparencySlider", {
        Title = "Ignored Transparency",
        Description = "Target is ignored if its Transparency is > than or = to the set one",
        Default = Configuration.IgnoredTransparency,
        Min = 0.1,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            Configuration.IgnoredTransparency = Value
        end
    })

    local SensitivitySection = Tabs.Aimbot:AddSection("Sensitivity")

    local UseSensitivityToggle = SensitivitySection:AddToggle("UseSensitivityToggle", { Title = "Use Sensitivity", Description = "Toggles the Sensitivity", Default = Configuration.UseSensitivity })
    UseSensitivityToggle:OnChanged(function(Value)
        Configuration.UseSensitivity = Value
    end)

    local SensitivitySlider = SensitivitySection:AddSlider("SensitivitySlider", {
        Title = "Sensitivity",
        Description = "Makes the Camera Smooth when Aiming",
        Default = Configuration.Sensitivity,
        Min = Configuration.Sensitivity,
        Max = 0.9,
        Rounding = 1,
        Callback = function(Value)
            Configuration.Sensitivity = Value
        end
    })

    local NotificationsSection = Tabs.Aimbot:AddSection("Notifications")

    local NotificationsToggle = NotificationsSection:AddToggle("NotificationsToggle", { Title = "Show Notifications", Description = "Toggles the Notifications Show", Default = Configuration.ShowNotifications })
    NotificationsToggle:OnChanged(function(Value)
        Configuration.ShowNotifications = Value
    end)

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
            Description = "Blurred background requires graphic quality 8+",
            Default = Fluent.Acrylic,
            Callback = function(Value)
                if not Value then
                    Fluent:ToggleAcrylic(Value)
                else
                    Window:Dialog({
                        Title = "Warning",
                        Content = "This option can be detected! Activate it anyway?",
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

    Window:SelectTab(1)
end


--// Notification Handler

local function Notify(Message)
    if Fluent and Configuration.ShowNotifications then
        Fluent:Notify({
            Title = "Open Aimbot",
            Content = Message,
            SubContent = "By @ttwiz_z",
            Duration = 1.5
        })
    end
end

Notify("Successfully initialized!")


--// Resetting Fields

local function ResetFields()
    Aiming = false
    Target = nil
end


--// Binding Key

local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
    if not Fluent then
        InputBegan:Disconnect()
    end
    if not UserInputService:GetFocusedTextBox() and Configuration.Aimbot and Input.KeyCode == Configuration.AimKey and not Aiming then
        Aiming = true
        Notify("[Aiming Mode]: ON")
    end
end)

local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
    if not Fluent then
        InputEnded:Disconnect()
    end
    if not UserInputService:GetFocusedTextBox() and Input.KeyCode == Configuration.AimKey and Aiming then
        ResetFields()
        Notify("[Aiming Mode]: OFF")
    end
end)


--// Checking Target

local function IsReady(Target)
    if Target and Target:FindFirstChildWhichIsA("Humanoid") and Target:FindFirstChildWhichIsA("Humanoid").Health > 0 and not Target:FindFirstChildWhichIsA("ForceField") and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
        local _Player = Players:GetPlayerFromCharacter(Target)
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
            RaycastParameters.FilterDescendantsInstances = {Player.Character}
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
        end
        return true, Target, TargetPart
    else
        return false
    end
end


--// String Generation

local function GenerateString()
    return string.lower(string.reverse(string.sub(HttpService:GenerateGUID(false), 1, 8)))
end


--// ESP Creation

local function CreateESP(Character)
    if Configuration.ESP and not Character:FindFirstChildWhichIsA("SelectionBox") then
        local Hitbox = Instance.new("SelectionBox", Character)
        task.spawn(function()
            while task.wait() do
                for Index = 1, 230 do
                    if not Character:FindFirstChildWhichIsA("SelectionBox") then
                        break
                    elseif not Fluent or Target ~= Character then
                        Debris:AddItem(Hitbox, 0)
                        break
                    end
                    Hitbox.Name = GenerateString()
                    Hitbox.Color3 = Color3.fromHSV(Index / 230, 1, 1)
                    task.wait()
                end
            end
        end)
        Hitbox.LineThickness = 0.05
        Hitbox.Adornee = Character
    end
end


--// Aimbot Loop

local AimbotLoop; AimbotLoop = RunService.RenderStepped:Connect(function()
    pcall(function()
        if Fluent.Unloaded then
            Fluent = nil
            ResetFields()
            AimbotLoop:Disconnect()
        elseif not Configuration.Aimbot then
            if Aiming then
                Notify("[Aiming Mode]: OFF")
            end
            ResetFields()
        end
        if Aiming then
            for _, _Player in next, Players:GetPlayers() do
                local IsCharacterReady, Character, Part = IsReady(_Player.Character)
                if _Player ~= Player and IsCharacterReady then
                    local Vector, IsInViewport = Camera:WorldToViewportPoint(Part.Position)
                    if IsInViewport then
                        local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
                        if Magnitude <= (Configuration.DistanceCheck and Configuration.TriggerDistance or math.huge) and not Target then
                            Target = Character
                            CreateESP(Target)
                            Notify(string.format("[Target]: @%s", _Player.Name))
                        end
                    end
                end
            end
            local IsTargetReady, self, Part = IsReady(Target)
            if IsTargetReady then
                if Configuration.UseSensitivity then
                    TweenService:Create(Camera, TweenInfo.new(Configuration.Sensitivity), {CFrame = CFrame.new(Camera.CFrame.Position, Part.Position)}):Play()
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Part.Position)
                end
            else
                Target = nil
            end
        end
    end)
end)