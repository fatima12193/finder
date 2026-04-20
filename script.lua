-- ==========================================
-- CYBER MUTATION HUNTER v2.4 (MULTI-FIND & AUTO-HOP)
-- ==========================================
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Ожидание игрока
local lp = Players.LocalPlayer
while not lp do
    task.wait()
    lp = Players.LocalPlayer
end

local TARGET_MUTATION = "Cyber"
local isRunning = false
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&excludeFullGames=true"

-- ==========================================
-- ИНТЕРФЕЙС
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")

ScreenGui.Name = "CyberUltraGui"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainButton.Name = "ToggleButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainButton.Position = UDim2.new(0, 20, 0.5, -25)
MainButton.Size = UDim2.new(0, 160, 0, 50)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "START HUNT"
MainButton.TextColor3 = Color3.fromRGB(0, 255, 127)
MainButton.TextSize = 16

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 127)
UIStroke.Thickness = 3
UIStroke.Parent = MainButton

-- ==========================================
-- ВИЗУАЛИЗАЦИЯ (ЛУЧ)
-- ==========================================
local function CreateBeamToTarget(target)
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart

    -- Очистка старых лучей
    for _, old in ipairs(char:GetChildren()) do
        if old.Name == "CyberHunt_Beam" then old:Destroy() end
    end

    local att0 = hrp:FindFirstChild("CyberHunt_Att0") or Instance.new("Attachment", hrp)
    att0.Name = "CyberHunt_Att0"

    local targetPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    
    if targetPart then
        local att1 = Instance.new("Attachment", targetPart)
        att1.Name = "CyberHunt_Att1"

        local beam = Instance.new("Beam")
        beam.Name = "CyberHunt_Beam"
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Width0 = 2
        beam.Width1 = 2
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        beam.LightEmission = 1
        beam.FaceCamera = true
        beam.Texture = "rbxassetid://403870490"
        beam.TextureSpeed = 2
        beam.Parent = char
    end
end

-- ==========================================
-- ЛОГИКА ТЕЛЕПОРТАЦИИ
-- ==========================================
local function StartTeleport()
    if not isRunning then return end
    print("[System] Ищу новый сервер...")

    if not isfile("Servers.JSON") then
        local success, result = pcall(function() return game:HttpGet(API) end)
        if success then writefile("Servers.JSON", result) end
    end

    local content = readfile("Servers.JSON")
    local success, JSONData = pcall(function() return HttpService:JSONDecode(content) end)
    
    if success and JSONData and JSONData.data and #JSONData.data > 0 then
        local JobId = JSONData.data[1].id
        table.remove(JSONData.data, 1)
        writefile("Servers.JSON", HttpService:JSONEncode(JSONData))
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, lp)
    else
        delfile("Servers.JSON")
        task.wait(1)
        StartTeleport()
    end
end

-- ==========================================
-- ПОИСК ВСЕХ КИБЕРОВ НА СЕРВЕРЕ
-- ==========================================
local function ScanServer()
    if not isRunning then return end

    local debris = Workspace:WaitForChild("Debris", 15)
    print("[System] Ожидание репликации объектов (3.5 сек)...")
    task.wait(3.5)

    local foundList = {} -- Таблица для хранения найденных объектов

    if debris then
        for _, template in ipairs(debris:GetChildren()) do
            if template.Name == "FastOverheadTemplate" then
                local currentName = "Unknown"
                local hasCyber = false

                -- Проходим по всем лейблам внутри оверхеда
                for _, element in ipairs(template:GetDescendants()) do
                    if element:IsA("TextLabel") then
                        local text = string.gsub(element.Text, "<[^>]+>", "")
                        
                        if element.Name == "DisplayName" then
                            currentName = text
                        end

                        if string.find(string.lower(text), string.lower(TARGET_MUTATION)) then
                            hasCyber = true
                        end
                    end
                end

                if hasCyber then
                    table.insert(foundList, {instance = template, name = currentName})
                end
            end
        end
    end

    -- Обработка результатов
    if #foundList > 0 then
        isRunning = false -- ОСТАНАВЛИВАЕМ ХОППЕР, МЫ НАШЛИ ЦЕЛЬ
        
        print("-----------------------------------------")
        print(string.format("[!!!] НАЙДЕНО КИБЕРОВ: %d", #foundList))
        
        for i, data in ipairs(foundList) do
            print(string.format("[%d] Брейнрот: %s", i, data.name))
        end
        print("-----------------------------------------")

        -- Рисуем луч к первому найденному
        CreateBeamToTarget(foundList[1].instance)
        
        MainButton.Text = "CYBER FOUND (" .. #foundList .. ")"
        MainButton.TextColor3 = Color3.fromRGB(0, 255, 255)
        UIStroke.Color = Color3.fromRGB(0, 255, 255)
    else
        -- Если ничего не нашли - прыгаем дальше автоматически
        if isRunning then
            print("[System] На этом сервере пусто. Хопаю дальше...")
            task.wait(0.5)
            StartTeleport()
        end
    end
end

-- ==========================================
-- КНОПКА
-- ==========================================
MainButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        MainButton.Text = "STOP HUNT"
        MainButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        UIStroke.Color = Color3.fromRGB(255, 75, 75)
        print("[System] Охота началась!")
        ScanServer()
    else
        MainButton.Text = "START HUNT"
        MainButton.TextColor3 = Color3.fromRGB(0, 255, 127)
        UIStroke.Color = Color3.fromRGB(0, 255, 127)
        print("[System] Охота остановлена.")
    end
end)

-- Фикс застревания при загрузке сервера
TeleportService.TeleportInitFailed:Connect(function()
    if isRunning then
        task.wait(3)
        StartTeleport()
    end
end)

if not game:IsLoaded() then game.Loaded:Wait() end
print("Cyber Hunter v2.4 (Infinite Loop & Multi-Log) Loaded!")
