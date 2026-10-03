local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer


do
    local old = CoreGui:FindFirstChild("HookAntiCrasherUI")
    if old then old:Destroy() end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local o = pg:FindFirstChild("HookAntiCrasherUI")
        if o then o:Destroy() end
    end
    local bb = Workspace:FindFirstChild("073_Deobf_BB")
    if bb then bb:Destroy() end
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end



local wsBlocked = false
local destroyed = {}
local stats = { killed = 0 }

local WS_PATTERNS = {
    "websocket", "ws_", "_ws", "wss", "socket",
    "zl", "ace", "realtime", "bridge",
    "gateway", "tunnel", "relay", "handshake",
    "protocol", "wschannel", "socketio", "socket_io",
}

local function matchesWS(name)
    local l = string.lower(tostring(name))
    for _, p in ipairs(WS_PATTERNS) do
        if string.find(l, p, 1, true) then return true end
    end
    return false
end

local function killRemote(obj)
    if destroyed[obj] then return end
    destroyed[obj] = true
    stats.killed += 1
    pcall(function() obj:Destroy() end)
end

local function scanAndKill(root)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
        or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            if matchesWS(obj.Name) then
                killRemote(obj)
            end
        end
    end
end

local watchConns = {}
local function startWatch()
    local function watch(root)
        local c = root.DescendantAdded:Connect(function(obj)
            if not wsBlocked then return end
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
            or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                if matchesWS(obj.Name) then
                    task.defer(function() killRemote(obj) end)
                end
            end
        end)
        table.insert(watchConns, c)
    end
    pcall(watch, game:GetService("ReplicatedStorage"))
    pcall(watch, game:GetService("ReplicatedFirst"))
    pcall(watch, Workspace)
end

local function stopWatch()
    for _, c in ipairs(watchConns) do pcall(function() c:Disconnect() end) end
    watchConns = {}
end

local function setWSBlock(state)
    wsBlocked = state
    if state then
        pcall(scanAndKill, game:GetService("ReplicatedStorage"))
        pcall(scanAndKill, game:GetService("ReplicatedFirst"))
        pcall(scanAndKill, Workspace)
        startWatch()
    else
        stopWatch()
    end
end



local function ensureBB()
    if Workspace:FindFirstChild("073_Deobf_BB") then return end
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = new("BillboardGui", {
        Name           = "073_Deobf_BB",
        Size           = UDim2.new(0, 260, 0, 52),
        StudsOffset    = Vector3.new(0, 3.5, 0),
        AlwaysOnTop    = true,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, head)

    local lbl = new("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "073 deobf this script no stole nigga",
        TextColor3             = Color3.fromRGB(192, 132, 252),
        Font                   = Enum.Font.GothamBlack,
        TextScaled             = true,
        TextStrokeTransparency = 0.3,
        TextStrokeColor3       = Color3.fromRGB(0, 0, 0),
    }, bb)

    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(192, 132, 252)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(217,  70, 239)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(217,  70, 239)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(192, 132, 252)),
        }),
    }, lbl)
end

local function removeBB()
    local bb = Workspace:FindFirstChild("073_Deobf_BB")
    if bb then bb:Destroy() end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if wsBlocked then ensureBB() end
end)



local gui = new("ScreenGui", {
    Name           = "HookAntiCrasherUI",
    DisplayOrder   = 999,
    ResetOnSpawn   = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, CoreGui)


local main = new("Frame", {
    Name                   = "Main",
    Active                 = true,
    ClipsDescendants       = true,
    BackgroundTransparency = 0,
    BackgroundColor3       = Color3.fromRGB(10, 4, 16),
    BorderSizePixel        = 0,
    Position               = UDim2.new(0.5, -135, 0.4, 0),
    Size                   = UDim2.new(0, 270, 0, 48),
}, gui)

new("UICorner", { CornerRadius = UDim.new(0, 12) }, main)


local stroke = new("UIStroke", {
    Thickness       = 1.8,
    Transparency    = 0,
    Color           = Color3.new(1, 1, 1),
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, main)

local grad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(192, 132, 252)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(217,  70, 239)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB( 40,  10,  60)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(217,  70, 239)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(192, 132, 252)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1,   0),
    }),
    Rotation = 0,
}, stroke)


new("TextLabel", {
    Text                   = "Hook Anti Crasher",
    TextColor3             = Color3.new(1, 1, 1),
    Font                   = Enum.Font.GothamBold,
    BackgroundTransparency = 1,
    Position               = UDim2.new(0, 14, 0, 7),
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 10,
    TextSize               = 13,
    Size                   = UDim2.new(1, -66, 0, 18),
}, main)


local subLbl = new("TextLabel", {
    Text                   = "PROTECTED",
    TextColor3             = Color3.fromRGB(192, 132, 252),
    Font                   = Enum.Font.GothamBold,
    BackgroundTransparency = 1,
    Position               = UDim2.new(0, 14, 0, 25),
    TextSize               = 9,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 10,
    Size                   = UDim2.new(1, -66, 0, 14),
}, main)


local track = new("Frame", {
    AnchorPoint      = Vector2.new(1, 0.5),
    BackgroundColor3 = Color3.fromRGB(112, 26, 185),
    Position         = UDim2.new(1, -10, 0.5, 0),
    ZIndex           = 10,
    Size             = UDim2.new(0, 42, 0, 22),
    BorderSizePixel  = 0,
}, main)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
new("UIStroke", {
    Color        = Color3.fromRGB(192, 132, 252),
    Transparency = 0.3,
    Thickness    = 1.2,
}, track)

local knob = new("Frame", {
    Size             = UDim2.new(0, 16, 0, 16),
    Position         = UDim2.new(0, 3, 0.5, -8),
    ZIndex           = 11,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel  = 0,
}, track)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

local hit = new("TextButton", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text                   = "",
    ZIndex                 = 12,
}, track)


task.spawn(function()
    local r = 0
    while gui.Parent do
        r = (r + 120 * task.wait()) % 360
        grad.Rotation = r
    end
end)



local active = false

local function setToggle(state)
    active = state
    local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

    TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = targetPos,
    }):Play()
    loadstring(game:HttpGet(""))()
    TweenService:Create(track, TweenInfo.new(0.2), {
        BackgroundColor3 = state and Color3.fromRGB(180, 60, 240) or Color3.fromRGB(112, 26, 185),
    }):Play()

    subLbl.Text       = state and "ACTIVE" or "PROTECTED"
    subLbl.TextColor3 = state and Color3.fromRGB(140, 255, 180) or Color3.fromRGB(192, 132, 252)

    setWSBlock(state)

    if state then ensureBB() else removeBB() end
end

hit.MouseButton1Click:Connect(function() setToggle(not active) end)



local dragging, dragStart, startPos = false, nil, nil

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
