-- ==========================================
-- CYBER MUTATION HUNTER v2.5 (AUTO-RESUME & FIXED BEAM)
-- ==========================================
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Надежное ожидание LocalPlayer
local lp = Players.LocalPlayer
while not lp do
    task.wait()
    lp = Players.LocalPlayer
end

local TARGET_MUTATION = "Cyber"
-- ТЕПЕРЬ ПО УМОЛЧАНИЮ TRUE ДЛЯ АВТО-СТАРТА ПОСЛЕ ХОПА
local isRunning = true 
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&excludeFullGames=true"

-- ==========================================
-- ИНТЕРФЕЙС
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")

ScreenGui.Name = "CyberAutoHunterGui"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainButton.Name = "ToggleButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainButton.Position = UDim2.new(0, 20, 0.5, -25)
MainButton.Size = UDim2.new(0, 160, 0, 50)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "STOP HUNT" -- Сразу пишем STOP, так как охота активна
MainButton.TextColor3 = Color3.fromRGB(255, 75, 75)
MainButton.TextSize = 16

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 75, 75)
UIStroke.Thickness = 3
UIStroke.Parent = MainButton

-- ==========================================
-- ВИЗУАЛИЗАЦИЯ (ЛУЧ К ТЕКСТУ ИЛИ ПЕТУ)
-- ==========================================
local function CreateBeamToTarget(target)
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart

    -- Полная очистка старых визуалов
    for _, old in ipairs(char:GetChildren()) do
        if old.Name == "CyberHunt_Beam" then old:Destroy() end
    end
    for _, old in ipairs(hrp:GetChildren()) do
        if old.Name == "CyberHunt_Att0" then old:Destroy() end
    end

    -- Находим физическую часть в шаблоне для привязки луча
    local targetPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    
    if targetPart then
        local att0 = Instance.new("Attachment", hrp)
        att0.Name = "CyberHunt_Att0"

        local att1 = Instance.new("Attachment", targetPart)
        att1.Name = "CyberHunt_Att1"

        local beam = Instance.new("Beam")
        beam.Name = "CyberHunt_Beam"
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Width0 = 3 -- Жирный луч
        beam.Width1 = 3
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.FaceCamera = true
        beam.Texture = "rbxassetid://403870490"
        beam.TextureSpeed = 3
        beam.ZOffset = 5 -- Всегда поверх большинства объектов
        beam.Parent = char
        
        print("[Visuals] Силовой луч успешно направлен на Cyber-цель.")
    else
        warn("[Visuals] Ошибка: Не найдена физическая часть для луча в " .. target.Name)
    end
end

-- ==========================================
-- ЛОГИКА ТЕЛЕПОРТАЦИИ
-- ==========================================
local function StartTeleport()
    if not isRunning then return end
    print("[System] Переход на следующий сервер...")

    -- Проверяем наличие файла серверов
    local successLoad, content = pcall(function() return readfile("Servers.JSON") end)
    
    if not successLoad or content == "" then
        local successGet, result = pcall(function() return game:HttpGet(API) end)
        if successGet then 
            writefile("Servers.JSON", result)
            content = result
        else
            warn("[System] Ошибка получения списка API. Жду 5 сек...")
            task.wait(5)
            return StartTeleport()
        end
    end

    local successDecode, JSONData = pcall(function() return HttpService:JSONDecode(content) end)
    
    if successDecode and JSONData and JSONData.data and #JSONData.data > 0 then
        local JobId = JSONData.data[1].id
        table.remove(JSONData.data, 1)
        writefile("Servers.JSON", HttpService:JSONEncode(JSONData))
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, lp)
    else
        -- Если список кончился, удаляем файл и берем свежий
        pcall(function() delfile("Servers.JSON") end)
        task.wait(1)
        StartTeleport()
    end
end

-- ==========================================
-- ГЛАВНЫЙ СКАНЕР
-- ==========================================
local function ScanServer()
    if not isRunning then return end

    local debris = Workspace:WaitForChild("Debris", 15)
    print("[System] Сервер загружен. Ожидание прогрузки петов (4 сек)...")
    task.wait(4) -- Немного увеличил, чтобы наверняка прогрузились оверхеды

    local foundList = {}

    if debris then
        for _, template in ipairs(debris:GetChildren()) do
            if template.Name == "FastOverheadTemplate" then
                local petName = "Unknown Pet"
                local hasCyber = false

                -- Сканируем всё внутри оверхеда
                for _, element in ipairs(template:GetDescendants()) do
                    if element:IsA("TextLabel") then
                        local text = string.gsub(element.Text, "<[^>]+>", "") -- Чистим RichText
                        
                        -- Запоминаем имя
                        if element.Name == "DisplayName" then
                            petName = text
                        end

                        -- Ищем мутацию
                        if string.find(string.lower(text), string.lower(TARGET_MUTATION)) then
                            hasCyber = true
                        end
                    end
                end

                if hasCyber then
                    table.insert(foundList, {instance = template, name = petName})
                end
            end
        end
    end

    -- Результаты поиска
    if #foundList > 0 then
        isRunning = false -- СТОП ОХОТА, ЦЕЛЬ НАЙДЕНА
        
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print(string.format("[!!!] НАЙДЕНО CYBER ПЕТОВ: %d", #foundList))
        for i, data in ipairs(foundList) do
            print(string.format("[%d] Название: %s", i, data.name))
        end
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

        -- Создаем луч к первому найденному
        CreateBeamToTarget(foundList[1].instance)
        
        MainButton.Text = "FOUND: " .. #foundList
        MainButton.TextColor3 = Color3.fromRGB(0, 255, 255)
        UIStroke.Color = Color3.fromRGB(0, 255, 255)
    else
        -- Если ничего не нашли - авто-хоп
        if isRunning then
            print("[System] На сервере нет Cyber-мутаций. Продолжаю поиск...")
            task.wait(0.5)
            StartTeleport()
        end
    end
end

-- ==========================================
-- УПРАВЛЕНИЕ КНОПКОЙ
-- ==========================================
MainButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        MainButton.Text = "STOP HUNT"
        MainButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        UIStroke.Color = Color3.fromRGB(255, 75, 75)
        ScanServer()
    else
        MainButton.Text = "START HUNT"
        MainButton.TextColor3 = Color3.fromRGB(0, 255, 127)
        UIStroke.Color = Color3.fromRGB(0, 255, 127)
    end
end)

-- Фикс ошибок телепорта (предотвращение застревания)
TeleportService.TeleportInitFailed:Connect(function()
    if isRunning then
        task.wait(3)
        StartTeleport()
    end
end)

-- АВТО-ЗАПУСК СКАНЕРА ПРИ ВЫПОЛНЕНИИ СКРИПТА
if not game:IsLoaded() then game.Loaded:Wait() end
print("Cyber Hunter v2.5 Loaded! Auto-scanning started...")
task.spawn(ScanServer)
