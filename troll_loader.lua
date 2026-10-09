--[[
    Proje: SELUX Hub (Gelişmiş UI ve Tam Düzeltilmiş ESP Sürümü)
]]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    ESPEnabled = false,
    AimbotEnabled = false,
    GodmodeEnabled = false,
    NoclipEnabled = false,
    FlyEnabled = false,
    FOV = 110,
    SmoothH = 24,
    SmoothV = 28,
    SelectedTarget = nil
}

--------------------------------------------------------------------------------
-- 1. PROFESYONEL ESP SİSTEMİ (Tam Düzeltilmiş Aç/Kapat)
--------------------------------------------------------------------------------
local function clearAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("SeluxESP") then
            p.Character.SeluxESP:Destroy()
        end
    end
end

local function applyESPToPlayer(player)
    if player == LocalPlayer then return end
    
    local function setup(char)
        if not char then return end
        if char:FindFirstChild("SeluxESP") then char.SeluxESP:Destroy() end
        
        if not Config.ESPEnabled then return end
        
        local folder = Instance.new("Folder")
        folder.Name = "SeluxESP"
        folder.Parent = char
        
        local hl = Instance.new("Highlight")
        hl.Name = "Box"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(0, 255, 120)
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(0, 255, 120)
        hl.Parent = folder
        
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local bg = Instance.new("BillboardGui")
        bg.Name = "Tag"
        bg.Adornee = head
        bg.Size = UDim2.new(0, 150, 0, 40)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = folder
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextSize = 12
        txt.Font = Enum.Font.Code
        txt.TextStrokeTransparency = 0.4
        txt.Parent = bg
    end

    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(function() setup(player.Character) end) end
end

local function toggleESPState(state)
    Config.ESPEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do applyESPToPlayer(p) end
    else
        clearAllESP()
    end
end

Players.PlayerAdded:Connect(applyESPToPlayer)

--------------------------------------------------------------------------------
-- 2. ANA DÖNGÜ (Aimbot, Godmode, Noclip)
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if Config.AimbotEnabled then
        local target = nil
        local minDist = Config.FOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local sp, onScreen = Camera:WorldToScreenPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                    if mag < minDist then
                        minDist = mag
                        target = p.Character.Head
                    end
                end
            end
        end
        if target then
            local cf = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, 1 / Config.SmoothH)
        end
    end

    if Config.GodmodeEnabled and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end

    if Config.NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

--------------------------------------------------------------------------------
-- 3. SELUX UI ARAYÜZÜ (Görsel Tasarım ve Insert Toggle)
--------------------------------------------------------------------------------
if CoreGui:FindFirstChild("SeluxUI") then CoreGui.SeluxUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SeluxUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Üst Bar (SELUX LOGO VE SEKMELER)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 21, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 100, 1, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "  SELUX"
LogoLabel.TextColor3 = Color3.fromRGB(160, 100, 255)
LogoLabel.Font = Enum.Font.Code
LogoLabel.TextSize = 16
LogoLabel.Parent = TopBar

-- Sekme Değiştirme Fonksiyonu için Konteynerler
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local function createTabPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    p.ScrollBarThickness = 4
    p.Parent = Container
    return p
end

local aimPage = createTabPage()
local espPage = createTabPage()
local miscPage = createTabPage()
aimPage.Visible = true -- Varsayılan Aim sekmesi açık

local function switchTab(page)
    aimPage.Visible = false
    espPage.Visible = false
    miscPage.Visible = false
    page.Visible = true
end

-- Üst Menü Sekme Butonları
local function createTopTabBtn(name, posX, page)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(0, posX, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 48)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = TopBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function() switchTab(page) end)
end

createTopTabBtn("AIM", 110, aimPage)
createTopTabBtn("ESP", 190, espPage)
createTopTabBtn("MISC", 270, miscPage)

-- Insert Tuşu ile Menüyü Gizle/Göster
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--------------------------------------------------------------------------------
-- 4. SEKME İÇERİKLERİ (Görseldeki Gibi Switch Butonları)
--------------------------------------------------------------------------------

-- AIM SEKMESİ
local function buildAimTab()
    local y = 10
    local function addToggle(text, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 330, 0, 35)
        f.Position = UDim2.new(0, 10, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(25, 22, 36)
        f.Parent = aimPage
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 250, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.Font = Enum.Font.Code
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 50, 0, 22)
        b.Position = UDim2.new(1, -60, 0.5, -11)
        b.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
        b.Text = "OFF"
        b.TextColor3 = Color3.fromRGB(150, 150, 150)
        b.Font = Enum.Font.Code
        b.TextSize = 11
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        local state = false
        b.MouseButton1Click:Connect(function()
            state = not state
            b.Text = state and "ON" or "OFF"
            b.BackgroundColor3 = state and Color3.fromRGB(130, 60, 255) or Color3.fromRGB(50, 40, 70)
            b.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            callback(state)
        end)
        y = y + 45
    end
    
    addToggle("Aim assist (Aimbot)", function(v) Config.AimbotEnabled = v end)
end
buildAimTab()

-- ESP SEKMESİ
local function buildEspTab()
    local y = 10
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 330, 0, 35)
    f.Position = UDim2.new(0, 10, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(25, 22, 36)
    f.Parent = espPage
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 250, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = "ESP enabled"
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 50, 0, 22)
    b.Position = UDim2.new(1, -60, 0.5, -11)
    b.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
    b.Text = "OFF"
    b.TextColor3 = Color3.fromRGB(150, 150, 150)
    b.Font = Enum.Font.Code
    b.TextSize = 11
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    
    b.MouseButton1Click:Connect(function()
        local newState = not Config.ESPEnabled
        toggleESPState(newState)
        b.Text = newState and "ON" or "OFF"
        b.BackgroundColor3 = newState and Color3.fromRGB(130, 60, 255) or Color3.fromRGB(50, 40, 70)
        b.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    end)
end
buildEspTab()

-- MISC SEKMESİ (Godmode, Noclip, Teleport)
local function buildMiscTab()
    local y = 10
    local function addToggle(text, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 330, 0, 35)
        f.Position = UDim2.new(0, 10, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(25, 22, 36)
        f.Parent = miscPage
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 250, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.Font = Enum.Font.Code
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 50, 0, 22)
        b.Position = UDim2.new(1, -60, 0.5, -11)
        b.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
        b.Text = "OFF"
        b.TextColor3 = Color3.fromRGB(150, 150, 150)
        b.Font = Enum.Font.Code
        b.TextSize = 11
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        local state = false
        b.MouseButton1Click:Connect(function()
            state = not state
            b.Text = state and "ON" or "OFF"
            b.BackgroundColor3 = state and Color3.fromRGB(130, 60, 255) or Color3.fromRGB(50, 40, 70)
            b.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            callback(state)
        end)
        y = y + 45
    end
    
    addToggle("GodMode", function(v) Config.GodmodeEnabled = v end)
    addToggle("Noclip", function(v) Config.NoclipEnabled = v end)
    
    -- Oyuncu Teleport Dropdown Simülasyonu
    y = y + 10
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 330, 0, 30)
    tpBtn.Position = UDim2.new(0, 10, 0, y)
    tpBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 60)
    tpBtn.Text = "Seçilen Oyuncu: Yok (Değiştirmek için tıkla)"
    tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpBtn.Font = Enum.Font.Code
    tpBtn.TextSize = 11
    tpBtn.Parent = miscPage
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
    
    y = y + 40
    local execTp = Instance.new("TextButton")
    execTp.Size = UDim2.new(0, 330, 0, 30)
    execTp.Position = UDim2.new(0, 10, 0, y)
    execTp.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    execTp.Text = "Işınlan (Teleport)"
    execTp.TextColor3 = Color3.fromRGB(255, 255, 255)
    execTp.Font = Enum.Font.Code
    execTp.TextSize = 11
    execTp.Parent = miscPage
    Instance.new("UICorner", execTp).CornerRadius = UDim.new(0, 6)
    
    tpBtn.MouseButton1Click:Connect(function()
        local list = Players:GetPlayers()
        local valid = {}
        for _, p in ipairs(list) do if p ~= LocalPlayer then table.insert(valid, p) end end
        if #valid == 0 then tpBtn.Text = "Sunucuda kimse yok!" return end
        
        local idx = 1
        for i, p in ipairs(valid) do
            if p.Name == Config.SelectedTarget then idx = i + 1 break end
        end
        if idx > #valid then idx = 1 end
        Config.SelectedTarget = valid[idx].Name
        tpBtn.Text = "Hedef: " .. Config.SelectedTarget
    end)
    
    execTp.MouseButton1Click:Connect(function()
        if not Config.SelectedTarget then return end
        local targetP = Players:FindFirstChild(Config.SelectedTarget)
        if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetP.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end
buildMiscTab()
