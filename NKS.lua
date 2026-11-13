-- NKS client utility for Evade.
-- Interface powered by the documented WindUI release.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ServerStateRegistryService = require(
    ReplicatedStorage.Services.Data.ServerStateRegistryService
)
local AdminCommandRemote = ReplicatedStorage.Remotes.Admin.Command

if _G.NKSCleanup then pcall(_G.NKSCleanup) end

local state = {
    playtimeTwoMinutes = false,
    skipIntermission = false,
    skipVote = false,
    autoEvent = false,
    antiNextbot = false,
    antiAfk = false,
    skyFarm = false,
    fullBright = false,
    noclip = false,
    streakGuard = false,
}

local config = {
    roundCommand = "!time 1",
    specialRound = nil,
    roundCheckInterval = 0.25,
    roundRetryInterval = 2,
    activeRoundTimeTrigger = 60,
    skyHeight = 1000,
    skyRadius = 100,
    windowKey = "RightShift",
    noclipKey = "RightAlt",
    showFloatingButton = true,
    skySpeed = 0.8,
    nextbotRange = 100,
    eventInterval = 0.12,
}

local runtime = {
    alive = true,
    connections = {},
    savedCFrame = nil,
    orbitCenter = nil,
    orbitAngle = 0,
    orbitStarted = false,
    originalLighting = nil,
    eventClock = 0,
    avoidClock = 0,
    roundClock = 0,
    roundPhase = nil,
    roundCommandSent = false,
    specialRoundSent = false,
    lastRoundAttempt = -math.huge,
    roundCommandCount = 0,
    lastRoundStatus = nil,
    activeRoundCommandSent = false,
    lastCommandPhase = nil,
    noclipParts = {},
    noclipCharacter = nil,
    noclipConnections = {},
    childCaches = {},
    overviewClock = 0,
}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    runtime.connections[#runtime.connections + 1] = connection
    return connection
end

local function getRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function zeroVelocity(root)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function clearChildCaches()
    for _, cache in pairs(runtime.childCaches) do
        for _, connection in ipairs(cache.connections) do connection:Disconnect() end
    end
    table.clear(runtime.childCaches)
end

local function releaseChildCache(slot)
    local cache = runtime.childCaches[slot]
    if not cache then return end
    for _, connection in ipairs(cache.connections) do connection:Disconnect() end
    runtime.childCaches[slot] = nil
end

local function cachedChildren(slot, folder)
    local cache = runtime.childCaches[slot]
    if cache and cache.folder == folder then return cache.items end
    if cache then
        for _, connection in ipairs(cache.connections) do connection:Disconnect() end
    end
    cache = {folder = folder, items = {}, connections = {}}
    runtime.childCaches[slot] = cache
    if not folder then return cache.items end
    cache.connections[1] = folder.ChildAdded:Connect(function(item) cache.items[item] = true end)
    cache.connections[2] = folder.ChildRemoved:Connect(function(item) cache.items[item] = nil end)
    for _, item in ipairs(folder:GetChildren()) do cache.items[item] = true end
    return cache.items
end

local function restoreNoclip()
    for _, connection in ipairs(runtime.noclipConnections) do connection:Disconnect() end
    table.clear(runtime.noclipConnections)
    for part, canCollide in pairs(runtime.noclipParts) do
        pcall(function() part.CanCollide = canCollide end)
    end
    table.clear(runtime.noclipParts)
    runtime.noclipCharacter = nil
end

local function applyNoclip()
    local character = LocalPlayer.Character
    if character ~= runtime.noclipCharacter then
        restoreNoclip()
        runtime.noclipCharacter = character
        if character then
            local function capture(part)
                if part:IsA("BasePart") and runtime.noclipParts[part] == nil then
                    runtime.noclipParts[part] = part.CanCollide
                end
            end
            runtime.noclipConnections[1] = character.DescendantAdded:Connect(capture)
            runtime.noclipConnections[2] = character.DescendantRemoving:Connect(function(part)
                local original = runtime.noclipParts[part]
                if original ~= nil then
                    pcall(function() part.CanCollide = original end)
                    runtime.noclipParts[part] = nil
                end
            end)
            for _, part in ipairs(character:GetDescendants()) do capture(part) end
        end
    end
    if not character then return end
    for part in pairs(runtime.noclipParts) do
        if part.CanCollide then part.CanCollide = false end
    end
end

local WINDUI_VERSION = "1.6.66"
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/download/" .. WINDUI_VERSION .. "/main.lua"
))()

WindUI:SetNotificationLower(true)

local specialRoundValues = {"None"}
local specialRoundsFolder = ReplicatedStorage.Info:FindFirstChild("SpecialRounds")
if specialRoundsFolder then
    for _, specialRound in ipairs(specialRoundsFolder:GetChildren()) do
        if specialRound:IsA("ModuleScript") then
            specialRoundValues[#specialRoundValues + 1] = specialRound.Name
        end
    end
    table.sort(specialRoundValues, function(a, b)
        if a == "None" then return true end
        if b == "None" then return false end
        return string.lower(a) < string.lower(b)
    end)
end

-- Graphite surfaces with cyan accents for a restrained tactical HUD.
local TACTICAL_THEME = "NKS Tactical"
WindUI:AddTheme({
    Name = TACTICAL_THEME,
    Accent = WindUI:Gradient({
        ["0"] = { Color = Color3.fromRGB(36, 156, 210), Transparency = 0 },
        ["100"] = { Color = Color3.fromRGB(64, 201, 255), Transparency = 0 },
    }, { Rotation = 0 }),
    Background = Color3.fromRGB(12, 16, 23),
    Outline = Color3.fromRGB(42, 56, 72),
    Text = Color3.fromRGB(236, 243, 250),
    Placeholder = Color3.fromRGB(145, 162, 181),
    Button = Color3.fromRGB(23, 32, 45),
    Icon = Color3.fromRGB(64, 201, 255),
})

local Window = WindUI:CreateWindow({
    Title = "NKS  /  Evade",
    Icon = "crosshair",
    Author = "MODERN TACTICAL  ·  PC EDITION",
    Folder = "NKS",
    Size = UDim2.fromOffset(820, 560),
    MinSize = Vector2.new(640, 460),
    MaxSize = Vector2.new(1000, 760),
    CornerRadius = UDim.new(0, 16),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = TACTICAL_THEME,
    Transparent = false,
    Resizable = true,
    SideBarWidth = 185,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    -- Independent rounded cards, rather than WindUI's joined top/middle/bottom shapes.
    NewElements = false,
    ElementsRadius = 14,
    OpenButton = {
        Title = "N",
        Icon = "",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 1,
        Color = ColorSequence.new(
            Color3.fromRGB(64, 201, 255),
            Color3.fromRGB(64, 201, 255)
        ),
    },
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- Keep the built-in floating button, but remove WindUI's drag-handle visuals.
local function compactOpenButton()
    local parent = Window.Parent
    if not parent then return end
    for _, candidate in ipairs(parent:GetDescendants()) do
        local dragHandle = candidate:FindFirstChild("Drag")
        local textButton = candidate:FindFirstChild("TextButton")
        local label = textButton and textButton:FindFirstChild("TextLabel")
        if candidate:IsA("Frame") and label and label.Text == "N" then
            if dragHandle then dragHandle:Destroy() end
            for _, child in ipairs(candidate:GetChildren()) do
                if child:IsA("Frame") and child ~= textButton then
                    child:Destroy()
                end
            end
            candidate.AutomaticSize = Enum.AutomaticSize.None
            candidate.Size = UDim2.fromOffset(44, 44)
            textButton.AutomaticSize = Enum.AutomaticSize.None
            textButton.Size = UDim2.fromOffset(36, 36)
            local textLayout = textButton:FindFirstChildOfClass("UIListLayout")
            if textLayout then
                textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            end
            local textPadding = textButton:FindFirstChildOfClass("UIPadding")
            if textPadding then
                textPadding.PaddingLeft = UDim.new(0, 0)
                textPadding.PaddingRight = UDim.new(0, 0)
            end

            local cyan = Color3.fromRGB(64, 201, 255)
            local stroke = candidate:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = cyan
                local gradient = stroke:FindFirstChildOfClass("UIGradient")
                if gradient then
                    gradient.Color = ColorSequence.new(cyan, cyan)
                end
            end

            -- WindUI binds dragging to the parent container; bind directly to
            -- the visible button so dragging still works after hiding its handle.
            local UserInputService = game:GetService("UserInputService")
            local container = candidate.Parent
            local dragInput, dragStart, startPosition
            local moved = false
            table.insert(runtime.connections, textButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                    dragStart = input.Position
                    startPosition = container.Position
                    moved = false
                end
            end))
            table.insert(runtime.connections, UserInputService.InputChanged:Connect(function(input)
                if not dragInput then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput then
                    local delta = input.Position - dragStart
                    if delta.Magnitude >= 4 then
                        moved = true
                        textButton.Active = false
                        container.Position = UDim2.new(
                            startPosition.X.Scale, startPosition.X.Offset + delta.X,
                            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                        )
                    end
                end
            end))
            table.insert(runtime.connections, UserInputService.InputEnded:Connect(function(input)
                if dragInput and (input == dragInput
                    or (dragInput.UserInputType == Enum.UserInputType.MouseButton1
                        and input.UserInputType == Enum.UserInputType.MouseButton1)) then
                    local suppressClick = moved
                    dragInput, dragStart, startPosition, moved = nil, nil, nil, false
                    if suppressClick then
                        task.delay(0.12, function()
                            if textButton.Parent then textButton.Active = true end
                        end)
                    end
                end
            end))
            return
        end
    end
end
task.defer(compactOpenButton)

local Tabs = {
    Dashboard = Window:Tab({
        Title = "Overview",
        Desc = "Session at a glance",
        Icon = "layout-dashboard",
    }),
    Farming = Window:Tab({
        Title = "Farming",
        Desc = "Round control, tokens, orbit and idle protection",
        Icon = "repeat-2",
    }),
    Survival = Window:Tab({
        Title = "Survival",
        Desc = "Movement and visibility",
        Icon = "shield",
    }),
    Settings = Window:Tab({
        Title = "Settings",
        Desc = "Appearance and shortcuts",
        Icon = "settings",
    }),
}

local function characterState()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character then return "Not spawned" end
    if not root then return "Lobby placeholder" end
    if humanoid then return string.format("Playable · %.0f HP", humanoid.Health) end
    return "Playable"
end

local function nextbotCount()
    local folder = workspace:FindFirstChild("Players")
    local count = 0
    for model in pairs(cachedChildren("nextbots", folder)) do
        if model:GetAttribute("AI") == true then count += 1 end
    end
    return count
end

Tabs.Dashboard:Paragraph({
    Title = LocalPlayer.Name .. "  /  " .. game.Name,
    Desc = string.format(
        "Connected client\nPlace %s · Job %s",
        tostring(game.PlaceId),
        tostring(game.JobId):sub(1, 8)
    ),
    Icon = "user-round-check",
})

local RuntimeStatus = Tabs.Dashboard:Paragraph({
    Title = "System activity",
    Desc = "Ready · All features are off",
    Icon = "activity",
})

local SnapshotCard = Tabs.Dashboard:Paragraph({
    Title = "Live session",
    Desc = "Character: " .. characterState() .. "\nNextbots detected: " .. tostring(nextbotCount()),
    Icon = "radar",
})

local ActiveCard = Tabs.Dashboard:Paragraph({
    Title = "Active systems",
    Desc = "All features are off",
    Icon = "layers",
})

local featureLabels = {
    {"playtimeTwoMinutes", "Playtime 2 Minutes"},
    {"skipIntermission", "Skip Intermission"},
    {"skipVote", "Skip Vote"},
    {"autoEvent", "Farm Token"},
    {"antiAfk", "Anti AFK"},
    {"antiNextbot", "Anti NextBots"},
    {"noclip", "Noclip"},
    {"streakGuard", "Streak Guard"},
    {"fullBright", "FullBright"},
    {"skyFarm", "Sky Orbit"},
}

local function refreshOverview()
    local roundStatus = ServerStateRegistryService:Get("RoundStatus") or 0
    local timeLeft = ServerStateRegistryService:Get("Time") or 0
    local phase = ServerStateRegistryService:Get("Voting") == true and "Map voting"
        or (ServerStateRegistryService:Get("MapLoading") == true and "Loading map")
        or (roundStatus == 2 and "In round")
        or (roundStatus == 1 and "Intermission") or "Waiting"
    local snapshot = characterState() .. "\n" .. phase .. " · " .. tostring(math.floor(timeLeft))
        .. "s remaining\nNextbots · " .. tostring(nextbotCount())
    if snapshot ~= runtime.lastSnapshot then
        runtime.lastSnapshot = snapshot
        SnapshotCard:SetDesc(snapshot)
    end
    local active = {}
    for _, feature in ipairs(featureLabels) do
        if state[feature[1]] then active[#active + 1] = feature[2] end
    end
    if config.specialRound then active[#active + 1] = "Special Round · " .. config.specialRound end
    local summary = #active > 0 and table.concat(active, "  ·  ") or "All features are off"
    if summary ~= runtime.lastFeatureSummary then
        runtime.lastFeatureSummary = summary
        ActiveCard:SetDesc(summary)
    end
end

Tabs.Dashboard:Button({
    Title = "Refresh Scan",
    Desc = "Re-scan player vitals and nearby threats.",
    Icon = "refresh-cw",
    Callback = function()
        refreshOverview()
        WindUI:Notify({
            Title = "Snapshot updated",
            Content = characterState(),
            Icon = "check",
            Duration = 2,
        })
    end,
})

Tabs.Dashboard:Paragraph({
    Title = "Quick controls",
    Desc = "Right Shift · Show / hide   |   N button · Drag to reposition\nLive session updates every second.",
    Icon = "keyboard",
})

local function setStatus(message)
    message = tostring(message)
    if runtime.lastStatus == message then return end
    runtime.lastStatus = message
    RuntimeStatus:SetDesc(message)
end

local function isVisibleInGame(object, gameGui)
    if not object or not gameGui or not gameGui.Enabled then return false end
    local current = object
    while current and current ~= gameGui do
        if current:IsA("GuiObject") and not current.Visible then return false end
        current = current.Parent
    end
    return current == gameGui
end

local function checkStreakGuard()
    local roundStatus = ServerStateRegistryService:Get("RoundStatus")
    -- Only a known non-active phase rearms the one-request latch.
    if roundStatus == 0 or roundStatus == 1 then
        runtime.streakResetAttempted = false
    end
    if not runtime.alive or not state.streakGuard or roundStatus ~= 2
        or runtime.streakResetAttempted
    then return end
    runtime.streakGuardDiagnostic = "Waiting for visible downed state"
    local loading = ServerStateRegistryService:Get("MapLoading")
    if loading ~= nil and loading ~= false then
        runtime.streakGuardDiagnostic = "Blocked: map loading or unsupported loading state"
        return
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local gameGui = playerGui and playerGui:FindFirstChild("Game")
    local respawn = gameGui and gameGui:FindFirstChild("Respawn")
    local downed = respawn and respawn:FindFirstChild("Downed")
    local death = respawn and respawn:FindFirstChild("Death")
    if not downed or not death then
        runtime.streakGuardDiagnostic = "Blocked: downed UI unavailable"
        setStatus("Streak Guard · downed UI unavailable; no reset requested")
        return
    end
    if isVisibleInGame(death, gameGui) then
        runtime.streakGuardDiagnostic = "Blocked: already died"
        setStatus("Streak Guard · already died; streak protection unconfirmed")
        return
    end
    if not isVisibleInGame(downed, gameGui) then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    -- Downed characters can have zero health; only the visible Death UI blocks above.
    if not humanoid then
        runtime.streakGuardDiagnostic = "Blocked: humanoid unavailable"
        setStatus("Streak Guard · humanoid unavailable; no reset requested")
        return
    end
    local map = workspace:FindFirstChild("Map")
    if not map or map:GetAttribute("ClientLoaded") ~= true then
        runtime.streakGuardDiagnostic = "Blocked: map not confirmed loaded"
        setStatus("Streak Guard · map not confirmed loaded; no reset requested")
        return
    end
    local name = map:GetAttribute("MapName")
    -- Do not guess aliases for display names containing spaces or punctuation.
    if type(name) ~= "string" or not name:match("^[%w_%-]+$") then
        setStatus("Streak Guard · map command name unavailable; no reset requested")
        return
    end
    local command = "!map " .. string.lower(name)
    runtime.streakResetAttempted = true
    runtime.streakGuardDiagnostic = "Request attempted: " .. command
    local ok, err = pcall(function() AdminCommandRemote:FireServer(command) end)
    if ok then
        setStatus("Streak Guard · requested " .. command .. "; reset and streak not confirmed")
    else
        setStatus("Streak Guard · request failed: " .. tostring(err))
    end
end

local controls = {}
local function setToggle(key, enabled, source, fromUi)
    enabled = enabled == true
    if not fromUi and controls[key] then
        controls[key]:Set(enabled)
        return
    end
    if state[key] == enabled then return end
    state[key] = enabled
    if not enabled then
        if key == "autoEvent" then releaseChildCache("tickets") end
        if key == "antiNextbot" then releaseChildCache("spawns") end
    end
    if key == "noclip" then
        if enabled then applyNoclip() else restoreNoclip() end
    end
    refreshOverview()
    local title = source or key
    setStatus(title .. (enabled and " enabled" or " disabled"))
    WindUI:Notify({
        Title = title,
        Content = enabled and "Enabled" or "Disabled",
        Icon = enabled and "circle-check" or "circle-minus",
        Duration = 1.8,
    })
end

local RoundControl = Tabs.Farming:Section({
    Title = "Round Control",
    Desc = "Independent round actions; admin access required",
    Icon = "repeat-2",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

local Survival = Tabs.Survival:Section({
    Title = "Survival controls",
    Desc = "Threat response, collision and lighting",
    Icon = "shield",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

controls.playtimeTwoMinutes = RoundControl:Toggle({
    Title = "Playtime 2 Minutes",
    Desc = "Skip the final 60 seconds at the two-minute playtime mark. Requires admin access.",
    Icon = "timer-reset",
    Value = false,
    Flag = "playtime_two_minutes",
    Callback = function(value) setToggle("playtimeTwoMinutes", value, "Playtime 2 Minutes", true) end,
})

controls.skipIntermission = RoundControl:Toggle({
    Title = "Skip Intermission",
    Desc = "Skip only intermission. Does not enable vote or playtime skipping.",
    Icon = "fast-forward",
    Value = false,
    Flag = "skip_intermission",
    Callback = function(value) setToggle("skipIntermission", value, "Skip Intermission", true) end,
})

controls.skipVote = RoundControl:Toggle({
    Title = "Skip Vote",
    Desc = "Skip only the map voting phase. Requires admin access.",
    Icon = "skip-forward",
    Value = false,
    Flag = "skip_vote",
    Callback = function(value) setToggle("skipVote", value, "Skip Vote", true) end,
})

controls.specialRound = RoundControl:Dropdown({
    Title = "Special Round",
    Desc = "Request at intermission, even with Skip Intermission off. None disables it; requires admin.",
    Values = specialRoundValues,
    Value = "None",
    AllowNone = false,
    Callback = function(value)
        if value == "None" then
            config.specialRound = nil
        else
            config.specialRound = value
        end
        runtime.specialRoundSent = false
        refreshOverview()
        setStatus(config.specialRound and ("Special Round selected · " .. config.specialRound)
            or "Special Round disabled")
    end,
})

local TokenFarming = Tabs.Farming:Section({
    Title = "Token Farming",
    Desc = "Event token collection",
    Icon = "ticket",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

controls.autoEvent = TokenFarming:Toggle({
    Title = "Farm Token",
    Desc = "Moves to the nearest event ticket. Pauses automatically during Sky Orbit.",
    Icon = "ticket",
    Value = false,
    Flag = "auto_event",
    Callback = function(value) setToggle("autoEvent", value, "Farm Token", true) end,
})

local IdleProtection = Tabs.Farming:Section({
    Title = "Idle Protection",
    Desc = "Independent idle protection",
    Icon = "clock-3",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

controls.antiAfk = IdleProtection:Toggle({
    Title = "Anti AFK",
    Desc = "Responds only when Roblox reports inactivity.",
    Icon = "clock-3",
    Value = false,
    Flag = "anti_afk",
    Callback = function(value) setToggle("antiAfk", value, "Anti AFK", true) end,
})

controls.streakGuard = Survival:Toggle({
    Title = "Streak Guard · Reset on downed",
    Desc = "UI-based downed detection requests the current map once per round. Affects everyone; requires admin. Streak preservation is not guaranteed.",
    Icon = "shield-alert",
    Value = false,
    Flag = "streak_guard",
    Callback = function(value) setToggle("streakGuard", value, "Streak Guard", true) end,
})

controls.antiNextbot = Survival:Toggle({
    Title = "Anti NextBots",
    Desc = "Move to a distant item spawn when a Nextbot gets close.",
    Icon = "shield-alert",
    Value = false,
    Flag = "anti_nextbot",
    Callback = function(value) setToggle("antiNextbot", value, "Anti NextBots", true) end,
})

controls.noclip = Survival:Toggle({
    Title = "Noclip",
    Desc = "Pass through walls. Restores character collision when disabled.",
    Icon = "ghost",
    Value = false,
    Flag = "noclip",
    Callback = function(value) setToggle("noclip", value, "Noclip", true) end,
})

controls.fullBright = Survival:Toggle({
    Title = "FullBright",
    Desc = "Applies readable lighting and restores the captured lighting when disabled.",
    Icon = "sun",
    Value = false,
    Flag = "full_bright",
    Callback = function(value) setToggle("fullBright", value, "FullBright", true) end,
})

local Orbit = Tabs.Farming:Section({
    Title = "Sky Orbit",
    Desc = "A high-altitude route. Your starting position is restored on exit.",
    Icon = "orbit",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

controls.skyFarm = Orbit:Toggle({
    Title = "Enable Sky Orbit",
    Desc = "Token collection and Nextbot movement pause while orbiting. Round controls stay independent.",
    Icon = "power",
    Value = false,
    Flag = "sky_farm",
    Callback = function(value) setToggle("skyFarm", value, "Sky Orbit", true) end,
})

local OrbitSliders = {}
OrbitSliders.height = Orbit:Slider({
    Title = "Height",
    Desc = "Vertical distance above the activation point.",
    Step = 50,
    Value = {Min = 50, Max = 5000, Default = config.skyHeight},
    Flag = "sky_height",
    Callback = function(value)
        config.skyHeight = value
        setStatus("Orbit height · " .. tostring(value) .. " studs")
    end,
})

OrbitSliders.radius = Orbit:Slider({
    Title = "Radius",
    Desc = "Horizontal orbit radius.",
    Step = 5,
    Value = {Min = 5, Max = 250, Default = config.skyRadius},
    Flag = "sky_radius",
    Callback = function(value)
        config.skyRadius = value
        setStatus("Orbit radius · " .. tostring(value) .. " studs")
    end,
})

OrbitSliders.speed = Orbit:Slider({
    Title = "Speed",
    Desc = "Angular speed in radians per second.",
    Step = 0.1,
    Value = {Min = 0.1, Max = 5, Default = config.skySpeed},
    Flag = "sky_speed",
    Callback = function(value)
        config.skySpeed = value
        setStatus(string.format("Orbit speed · %.1f rad/s", value))
    end,
})

Orbit:Button({
    Title = "Restore orbit defaults",
    Desc = "Height 1000 · Radius 100 · Speed 0.8",
    Icon = "rotate-ccw",
    Callback = function()
        OrbitSliders.height:Set(1000)
        OrbitSliders.radius:Set(100)
        OrbitSliders.speed:Set(0.8)
        setStatus("Orbit defaults restored")
    end,
})

local Appearance = Tabs.Settings:Section({
    Title = "Appearance",
    Desc = "Theme and window finish",
    Icon = "palette",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

Appearance:Dropdown({
    Title = "Theme",
    Desc = "Changes the interface theme immediately.",
    Values = {TACTICAL_THEME, "Dark", "Light"},
    Value = TACTICAL_THEME,
    AllowNone = false,
    Callback = function(value)
        WindUI:SetTheme(value)
        setStatus("Theme · " .. tostring(value))
    end,
})

Appearance:Toggle({
    Title = "Transparent window",
    Desc = "Use WindUI transparency without changing game lighting.",
    Icon = "blend",
    Value = false,
    Callback = function(value)
        Window:ToggleTransparency(value)
    end,
})

Tabs.Settings:Space()
local WindowControls = Tabs.Settings:Section({
    Title = "Window controls",
    Desc = "Visibility shortcut and session cleanup",
    Icon = "keyboard",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

local WindowKeyControl, NoclipKeyControl

local function handleNoclipInput(input, processed)
    if not runtime.alive or processed or UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == Enum.KeyCode[config.noclipKey] then
        setToggle("noclip", not state.noclip, "Noclip")
    end
end

local function setNoclipKey(value)
    local name = tostring(value)
    if not Enum.KeyCode[name] then return end
    if name == config.windowKey then
        if NoclipKeyControl then NoclipKeyControl:Set(config.noclipKey) end
        setStatus("Noclip key · choose a different key from Window key")
        return
    end
    config.noclipKey = name
    setStatus("Noclip key · " .. name)
end

local function setFloatingButton(enabled)
    enabled = enabled == true
    config.showFloatingButton = enabled
    Window.IsOpenButtonEnabled = enabled
    if Window.OpenButtonMain then
        Window.OpenButtonMain:Visible(enabled and Window.Closed == true)
    end
end

local function setWindowKey(value)
    local name = typeof(value) == "EnumItem" and value.Name or tostring(value)
    local key = Enum.KeyCode[name]
    if not key then return end
    if name == config.noclipKey then
        if WindowKeyControl then WindowKeyControl:Set(config.windowKey) end
        setStatus("Window key · choose a different key from Noclip key")
        return
    end
    Window:SetToggleKey(key)
    config.windowKey = name
    setStatus("Window key · " .. name)
end

WindowKeyControl = WindowControls:Dropdown({
    Title = "Window key",
    Desc = "Select a shortcut. Applied immediately; do not use while typing in chat.",
    Values = {"RightShift", "LeftAlt", "RightAlt", "Insert", "Home", "F4", "F6", "F8"},
    Value = config.windowKey,
    AllowNone = false,
    Callback = setWindowKey,
})

NoclipKeyControl = WindowControls:Dropdown({
    Title = "Noclip key",
    Desc = "Toggle noclip without opening the panel. Ignored while typing.",
    Values = {"RightAlt", "LeftAlt", "RightShift", "Insert", "Home", "F4", "F6", "F8"},
    Value = config.noclipKey,
    AllowNone = false,
    Callback = setNoclipKey,
})

WindowControls:Toggle({
    Title = "Show floating N button",
    Desc = "Hide the minimized logo. Your Window key can still reopen the panel.",
    Icon = "eye",
    Value = true,
    Callback = setFloatingButton,
})

connect(UserInputService.InputBegan, handleNoclipInput)

WindowControls:Button({
    Title = "Unload NKS",
    Desc = "Restore managed state and remove the WindUI window.",
    Icon = "power-off",
    Callback = function()
        if _G.NKSCleanup then _G.NKSCleanup() end
    end,
})

Window:CreateTopbarButton("theme-switcher", "moon", function()
    local nextTheme = WindUI:GetCurrentTheme() == TACTICAL_THEME and "Light" or TACTICAL_THEME
    WindUI:SetTheme(nextTheme)
    setStatus("Theme · " .. nextTheme)
end, 990)

Tabs.Dashboard:Select()

local lightingProperties = {
    "GlobalShadows", "Brightness", "Ambient", "OutdoorAmbient",
    "ClockTime", "ExposureCompensation", "FogEnd",
}

local fullBrightValues = {
    GlobalShadows = false,
    Brightness = 3,
    Ambient = Color3.new(1, 1, 1),
    OutdoorAmbient = Color3.new(1, 1, 1),
    ClockTime = 12,
    ExposureCompensation = 0.5,
    FogEnd = 1e10,
}

local function applyFullBright()
    for property, value in pairs(fullBrightValues) do
        if Lighting[property] ~= value then Lighting[property] = value end
    end
end

local function saveLighting()
    if runtime.originalLighting then return end
    runtime.originalLighting = {}
    for _, property in ipairs(lightingProperties) do
        runtime.originalLighting[property] = Lighting[property]
    end
end

local function restoreLighting()
    if not runtime.originalLighting then return end
    for property, value in pairs(runtime.originalLighting) do Lighting[property] = value end
    runtime.originalLighting = nil
end

local function nearestEventItem(root)
    local effects = workspace:FindFirstChild("Effects")
    local tickets = effects and effects:FindFirstChild("Tickets")
    local nearest, distance = nil, math.huge
    for item in pairs(cachedChildren("tickets", tickets)) do
        local part = item:FindFirstChild("HumanoidRootPart") or item:FindFirstChildWhichIsA("BasePart")
        if part then
            local candidateDistance = (root.Position - part.Position).Magnitude
            if candidateDistance < distance then nearest, distance = part, candidateDistance end
        end
    end
    return nearest, distance
end

local function nearestNextbot(root)
    local folder = workspace:FindFirstChild("Players")
    local nearest, distance = nil, config.nextbotRange
    for bot in pairs(cachedChildren("nextbots", folder)) do
        local botRoot = bot:FindFirstChild("HumanoidRootPart")
        if bot:GetAttribute("AI") == true and botRoot then
            local candidateDistance = (root.Position - botRoot.Position).Magnitude
            if candidateDistance < distance then nearest, distance = botRoot, candidateDistance end
        end
    end
    return nearest, distance
end

local function safestItemSpawn(threat)
    local map = workspace:FindFirstChild("Map")
    local spawns = map and map:FindFirstChild("ItemSpawns")
    local safest, distance = nil, -math.huge
    for spawnPoint in pairs(cachedChildren("spawns", spawns)) do
        if spawnPoint.Name == "ItemSpawn" and spawnPoint:IsA("BasePart") then
            local candidateDistance = (spawnPoint.Position - threat.Position).Magnitude
            if candidateDistance > distance then safest, distance = spawnPoint, candidateDistance end
        end
    end
    return safest
end

local function currentRoundPhase(roundStatus, timeLeft, mapLoading, voting)
    if mapLoading then return nil end
    if voting then
        return "Map voting"
    end

    if roundStatus == 1 and type(timeLeft) == "number" and timeLeft <= 30 then
        return "Intermission"
    end

    return nil
end

local function sendRoundCommand(phase)
    runtime.lastRoundAttempt = os.clock()

    local ok, err = pcall(function()
        AdminCommandRemote:FireServer(config.roundCommand)
    end)

    if not ok then
        setStatus("Time Skip · " .. tostring(err))
        return false
    end

    runtime.roundCommandCount += 1
    runtime.lastCommandPhase = phase
    setStatus(phase .. " · sent " .. config.roundCommand)
    WindUI:Notify({
        Title = "Time Skip",
        Content = phase .. " · " .. config.roundCommand,
        Icon = "timer",
        Duration = 2,
    })
    return true
end

local function sendSpecialRoundCommand(phase)
    if not config.specialRound then return true end

    runtime.lastRoundAttempt = os.clock()
    local command = "!specialround " .. config.specialRound
    local ok, err = pcall(function()
        AdminCommandRemote:FireServer(command)
    end)

    if not ok then
        setStatus("Special Round · " .. tostring(err))
        return false
    end

    runtime.roundCommandCount += 1
    runtime.lastCommandPhase = phase
    setStatus(phase .. " · sent " .. command)
    WindUI:Notify({
        Title = "Special Round",
        Content = phase .. " · " .. command,
        Icon = "sparkles",
        Duration = 2,
    })
    return true
end

local function checkRoundAutomation()
    local roundStatus = ServerStateRegistryService:Get("RoundStatus")
    local timeLeft = ServerStateRegistryService:Get("Time")
    local mapLoading = ServerStateRegistryService:Get("MapLoading") == true
    local voting = ServerStateRegistryService:Get("Voting") == true
    -- Loading is a pause, not confirmation that the previous phase ended.
    if mapLoading then return end
    local phase = currentRoundPhase(roundStatus, timeLeft, mapLoading, voting)

    if phase ~= runtime.roundPhase then
        runtime.roundPhase = phase
        runtime.roundCommandSent = false
        runtime.specialRoundSent = false
    end

    if roundStatus ~= runtime.lastRoundStatus then
        runtime.lastRoundStatus = roundStatus
        if roundStatus == 2 then runtime.activeRoundCommandSent = false end
    end

    if os.clock() - runtime.lastRoundAttempt < config.roundRetryInterval then return end

    if phase == "Intermission" and config.specialRound and not runtime.specialRoundSent then
        runtime.specialRoundSent = sendSpecialRoundCommand(phase)
        return
    end

    local skipPhase = (phase == "Map voting" and state.skipVote)
        or (phase == "Intermission" and state.skipIntermission)
    if skipPhase and not runtime.roundCommandSent then
        runtime.roundCommandSent = sendRoundCommand(phase)
    elseif state.playtimeTwoMinutes
        and roundStatus == 2
        and not voting
        and type(timeLeft) == "number"
        and timeLeft <= config.activeRoundTimeTrigger
        and not runtime.activeRoundCommandSent
    then
        runtime.activeRoundCommandSent = sendRoundCommand("Playtime · two-minute mark")
    end
end

connect(LocalPlayer.Idled, function()
    if not state.antiAfk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    setStatus("Anti AFK pulse sent")
end)

connect(LocalPlayer.CharacterAdded, function()
    restoreNoclip()
    runtime.orbitStarted = false
    runtime.savedCFrame = nil
    runtime.orbitCenter = nil
end)

connect(RunService.Stepped, function()
    if runtime.alive and state.noclip then applyNoclip() end
end)

connect(RunService.Heartbeat, function(dt)
    if not runtime.alive then return end
    checkStreakGuard()
    local root = getRoot()

    runtime.overviewClock += dt
    if runtime.overviewClock >= 1 then
        runtime.overviewClock = 0
        refreshOverview()
    end

    if state.fullBright then
        saveLighting()
        applyFullBright()
    elseif runtime.originalLighting then
        restoreLighting()
    end

    runtime.roundClock += dt
    if runtime.roundClock >= config.roundCheckInterval then
        runtime.roundClock = 0
        checkRoundAutomation()
    end

    if not root then return end

    if state.skyFarm then
        if not runtime.orbitStarted then
            runtime.orbitStarted = true
            runtime.savedCFrame = root.CFrame
            runtime.orbitCenter = root.Position + Vector3.new(0, config.skyHeight, 0)
            runtime.orbitAngle = 0
            setStatus("Sky orbit started")
        end
        runtime.orbitAngle += dt * config.skySpeed
        local position = runtime.orbitCenter + Vector3.new(
            math.cos(runtime.orbitAngle) * config.skyRadius,
            0,
            math.sin(runtime.orbitAngle) * config.skyRadius
        )
        zeroVelocity(root)
        root.CFrame = CFrame.lookAt(position, runtime.orbitCenter)
        return
    elseif runtime.orbitStarted then
        runtime.orbitStarted = false
        zeroVelocity(root)
        if runtime.savedCFrame then root.CFrame = runtime.savedCFrame end
        runtime.savedCFrame = nil
        runtime.orbitCenter = nil
        setStatus("Sky orbit stopped; position restored")
    end

    runtime.eventClock += dt
    if state.autoEvent and runtime.eventClock >= config.eventInterval then
        runtime.eventClock = 0
        local target, distance = nearestEventItem(root)
        if target then
            zeroVelocity(root)
            root.CFrame = CFrame.new(target.Position)
            setStatus(string.format("Event item: %.0f studs", distance))
        end
    end

    runtime.avoidClock += dt
    if state.antiNextbot and runtime.avoidClock >= 0.2 then
        runtime.avoidClock = 0
        local threat, distance = nearestNextbot(root)
        if threat then
            local safeSpawn = safestItemSpawn(threat)
            if safeSpawn then
                zeroVelocity(root)
                root.CFrame = safeSpawn.CFrame + Vector3.new(0, 3, 0)
                setStatus(string.format("Avoided Nextbot: %.0f studs", distance))
            end
        end
    end
end)

local function cleanup()
    if not runtime.alive then return end
    runtime.alive = false
    restoreNoclip()
    clearChildCaches()
    local root = getRoot()
    if root and runtime.orbitStarted and runtime.savedCFrame then
        zeroVelocity(root)
        root.CFrame = runtime.savedCFrame
    end
    restoreLighting()
    for _, connection in ipairs(runtime.connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(runtime.connections)
    if Window then pcall(function() Window:Destroy() end) end
    _G.NKS = nil
    _G.NKSCleanup = nil
end

_G.NKS = {
    state = state,
    config = config,
    runtime = runtime,
    ui = {WindUI = WindUI, Window = Window, Toggles = controls},
    set = setToggle,
    cleanup = cleanup,
}
_G.NKSCleanup = cleanup
print("[NKS] loaded with WindUI " .. WINDUI_VERSION)
