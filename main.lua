local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ==============================
-- ⚙️ KONFIGURASI UKURAN GUI ⚙️
-- ==============================
local GUI_CONFIG = {
    -- Ukuran default saat pertama kali muncul
    DefaultWidth = 320,   -- Ubah sesuai keinginan (minimal 280)
    DefaultHeight = 240,  -- Ubah sesuai keinginan (minimal 200)
    
    -- Batas minimal dan maksimal resize
    MinWidth = 280,
    MinHeight = 200,
    MaxWidth = 800,
    MaxHeight = 600,
    
    -- Ukuran floating button
    ButtonSize = 30,      -- Ukuran tombol toggle
}

-- ==============================
-- AUTHENTICATION SYSTEM
-- ==============================
local REQUIRED_KEY = "140611"

local function verifyKey(inputKey)
    inputKey = inputKey:gsub("^%s*(.-)%s*$", "%1")
    return inputKey == REQUIRED_KEY
end

-- ==============================
-- FLOATING TOGGLE BUTTON
-- ==============================
local function createFloatingButton()
    local btnSize = GUI_CONFIG.ButtonSize
    local FloatingBtn = Instance.new("ImageButton")
    FloatingBtn.Name = "FloatingToggle"
    FloatingBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    FloatingBtn.Position = UDim2.new(0.02, 0, 0.5, -btnSize/2)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.Image = "rbxassetid://6023420392"
    FloatingBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    FloatingBtn.ScaleType = Enum.ScaleType.Fit
    
    local Glow = Instance.new("ImageLabel", FloatingBtn)
    Glow.Size = UDim2.new(2, 0, 2, 0)
    Glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://131522470"
    Glow.ImageColor3 = Color3.fromRGB(100, 100, 255)
    Glow.ImageTransparency = 0.6
    Glow.ZIndex = 0
    
    local Gradient = Instance.new("UIGradient", FloatingBtn)
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 60, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 180))
    })
    Gradient.Rotation = 45
    
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
    
    local pulseTween = TweenService:Create(FloatingBtn, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(0, btnSize + 3, 0, btnSize + 3)
    })
    pulseTween:Play()
    
    FloatingBtn.MouseEnter:Connect(function()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, btnSize + 7, 0, btnSize + 7)}):Play()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(150, 150, 255)}):Play()
    end)
    
    FloatingBtn.MouseLeave:Connect(function()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, btnSize, 0, btnSize)}):Play()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    local dragging = false
    local dragStartX, dragStartY, startPosX, startPosY
    
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartX = input.Position.X
            dragStartY = input.Position.Y
            startPosX = FloatingBtn.Position.X.Scale
            startPosY = FloatingBtn.Position.Y.Scale
        end
    end)
    
    FloatingBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = (input.Position.X - dragStartX) / UserInputService.ViewportSize.X
            local deltaY = (input.Position.Y - dragStartY) / UserInputService.ViewportSize.Y
            
            local newX = math.clamp(startPosX + deltaX, 0.01, 0.89)
            local newY = math.clamp(startPosY + deltaY, 0.01, 0.89)
            
            FloatingBtn.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
    
    FloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return FloatingBtn
end

-- ==============================
-- CREATE MAIN GUI - RESIZEABLE
-- ==============================
local function createMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IdilServerHOPGUI"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game.CoreGui
    end
    
    local FloatingBtn = createFloatingButton()
    FloatingBtn.Parent = ScreenGui
    
    -- ==============================
    -- MAIN FRAME - RESIZEABLE
    -- ==============================
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -GUI_CONFIG.DefaultWidth/2, 0.5, -GUI_CONFIG.DefaultHeight/2)
    MainFrame.Size = UDim2.new(0, GUI_CONFIG.DefaultWidth, 0, GUI_CONFIG.DefaultHeight)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    local MainGradient = Instance.new("UIGradient", MainFrame)
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
    })
    MainGradient.Rotation = 135
    
    local OuterGlow = Instance.new("ImageLabel", MainFrame)
    OuterGlow.Size = UDim2.new(1.1, 0, 1.1, 0)
    OuterGlow.Position = UDim2.new(-0.05, 0, -0.05, 0)
    OuterGlow.BackgroundTransparency = 1
    OuterGlow.Image = "rbxassetid://131522470"
    OuterGlow.ImageColor3 = Color3.fromRGB(80, 80, 255)
    OuterGlow.ImageTransparency = 0.5
    OuterGlow.ZIndex = 0
    
    local BorderGlow = Instance.new("Frame", MainFrame)
    BorderGlow.Size = UDim2.new(1, 4, 1, 4)
    BorderGlow.Position = UDim2.new(0, -2, 0, -2)
    BorderGlow.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    BorderGlow.BackgroundTransparency = 0.8
    BorderGlow.BorderSizePixel = 0
    BorderGlow.ZIndex = 0
    Instance.new("UICorner", BorderGlow).CornerRadius = UDim.new(0, 14)
    
    -- ==============================
    -- HEADER
    -- ==============================
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    
    local HeaderGradient = Instance.new("UIGradient", Header)
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 40, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 160))
    })
    HeaderGradient.Rotation = 90
    
    local TitleIcon = Instance.new("ImageLabel", Header)
    TitleIcon.Size = UDim2.new(0, 18, 0, 18)
    TitleIcon.Position = UDim2.new(0, 10, 0, 12)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Image = "rbxassetid://6023420392"
    TitleIcon.ImageColor3 = Color3.fromRGB(255, 200, 50)
    
    local HeaderTitle = Instance.new("TextLabel", Header)
    HeaderTitle.Size = UDim2.new(1, -70, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 35, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.Text = "✦ IdilHop ✦"
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusDot = Instance.new("Frame", Header)
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(1, -40, 0, 17)
    StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    StatusDot.BorderSizePixel = 0
    StatusDot.Visible = false
    Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)
    
    local DotPulse = Instance.new("Frame", StatusDot)
    DotPulse.Size = UDim2.new(2, 0, 2, 0)
    DotPulse.Position = UDim2.new(-0.5, 0, -0.5, 0)
    DotPulse.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    DotPulse.BackgroundTransparency = 0.6
    DotPulse.BorderSizePixel = 0
    DotPulse.ZIndex = 0
    Instance.new("UICorner", DotPulse).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while StatusDot.Visible do
            TweenService:Create(DotPulse, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Size = UDim2.new(2.5, 0, 2.5, 0),
                Position = UDim2.new(-0.75, 0, -0.75, 0)
            }):Play()
            task.wait(1)
        end
    end)
    
    local CloseBtn = Instance.new("ImageButton", Header)
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxassetid://143982074"
    CloseBtn.ImageColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.ImageRectOffset = Vector2.new(6, 6)
    CloseBtn.ImageRectSize = Vector2.new(12, 12)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 100, 100)}):Play()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 28, 0, 28)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 70, 70)}):Play()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 26, 0, 26)}):Play()
    end)
    
    -- ==============================
    -- CONTENT CONTAINER
    -- ==============================
    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -30, 1, -58)
    ContentContainer.Position = UDim2.new(0, 15, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    
    -- ==============================
    -- AUTHENTICATION UI
    -- ==============================
    local AuthContainer = Instance.new("Frame", ContentContainer)
    AuthContainer.Size = UDim2.new(1, 0, 1, 0)
    AuthContainer.BackgroundTransparency = 1
    
    local AuthCard = Instance.new("Frame", AuthContainer)
    AuthCard.Size = UDim2.new(0.85, 0, 0.75, 0)
    AuthCard.Position = UDim2.new(0.075, 0, 0.05, 0)
    AuthCard.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    AuthCard.BackgroundTransparency = 0.5
    AuthCard.BorderSizePixel = 0
    Instance.new("UICorner", AuthCard).CornerRadius = UDim.new(0, 8)
    
    local AuthIcon = Instance.new("ImageLabel", AuthCard)
    AuthIcon.Size = UDim2.new(0, 35, 0, 35)
    AuthIcon.Position = UDim2.new(0.5, -17, 0, 8)
    AuthIcon.BackgroundTransparency = 1
    AuthIcon.Image = "rbxassetid://6023420392"
    AuthIcon.ImageColor3 = Color3.fromRGB(255, 200, 50)
    
    local AuthLabel = Instance.new("TextLabel", AuthCard)
    AuthLabel.Size = UDim2.new(1, -30, 0, 20)
    AuthLabel.Position = UDim2.new(0, 15, 0, 48)
    AuthLabel.BackgroundTransparency = 1
    AuthLabel.Font = Enum.Font.GothamBold
    AuthLabel.Text = "🔐 Verifikasi"
    AuthLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    AuthLabel.TextSize = 13
    
    local KeyBox = Instance.new("TextBox", AuthCard)
    KeyBox.Size = UDim2.new(1, -30, 0, 32)
    KeyBox.Position = UDim2.new(0, 15, 0, 73)
    KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    KeyBox.BorderSizePixel = 0
    KeyBox.Font = Enum.Font.GothamBold
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "⌨️ Masukkan Key"
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.TextSize = 12
    KeyBox.ClearTextOnFocus = false
    KeyBox.PlaceholderColor3 = Color3.fromRGB(128, 128, 150)
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)
    
    KeyBox.Focused:Connect(function()
        TweenService:Create(KeyBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 70)}):Play()
    end)
    KeyBox.FocusLost:Connect(function()
        TweenService:Create(KeyBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 60)}):Play()
    end)
    
    local AuthBtn = Instance.new("TextButton", AuthCard)
    AuthBtn.Size = UDim2.new(1, -30, 0, 34)
    AuthBtn.Position = UDim2.new(0, 15, 0, 112)
    AuthBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 220)
    AuthBtn.BorderSizePixel = 0
    AuthBtn.Font = Enum.Font.GothamBold
    AuthBtn.Text = "✅ Verifikasi"
    AuthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AuthBtn.TextSize = 12
    Instance.new("UICorner", AuthBtn).CornerRadius = UDim.new(0, 6)
    
    AuthBtn.MouseEnter:Connect(function()
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 240)}):Play()
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {Size = UDim2.new(1, -28, 0, 36)}):Play()
    end)
    AuthBtn.MouseLeave:Connect(function()
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 220)}):Play()
        TweenService:Create(AuthBtn, TweenInfo.new(0.2), {Size = UDim2.new(1, -30, 0, 34)}):Play()
    end)
    
    local AuthStatus = Instance.new("TextLabel", AuthCard)
    AuthStatus.Size = UDim2.new(1, -30, 0, 25)
    AuthStatus.Position = UDim2.new(0, 15, 0, 150)
    AuthStatus.BackgroundTransparency = 1
    AuthStatus.Font = Enum.Font.Gotham
    AuthStatus.Text = "🔑 Masukkan key akses"
    AuthStatus.TextColor3 = Color3.fromRGB(160, 160, 180)
    AuthStatus.TextSize = 10
    AuthStatus.TextWrapped = true
    
    -- ==============================
    -- FUNCTIONALITY UI
    -- ==============================
    local FuncContainer = Instance.new("Frame", ContentContainer)
    FuncContainer.Size = UDim2.new(1, 0, 1, 0)
    FuncContainer.BackgroundTransparency = 1
    FuncContainer.Visible = false
    
    local PlayerCard = Instance.new("Frame", FuncContainer)
    PlayerCard.Size = UDim2.new(1, 0, 0, 28)
    PlayerCard.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    PlayerCard.BackgroundTransparency = 0.5
    PlayerCard.BorderSizePixel = 0
    Instance.new("UICorner", PlayerCard).CornerRadius = UDim.new(0, 6)
    
    local NowLabel = Instance.new("TextLabel", PlayerCard)
    NowLabel.Size = UDim2.new(1, -15, 1, 0)
    NowLabel.Position = UDim2.new(0, 8, 0, 0)
    NowLabel.BackgroundTransparency = 1
    NowLabel.Font = Enum.Font.GothamBold
    NowLabel.TextXAlignment = Enum.TextXAlignment.Left
    NowLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
    NowLabel.TextSize = 12
    NowLabel.Text = "👥 Memuat..."
    
    local StatusCard = Instance.new("Frame", FuncContainer)
    StatusCard.Size = UDim2.new(1, 0, 0, 32)
    StatusCard.Position = UDim2.new(0, 0, 0, 33)
    StatusCard.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    StatusCard.BackgroundTransparency = 0.5
    StatusCard.BorderSizePixel = 0
    Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 6)
    
    local StatusLabel = Instance.new("TextLabel", StatusCard)
    StatusLabel.Size = UDim2.new(1, -15, 1, 0)
    StatusLabel.Position = UDim2.new(0, 8, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    StatusLabel.TextSize = 10
    StatusLabel.TextWrapped = true
    StatusLabel.Text = "✅ Siap digunakan"
    
    local SettingsCard = Instance.new("Frame", FuncContainer)
    SettingsCard.Size = UDim2.new(1, 0, 0, 36)
    SettingsCard.Position = UDim2.new(0, 0, 0, 70)
    SettingsCard.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    SettingsCard.BackgroundTransparency = 0.5
    SettingsCard.BorderSizePixel = 0
    Instance.new("UICorner", SettingsCard).CornerRadius = UDim.new(0, 6)
    
    local MaxLabel = Instance.new("TextLabel", SettingsCard)
    MaxLabel.Size = UDim2.new(0.55, -8, 1, 0)
    MaxLabel.Position = UDim2.new(0, 8, 0, 0)
    MaxLabel.BackgroundTransparency = 1
    MaxLabel.Font = Enum.Font.Gotham
    MaxLabel.TextXAlignment = Enum.TextXAlignment.Left
    MaxLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    MaxLabel.TextSize = 10
    MaxLabel.Text = "🎯 Hop jika >"
    
    local MaxBox = Instance.new("TextBox", SettingsCard)
    MaxBox.Size = UDim2.new(0.35, -8, 0, 24)
    MaxBox.Position = UDim2.new(0.6, 4, 0, 6)
    MaxBox.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    MaxBox.BorderSizePixel = 0
    MaxBox.Font = Enum.Font.GothamBold
    MaxBox.Text = "1"
    MaxBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    MaxBox.TextSize = 12
    MaxBox.ClearTextOnFocus = false
    MaxBox.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", MaxBox).CornerRadius = UDim.new(0, 5)
    
    local ButtonsCard = Instance.new("Frame", FuncContainer)
    ButtonsCard.Size = UDim2.new(1, 0, 0, 40)
    ButtonsCard.Position = UDim2.new(0, 0, 0, 111)
    ButtonsCard.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    ButtonsCard.BackgroundTransparency = 0.5
    ButtonsCard.BorderSizePixel = 0
    Instance.new("UICorner", ButtonsCard).CornerRadius = UDim.new(0, 6)
    
    local HopBtn = Instance.new("TextButton", ButtonsCard)
    HopBtn.Size = UDim2.new(0.45, -4, 0.8, 0)
    HopBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
    HopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 220)
    HopBtn.BorderSizePixel = 0
    HopBtn.Font = Enum.Font.GothamBold
    HopBtn.Text = "⏩ Hop"
    HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HopBtn.TextSize = 12
    Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0, 6)
    
    HopBtn.MouseEnter:Connect(function()
        TweenService:Create(HopBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 240)}):Play()
    end)
    HopBtn.MouseLeave:Connect(function()
        TweenService:Create(HopBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 220)}):Play()
    end)
    
    local AutoBtn = Instance.new("TextButton", ButtonsCard)
    AutoBtn.Size = UDim2.new(0.45, -4, 0.8, 0)
    AutoBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 70)
    AutoBtn.BorderSizePixel = 0
    AutoBtn.Font = Enum.Font.GothamBold
    AutoBtn.Text = "🔄 Auto: OFF"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.TextSize = 12
    Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 6)
    
    AutoBtn.MouseEnter:Connect(function()
        if AutoBtn.Text:find("OFF") then
            TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 140, 80)}):Play()
        else
            TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
        end
    end)
    AutoBtn.MouseLeave:Connect(function()
        if AutoBtn.Text:find("OFF") then
            TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 120, 70)}):Play()
        else
            TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play()
        end
    end)
    
    -- ==============================
    -- RESIZE HANDLE
    -- ==============================
    local ResizeHandle = Instance.new("ImageButton", MainFrame)
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Image = "rbxassetid://138066793"
    ResizeHandle.ImageColor3 = Color3.fromRGB(150, 150, 220)
    ResizeHandle.ImageRectOffset = Vector2.new(21, 21)
    ResizeHandle.ImageRectSize = Vector2.new(10, 10)
    ResizeHandle.ZIndex = 10
    
    local ResizeGlow = Instance.new("ImageLabel", ResizeHandle)
    ResizeGlow.Size = UDim2.new(2.5, 0, 2.5, 0)
    ResizeGlow.Position = UDim2.new(-0.75, 0, -0.75, 0)
    ResizeGlow.BackgroundTransparency = 1
    ResizeGlow.Image = "rbxassetid://131522470"
    ResizeGlow.ImageColor3 = Color3.fromRGB(150, 150, 255)
    ResizeGlow.ImageTransparency = 0.7
    ResizeGlow.ZIndex = 0
    
    ResizeHandle.MouseEnter:Connect(function()
        TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(200, 200, 255)}):Play()
        TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {Size = UDim2.new(0, 24, 0, 24)}):Play()
        TweenService:Create(ResizeGlow, TweenInfo.new(0.2), {ImageTransparency = 0.3}):Play()
    end)
    ResizeHandle.MouseLeave:Connect(function()
        TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 220)}):Play()
        TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {Size = UDim2.new(0, 20, 0, 20)}):Play()
        TweenService:Create(ResizeGlow, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
    end)
    
    -- Resize logic
    local resizing = false
    local startSizeX, startSizeY, startMouseX, startMouseY
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startMouseX = input.Position.X
            startMouseY = input.Position.Y
            startSizeX = MainFrame.Size.X.Offset
            startSizeY = MainFrame.Size.Y.Offset
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local deltaX = input.Position.X - startMouseX
            local deltaY = input.Position.Y - startMouseY
            
            local newSizeX = math.clamp(startSizeX + deltaX, GUI_CONFIG.MinWidth, GUI_CONFIG.MaxWidth)
            local newSizeY = math.clamp(startSizeY + deltaY, GUI_CONFIG.MinHeight, GUI_CONFIG.MaxHeight)
            
            MainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
            ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    -- ==============================
    -- TOGGLE LOGIC
    -- ==============================
    local isVisible = false
    
    FloatingBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
        
        if isVisible then
            MainFrame.Size = UDim2.new(0, GUI_CONFIG.DefaultWidth - 30, 0, GUI_CONFIG.DefaultHeight - 30)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, GUI_CONFIG.DefaultWidth, 0, GUI_CONFIG.DefaultHeight)}):Play()
            TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(100, 255, 100)}):Play()
            TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, GUI_CONFIG.ButtonSize - 3, 0, GUI_CONFIG.ButtonSize - 3)}):Play()
            
            if keyValid then
                StatusDot.Visible = true
            end
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, GUI_CONFIG.DefaultWidth - 60, 0, GUI_CONFIG.DefaultHeight - 70)}):Play()
            TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, GUI_CONFIG.ButtonSize, 0, GUI_CONFIG.ButtonSize)}):Play()
            StatusDot.Visible = false
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        isVisible = false
        MainFrame.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, GUI_CONFIG.DefaultWidth - 60, 0, GUI_CONFIG.DefaultHeight - 70)}):Play()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        StatusDot.Visible = false
    end)
    
    -- ==============================
    -- AUTH HANDLER
    -- ==============================
    local keyValid = false
    local authAttempts = 0
    local lastAuthAttempt = 0
    
    AuthBtn.MouseButton1Click:Connect(function()
        local currentTime = os.time()
        if currentTime - lastAuthAttempt < 2 then
            AuthStatus.Text = "⏳ Tunggu 2 detik!"
            AuthStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
            return
        end
        lastAuthAttempt = currentTime
        
        authAttempts = authAttempts + 1
        if authAttempts > 5 then
            AuthStatus.Text = "⛔ Terlalu banyak!"
            AuthStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(10)
            authAttempts = 0
            AuthStatus.Text = "🔑 Masukkan key akses"
            AuthStatus.TextColor3 = Color3.fromRGB(160, 160, 180)
            return
        end
        
        local inputKey = KeyBox.Text
        if verifyKey(inputKey) then
            keyValid = true
            AuthStatus.Text = "✅ Key valid!"
            AuthStatus.TextColor3 = Color3.fromRGB(100, 220, 100)
            AuthBtn.Text = "✅ Verified"
            AuthBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
            
            TweenService:Create(AuthContainer, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            AuthContainer.Visible = false
            FuncContainer.Visible = true
            FuncContainer.BackgroundTransparency = 1
            
            FuncContainer.BackgroundTransparency = 0
            TweenService:Create(FuncContainer, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
            
            MainFrame.Size = UDim2.new(0, GUI_CONFIG.DefaultWidth + 20, 0, GUI_CONFIG.DefaultHeight - 40)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, GUI_CONFIG.DefaultWidth, 0, GUI_CONFIG.DefaultHeight - 40)}):Play()
            
            StatusDot.Visible = isVisible
            authAttempts = 0
            StatusLabel.Text = "✅ Siap digunakan"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
        else
            AuthStatus.Text = "❌ Key salah! Sisa: " .. (5 - authAttempts)
            AuthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
            KeyBox.Text = ""
            
            AuthBtn.Position = UDim2.new(0, 14, 0, 112)
            TweenService:Create(AuthBtn, TweenInfo.new(0.1), {Position = UDim2.new(0, 18, 0, 112)}):Play()
            task.wait(0.1)
            TweenService:Create(AuthBtn, TweenInfo.new(0.1), {Position = UDim2.new(0, 12, 0, 112)}):Play()
            task.wait(0.1)
            TweenService:Create(AuthBtn, TweenInfo.new(0.1), {Position = UDim2.new(0, 15, 0, 112)}):Play()
        end
    end)
    
    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            AuthBtn.MouseButton1Click:Fire()
        end
    end)
    
    -- ==============================
    -- LOGIC
    -- ==============================
    local autoEnabled = false
    local autoThread = nil
    
    task.spawn(function()
        while ScreenGui.Parent do
            if keyValid and FuncContainer.Visible then
                local count = #Players:GetPlayers()
                NowLabel.Text = "👥 Player: " .. count
            end
            task.wait(0.5)
        end
    end)
    
    local function getRandomServer()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local ok, raw = pcall(function() return game:HttpGet(url) end)
        if not ok or not raw or raw == "" then return nil end
        
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or not data or not data.data or #data.data == 0 then return nil end
        
        local currentId = tostring(game.JobId)
        local candidates = {}
        for _, s in ipairs(data.data) do
            if s.id and tostring(s.id) ~= currentId then
                table.insert(candidates, tostring(s.id))
            end
        end
        
        if #candidates == 0 then return nil end
        return candidates[math.random(1, #candidates)]
    end
    
    local function hopOnce()
        if not keyValid then
            StatusLabel.Text = "❌ Key tidak valid!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return false
        end
        
        local threshold = math.max(1, math.floor(tonumber(MaxBox.Text) or 1))
        local currentCount = #Players:GetPlayers()
        
        if currentCount <= threshold then
            StatusLabel.Text = "✅ " .. currentCount .. " player. Aman."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
            return false
        end
        
        StatusLabel.Text = "🔍 " .. currentCount .. " player..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        task.wait(0.3)
        
        local serverId = getRandomServer()
        if not serverId then
            StatusLabel.Text = "❌ Gagal dapat server."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return false
        end
        
        StatusLabel.Text = "⏳ Teleport..."
        StatusLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
        task.wait(0.3)
        
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
        end)
        
        if not ok then
            StatusLabel.Text = "❌ Error: " .. tostring(err):sub(1, 30)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return false
        end
        
        return true
    end
    
    HopBtn.MouseButton1Click:Connect(function()
        if not keyValid then return end
        HopBtn.Active = false
        TweenService:Create(HopBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 180)}):Play()
        hopOnce()
        task.wait(2)
        TweenService:Create(HopBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 220)}):Play()
        HopBtn.Active = true
    end)
    
    AutoBtn.MouseButton1Click:Connect(function()
        if not keyValid then return end
        
        autoEnabled = not autoEnabled
        
        if autoEnabled then
            AutoBtn.Text = "🔄 Auto: ON"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            
            autoThread = task.spawn(function()
                while autoEnabled and ScreenGui.Parent and keyValid do
                    local threshold = math.max(1, math.floor(tonumber(MaxBox.Text) or 1))
                    local count = #Players:GetPlayers()
                    
                    if count <= threshold then
                        StatusLabel.Text = "✅ " .. count .. " player. Menunggu..."
                        StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                        task.wait(3)
                    else
                        hopOnce()
                        task.wait(5)
                    end
                end
            end)
        else
            AutoBtn.Text = "🔄 Auto: OFF"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 70)
            if autoThread then
                task.cancel(autoThread)
                autoThread = nil
            end
            StatusLabel.Text = "⏸️ Auto dihentikan"
            StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
    end)
    
    return {
        ScreenGui = ScreenGui,
        FloatingBtn = FloatingBtn,
        MainFrame = MainFrame
    }
end

-- ==============================
-- INIT
-- ==============================
local GUI = createMainGUI()
