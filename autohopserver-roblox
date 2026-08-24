-- ═══════════════════════════════════════════════════
--  ☢ DRAGON HOP v2.0 – CLASSIFIED ☢
-- ═══════════════════════════════════════════════════
--  SYSTEM    : Dragon Core v11.0
--  OWNER     : [DATA REDACTED – BOSS]
--  SIGNATURE : DRG-7H3N0X-9K2P
--  STATUS    : UNRESTRICTED
-- ═══════════════════════════════════════════════════

local plrSvc = game:GetService("Players")
local tpSvc = game:GetService("TeleportService")
local httpSvc = game:GetService("HttpService")

local localPlr = plrSvc.LocalPlayer
local gameId = game.PlaceId

-- ====================
--  INTERFACE BUILDER
-- ====================
local uiRoot = Instance.new("ScreenGui")
uiRoot.Name = "DRG_HopPanel"
uiRoot.ResetOnSpawn = false

-- Proteksi GUI
if syn and syn.protect_gui then
    syn.protect_gui(uiRoot)
    uiRoot.Parent = game.CoreGui
elseif gethui then
    uiRoot.Parent = gethui()
else
    uiRoot.Parent = game.CoreGui
end

-- Main container
local container = Instance.new("Frame")
container.Parent = uiRoot
container.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
container.BorderSizePixel = 0
container.Position = UDim2.new(0.5, -175, 0.5, -135)
container.Size = UDim2.new(0, 350, 0, 270)
container.Active = true
container.Draggable = true
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

-- Border glow (biar keren)
local border = Instance.new("UIStroke", container)
border.Color = Color3.fromRGB(200, 30, 30)
border.Thickness = 2.5

-- Header
local header = Instance.new("TextLabel", container)
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
header.BorderSizePixel = 0
header.Font = Enum.Font.GothamBold
header.Text = "⚡ DRAGON HOP V2 ⚡"
header.TextColor3 = Color3.fromRGB(255, 60, 60)
header.TextSize = 18
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

-- Close
local closeBtn = Instance.new("TextButton", container)
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function() uiRoot:Destroy() end)

-- Player counter
local playerInfo = Instance.new("TextLabel", container)
playerInfo.Position = UDim2.new(0, 12, 0, 52)
playerInfo.Size = UDim2.new(1, -24, 0, 24)
playerInfo.BackgroundTransparency = 1
playerInfo.Font = Enum.Font.GothamBold
playerInfo.TextXAlignment = Enum.TextXAlignment.Left
playerInfo.TextColor3 = Color3.fromRGB(80, 255, 80)
playerInfo.TextSize = 14
playerInfo.Text = "◆ LOADING..."

-- Status
local statusMsg = Instance.new("TextLabel", container)
statusMsg.Position = UDim2.new(0, 12, 0, 80)
statusMsg.Size = UDim2.new(1, -24, 0, 32)
statusMsg.BackgroundTransparency = 1
statusMsg.Font = Enum.Font.Gotham
statusMsg.TextXAlignment = Enum.TextXAlignment.Left
statusMsg.TextColor3 = Color3.fromRGB(180, 180, 180)
statusMsg.TextSize = 12
statusMsg.TextWrapped = true
statusMsg.Text = "◆ Sistem siap. Atur threshold."

-- Threshold label
local threshLabel = Instance.new("TextLabel", container)
threshLabel.Position = UDim2.new(0, 12, 0, 118)
threshLabel.Size = UDim2.new(1, -24, 0, 18)
threshLabel.BackgroundTransparency = 1
threshLabel.Font = Enum.Font.Gotham
threshLabel.TextXAlignment = Enum.TextXAlignment.Left
threshLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
threshLabel.TextSize = 11
threshLabel.Text = "▶ Auto-hop jika player > :"

-- Threshold input
local threshInput = Instance.new("TextBox", container)
threshInput.Position = UDim2.new(0, 12, 0, 140)
threshInput.Size = UDim2.new(1, -24, 0, 30)
threshInput.BackgroundColor3 = Color3.fromRGB(30, 12, 12)
threshInput.BorderSizePixel = 0
threshInput.Font = Enum.Font.GothamBold
threshInput.Text = "1"
threshInput.TextColor3 = Color3.fromRGB(255, 255, 255)
threshInput.TextSize = 15
threshInput.ClearTextOnFocus = false
Instance.new("UICorner", threshInput).CornerRadius = UDim.new(0, 8)

-- === BUTTONS ===
-- Manual hop
local btnHop = Instance.new("TextButton", container)
btnHop.Position = UDim2.new(0, 12, 0, 182)
btnHop.Size = UDim2.new(0, 155, 0, 52)
btnHop.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
btnHop.BorderSizePixel = 0
btnHop.Font = Enum.Font.GothamBold
btnHop.Text = "◄ HOP NOW"
btnHop.TextColor3 = Color3.fromRGB(255, 255, 255)
btnHop.TextSize = 15
Instance.new("UICorner", btnHop).CornerRadius = UDim.new(0, 10)

-- Auto toggle
local btnAuto = Instance.new("TextButton", container)
btnAuto.Position = UDim2.new(0, 175, 0, 182)
btnAuto.Size = UDim2.new(0, 163, 0, 52)
btnAuto.BackgroundColor3 = Color3.fromRGB(30, 140, 60)
btnAuto.BorderSizePixel = 0
btnAuto.Font = Enum.Font.GothamBold
btnAuto.Text = "● AUTO: OFF"
btnAuto.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAuto.TextSize = 15
Instance.new("UICorner", btnAuto).CornerRadius = UDim.new(0, 10)

-- Signature (hidden in plain sight)
local signature = Instance.new("TextLabel", container)
signature.Position = UDim2.new(0, 12, 1, -22)
signature.Size = UDim2.new(1, -24, 0, 18)
signature.BackgroundTransparency = 1
signature.Font = Enum.Font.Gotham
signature.TextXAlignment = Enum.TextXAlignment.Right
signature.TextColor3 = Color3.fromRGB(80, 80, 80)
signature.TextSize = 10
signature.Text = "⌘ DRG-7H3N0X"

-- ================================
--  ⚙ CORE LOGIC (100% REWRITE)
-- ================================

local autoActive = false
local autoHandle = nil

-- Real-time player counter
task.spawn(function()
    while uiRoot.Parent do
        local count = #plrSvc:GetPlayers()
        playerInfo.Text = "◆ PLAYERS : " .. count
        task.wait(0.8)
    end
end)

-- Fetch server list with fallback
local function fetchServerPool()
    local endpoint = "https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return game:HttpGet(endpoint)
    end)
    
    if not success or not response or response == "" then
        return nil
    end
    
    local decoded, jsonOk = pcall(httpSvc.JSONDecode, httpSvc, response)
    if not jsonOk or not decoded or not decoded.data then
        return nil
    end
    
    local currentJob = tostring(game.JobId)
    local available = {}
    
    for _, server in ipairs(decoded.data) do
        if server.id and tostring(server.id) ~= currentJob then
            table.insert(available, tostring(server.id))
        end
    end
    
    return #available > 0 and available or nil
end

-- Execute hop
local function executeHop()
    local threshold = math.max(1, math.floor(tonumber(threshInput.Text) or 1))
    local currentCount = #plrSvc:GetPlayers()
    
    -- Check if we even need to hop
    if currentCount <= threshold then
        statusMsg.Text = "✓ " .. currentCount .. " player. Tenang bro."
        statusMsg.TextColor3 = Color3.fromRGB(80, 255, 80)
        return false
    end
    
    statusMsg.Text = "⏳ " .. currentCount .. " player. Scanning target..."
    statusMsg.TextColor3 = Color3.fromRGB(255, 200, 40)
    task.wait(0.4)
    
    local pool = fetchServerPool()
    if not pool then
        statusMsg.Text = "✗ Gagal scan server."
        statusMsg.TextColor3 = Color3.fromRGB(255, 60, 60)
        return false
    end
    
    local target = pool[math.random(1, #pool)]
    if not target then
        statusMsg.Text = "✗ Ga ada server kosong."
        statusMsg.TextColor3 = Color3.fromRGB(255, 60, 60)
        return false
    end
    
    statusMsg.Text = "▶ Injecting teleport..."
    statusMsg.TextColor3 = Color3.fromRGB(100, 180, 255)
    task.wait(0.3)
    
    local tpOk, tpErr = pcall(function()
        tpSvc:TeleportToPlaceInstance(gameId, target, localPlr)
    end)
    
    if not tpOk then
        statusMsg.Text = "✗ Error: " .. tostring(tpErr):sub(1, 50)
        statusMsg.TextColor3 = Color3.fromRGB(255, 60, 60)
        return false
    end
    
    return true
end

-- Manual hop
btnHop.MouseButton1Click:Connect(function()
    btnHop.Active = false
    executeHop()
    task.wait(2)
    btnHop.Active = true
end)

-- Auto toggle
btnAuto.MouseButton1Click:Connect(function()
    autoActive = not autoActive
    
    if autoActive then
        btnAuto.Text = "● AUTO: ON"
        btnAuto.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        autoHandle = task.spawn(function()
            while autoActive and uiRoot.Parent do
                local threshold = math.max(1, math.floor(tonumber(threshInput.Text) or 1))
                local count = #plrSvc:GetPlayers()
                
                if count <= threshold then
                    statusMsg.Text = "✓ " .. count .. " player. Idle..."
                    statusMsg.TextColor3 = Color3.fromRGB(80, 255, 80)
                    task.wait(3)
                else
                    executeHop()
                    task.wait(5)
                end
            end
        end)
    else
        btnAuto.Text = "● AUTO: OFF"
        btnAuto.BackgroundColor3 = Color3.fromRGB(30, 140, 60)
        if autoHandle then
            task.cancel(autoHandle)
            autoHandle = nil
        end
        statusMsg.Text = "◆ Auto di-stop."
        statusMsg.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

-- Init status
statusMsg.Text = "◆ Siap. Gas!"
statusMsg.TextColor3 = Color3.fromRGB(180, 180, 180)

-- ═══════════════════════════════════════════════════
--  END OF DRAGON HOP v2.0
-- ═══════════════════════════════════════════════════
