-- ==========================================
-- CYBER HUNTER v3.1 (FIXED UI & CONFIG)
-- ==========================================
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
while not lp do task.wait() lp = Players.LocalPlayer end

-- ==========================================
-- CONFIGURATION & DATA
-- ==========================================
local CONFIG_FILE = "BrainrotConfig.json"
local TARGET_MUTATION = "Cyber"
local isRunning = true
local CheckedPets = {}
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&excludeFullGames=true"

-- Полный список из твоего pets.txt
local PET_NAMES = {
    "Noobini Pizzanini", "Liril\195\172 Laril\195\160", "Tim Cheese", "Fluriflura", "Svinina Bombardino", "Talpa Di Fero",
    "Pipi Kiwi", "Pipi Corni", "Raccooni Jandelini", "Tartaragno", "Noobini Santanini", "Holy Arepa",
    "Trippi Troppi", "Gangster Footera", "Boneca Ambalabu", "Ta Ta Ta Ta Sahur", "Tric Trac Baraboom", "Bandito Bobritto",
    "Cacto Hipopotamo", "Pipi Avocado", "Pinealotto Fruttarino", "Cupcake Koala", "Frogo Elfo", "Pengolino Nuvoletto",
    "Cappuccino Assassino", "Brr Brr Patapim", "Trulimero Trulicina", "Bananita Dolphinita", "Brri Brri Bicus Dicus Bombicus", "Bambini Crostini",
    "Perochello Lemonchello", "Avocadini Guffo", "Salamino Penguino", "Ti Ti Ti Sahur", "Penguino Cocosino", "Avocadini Antilopini",
    "Malame Amarele", "Mangolini Parrocini", "Mummio Rappitto", "Frogato Pirato", "Wombo Rollo", "Doi Doi Do",
    "Penguin Tree", "Gato Celesto", "Burbaloni Loliloli", "Chimpanzini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra",
    "Glorbo Fruttodrillo", "Blueberrinni Octopusini", "Lionel Cactuseli", "Pandaccini Bananini", "Strawberrelli Flamingelli", "Cocosini Mama",
    "Pi Pi Watermelon", "Sigma Boy", "Pipi Potato", "Quivioli Ameleonni", "Caramello Filtrello", "Sigma Girl",
    "Quackula", "Buho de Fuego", "Clickerino Crabo", "Puffaball", "Chocco Bunny", "Sealo Regalo",
    "Buho del Cielo", "Seraphino Gruyero", "Bandito Axolito", "Electro Quacko", "Frigo Camelo", "Orangutini Ananassini",
    "Bombardiro Crocodilo", "Bombombini Gusini", "Rhino Toasterino", "Cavallo Virtuoso", "Spioniro Golubiro", "Zibra Zubra Zibralini",
    "Tigrilini Watermelini", "Gorillo Watermelondrillo", "Avocadorilla", "Ganganzelli Trulala", "Tob Tobi Tobi", "Te Te Te Sahur",
    "Tracoducotulu Delapeladustuz", "Lerulerulerule", "Carloo", "Carrotini Brainini", "Brutto Gialutto", "Gorillo Subwoofero",
    "Los Noobinis", "Rhino Helicopterino", "Toiletto Focaccino", "Cachorrito Melonito", "Bananito Bandito", "Magi Ribbitini",
    "Jacko Spaventosa", "Stoppo Luminino", "Centrucci Nuclucci", "Jingle Jingle Sahur", "Tree Tree Tree Sahur", "Spongini Quackini",
    "Fizzy Soda", "Harpuccino", "Berenjello Angello", "Bee Loco", "Orbi Mochi", "Chihuanini Taconini",
    "Cocofanto Elefanto", "Tralalero Tralala", "Odin Din Din Dun", "Girafa Celestre", "Trenostruzzo Turbo 3000", "Matteo",
    "Tigroligre Frutonni", "Orcalero Orcala", "Unclito Samito", "Gattatino Nyanino", "Espresso Signora", "Ballerino Lololo",
    "Piccione Macchina", "Los Crocodillitos", "Tukanno Bananno", "Trippi Troppi Troppa Trippa", "Los Tungtungtungcitos", "Bulbito Bandito Traktorito",
    "Los Orcalitos", "Tipi Topi Taco", "Bombardini Tortinii", "Tralalita Tralala", "Urubini Flamenguini", "Alessio",
    "Pakrahmatmamat", "Los Bombinitos", "Brr es Teh Patipum", "Tartaruga Cisterna", "Cacasito Satalito", "Mastodontico Telepiedone",
    "Crabbo Limonetta", "Gattito Tacoto", "Los Tipi Tacos", "Las Capuchinas", "Orcalita Orcala", "Piccionetta Macchina",
    "Anpali Babel", "Extinct Ballerina", "Tractoro Dinosauro", "Belula Beluga", "Capi Taco", "Corn Corn Corn Sahur",
    "Brasilini Berimbini", "Squalanana", "Pop Pop Sahur", "Vampira Cappucina", "Jacko Jack Jack", "Snailenzo",
    "Tentacolo Tecnico", "Pakrahmatmatina", "Bambu Bambu Sahur", "Krupuk Pagi Pagi", "Mummy Ambalabu", "Cappuccino Clownino",
    "Skull Skull Skull", "Aquanaut", "Frio Ninja", "Money Money Man", "Noo La Polizia", "Los Chihuaninis",
    "Los Gattitos", "Granchiello Spiritell", "Ballerina Peppermintina", "Ginger Globo", "Ginger Cisterna", "Yeti Claus",
    "Buho de Noelo", "Chrismasmamat", "Cocoa Assassino", "Pandanini Frostini", "Tootini Shrimpini", "Boba Panda",
    "Dolphini Jetskini", "Luv Luv Luv", "Karkerheart Luvkur", "Divino Platypio", "Astrolero Cervalero", "Dumborino Miracello",
    "Patteo", "Clovkur Kurkur", "Bunny Tralala", "Eggdin Egg Egg Dun", "Pineaplino", "Lazy Ducky",
    "Cola Cat", "Tenini Ballini", "Appelini", "Trenotubo Axolotrico 9000", "Pretzo Robo", "La Vacca Saturno Saturnita",
    "Los Tralaleritos", "Graipuss Medussi", "La Grande Combinasion", "Sammyni Spyderini", "Garama and Madundung", "Torrtuginni Dragonfrutini",
    "Las Tralaleritas", "Pot Hotspot", "Nuclearo Dinossauro", "Las Vaquitas Saturnitas", "Chicleteira Bicicleteira", "Agarrini la Palini",
    "Los Combinasionas", "Karkerkar Kurkur", "Dragon Cannelloni", "Los Hotspotsitos", "Esok Sekolah", "Nooo My Hotspot",
    "Los Matteos", "Job Job Job Sahur", "Dul Dul Dul", "Blackhole Goat", "Los Spyderinis", "Ketupat Kepat",
    "La Supreme Combinasion", "Bisonte Giuppitere", "Guerriro Digitale", "Ketchuru and Musturu", "Spaghetti Tualetti", "Los Nooo My Hotspotsitos",
    "Trenostruzzo Turbo 4000", "Fragola La La La", "La Sahur Combinasion", "La Karkerkar Combinasion", "Tralaledon", "Los Bros",
    "Los Chicleteiras", "Chachechi", "Extinct Tralalero", "Extinct Matteo", "67", "Las Sis",
    "Celularcini Viciosini", "La Extinct Grande", "Quesadilla Crocodila", "Tacorita Bicicleta", "La Cucaracha", "To to to Sahur",
    "Mariachi Corazoni", "Los Tacoritas", "Tictac Sahur", "Yess my examine", "Karker Sahur", "Noo my examine",
    "Money Money Puggy", "Los Primos", "Tang Tang Keletang", "Perrito Burrito", "Chillin Chili", "Los Tortus",
    "Los Karkeritos", "Los Jobcitos", "Los 67", "La Secret Combinasion", "Burguro And Fryuro", "Zombie Tralala",
    "Vulturino Skeletono", "Frankentteo", "La Vacca Jacko Linterino", "Chicleteirina Bicicleteirina", "Eviledon", "La Spooky Grande",
    "Los Mobilis", "Spooky and Pumpky", "Boatito Auratito", "Horegini Boom", "Rang Ring Bus", "Mieteteira Bicicleteira",
    "Quesadillo Vampiro", "Burrito Bandito", "Chipso and Queso", "Jackorilla", "Pumpkini Spyderini", "Trickolino",
    "Telemorte", "Pot Pumpkin", "Noo my Candy", "Los Spooky Combinasionas", "La Casa Boo", "La Taco Combinasion",
    "1x1x1x1", "Capitano Moby", "Guest 666", "Pirulitoita Bicicleteira", "Los Puggies", "Los Spaghettis",
    "Fragrama and Chocrama", "Swag Soda", "Orcaledon", "Los Cucarachas", "Los Burritos", "Los Quesadillas",
    "Cuadramat and Pakrahmatmamat", "Fishino Clownino", "Los Planitos", "W or L", "Lavadorito Spinito", "Gobblino Uniciclino",
    "Giftini Spyderini", "Tung Tung Tung Sahur", "Coffin Tung Tung Tung Sahur", "Cooki and Milki", "25", "La Vacca Prese Presente",
    "Reindeer Tralala", "Santteo", "Please my Present", "List List List Sahur", "Ho Ho Ho Sahur", "Chicleteira Noelteira",
    "La Jolly Grande", "Los Candies", "Triplito Tralaleritos", "Santa Hotspot", "La Ginger Sekolah", "Reinito Sleighito",
    "Naughty Naughty", "Noo my Present", "Los 25", "Chimnino", "Festive 67", "Swaggy Bros",
    "Bunnyman", "Dragon Gingerini", "Donkeyturbo Express", "Money Money Reindeer", "Los Jolly Combinasionas", "Jolly Jolly Sahur",
    "Ginger Gerat", "Rocco Disco", "Bunito Bunito Spinito", "Tuff Toucan", "Cerberus", "GOAT",
    "Brunito Marsito", "Los Trios", "Chill Puppy", "Arcadopus", "Spinny Hammy", "Bacuru and Egguru",
    "Ketupat Bros", "Hydra Dragon Cannelloni", "Mi Gatito", "Los Mi Gatitos", "Popcuru and Fizzuru", "Love Love Love Sahur",
    "Cupid Cupid Sahur", "Cupid Hotspot", "Noo my Heart", "Chicleteira Cupideira", "Lovin Rose", "La Romantic Grande",
    "Rosetti Tualetti", "Love Love Bear", "Rosey and Teddy", "Los Sweethearts", "Sammyni Fattini", "La Food Combinasion",
    "Los Sekolahs", "Los Amigos", "Tirilikalika Tirilikalako", "Antonio", "Elefanto Frigo", "Signore Carapace",
    "Fishboard", "DJ Panda", "Ventoliero Pavonero", "Celestial Pegasus", "Tacorillo Crocodillo", "Nacho Spyder",
    "Paradiso Axolottino", "Serafinna Medusella", "Cigno Fulgoro", "Los Cupids", "Griffin", "La Vacca Lepre Lepreino",
    "Luck Luck Luck Sahur", "Noo my Gold", "Snailo Clovero", "Gold Gold Gold", "Fortunu and Cashuru", "Cloverat Clapat",
    "Dug dug dug", "La Lucky Grande", "Eid Eid Eid Sahur", "Granny", "Foxini Lanternini", "Buntteo",
    "Bunny Bunny Bunny Sahur", "Noo my Eggs", "La Easter Grande", "Easter Easter Easter Sahur", "Los Bunitos", "Baskito",
    "Churrito Bunnito", "Quackini Snackini", "Hopilikalika Hopilikalako", "Boppin Bunny", "Hydra Bunny", "Bunny and Eggy",
    "Globa Steppa", "Rico Dinero", "Pancake and Syrup", "Arcadragon", "Berryno", "Strawberrita",
    "Bananito", "Cash or Card", "Los Mariachis", "Buho de Volto", "Camera Ramena", "Gym Bros",
    "Los Chillis", "Kalika Bros", "Digi Narwhal", "Skibidi Toilet", "Strawberry Elephant", "Headless Horseman",
    "Meowl", "Gold Egg", "Gold Elf"
}

-- ==========================================
-- SAVE/LOAD SYSTEM
-- ==========================================
local function LoadConfig()
    if isfile(CONFIG_FILE) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if success then CheckedPets = data end
    end
end

local function SaveConfig()
    writefile(CONFIG_FILE, HttpService:JSONEncode(CheckedPets))
end

-- ==========================================
-- UI CONSTRUCTION (IMAGE_4C605C.PNG)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "BrainrotCollector"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0

-- Кнопка для перетаскивания (Header)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "BRAINROT CYBER HUNTER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local CounterLabel = Instance.new("TextLabel", MainFrame)
CounterLabel.Size = UDim2.new(1, -20, 0, 25)
CounterLabel.Position = UDim2.new(0, 10, 0, 35)
CounterLabel.Text = "Total amount 0/453"
CounterLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
CounterLabel.Font = Enum.Font.Gotham
CounterLabel.BackgroundTransparency = 1
CounterLabel.TextXAlignment = Enum.TextXAlignment.Right

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -115)
Scroll.Position = UDim2.new(0, 10, 0, 65)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Scroll.CanvasSize = UDim2.new(0, 0, 0, #PET_NAMES * 28)
Scroll.ScrollBarThickness = 6
Scroll.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 4)

local function UpdateCounter()
    local count = 0
    for _ in pairs(CheckedPets) do count = count + 1 end
    CounterLabel.Text = "Total amount " .. count .. "/453"
end

-- Генерация списка чекбоксов
for _, name in ipairs(PET_NAMES) do
    local Entry = Instance.new("Frame", Scroll)
    Entry.Size = UDim2.new(1, -12, 0, 24)
    Entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Entry.BorderSizePixel = 0

    local Label = Instance.new("TextLabel", Entry)
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham

    local Checkbox = Instance.new("TextButton", Entry)
    Checkbox.Size = UDim2.new(0, 18, 0, 18)
    Checkbox.Position = UDim2.new(0.9, 0, 0, 3)
    Checkbox.Text = CheckedPets[name] and "X" or ""
    Checkbox.BackgroundColor3 = CheckedPets[name] and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(60, 60, 60)
    Checkbox.TextColor3 = Color3.fromRGB(0, 0, 0)
    Checkbox.Font = Enum.Font.GothamBold

    Checkbox.MouseButton1Click:Connect(function()
        if CheckedPets[name] then
            CheckedPets[name] = nil
            Checkbox.Text = ""
            Checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            CheckedPets[name] = true
            Checkbox.Text = "X"
            Checkbox.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        end
        SaveConfig()
        UpdateCounter()
    end)
end

local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(1, -20, 0, 35)
ToggleButton.Position = UDim2.new(0, 10, 1, -45)
ToggleButton.Text = "STOP HUNT"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold

-- Система перетаскивания (Draggable Fix)
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ==========================================
-- BEAM LOGIC
-- ==========================================
local function CreatePowerBeam(target)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- Находим или создаем физическую точку
    local targetPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    if not targetPart then
        targetPart = Instance.new("Part")
        targetPart.Size = Vector3.new(1, 1, 1)
        targetPart.Transparency = 1
        targetPart.CanCollide = false
        targetPart.Anchored = true
        targetPart.CFrame = target:GetPivot()
        targetPart.Parent = Workspace
    end

    local att0 = Instance.new("Attachment", hrp)
    local att1 = Instance.new("Attachment", targetPart)

    local beam = Instance.new("Beam", char)
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    beam.Width0 = 3
    beam.Width1 = 3
    beam.LightEmission = 1
    beam.FaceCamera = true
    beam.Texture = "rbxassetid://403870490"
    beam.TextureSpeed = 4
end

-- ==========================================
-- HOPPER & SCANNER
-- ==========================================
local function StartTeleport()
    if not isRunning then return end
    
    local success, content = pcall(function() return readfile("Servers.JSON") end)
    if not success or content == "" then
        writefile("Servers.JSON", game:HttpGet(API))
        content = readfile("Servers.JSON")
    end
    
    local JSONData = HttpService:JSONDecode(content)
    if JSONData and JSONData.data and #JSONData.data > 0 then
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

local function ScanServer()
    if not isRunning then return end
    task.wait(4)

    local debris = Workspace:WaitForChild("Debris", 10)
    local targetFound = nil

    if debris then
        for _, template in ipairs(debris:GetChildren()) do
            if template.Name == "FastOverheadTemplate" then
                local petName = "Unknown"
                local isCyber = false

                for _, el in ipairs(template:GetDescendants()) do
                    if el:IsA("TextLabel") then
                        local txt = string.gsub(el.Text, "<[^>]+>", "")
                        if el.Name == "DisplayName" then petName = txt end
                        if string.find(string.lower(txt), "cyber") then isCyber = true end
                    end
                end

                -- Если нашли кибера, проверяем, нет ли его в "Залитых" чекбоксах
                if isCyber then
                    if CheckedPets[petName] then
                        print("[System] Игнорирую " .. petName .. " (уже в конфиге)")
                    else
                        targetFound = {instance = template, name = petName}
                        break
                    end
                end
            end
        end
    end

    if targetFound then
        isRunning = false
        ToggleButton.Text = "START HUNT"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("[!!!] ЦЕЛЬ ОБНАРУЖЕНА: " .. targetFound.name)
        CreatePowerBeam(targetFound.instance)
    else
        print("[System] Подходящих целей нет, прыгаю дальше...")
        StartTeleport()
    end
end

-- ==========================================
-- INIT
-- ==========================================
LoadConfig()
UpdateCounter()

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    ToggleButton.Text = isRunning and "STOP HUNT" or "START HUNT"
    ToggleButton.BackgroundColor3 = isRunning and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
    if isRunning then ScanServer() end
end)

if isRunning then task.spawn(ScanServer) end
print("Cyber Hunter v3.1 Loaded! UI Fixed.")
