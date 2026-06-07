local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
    Name = "Arsenal VeXHeX",
    LoadingTitle = "what? who are you?",
    LoadingSubtitle = "by Bro",
    ConfigurationSaving = { Enabled = false },
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local HitboxTab = Window:CreateTab("Hitbox", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SkinTab = Window:CreateTab("Skin Changer", 4483362458)

local SkinsList = {
    "Wood","Subzero Crystalline","Vine Wrap","Scale","Arctic Camo","Multiplier","Grid","Circuits",
    "Brick","TRANS PRIDE","Widow","Candies","Fleshy","Triangles","Cube","Aurora","Crimson",
    "Froggo","Target","Cherry","Run","Alien","Big BUX","Stars","Rope","Time Is Money",
    "Canes and Cookies","Duckies","Binary","Gift Wrapped","Flow","Galaxy","Squad","Glitter",
    "Winter Day","Integrated","Bronze","Mushroom","Water","Arctic OP","LGBTQIA+","Bruh",
    "Strands","Hive Mind","Splots","Aura Pop","Clovers","Spirals","Candied","Node","No",
    "Static","Swirls","Candy Cross","Loops","Animated","Checker","Crystaline","Clouds",
    "Cobalt","Construct","Pumpkins","Gold","Candles","Silver","Big TIX","Coal","Cyber",
    "Skulls","Bacon","Polkas","Negative Circuit","B-Bot","Holly","Sci Tri","Snow Blasted",
    "Dark Matter","Snow Scattered","Scavenger Camo","Fog","Creator","Studs","Active Camo",
    "Bubbles","Webs","Petal","Nomad","Stocking Galore","Cell","Sizer","GX","Ugly Sweater",
    "Cartoony Ghost","Armored","Hallowed Crystals","Winter Candlelight","Sardine Lover",
    "Police Tape","Crow","Blind Justice","Winter OP","Scrambled","Warp","Melees",
    "Show Time Crow","Big Hoss","Scytheric","Bells","Jungle Press","Quandale Dingle",
    "Weapon Skins","Chainage","Team Sort","Speed","Murky Depth","Horz","Suit","FrostBurn",
    "Bones","Diamonds","Seals","FREE","Flesh","ACT","Danger Stickers","Cheese"
}

local CurrentSkin = "None"

local function ChangeSkin(skinName)
    local Equipped = LocalPlayer:WaitForChild("Equipped")
    if not Equipped or not Equipped:IsA("StringValue") then return end
    local SkinsFolder = ReplicatedStorage:WaitForChild("Skins"):WaitForChild("ACT")
    if not SkinsFolder then return end
    Equipped.Value = skinName
    wait(0.1)
    Equipped.Value = skinName
end

SkinTab:CreateDropdown({
    Name = "Choose Skin",
    Options = SkinsList,
    CurrentOption = {"None"},
    Callback = function(Option)
        CurrentSkin = Option[1]
        ChangeSkin(CurrentSkin)
    end,
})

SkinTab:CreateButton({
    Name = "Apply Skin",
    Callback = function()
        ChangeSkin(CurrentSkin)
    end,
})

local InvisibleEnabled = false

local function ApplyInvis()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
    if char:FindFirstChild("Head") and char.Head:FindFirstChild("face") then
        char.Head.face.Transparency = 1
    end
end

local function ResetInvis()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 0
        end
    end
    if char:FindFirstChild("Head") and char.Head:FindFirstChild("face") then
        char.Head.face.Transparency = 0
    end
end

MiscTab:CreateToggle({
    Name = "Invisible ( Doesnt Works )",
    CurrentValue = false,
    Callback = function(Value)
        InvisibleEnabled = Value
        if Value then ApplyInvis() else ResetInvis() end
    end,
})

local ESP = {
    Enabled = true,
    ShowBoxes = true,
    ShowCircles = false,
    ShowSkeleton = false,
    Boxes = {},
    Circles = {},
    Skeletons = {}
}

local HitboxSize = 5
local lastHitboxSize = 5

ESPTab:CreateToggle({
    Name = "Enable esp",
    CurrentValue = true,
    Callback = function(Value) ESP.Enabled = Value end,
})

ESPTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = true,
    Callback = function(Value) ESP.ShowBoxes = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Circles",
    CurrentValue = false,
    Callback = function(Value) ESP.ShowCircles = Value end,
})

ESPTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = false,
    Callback = function(Value) ESP.ShowSkeleton = Value end,
})

HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 21.5},
    Increment = 0.5,
    CurrentValue = 5,
    Callback = function(Value)
        HitboxSize = Value
    end,
})

local function createDrawing(type)
    local d = Drawing.new(type)
    d.Visible = false
    d.Color = Color3.fromRGB(255, 0, 255)
    d.Thickness = 1.5
    d.Transparency = 1
    return d
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen and ESP.Enabled then
            if not ESP.Boxes[player] then
                ESP.Boxes[player] = createDrawing("Square")
                ESP.Circles[player] = createDrawing("Circle")
                ESP.Skeletons[player] = {}
            end

            local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local height = (top.Y - bottom.Y)
            local width = height * 0.6

            local box = ESP.Boxes[player]
            box.Visible = ESP.ShowBoxes
            if ESP.ShowBoxes then
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2 + 5)
            end

            local circle = ESP.Circles[player]
            circle.Visible = ESP.ShowCircles
            if ESP.ShowCircles then
                circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                circle.Radius = 70
            end

            if ESP.ShowSkeleton then
                for _, line in pairs(ESP.Skeletons[player]) do line.Visible = false end
            end
        else
            if ESP.Boxes[player] then
                ESP.Boxes[player].Visible = false
                ESP.Circles[player].Visible = false
            end
        end
    end
end

local function applyHitbox(char)
    if not char then return end
    local parts = {"Head", "UpperTorso", "LowerTorso"}
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part then
            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            part.Transparency = 0.8
            part.CanCollide = false
            part.Massless = true
        end
    end
end

-- Setup
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then applyHitbox(plr.Character) end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.6)
        applyHitbox(char)
    end)
end)

RunService.RenderStepped:Connect(function()
    updateESP()
    if HitboxSize ~= lastHitboxSize then
        lastHitboxSize = HitboxSize
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                applyHitbox(plr.Character)
            end
        end
    end
end)

Rayfield:Notify({
    Title = "Arsenal VeXHeX By Bro",
    Content = "Find it out",
    Duration = 5,
})

print("You just leaked your IP to Bro 🤡")
