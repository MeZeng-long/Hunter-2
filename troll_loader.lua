--[[
    Proje: Hunter Script (Kategorize Edilmiş ve Gelişmiş Sürüm)
    Özellikler: Sol Sekmeler (Combat, Visual, Misc), FOV, Smooth, Dinamik Teleport Listesi, Insert Toggle
]]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Hile İlk Açıldığında Hepsi Tamamen Kapalı Başlar
local Config = {
    ESPEnabled = false,
    AimbotEnabled = false,
    GodmodeEnabled = false,
    NoclipEnabled = false,
    InfiniteStamina = false,
    FlyEnabled = false,
    HealEnabled = false,
    FOV = 100,
    Smoothness = 0.2,
    SelectedTargetPlayer = nil
}

--------------------------------------------------------------------------------
-- 1. AÇILIŞ BİLDİRİMİ
--------------------------------------------------------------------------------
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Hunter Script",
    Text = "Yüklendi! Menüyü açıp kapatmak için [INSERT] tuşuna basın.",
    Duration = 5
})

--------------------------------------------------------------------------------
-- 2. ESP MODÜLÜ (Başlangıçta Kapalı)
--------------------------------------------------------------------------------
local function createHunterESP(player)
    if player == LocalPlayer then return end
    
    local function setupChar(char)
        if not char then return end
        if char:FindFirstChild("HunterESP") then char.HunterESP:Destroy() end
        
        local folder = Instance.new("Folder")
        folder.Name = "HunterESP"
        folder.Parent = char
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "Box"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = folder
        
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "InfoTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = folder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = billboard
        
        local healthBarBg = Instance.new("Frame")
        healthBarBg.Size = UDim2.new(0, 100, 0, 6)
        healthBarBg.Position = UDim2.new(0.5, -50, 0, 22)
        healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBg.BorderSizePixel = 0
        healthBarBg.Parent = billboard
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBarBg
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                local percent = math.clamp(health / humanoid.MaxHealth, 0, 1)
                healthBar.Size = UDim2.new(percent, 0, 1, 0)
            end)
        end
    end

    player.CharacterAdded:Connect(setupChar)
    if player.Character then task.spawn(function() setupChar(player.Character) end) end
end

local function toggleESP(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HunterESP") then
            p.Character.HunterESP.Enabled = state
        elseif state then
            createHunterESP(p)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do createHunterESP(p) end
Players.PlayerAdded:Connect(createHunterESP)


--------------------------------------------------------------------------------
-- 3. ANA DÖNGÜ (Aimbot, Smooth, Godmode, Noclip, Heal, Fly)
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    -- Aimbot + Smoothness + FOV
    if Config.AimbotEnabled then
        local closestTarget = nil
        local shortestDist = Config.FOV
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenPoint, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if magnitude < shortestDist then
                        shortestDist = magnitude
                        closestTarget = player.Character.Head
                    end
                end
            end
        end
        if closestTarget then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end

    -- Godmode
    if Config.GodmodeEnabled and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end

    -- Heal (Tek seferlik can fulleme simülasyonu)
    if Config.HealEnabled and humanoid then
        humanoid.Health = humanoid.MaxHealth
        Config.HealEnabled = false
    end

    -- Noclip
    if Config.NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


--------------------------------------------------------------------------------
-- 4. ARAYÜZ (GUI) VE SOL KATEGORİ SİSTEMİ
--------------------------------------------------------------------------------
if CoreGui:FindFirstChild("HunterScriptGUI") then
    CoreGui.HunterScriptGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HunterScriptGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.Text = "  H U N T E R  S C R I P T"
TitleBar.TextColor3 = Color3.fromRGB(255, 60, 60)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.Code
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

-- Sol Kategori Paneli
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- İçerik Konteynerleri (Sayfalar)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -120, 1, -45)
Container.Position = UDim2.new(0, 120, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local function createPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    p.ScrollBarThickness = 4
    p.Parent = Container
    return p
end

local combatPage = createPage()
local visualPage = createPage()
local miscPage = createPage()
combatPage.Visible = true -- Varsayılan açık sayfa

local function switchPage(page)
    combatPage.Visible = false
    visualPage.Visible = false
    miscPage.Visible = false
    page.Visible = true
end

-- Sol Sekme Butonları
local function createTabButton(name, posY, page)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 0, 30)
    btn.Position = UDim2.new(0, 7, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.Code
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        switchPage(page)
    end)
end

createTabButton("Combat", 15, combatPage)
createTabButton("Visual", 55, visualPage)
createTabButton("Misc", 95, miscPage)

-- Insert Tuşu ile Menü Gizleme / Gösterme
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--------------------------------------------------------------------------------
-- 5. SAYFA İÇERİKLERİ VE BUTONLAR (Açık/Kapalı Yazılı)
--------------------------------------------------------------------------------

-- COMBAT SEKMESİ (Aimbot, FOV, Smooth)
local function addCombatElements()
    local yPos = 10
    
    -- Aimbot Butonu
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 330, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "Aimbot: Kapalı"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize, btn.Font = 12, Enum.Font.Code
    btn.Parent = combatPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Config.AimbotEnabled = not Config.AimbotEnabled
        btn.Text = Config.AimbotEnabled and "Aimbot: Açık" or "Aimbot: Kapalı"
        btn.TextColor3 = Config.AimbotEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
    end)
    
    yPos = yPos + 40
    
    -- FOV Bilgisi/Ayarı
    local fovBtn = Instance.new("TextButton")
    fovBtn.Size = UDim2.new(0, 330, 0, 30)
    fovBtn.Position = UDim2.new(0, 0, 0, yPos)
    fovBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    fovBtn.Text = "FOV Değiştir (Şu an: 100)"
    fovBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovBtn.TextSize, fovBtn.Font = 12, Enum.Font.Code
    fovBtn.Parent = combatPage
    Instance.new("UICorner", fovBtn).CornerRadius = UDim.new(0, 4)
    
    fovBtn.MouseButton1Click:Connect(function()
        Config.FOV = Config.FOV == 100 and 200 or (Config.FOV == 200 and 300 or 100)
        fovBtn.Text = "FOV Değiştir (Şu an: " .. Config.FOV .. ")"
    end)
    
    yPos = yPos + 40
    
    -- Smoothness Ayarı
    local smoothBtn = Instance.new("TextButton")
    smoothBtn.Size = UDim2.new(0, 330, 0, 30)
    smoothBtn.Position = UDim2.new(0, 0, 0, yPos)
    smoothBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    smoothBtn.Text = "Smoothness: 0.2 (Normal)"
    smoothBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    smoothBtn.TextSize, smoothBtn.Font = 12, Enum.Font.Code
    smoothBtn.Parent = combatPage
    Instance.new("UICorner", smoothBtn).CornerRadius = UDim.new(0, 4)
    
    smoothBtn.MouseButton1Click:Connect(function()
        if Config.Smoothness == 0.2 then
            Config.Smoothness = 0.5
            smoothBtn.Text = "Smoothness: 0.5 (Hızlı)"
        elseif Config.Smoothness == 0.5 then
            Config.Smoothness = 1.0
            smoothBtn.Text = "Smoothness: 1.0 (Anlık/Snap)"
        else
            Config.Smoothness = 0.2
            smoothBtn.Text = "Smoothness: 0.2 (Yumuşak)"
        end
    end)
end
addCombatElements()


-- VISUAL SEKMESİ (ESP)
local function addVisualElements()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 330, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "ESP: Kapalı"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize, btn.Font = 12, Enum.Font.Code
    btn.Parent = visualPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        toggleESP(Config.ESPEnabled)
        btn.Text = Config.ESPEnabled and "ESP: Açık" or "ESP: Kapalı"
        btn.TextColor3 = Config.ESPEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
    end)
end
addVisualElements()


-- MISC SEKMESİ (Godmode, Fly, Noclip, Heal, Teleport Oyuncu Listesi)
local function addMiscElements()
    local yPos = 10
    
    local function createToggle(name, configKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 330, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = name .. ": Kapalı"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize, btn.Font = 12, Enum.Font.Code
        btn.Parent = miscPage
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            btn.Text = Config[configKey] and (name .. ": Açık") or (name .. ": Kapalı")
            btn.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
        end)
        yPos = yPos + 40
    end
    
    createToggle("GodMode", "GodmodeEnabled")
    createToggle("Noclip", "NoclipEnabled")
    createToggle("Heal", "HealEnabled")
    createToggle("Fly", "FlyEnabled")
    
    -- TELEPORT ÖZELLİĞİ (Dinamik Oyuncu Listesi)
    local tpLabel = Instance.new("TextLabel")
    tpLabel.Size = UDim2.new(0, 330, 0, 20)
    tpLabel.Position = UDim2.new(0, 0, 0, yPos)
    tpLabel.BackgroundTransparency = 1
    tpLabel.Text = "--- Oyuncu Teleport Listesi ---"
    tpLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    tpLabel.TextSize, tpLabel.Font = 12, Enum.Font.Code
    tpLabel.Parent = miscPage
    yPos = yPos + 25
    
    -- Oyuncu Seçme Butonu (Tıkladıkça sunucudaki sıradaki oyuncuya geçer)
    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(0, 330, 0, 30)
    targetBtn.Position = UDim2.new(0, 0, 0, yPos)
    targetBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
    targetBtn.Text = "Hedef Seç: (Kimse Seçilmedi)"
    targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBtn.TextSize, targetBtn.Font = 12, Enum.Font.Code
    targetBtn.Parent = miscPage
    Instance.new("UICorner", targetBtn).CornerRadius = UDim.new(0, 4)
    
    yPos = yPos + 40
    
    -- Işınlanma Butonu
    local executeTpBtn = Instance.new("TextButton")
    executeTpBtn.Size = UDim2.new(0, 330, 0, 30)
    executeTpBtn.Position = UDim2.new(0, 0, 0, yPos)
    executeTpBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    executeTpBtn.Text = "Seçilen Oyuncuya Işınlan"
    executeTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeTpBtn.TextSize, executeTpBtn.Font = 12, Enum.Font.Code
    executeTpBtn.Parent = miscPage
    Instance.new("UICorner", executeTpBtn).CornerRadius = UDim.new(0, 4)
    
    -- Oyuncu Listesini Döngüyle Değiştirme Mantığı
    targetBtn.MouseButton1Click:Connect(function()
        local playersList = Players:GetPlayers()
        local validTargets = {}
        for _, p in ipairs(playersList) do
            if p ~= LocalPlayer then table.insert(validTargets, p) end
        end
        
        if #validTargets == 0 then
            targetBtn.Text = "Sunucuda başka oyuncu yok!"
            return
        end
        
        -- Sıradaki oyuncuyu seç
        local currentIndex = 1
        for i, p in ipairs(validTargets) do
            if p.Name == Config.SelectedTargetPlayer then
                currentIndex = i + 1
                break
            end
        end
        
        if currentIndex > #validTargets then currentIndex = 1 end
        Config.SelectedTargetPlayer = validTargets[currentIndex].Name
        targetBtn.Text = "Hedef: " .. Config.SelectedTargetPlayer
    end)
    
    -- Seçilen Oyuncuya Işınlanma Tetikleyicisi
    executeTpBtn.MouseButton1Click:Connect(function()
        if not Config.SelectedTargetPlayer then return end
        local targetP = Players:FindFirstChild(Config.SelectedTargetPlayer)
        if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetP.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end
addMiscElements()