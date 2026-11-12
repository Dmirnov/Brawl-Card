# Brawl Card — пакет скриптов Roblox

Этот файл содержит все скрипты проекта в одном документе. **Не вставляй весь файл целиком в один Script:** разделы нужно разнести по указанным объектам в Roblox Studio.

## 1. WorldSetup

Создай обычный `Script` в `ServerScriptService` и назови его `WorldSetup`. Замени его содержимое разделом ниже.

```lua
-- Brawl Card: central spawn hub prototype.
-- Put this normal Script in ServerScriptService and press Play.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local oldWorld = Workspace:FindFirstChild("BrawlWorld")
if oldWorld then
	oldWorld:Destroy()
end

-- Remove the default green flat world so it does not show around the designed map.
-- The actual hub, stepped route, and personal bases are generated below.
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
	terrain:Clear()
end

for _, object in ipairs(Workspace:GetDescendants()) do
	if object:IsA("BasePart") then
		local isNamedBaseplate = object.Name == "Baseplate"
		local isHugeFlatFloor = object.Size.X >= 400 and object.Size.Z >= 400 and object.Size.Y <= 20
		if isNamedBaseplate or isHugeFlatFloor then
			object:Destroy()
		end
	end
end

local world = Instance.new("Folder")
world.Name = "BrawlWorld"
world.Parent = Workspace

local function makePart(name, size, position, color, material, parent)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Anchored = true
	object.Material = material or Enum.Material.SmoothPlastic
	object.Color = color
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent or world
	return object
end

local sand = Color3.fromRGB(242, 190, 93)
local blue = Color3.fromRGB(35, 105, 255)
local purple = Color3.fromRGB(130, 45, 220)
local yellow = Color3.fromRGB(255, 205, 35)
local dark = Color3.fromRGB(42, 32, 69)
local green = Color3.fromRGB(82, 190, 85)

-- Spacious central hub: 180x180, with the walkable top at Y=0.
makePart("SpawnHubFloor", Vector3.new(180, 2, 180), Vector3.new(0, -1, 0), sand, Enum.Material.Sand)

-- Colored perimeter frame.
makePart("Border_Front", Vector3.new(180, 1, 5), Vector3.new(0, 0.1, 87.5), blue)
makePart("Border_Back", Vector3.new(180, 1, 5), Vector3.new(0, 0.1, -87.5), purple)
makePart("Border_Left", Vector3.new(5, 1, 170), Vector3.new(-87.5, 0.1, 0), purple)
makePart("Border_Right", Vector3.new(5, 1, 170), Vector3.new(87.5, 0.1, 0), blue)

-- Raised adventure route inspired by the reference: the flat baseplate stays
-- underneath as a safe playable foundation; stepped islands create the relief.
local route = Instance.new("Folder")
route.Name = "AdventureRoute"
route.Parent = world

local ice = Color3.fromRGB(105, 211, 255)
local iceLight = Color3.fromRGB(200, 245, 255)
local candy = Color3.fromRGB(242, 73, 208)
local leaf = Color3.fromRGB(54, 190, 106)
local leafLight = Color3.fromRGB(123, 232, 117)
local coral = Color3.fromRGB(255, 118, 83)

local function routePart(name, size, position, color, material, parent)
	local part = makePart(name, size, position, color, material, parent or route)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- Broad star-shaped plaza at the heart of the hub.
routePart("StarPlaza_Foundation", Vector3.new(48, 1.4, 48), Vector3.new(0, 0.45, 0), dark, Enum.Material.Slate)
routePart("StarPlaza_Rim", Vector3.new(43, 0.35, 43), Vector3.new(0, 1.25, 0), blue, Enum.Material.Neon)
routePart("StarPlaza_Center", Vector3.new(35, 0.45, 35), Vector3.new(0, 1.62, 0), yellow, Enum.Material.SmoothPlastic)
for i, spec in ipairs({
	{ "North", Vector3.new(0, 1.65, -24), Vector3.new(13, 0.4, 24), 0 },
	{ "South", Vector3.new(0, 1.65, 24), Vector3.new(13, 0.4, 24), 0 },
	{ "West", Vector3.new(-24, 1.65, 0), Vector3.new(24, 0.4, 13), 0 },
	{ "East", Vector3.new(24, 1.65, 0), Vector3.new(24, 0.4, 13), 0 },
	{ "NorthWestRay", Vector3.new(-17, 1.66, -17), Vector3.new(10, 0.4, 25), -45 },
	{ "NorthEastRay", Vector3.new(17, 1.66, -17), Vector3.new(10, 0.4, 25), 45 },
	{ "SouthWestRay", Vector3.new(-17, 1.66, 17), Vector3.new(10, 0.4, 25), 45 },
	{ "SouthEastRay", Vector3.new(17, 1.66, 17), Vector3.new(10, 0.4, 25), -45 },
}) do
	local ray = routePart("StarPlaza_Ray_" .. spec[1], spec[3], spec[2], yellow, Enum.Material.Neon)
	ray.Orientation = Vector3.new(0, spec[4], 0)
end
routePart("StarPlaza_Core", Vector3.new(12, 0.8, 12), Vector3.new(0, 2.2, 0), dark, Enum.Material.Metal)
local coreLight = routePart("StarPlaza_CoreLight", Vector3.new(8, 0.25, 8), Vector3.new(0, 2.72, 0), ice, Enum.Material.Neon)
coreLight.CanCollide = false

local function makeBiome(name, center, topY, mainColor, accentColor, label)
	local model = Instance.new("Model")
	model.Name = "Zone_" .. name
	model.Parent = route
	local base = routePart(name .. "_Island", Vector3.new(30, 3, 26), Vector3.new(center.X, topY - 1.5, center.Z), dark, Enum.Material.Slate, model)
	base:SetAttribute("Biome", name)
	routePart(name .. "_Top", Vector3.new(28, 0.5, 24), Vector3.new(center.X, topY - 0.25, center.Z), mainColor, Enum.Material.SmoothPlastic, model)
	for i = -1, 1 do
		local trim = routePart(name .. "_Trim_" .. i, Vector3.new(8, 0.35, 0.55), Vector3.new(center.X + i * 9, topY + 0.05, center.Z + 11.7), accentColor, Enum.Material.Neon, model)
		trim.CanCollide = false
	end
	local marker = routePart(name .. "_Marker", Vector3.new(2, 8, 2), Vector3.new(center.X, topY + 4, center.Z - 8), dark, Enum.Material.Metal, model)
	local flag = routePart(name .. "_Sign", Vector3.new(14, 4, 0.6), Vector3.new(center.X, topY + 7, center.Z - 8), dark, Enum.Material.SmoothPlastic, model)
	flag.CanCollide = false
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ZoneLabel"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.Parent = flag
	local text = Instance.new("TextLabel")
	text.Name = "Title"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = accentColor
	text.TextStrokeColor3 = dark
	text.TextStrokeTransparency = 0.15
	text.TextScaled = true
	text.Font = Enum.Font.GothamBlack
	text.Parent = gui
	marker.CanCollide = false
	return model
end

-- The diagonal route crosses ice, candy, the central star plaza and jungle,
-- then finishes at a small canyon lookout / exit. Heights stay gently walkable.
local routeNodes = {
	{ x = -62, z = 54, y = 3, name = "Ice", color = ice, accent = iceLight, label = "ЛЕДЯНАЯ ЗОНА" },
	{ x = -34, z = 30, y = 2.4, name = "Candy", color = candy, accent = yellow, label = "КОНФЕТНАЯ ЗОНА" },
	{ x = 0, z = 0, y = 1.9, name = "Star", color = yellow, accent = blue, label = "ЦЕНТРАЛЬНАЯ ПЛОЩАДЬ" },
	{ x = 34, z = -30, y = 2.4, name = "Jungle", color = leaf, accent = leafLight, label = "ЗЕЛЁНАЯ ЗОНА" },
	{ x = 62, z = -54, y = 3, name = "Canyon", color = sand, accent = coral, label = "ВЫХОД" },
}

for _, node in ipairs(routeNodes) do
	if node.name ~= "Star" then
		makeBiome(node.name, Vector3.new(node.x, 0, node.z), node.y, node.color, node.accent, node.label)
	end
end

local function makeSteps(fromNode, toNode, segmentIndex)
	local steps = 7
	for step = 1, steps do
		local alpha = step / (steps + 1)
		local x = fromNode.x + (toNode.x - fromNode.x) * alpha
		local z = fromNode.z + (toNode.z - fromNode.z) * alpha
		local y = fromNode.y + (toNode.y - fromNode.y) * alpha
		local tread = routePart(
			"AdventureStep_" .. segmentIndex .. "_" .. step,
			Vector3.new(9, 0.7, 8),
			Vector3.new(x, y - 0.35, z),
			(step % 2 == 0) and blue or purple,
			Enum.Material.SmoothPlastic
		)
		tread.Orientation = Vector3.new(0, 45, 0)
	end
	local dx = toNode.x - fromNode.x
	local dz = toNode.z - fromNode.z
	local length = math.sqrt(dx * dx + dz * dz)
	local bridge = routePart(
		"AdventurePath_" .. segmentIndex,
		Vector3.new(length, 0.3, 5.5),
		Vector3.new((fromNode.x + toNode.x) / 2, (fromNode.y + toNode.y) / 2 - 0.45, (fromNode.z + toNode.z) / 2),
		dark,
		Enum.Material.Metal
	)
	bridge.Orientation = Vector3.new(0, 45, 0)
	bridge.CanCollide = false
end

for index = 1, #routeNodes - 1 do
	makeSteps(routeNodes[index], routeNodes[index + 1], index)
end

-- Snow crystals, candy props, jungle palms, and canyon rocks make the route
-- read as distinct 3D regions from a distance without covering the walkways.
for i = 1, 5 do
	local x = -72 + i * 5
	local crystal = routePart("IceCrystal_" .. i, Vector3.new(3, 9 + (i % 3) * 2, 3), Vector3.new(x, 7, 60 + (i % 2) * 5), iceLight, Enum.Material.Glass)
	crystal.Transparency = 0.2
	crystal.Orientation = Vector3.new(0, i * 19, (i % 2 == 0) and 8 or -8)
end
for i = 1, 4 do
	local x = -43 + i * 5
	local lollipop = routePart("CandyPop_" .. i, Vector3.new(1.2, 6, 1.2), Vector3.new(x, 5.3, 28 + (i % 2) * 6), (i % 2 == 0) and yellow or ice, Enum.Material.Metal)
	local candyTop = routePart("CandyPopTop_" .. i, Vector3.new(4, 4, 1), lollipop.Position + Vector3.new(0, 4, 0), (i % 2 == 0) and candy or purple, Enum.Material.Neon)
	candyTop.Shape = Enum.PartType.Ball
end
for i = 1, 4 do
	local x = 28 + i * 5
	local trunk = routePart("JunglePalmTrunk_" .. i, Vector3.new(2, 10, 2), Vector3.new(x, 5, -39 - (i % 2) * 5), Color3.fromRGB(125, 80, 48), Enum.Material.Wood)
	local crown = routePart("JunglePalmCrown_" .. i, Vector3.new(8, 4, 8), trunk.Position + Vector3.new(0, 6, 0), leafLight, Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
end
for i = 1, 4 do
	local rockPart = routePart("CanyonRock_" .. i, Vector3.new(7, 8 + i % 2 * 3, 7), Vector3.new(55 + i * 4, 4 + i % 2, -62 + i * 3), (i % 2 == 0) and coral or Color3.fromRGB(185, 83, 76), Enum.Material.Slate)
	rockPart.Orientation = Vector3.new(0, i * 25, (i % 2 == 0) and 8 or -8)
end

-- Central star emblem details continue over the larger plaza.
makePart("Star_Center", Vector3.new(20, 0.35, 20), Vector3.new(0, 2.9, 0), yellow, Enum.Material.Neon)
makePart("Star_Core", Vector3.new(10, 0.9, 10), Vector3.new(0, 3.5, 0), dark, Enum.Material.Metal)

-- Entrance gate, with the title plate floating above the arch.
local gateZ = -78
local openingWidth = 34
local pillarWidth = 6
local pillarHeight = 20
local topHeight = 6
makePart("Gate_LeftPillar", Vector3.new(pillarWidth, pillarHeight, 6), Vector3.new(-openingWidth / 2 - pillarWidth / 2, pillarHeight / 2, gateZ), blue)
makePart("Gate_RightPillar", Vector3.new(pillarWidth, pillarHeight, 6), Vector3.new(openingWidth / 2 + pillarWidth / 2, pillarHeight / 2, gateZ), purple)
makePart("Gate_Top", Vector3.new(openingWidth + pillarWidth, topHeight, 6), Vector3.new(0, pillarHeight + topHeight / 2, gateZ), dark)

local titlePlate = makePart("Gate_TitlePlate", Vector3.new(34, 7, 1), Vector3.new(0, 27, gateZ - 3.6), dark)
local titleGui = Instance.new("SurfaceGui")
titleGui.Name = "FloatingBaseTitle"
titleGui.Face = Enum.NormalId.Front
titleGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
titleGui.PixelsPerStud = 40
titleGui.AlwaysOnTop = true
titleGui.Parent = titlePlate

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "BRAWL HUB"
title.TextColor3 = Color3.fromRGB(255, 230, 95)
title.TextStrokeColor3 = Color3.fromRGB(25, 12, 50)
title.TextStrokeTransparency = 0
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = titleGui

-- A clear path from the central emblem to the gate.
local pathZPositions = { -16, -28, -40, -52, -64 }
for index, z in ipairs(pathZPositions) do
	local tileColor = if index % 2 == 0 then blue else purple
	makePart("GatePathTile_" .. index, Vector3.new(12, 0.18, 8), Vector3.new(0, 0.12, z), tileColor)
end

-- Training corner on the right rear side of the hub.
local training = Instance.new("Folder")
training.Name = "TrainingCorner"
training.Parent = world

makePart("TrainingMat", Vector3.new(52, 0.4, 42), Vector3.new(55, 0.3, 48), blue, Enum.Material.SmoothPlastic, training)
makePart("TrainingMat_Inset", Vector3.new(44, 0.25, 34), Vector3.new(55, 0.55, 48), purple, Enum.Material.SmoothPlastic, training)

local function makeTarget(name, x, z, targetColor)
	makePart(name .. "_Stand", Vector3.new(3, 6, 3), Vector3.new(x, 3, z), dark, Enum.Material.Wood, training)
	makePart(name .. "_Body", Vector3.new(8, 8, 2), Vector3.new(x, 9, z), targetColor, Enum.Material.SmoothPlastic, training)
	makePart(name .. "_Bullseye", Vector3.new(3, 3, 0.5), Vector3.new(x, 9, z - 1.25), yellow, Enum.Material.Neon, training)
end

makeTarget("Target_Left", 40, 34, green)
makeTarget("Target_Center", 55, 34, Color3.fromRGB(235, 90, 75))
makeTarget("Target_Right", 70, 34, green)

-- Decorative supply crates.
local function makeCrate(name, position, accent)
	local crate = Instance.new("Model")
	crate.Name = name
	crate.Parent = training
	makePart("Body", Vector3.new(8, 8, 8), position, Color3.fromRGB(174, 95, 45), Enum.Material.WoodPlanks, crate)
	makePart("TopStripe", Vector3.new(8.2, 1, 1.2), position + Vector3.new(0, 0, -2), accent, Enum.Material.SmoothPlastic, crate)
	makePart("SideStripe", Vector3.new(1.2, 1, 8.2), position + Vector3.new(2, 0, 0), accent, Enum.Material.SmoothPlastic, crate)
end

makeCrate("SupplyCrate_Blue", Vector3.new(34, 4.1, 61), blue)
makeCrate("SupplyCrate_Purple", Vector3.new(76, 4.1, 61), purple)

-- Training sign now stands on two posts at the front edge of the training mat.
local signZ = 72
local signWidth = 32
local signHeight = 6
makePart("TrainingSign_LeftPost", Vector3.new(2, 8, 2), Vector3.new(55 - signWidth / 2 + 1, 4, signZ), dark, Enum.Material.SmoothPlastic, training)
makePart("TrainingSign_RightPost", Vector3.new(2, 8, 2), Vector3.new(55 + signWidth / 2 - 1, 4, signZ), dark, Enum.Material.SmoothPlastic, training)
local trainingSign = makePart("TrainingSign", Vector3.new(signWidth, signHeight, 1), Vector3.new(55, 8 + signHeight / 2, signZ), dark, Enum.Material.SmoothPlastic, training)

local trainingGui = Instance.new("SurfaceGui")
trainingGui.Name = "TrainingLabel"
trainingGui.Face = Enum.NormalId.Front
trainingGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
trainingGui.PixelsPerStud = 40
trainingGui.AlwaysOnTop = true
trainingGui.Parent = trainingSign

local trainingText = Instance.new("TextLabel")
trainingText.Name = "Title"
trainingText.Size = UDim2.fromScale(1, 1)
trainingText.BackgroundTransparency = 1
trainingText.Text = "ТРЕНИРОВКА"
trainingText.TextColor3 = yellow
trainingText.TextStrokeColor3 = dark
trainingText.TextStrokeTransparency = 0
trainingText.TextScaled = true
trainingText.Font = Enum.Font.GothamBlack
trainingText.Parent = trainingGui

-- Hub decorations along the perimeter. Keep the middle and gate path clear.
local function makeBarrel(name, x, z, accent)
	local barrel = Instance.new("Part")
	barrel.Name = name
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(8, 6, 6)
	barrel.Position = Vector3.new(x, 4, z)
	barrel.Orientation = Vector3.new(0, 0, 90)
	barrel.Anchored = true
	barrel.Material = Enum.Material.WoodPlanks
	barrel.Color = Color3.fromRGB(145, 82, 43)
	barrel.Parent = world
	local band = Instance.new("Part")
	band.Name = name .. "_Band"
	band.Shape = Enum.PartType.Cylinder
	band.Size = Vector3.new(1, 6.2, 6.2)
	band.Position = Vector3.new(x, 4, z)
	band.Orientation = Vector3.new(0, 0, 90)
	band.Anchored = true
	band.Material = Enum.Material.Metal
	band.Color = accent
	band.Parent = world
end

local function makeHubFlag(name, x, z, flagColor)
	makePart(name .. "_Pole", Vector3.new(1, 18, 1), Vector3.new(x, 9, z), dark, Enum.Material.Metal)
	makePart(name .. "_Cloth", Vector3.new(10, 6, 0.5), Vector3.new(x + 5, 14, z), flagColor, Enum.Material.SmoothPlastic)
	makePart(name .. "_Base", Vector3.new(5, 1, 5), Vector3.new(x, 0.5, z), dark, Enum.Material.Metal)
end

makeCrate("HubCrate_LeftFront", Vector3.new(-72, 4.1, 62), blue)
makeCrate("HubCrate_LeftBack", Vector3.new(-72, 4.1, -55), purple)
makeCrate("HubCrate_RightBack", Vector3.new(72, 4.1, -55), yellow)
makeBarrel("HubBarrel_Left", -78, 20, blue)
makeBarrel("HubBarrel_Right", 78, -18, purple)
makeHubFlag("HubFlag_LeftFront", -76, 78, blue)
makeHubFlag("HubFlag_RightFront", 76, 78, purple)
makeHubFlag("HubFlag_LeftBack", -76, -75, yellow)
makeHubFlag("HubFlag_RightBack", 76, -75, blue)

-- Six personal base plots around the central hub.
-- Each plot has placeholder spaces for a case and collectible cards.
local personalBases = Instance.new("Folder")
personalBases.Name = "PersonalBases"
personalBases.Parent = world

local plotSpecs = {
	{ x = -170, z = -125, color = blue },
	{ x = 0, z = -190, color = purple },
	{ x = 170, z = -125, color = yellow },
	{ x = -170, z = 125, color = green },
	{ x = 0, z = 190, color = Color3.fromRGB(235, 90, 75) },
	{ x = 170, z = 125, color = Color3.fromRGB(30, 200, 190) },
}

local baseSlots = {}
local baseByUserId = {}
local upgradePrompts = {}

local upgradeConfig = {
	Speed = { attribute = "SpeedLevel", baseCost = 100, maximum = 5, displayName = "СКОРОСТЬ" },
	Money = { attribute = "MoneyLevel", baseCost = 150, maximum = 5, displayName = "ДЕНЬГИ" },
	Luck = { attribute = "LuckLevel", baseCost = 125, maximum = 5, displayName = "УДАЧА" },
}

-- A one-off visual prototype for slot 1 (the first slot assigned to a player).
-- It keeps the regular base systems,
-- but dresses the plot as a small cartoon desert arena / canyon outpost.
local function buildDesertBase(center, parent)
	local wood = Color3.fromRGB(133, 72, 43)
	local woodLight = Color3.fromRGB(190, 111, 57)
	local red = Color3.fromRGB(230, 69, 75)
	local cream = Color3.fromRGB(255, 235, 189)
	local rock = Color3.fromRGB(179, 79, 77)
	local rockLight = Color3.fromRGB(225, 112, 91)
	local teal = Color3.fromRGB(74, 203, 173)
	local function part(name, size, offset, color, material, shape, collide)
		local p = makePart(name, size, center + offset, color, material or Enum.Material.SmoothPlastic, parent)
		if shape then p.Shape = shape end
		p.CanCollide = collide == true
		return p
	end
	local function sign(name, text, offset, size)
		local board = part(name, size, offset, dark, Enum.Material.SmoothPlastic, nil, false)
		local gui = Instance.new("SurfaceGui")
		gui.Name = name .. "Gui"
		gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 35
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = yellow
		label.TextStrokeColor3 = dark
		label.TextStrokeTransparency = 0.25
		label.TextScaled = true
		label.Font = Enum.Font.GothamBlack
		label.Parent = gui
		return board
	end

	-- Sandy plaza with a bright, chunky star badge in the middle.
	part("DesertPlaza", Vector3.new(72, 0.35, 37), Vector3.new(0, 0.43, 24), Color3.fromRGB(255, 202, 105), Enum.Material.Sand, nil, false)
	for i, tile in ipairs({
		{ -22, 0, 14, blue }, { 22, 0, 14, purple }, { -22, 0, 34, red }, { 22, 0, 34, yellow },
	}) do
		part("PlazaTile_" .. i, Vector3.new(17, 0.18, 17), Vector3.new(tile[1], 0.68, tile[3]), tile[4], Enum.Material.SmoothPlastic, nil, false)
	end
	part("PlazaEmblemCenter", Vector3.new(10, 0.35, 10), Vector3.new(0, 0.9, 24), yellow, Enum.Material.Neon, nil, false)
	for i, offset in ipairs({ Vector3.new(0, 0.92, 13), Vector3.new(0, 0.92, 35), Vector3.new(-11, 0.92, 24), Vector3.new(11, 0.92, 24) }) do
		part("PlazaStarRay_" .. i, Vector3.new(8, 0.3, 8), offset, yellow, Enum.Material.Neon, nil, false).Orientation = Vector3.new(0, 45, 0)
	end

	-- Two-storey arena facade, side towers, broad stairs and a purple portal.
	part("ArenaFoundation", Vector3.new(38, 1.5, 18), Vector3.new(0, 1, -35), dark, Enum.Material.Slate, nil, true)
	part("ArenaLowerWall", Vector3.new(31, 8, 10), Vector3.new(0, 5.5, -38), Color3.fromRGB(38, 48, 112), nil, nil, true)
	part("ArenaUpperWall", Vector3.new(27, 7, 8), Vector3.new(0, 13, -39), dark, nil, nil, true)
	part("ArenaRoofTrim", Vector3.new(40, 1.2, 20), Vector3.new(0, 17, -35), blue, Enum.Material.Metal, nil, true)
	for _, side in ipairs({ -1, 1 }) do
		part("ArenaTower_" .. side, Vector3.new(8, 20, 12), Vector3.new(side * 18, 10, -35), blue, Enum.Material.Slate, nil, true)
		part("ArenaTowerCap_" .. side, Vector3.new(10, 2, 14), Vector3.new(side * 18, 21, -35), purple, nil, nil, true)
		part("ArenaTowerGlow_" .. side, Vector3.new(0.45, 7, 5), Vector3.new(side * 13.85, 9, -28.8), teal, Enum.Material.Neon, nil, false)
	end
	for step = 1, 9 do
		part("ArenaStair_" .. step, Vector3.new(26, 0.55, 2.4), Vector3.new(0, 0.72 + (10 - step) * 0.48, -22 + step * 2.2), if step % 2 == 0 then blue else Color3.fromRGB(75, 85, 155), nil, nil, true)
	end
	local portal = part("ArenaPortal", Vector3.new(10, 11, 0.8), Vector3.new(0, 6.7, -25), purple, Enum.Material.Neon, nil, false)
	portal.Transparency = 0.18
	part("PortalFrameTop", Vector3.new(13, 1, 1.5), Vector3.new(0, 12.6, -25), yellow, Enum.Material.Neon, nil, false)
	for _, side in ipairs({ -1, 1 }) do
		part("PortalFrameSide_" .. side, Vector3.new(1, 12, 1.5), Vector3.new(side * 6.2, 6.5, -25), yellow, Enum.Material.Neon, nil, false)
		local lamp = part("ArenaLamp_" .. side, Vector3.new(1.8, 4, 1.8), Vector3.new(side * 9, 3, -23), wood, nil, nil, false)
		part("ArenaLampGlow_" .. side, Vector3.new(2.3, 2.3, 2.3), lamp.Position - center + Vector3.new(0, 2.4, 0), yellow, Enum.Material.Neon, Enum.PartType.Ball, false)
	end
	local emblem = sign("ArenaEmblem", "★", Vector3.new(0, 13, -34), Vector3.new(8, 7, 0.5))
	emblem.Color = purple
	for i, x in ipairs({ -11, 11 }) do
		local banner = part("ArenaBanner_" .. i, Vector3.new(3.2, 8, 0.35), Vector3.new(x, 11, -29), if i == 1 then blue else purple, nil, nil, false)
		local decal = Instance.new("SurfaceGui")
		decal.Face = Enum.NormalId.Back
		decal.Parent = banner
		local skull = Instance.new("TextLabel")
		skull.Size = UDim2.fromScale(1, 1)
		skull.BackgroundTransparency = 1
		skull.Text = "☠"
		skull.TextColor3 = yellow
		skull.TextScaled = true
		skull.Font = Enum.Font.GothamBlack
		skull.Parent = decal
	end
	sign("ArenaTitle", "ARENA • OUTPOST", Vector3.new(0, 18.2, -25), Vector3.new(22, 3, 0.5))

	-- Small wooden side shops with striped awnings, lit windows and readable signs.
	for _, side in ipairs({ -1, 1 }) do
		local x = side * 43
		local shopName = if side < 0 then "LeftShop" else "RightShop"
		part(shopName .. "Floor", Vector3.new(19, 1, 16), Vector3.new(x, 0.9, -16), wood, Enum.Material.WoodPlanks, nil, true)
		part(shopName .. "Back", Vector3.new(18, 10, 1), Vector3.new(x, 6, -22.5), wood, Enum.Material.WoodPlanks, nil, true)
		part(shopName .. "Left", Vector3.new(1, 10, 13), Vector3.new(x - 8.5, 6, -16), wood, Enum.Material.WoodPlanks, nil, true)
		part(shopName .. "Right", Vector3.new(1, 10, 13), Vector3.new(x + 8.5, 6, -16), wood, Enum.Material.WoodPlanks, nil, true)
		part(shopName .. "Counter", Vector3.new(14, 2, 2), Vector3.new(x, 2.5, -10), woodLight, Enum.Material.WoodPlanks, nil, true)
		for stripe = 1, 7 do
			part(shopName .. "AwningStripe_" .. stripe, Vector3.new(2.8, 0.7, 9), Vector3.new(x - 8.4 + stripe * 2.4, 11.2, -15), if stripe % 2 == 0 then cream else red, nil, nil, false)
		end
		part(shopName .. "Awning", Vector3.new(20, 0.5, 10), Vector3.new(x, 10.8, -15), red, nil, nil, false)
		part(shopName .. "Window", Vector3.new(0.25, 3.5, 5), Vector3.new(x + side * 6.8, 6.5, -12), yellow, Enum.Material.Neon, nil, false)
		local shopSign = sign(shopName .. "Sign", if side < 0 then "SUPPLY" else "UPGRADES", Vector3.new(x, 12.3, -11), Vector3.new(15, 3, 0.5))
		shopSign.Color = dark
		for crate = 1, 3 do
			local crateOffset = Vector3.new(x + (crate - 2) * 5, 2.2, -7 + (crate % 2) * 2)
			part(shopName .. "Crate_" .. crate, Vector3.new(3.5, 3.5, 3.5), crateOffset, if crate % 2 == 0 then woodLight else wood, Enum.Material.WoodPlanks, nil, true)
		end
	end

	-- Low-poly canyon rocks and cacti around the rim, leaving the entrance side open.
	for i = 1, 14 do
		local x = -56 + (i - 1) * 8
		if x < -47 or x > -25 then
			local height = 8 + (i % 4) * 2
			local boulder = part("CanyonBackRock_" .. i, Vector3.new(8 + (i % 3), height, 7), Vector3.new(x, height / 2 + 0.4, -49), if i % 2 == 0 then rock else rockLight, Enum.Material.Slate, nil, true)
			boulder.Orientation = Vector3.new(0, (i * 23) % 360, (i % 3 - 1) * 5)
		end
	end
	for i, x in ipairs({ -54, -38, 38, 54 }) do
		local z = if i < 3 then 43 else 40
		part("CactusTrunk_" .. i, Vector3.new(2.4, 7 + (i % 2) * 2, 2.4), Vector3.new(x, 4.2, z), green, nil, Enum.PartType.Cylinder, false)
		local arm = part("CactusArm_" .. i, Vector3.new(1.8, 4, 1.8), Vector3.new(x + 1.7, 4.8, z), green, nil, Enum.PartType.Cylinder, false)
		arm.Orientation = Vector3.new(0, 0, 90)
	end
	for i = 1, 5 do
		local barrel = part("DesertBarrel_" .. i, Vector3.new(3, 4, 3), Vector3.new(-51 + i * 5, 2.4, 38), if i % 2 == 0 then purple else wood, Enum.Material.WoodPlanks, Enum.PartType.Cylinder, true)
		barrel.Orientation = Vector3.new(0, 0, 90)
	end

	-- Purple water tower at the rear-right corner and small pennants.
	part("WaterTowerLeg_A", Vector3.new(2, 15, 2), Vector3.new(53, 7.5, -39), purple, Enum.Material.Metal, nil, true)
	part("WaterTowerLeg_B", Vector3.new(2, 15, 2), Vector3.new(61, 7.5, -39), purple, Enum.Material.Metal, nil, true)
	part("WaterTowerTank", Vector3.new(13, 7, 10), Vector3.new(57, 17, -39), purple, Enum.Material.Metal, nil, true)
	part("WaterTowerGlow", Vector3.new(12, 1, 9), Vector3.new(57, 15, -39), teal, Enum.Material.Neon, nil, false)
	for i = 1, 4 do
		local flag = part("CanyonPennant_" .. i, Vector3.new(3.5, 2.3, 0.25), Vector3.new(-47 + i * 18, 15 + (i % 2), -45), if i % 2 == 0 then blue else red, nil, nil, false)
		flag.Orientation = Vector3.new(0, 15, 0)
	end
end

local function createPersonalBase(index, spec)
	local model = Instance.new("Model")
	model.Name = "PlayerBase_" .. index
	model:SetAttribute("SlotNumber", index)
	model:SetAttribute("OwnerUserId", 0)
	model.Parent = personalBases

	local center = Vector3.new(spec.x, 0, spec.z)
	local desertPrototype = index == 1
	makePart("BasePlatform", Vector3.new(128, 2, 108), center + Vector3.new(0, -1, 0), Color3.fromRGB(65, 70, 95), Enum.Material.Slate, model)
	makePart("BaseColorInset", Vector3.new(120, 0.35, 100), center + Vector3.new(0, 0.2, 0), if desertPrototype then sand else spec.color, Enum.Material.SmoothPlastic, model)
	makePart("BaseBorder_Front", Vector3.new(128, 0.7, 3), center + Vector3.new(0, 0.25, 52.5), yellow, Enum.Material.SmoothPlastic, model)
	makePart("BaseBorder_Back", Vector3.new(128, 0.7, 3), center + Vector3.new(0, 0.25, -52.5), yellow, Enum.Material.SmoothPlastic, model)
	local spawnPad = makePart("PlayerSpawnPoint", Vector3.new(12, 0.35, 12), center + Vector3.new(0, 0.55, 38), yellow, Enum.Material.SmoothPlastic, model)

	-- Put the owner sign at the entrance where the path meets this plot.
	local signPosition
	local signSize
	local signYaw = 0
	local postOffsets
	if spec.x == 0 then
		local inward = if spec.z < 0 then 1 else -1
		local sideOffset = 24
		signPosition = center + Vector3.new(sideOffset, 8, inward * 52)
		signSize = Vector3.new(24, 5, 1)
		postOffsets = { Vector3.new(-10, -4, 0), Vector3.new(10, -4, 0) }
		signYaw = if spec.z < 0 then 180 else 0
	else
		local inwardX = if spec.x < 0 then 1 else -1
		local inwardZ = if spec.z < 0 then 1 else -1
		local sideOffset = -inwardZ * 24
		signPosition = center + Vector3.new(inwardX * 72, 8, inwardZ * 35 + sideOffset)
		signSize = Vector3.new(1, 5, 22)
		signYaw = if spec.x < 0 then -90 else 90
		postOffsets = { Vector3.new(0, -4, -9), Vector3.new(0, -4, 9) }
	end
	local sign = makePart("OwnerSign", signSize, signPosition, dark, Enum.Material.SmoothPlastic, model)
	sign.Orientation = Vector3.new(0, signYaw, 0)
	sign.CanCollide = false
	for postIndex, offset in ipairs(postOffsets) do
		makePart("OwnerSignPost_" .. postIndex, Vector3.new(1.5, 8, 1.5), signPosition + offset, dark, Enum.Material.Metal, model)
	end
	local signGui = Instance.new("BillboardGui")
	signGui.Name = "OwnerDisplay"
	signGui.Size = UDim2.fromOffset(180, 30)
	signGui.StudsOffset = Vector3.new(0, 5, 0)
	signGui.MaxDistance = 280
	signGui.AlwaysOnTop = false
	signGui.Adornee = sign
	signGui.Parent = sign
	local ownerText = Instance.new("TextLabel")
	ownerText.Name = "OwnerName"
	ownerText.Size = UDim2.fromScale(1, 1)
	ownerText.BackgroundColor3 = dark
	ownerText.BackgroundTransparency = 0.3
	ownerText.Text = "БАЗА " .. index .. " • СВОБОДНА"
	ownerText.TextColor3 = yellow
	ownerText.TextStrokeColor3 = dark
	ownerText.TextStrokeTransparency = 0.3
	ownerText.TextScaled = true
	ownerText.Font = Enum.Font.GothamBlack
	ownerText.Parent = signGui

	-- Flat, colored connector from each plot toward the central hub.
	if spec.x == 0 then
		local direction = if spec.z < 0 then 1 else -1
		makePart("PathToHub", Vector3.new(16, 0.5, 78), center + Vector3.new(0, 0.25, direction * 77), spec.color, Enum.Material.SmoothPlastic, model)
	else
		local xDirection = if spec.x < 0 then 1 else -1
		local zDirection = if spec.z < 0 then 1 else -1
		makePart("PathToHub", Vector3.new(42, 0.5, 18), center + Vector3.new(xDirection * 72, 0.25, zDirection * 35), spec.color, Enum.Material.SmoothPlastic, model)
	end

	-- Card gallery: twelve display slots, ready for the player's future collection.
	local galleryCenter = if desertPrototype then Vector3.new(23, 0.85, 27) else Vector3.new(31, 0.85, -2)
	local gallery = makePart("CardGallery", Vector3.new(34, 1, 32), center + galleryCenter, dark, Enum.Material.Metal, model)
	for cardIndex = 1, 12 do
		local row = math.floor((cardIndex - 1) / 4)
		local column = (cardIndex - 1) % 4
		local cardOffset = if desertPrototype then Vector3.new(11 + column * 8, 5.5, 15 + row * 10) else Vector3.new(19 + column * 8, 5.5, -12 + row * 10)
		local card = makePart("CardDisplay_" .. cardIndex, Vector3.new(5, 8, 0.8), center + cardOffset, if desertPrototype then blue else spec.color, Enum.Material.SmoothPlastic, model)
		makePart("CardStar_" .. cardIndex, Vector3.new(2, 2, 0.3), card.Position + Vector3.new(0, 0, -0.55), yellow, Enum.Material.Neon, model)
	end

	-- Case conveyor with three static case placeholders.
	local conveyorCenter = if desertPrototype then Vector3.new(-30, 0.9, 17) else Vector3.new(-5, 0.9, -25)
	makePart("CaseConveyor", Vector3.new(62, 1.2, 10), center + conveyorCenter, dark, Enum.Material.Metal, model)
	makePart("ConveyorBelt", Vector3.new(58, 0.35, 7), center + conveyorCenter + Vector3.new(0, 0.75, 0), Color3.fromRGB(40, 45, 58), Enum.Material.SmoothPlastic, model)
	makePart("ConveyorRail_Left", Vector3.new(62, 0.8, 0.55), center + conveyorCenter + Vector3.new(0, 1.15, -4.25), blue, Enum.Material.Metal, model)
	makePart("ConveyorRail_Right", Vector3.new(62, 0.8, 0.55), center + conveyorCenter + Vector3.new(0, 1.15, 4.25), blue, Enum.Material.Metal, model)
	for rollerIndex = 1, 10 do
		local rollerX = conveyorCenter.X - 29 + (rollerIndex - 1) * 6
		local roller = makePart("ConveyorRoller_" .. rollerIndex, Vector3.new(0.55, 7.3, 0.55), center + Vector3.new(rollerX, 1.95, conveyorCenter.Z), Color3.fromRGB(115, 125, 150), Enum.Material.Metal, model)
		roller.Shape = Enum.PartType.Cylinder
		roller.Orientation = Vector3.new(90, 0, 0)
	end
	for caseIndex = 1, 3 do
		local caseX = conveyorCenter.X - 20 + (caseIndex - 1) * 20
		local caseColor = if caseIndex == 1 then blue elseif caseIndex == 2 then purple else yellow
		local case = makePart("ConveyorCase_" .. caseIndex, Vector3.new(5.2, 5.2, 5.2), center + Vector3.new(caseX, 4.4, conveyorCenter.Z), Color3.fromRGB(174, 95, 45), Enum.Material.WoodPlanks, model)
		makePart("ConveyorCaseStripe_" .. caseIndex, Vector3.new(5.35, 0.75, 0.35), case.Position + Vector3.new(0, 0, if desertPrototype then 2.8 else -2.8), caseColor, Enum.Material.Neon, model)
	end
	if desertPrototype then
		buildDesertBase(center, model)
	end

	-- Upgrade terminals are visual placeholders; upgrade logic will be added later.
	local function makeUpgradeMachine(machineName, label, zOffset, machineColor)
		local machinePosition = center + (if desertPrototype then Vector3.new(43, 4.5, zOffset + 25) else Vector3.new(-37, 4.5, zOffset + 12))
		local machine = makePart("UpgradeMachine_" .. machineName, Vector3.new(10, 9, 8), machinePosition, dark, Enum.Material.Metal, model)
		if desertPrototype then machine.Orientation = Vector3.new(0, 180, 0) end
		machine:SetAttribute("UpgradeType", machineName)
		machine:SetAttribute("BaseSlotNumber", index)
		-- Front face points toward the open center of the base (+X).
		local screenOffset = if desertPrototype then Vector3.new(-5.25, 1, 0) else Vector3.new(5.25, 1, 0)
		local screen = makePart("UpgradeScreen_" .. machineName, Vector3.new(0.5, 4.5, 6.5), machine.Position + screenOffset, machineColor, Enum.Material.Neon, model)
		local machineLabel = Instance.new("BillboardGui")
		machineLabel.Name = "UpgradeLabel_" .. machineName
		machineLabel.Size = UDim2.fromOffset(170, 38)
		machineLabel.StudsOffset = Vector3.new(0, 6.5, 0)
		machineLabel.MaxDistance = 115
		machineLabel.AlwaysOnTop = false
		machineLabel.Adornee = machine
		machineLabel.Parent = machine
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundColor3 = dark
		text.BackgroundTransparency = 0.1
		text.Text = label
		text.TextColor3 = yellow
		text.TextScaled = false
		text.TextSize = 18
		text.TextWrapped = true
		text.Font = Enum.Font.GothamBlack
		text.Parent = machineLabel
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "UpgradePrompt"
		prompt.ActionText = "Улучшить"
		prompt.ObjectText = label .. " • уровень 0/5 • " .. upgradeConfig[machineName].baseCost .. " монет"
		prompt.HoldDuration = 0.4
		prompt.MaxActivationDistance = 16
		prompt.RequiresLineOfSight = false
		prompt.Parent = machine
		table.insert(upgradePrompts, {
			prompt = prompt,
			baseSlotNumber = index,
			upgradeType = machineName,
		})
	end
	if desertPrototype then
		local title = Instance.new("BillboardGui")
		title.Name = "PrototypeBaseTitle"
		title.Size = UDim2.fromOffset(230, 42)
		title.StudsOffset = Vector3.new(0, 25, 0)
		title.MaxDistance = 180
		title.AlwaysOnTop = false
		title.Adornee = model:FindFirstChild("ArenaEmblem")
		title.Parent = model:FindFirstChild("ArenaEmblem")
		local titleText = Instance.new("TextLabel")
		titleText.Size = UDim2.fromScale(1, 1)
		titleText.BackgroundColor3 = dark
		titleText.BackgroundTransparency = 0.15
		titleText.Text = "ПРОТОТИП • БАЗА 1"
		titleText.TextColor3 = yellow
		titleText.TextStrokeColor3 = dark
		titleText.TextStrokeTransparency = 0.1
		titleText.TextScaled = true
		titleText.Font = Enum.Font.GothamBlack
		titleText.Parent = title
	end

	makeUpgradeMachine("Speed", "СКОРОСТЬ", -25, blue)
	makeUpgradeMachine("Money", "ДЕНЬГИ", -5, yellow)
	makeUpgradeMachine("Luck", "УДАЧА", 15, purple)

	local slot = {
		model = model,
		spawnPosition = spawnPad.Position + Vector3.new(0, 4, 0),
		ownerText = ownerText,
		ownerUserId = nil,
	}
	table.insert(baseSlots, slot)
	return slot
end

for index, spec in ipairs(plotSpecs) do
	createPersonalBase(index, spec)
end

-- Server-authoritative purchase handling for the three upgrade machines.
for _, entry in ipairs(upgradePrompts) do
	entry.prompt.Triggered:Connect(function(player)
		local slot = baseSlots[entry.baseSlotNumber]
		local config = upgradeConfig[entry.upgradeType]
		if not slot or slot.ownerUserId ~= player.UserId then
			return
		end

		local stats = player:FindFirstChild("leaderstats")
		local coins = stats and stats:FindFirstChild("Coins")
		if not coins or not coins:IsA("IntValue") then
			return
		end

		local currentLevel = player:GetAttribute(config.attribute) or 0
		if currentLevel >= config.maximum then
			entry.prompt.ActionText = "МАКС. УРОВЕНЬ"
			return
		end

		local cost = config.baseCost * (currentLevel + 1)
		entry.prompt.ObjectText = config.displayName .. " • уровень " .. currentLevel .. "/" .. config.maximum .. " • " .. cost .. " монет"
		if coins.Value < cost then
			entry.prompt.ActionText = "НУЖНО " .. cost .. " МОНЕТ"
			task.delay(2, function()
				if entry.prompt.Parent then
					entry.prompt.ActionText = "Улучшить"
				end
			end)
			return
		end

		coins.Value -= cost
		local newLevel = currentLevel + 1
		player:SetAttribute(config.attribute, newLevel)
		entry.prompt.ObjectText = config.displayName .. " • уровень " .. newLevel .. "/" .. config.maximum .. " • " .. (config.baseCost * (newLevel + 1)) .. " монет"
		entry.prompt.ActionText = if newLevel >= config.maximum then "МАКС. УРОВЕНЬ" else "Улучшить"

		if entry.upgradeType == "Speed" and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16 + newLevel * 2
			end
		end
	end)
end

local function assignBase(player)
	if baseByUserId[player.UserId] then
		return baseByUserId[player.UserId]
	end
	for _, slot in ipairs(baseSlots) do
		if slot.ownerUserId == nil then
			slot.ownerUserId = player.UserId
			slot.model:SetAttribute("OwnerUserId", player.UserId)
			slot.ownerText.Text = "БАЗА " .. slot.model:GetAttribute("SlotNumber") .. " • " .. player.DisplayName
			baseByUserId[player.UserId] = slot
			for _, entry in ipairs(upgradePrompts) do
				if entry.baseSlotNumber == slot.model:GetAttribute("SlotNumber") then
					local config = upgradeConfig[entry.upgradeType]
					local level = player:GetAttribute(config.attribute) or 0
					entry.prompt.ObjectText = config.displayName .. " • уровень " .. level .. "/" .. config.maximum .. " • " .. (config.baseCost * (level + 1)) .. " монет"
					entry.prompt.ActionText = if level >= config.maximum then "МАКС. УРОВЕНЬ" else "Улучшить"
				end
			end
			return slot
		end
	end
	warn("No free personal base for " .. player.Name .. "; server capacity should be set to 6")
	return nil
end

local function moveCharacterToBase(player, character)
	local slot = assignBase(player)
	if not slot then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root and player.Parent == Players then
		character:PivotTo(CFrame.new(slot.spawnPosition))
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16 + (player:GetAttribute("SpeedLevel") or 0) * 2
		end
	end
end

local function onPlayerAdded(player)
	assignBase(player)
	player:SetAttribute("SpeedLevel", player:GetAttribute("SpeedLevel") or 0)
	player:SetAttribute("MoneyLevel", player:GetAttribute("MoneyLevel") or 0)
	player:SetAttribute("LuckLevel", player:GetAttribute("LuckLevel") or 0)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	if not leaderstats:FindFirstChild("Coins") then
		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 10000 -- temporary test balance; lower this after testing the cases
		coins.Parent = leaderstats
	end
	player.CharacterAdded:Connect(function(character)
		moveCharacterToBase(player, character)
	end)
	if player.Character then
		task.spawn(moveCharacterToBase, player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	local slot = baseByUserId[player.UserId]
	if slot then
		slot.ownerUserId = nil
		slot.model:SetAttribute("OwnerUserId", 0)
		slot.ownerText.Text = "БАЗА " .. slot.model:GetAttribute("SlotNumber") .. " • СВОБОДНА"
		for _, entry in ipairs(upgradePrompts) do
			if entry.baseSlotNumber == slot.model:GetAttribute("SlotNumber") then
				local config = upgradeConfig[entry.upgradeType]
				entry.prompt.ObjectText = config.displayName .. " • уровень 0/" .. config.maximum .. " • " .. config.baseCost .. " монет"
				entry.prompt.ActionText = "Улучшить"
			end
		end
		baseByUserId[player.UserId] = nil
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- Money levels produce periodic coins; luck can double that payout.
task.spawn(function()
	while true do
		task.wait(15)
		for _, player in ipairs(Players:GetPlayers()) do
			local moneyLevel = player:GetAttribute("MoneyLevel") or 0
			if moneyLevel > 0 then
				local stats = player:FindFirstChild("leaderstats")
				local coins = stats and stats:FindFirstChild("Coins")
				if coins and coins:IsA("IntValue") then
					local payout = moneyLevel * 10
					local luckLevel = player:GetAttribute("LuckLevel") or 0
					if luckLevel > 0 and math.random() < luckLevel * 0.1 then
						payout *= 2
					end
					coins.Value += payout
				end
			end
		end
	end
end)

-- Invisible spawn point in the center.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 0.6, 0)
spawn.Anchored = true
spawn.Transparency = 1
spawn.LocalTransparencyModifier = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.AllowTeamChangeOnTouch = false
spawn.Duration = 0
spawn.Parent = world

print("Brawl Card central spawn hub created")
```

## 2. CardSystems

Создай обычный `Script` в `ServerScriptService` и назови его `CardSystems`. Замени его содержимое разделом ниже.

```lua
-- Brawl Card: server-authoritative case opening and player trading prototype.
-- Put this normal Script in ServerScriptService alongside WorldSetup.server.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("CardGameRemotes") or Instance.new("Folder")
remotes.Name = "CardGameRemotes"
remotes.Parent = ReplicatedStorage

local function getRemote(name)
	local remote = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local tradeRequest = getRemote("TradeRequest")
local tradeReply = getRemote("TradeReply")
local tradeOffer = getRemote("TradeOffer")
local tradeResult = getRemote("TradeResult")
local inventoryUpdate = getRemote("InventoryUpdate")
local caseReveal = getRemote("CaseReveal")
local setHotbar = getRemote("SetHotbar")
local placeFighter = getRemote("PlaceFighter")

local CASE_COOLDOWN = 2
local TRADE_TIMEOUT = 30
local cards = {
	{ name = "Шелли", rarity = "Обычная", color = Color3.fromRGB(65, 145, 255) },
	{ name = "Нита", rarity = "Обычная", color = Color3.fromRGB(65, 145, 255) },
	{ name = "Кольт", rarity = "Редкая", color = Color3.fromRGB(155, 80, 255) },
	{ name = "Спайк", rarity = "Эпическая", color = Color3.fromRGB(255, 150, 45) },
	{ name = "Ворон", rarity = "Легендарная", color = Color3.fromRGB(255, 215, 55) },
	{ name = "Эдгар", rarity = "Эпическая", color = Color3.fromRGB(205, 75, 245) },
}
local caseTypes = {
	Starter = { name = "СТАРТОВЫЙ КЕЙС", cost = 100, color = Color3.fromRGB(45, 130, 255), weights = { 47, 30, 16, 5, 1, 1 }, chances = "Обычн. 77% • Редк. 16% • Эпич. 6% • Лег. 1%" },
	Brawl = { name = "БРАВЛ КЕЙС", cost = 350, color = Color3.fromRGB(170, 60, 255), weights = { 29, 24, 20, 15, 6, 6 }, chances = "Обычн. 53% • Редк. 20% • Эпич. 21% • Лег. 6%" },
	Mega = { name = "МЕГА КЕЙС", cost = 900, color = Color3.fromRGB(255, 185, 35), weights = { 14, 18, 22, 24, 15, 7 }, chances = "Обычн. 32% • Редк. 22% • Эпич. 31% • Лег. 15%" },
}

local inventories = {}
local pendingRequests = {}
local activeTrades = {}
local lastCaseAt = {}
local openingCase = {}
local hotbars = {}
local firstCaseAwarded = {}
local MAX_PLACED_FIGHTERS = 12

local function send(player, message, kind)
	if player and player.Parent == Players then
		tradeResult:FireClient(player, message, kind or "info")
	end
end

local function getCoins(player)
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if coins and coins:IsA("IntValue") then return coins end
	return nil
end

local function inventoryFor(player)
	inventories[player.UserId] = inventories[player.UserId] or {}
	return inventories[player.UserId]
end

local function sendInventory(player)
	inventoryUpdate:FireClient(player, inventoryFor(player), hotbars[player.UserId] or {})
end

	local function pickCard(caseType)
	local config = caseTypes[caseType]
	local total = 0
	for index in ipairs(cards) do total += config.weights[index] end
	local roll = math.random(1, total)
	for index, card in ipairs(cards) do
		roll -= config.weights[index]
		if roll <= 0 then return card end
	end
	return cards[1]
end

local findCard

local function handleOpenCase(player, caseType, base)
	local config = caseTypes[caseType]
	if not config or not base or base:GetAttribute("OwnerUserId") ~= player.UserId then return end
	if openingCase[player.UserId] then return end
	local now = os.clock()
	if now - (lastCaseAt[player.UserId] or 0) < CASE_COOLDOWN then return end
	lastCaseAt[player.UserId] = now
	local coins = getCoins(player)
	if not coins then send(player, "Монеты пока не загрузились.", "error"); return end
	if coins.Value < config.cost then send(player, "Для этого кейса нужно " .. config.cost .. " монет.", "error"); return end
	coins.Value -= config.cost
	openingCase[player.UserId] = true
	local card
	if not firstCaseAwarded[player.UserId] then
		card = findCard("Эдгар")
		firstCaseAwarded[player.UserId] = true
	else
		card = pickCard(caseType)
	end
	caseReveal:FireClient(player, "Start", caseType, config.name, card.name, card.rarity, card.color)
	-- Reveal lasts about 8 seconds; award only after the client-side animation finishes.
	task.delay(8.5, function()
		openingCase[player.UserId] = nil
		if player.Parent ~= Players then return end
		local inventory = inventoryFor(player)
		inventory[card.name] = (inventory[card.name] or 0) + 1
		local hotbar = hotbars[player.UserId] or {}
		local equipped = false
		for _, name in pairs(hotbar) do
			if name == card.name then equipped = true; break end
		end
		if not equipped then
			local freeSlot
			for slotIndex = 1, 5 do
				if not hotbar[slotIndex] then freeSlot = slotIndex; break end
			end
			if not freeSlot then freeSlot = 5 end
			hotbar[freeSlot] = card.name
			hotbars[player.UserId] = hotbar
		end
		sendInventory(player)
		caseReveal:FireClient(player, "Result", caseType, config.name, card.name, card.rarity, card.color)
		send(player, "Выпала карточка «" .. card.name .. "» — " .. card.rarity .. "!", "success")
	end)
end

findCard = function(cardName)
	for _, card in ipairs(cards) do
		if card.name == cardName then return card end
	end
	return nil
end

setHotbar.OnServerEvent:Connect(function(player, requestedHotbar)
	if typeof(requestedHotbar) ~= "table" then return end
	local inventory = inventoryFor(player)
	local safeHotbar = {}
	local used = {}
	for index = 1, 5 do
		local cardName = requestedHotbar[index]
		if typeof(cardName) == "string" and findCard(cardName) and (inventory[cardName] or 0) > 0 and not used[cardName] then
			safeHotbar[index] = cardName
			used[cardName] = true
		end
	end
	hotbars[player.UserId] = safeHotbar
	sendInventory(player)
end)

placeFighter.OnServerEvent:Connect(function(player, cardName, requestedPosition)
	local card = findCard(cardName)
	if not card or typeof(requestedPosition) ~= "Vector3" then return end
	local inventory = inventoryFor(player)
	if (inventory[cardName] or 0) < 1 then
		send(player, "Этого бойца больше нет в инвентаре.", "error")
		return
	end
	local selectedInHotbar = false
	for _, equippedName in pairs(hotbars[player.UserId] or {}) do
		if equippedName == cardName then selectedInHotbar = true; break end
	end
	if not selectedInHotbar then
		send(player, "Сначала добавь бойца в быстрый доступ.", "error")
		return
	end
	local world = workspace:FindFirstChild("BrawlWorld")
	local bases = world and world:FindFirstChild("PersonalBases")
	local ownedBase
	if bases then
		for _, base in ipairs(bases:GetChildren()) do
			if base:GetAttribute("OwnerUserId") == player.UserId then ownedBase = base; break end
		end
	end
	local platform = ownedBase and ownedBase:FindFirstChild("BasePlatform")
	if not platform or not platform:IsA("BasePart") then return end
	local localPosition = platform.CFrame:PointToObjectSpace(requestedPosition)
	if math.abs(localPosition.X) > platform.Size.X / 2 - 6 or math.abs(localPosition.Z) > platform.Size.Z / 2 - 6 then
		send(player, "Поставить бойца можно только внутри своей базы.", "error")
		return
	end
	local floorY = platform.Position.Y + platform.Size.Y / 2
	if requestedPosition.Y < floorY - 0.2 or requestedPosition.Y > floorY + 1 then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - requestedPosition).Magnitude > 120 then return end
	local placedFolder = ownedBase:FindFirstChild("PlacedFighters")
	if not placedFolder then
		placedFolder = Instance.new("Folder")
		placedFolder.Name = "PlacedFighters"
		placedFolder.Parent = ownedBase
	end
	if #placedFolder:GetChildren() >= MAX_PLACED_FIGHTERS then
		send(player, "На базе уже размещено максимальное число бойцов.", "error")
		return
	end
	local figure = Instance.new("Model")
	figure.Name = "Fighter_" .. cardName
	figure:SetAttribute("FighterName", cardName)
	figure.Parent = placedFolder
	local center = Vector3.new(requestedPosition.X, floorY + 2.4, requestedPosition.Z)
	local bodyColor = Color3.fromRGB(48, 42, 72)
	local function figurePart(partName, size, offset, color, material)
		local part = Instance.new("Part")
		part.Name = partName
		part.Size = size
		part.CFrame = CFrame.new(center + offset)
		part.Anchored = true
		part.CanCollide = false
		part.Material = material or Enum.Material.SmoothPlastic
		part.Color = color
		part.Parent = figure
		return part
	end
	figurePart("Body", Vector3.new(2, 2.4, 1.1), Vector3.new(0, 0, 0), bodyColor)
	figurePart("Head", Vector3.new(1.6, 1.6, 1.4), Vector3.new(0, 2, 0), Color3.fromRGB(255, 190, 125))
	figurePart("Hair", Vector3.new(1.8, 0.6, 1.5), Vector3.new(0, 2.9, 0), card.color)
	figurePart("LeftLeg", Vector3.new(0.7, 1.2, 0.9), Vector3.new(-0.5, -1.8, 0), card.color)
	figurePart("RightLeg", Vector3.new(0.7, 1.2, 0.9), Vector3.new(0.5, -1.8, 0), card.color)
	figurePart("LeftArm", Vector3.new(0.65, 1.7, 0.8), Vector3.new(-1.3, 0, 0), bodyColor)
	figurePart("RightArm", Vector3.new(0.65, 1.7, 0.8), Vector3.new(1.3, 0, 0), bodyColor)
	local emblem = figurePart("Emblem", Vector3.new(0.7, 0.7, 0.16), Vector3.new(0, 0.3, 0.62), card.color, Enum.Material.Neon)
	if cardName == "Эдгар" then
		figurePart("Scarf", Vector3.new(2.2, 0.35, 0.45), Vector3.new(0, 0.95, 0.8), Color3.fromRGB(185, 55, 235))
		figurePart("ScarfTail", Vector3.new(0.5, 1.8, 0.35), Vector3.new(0.75, -0.15, 1), Color3.fromRGB(185, 55, 235))
	end
	local glow = Instance.new("PointLight")
	glow.Color = card.color
	glow.Brightness = 1.5
	glow.Range = 12
	glow.Parent = emblem
	inventory[cardName] -= 1
	if inventory[cardName] <= 0 then
		inventory[cardName] = nil
		for slotIndex, equippedName in pairs(hotbars[player.UserId] or {}) do
			if equippedName == cardName then hotbars[player.UserId][slotIndex] = nil end
		end
	end
	sendInventory(player)
	send(player, cardName .. " теперь стоит на твоей базе.", "success")
end)

tradeRequest.OnServerEvent:Connect(function(player, targetUserId)
	if typeof(targetUserId) ~= "number" or targetUserId == player.UserId then return end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target then send(player, "Игрок уже вышел.", "error"); return end
	if activeTrades[player.UserId] or activeTrades[target.UserId] then
		send(player, "Один из игроков уже участвует в обмене.", "error"); return
	end
	pendingRequests[target.UserId] = { from = player, expires = os.clock() + TRADE_TIMEOUT }
	tradeRequest:FireClient(target, player.UserId, player.DisplayName)
	send(player, "Запрос на обмен отправлен игроку " .. target.DisplayName .. ".")
	task.delay(TRADE_TIMEOUT, function()
		local request = pendingRequests[target.UserId]
		if request and request.from == player then
			pendingRequests[target.UserId] = nil
			send(player, "Запрос на обмен истёк.", "error")
			send(target, "Запрос на обмен истёк.", "error")
		end
	end)
end)

tradeReply.OnServerEvent:Connect(function(target, accepted)
	local request = pendingRequests[target.UserId]
	if not request then return end
	pendingRequests[target.UserId] = nil
	local from = request.from
	if os.clock() > request.expires or not from or from.Parent ~= Players then
		send(target, "Запрос уже недействителен.", "error"); return
	end
	if accepted ~= true then send(from, target.DisplayName .. " отклонил обмен.", "error"); return end
	if activeTrades[target.UserId] or activeTrades[from.UserId] then return end
	local tradeId = tostring(target.UserId) .. ":" .. tostring(from.UserId) .. ":" .. tostring(os.clock())
	local trade = { id = tradeId, a = from, b = target, offers = {}, submitted = {} }
	activeTrades[from.UserId] = trade
	activeTrades[target.UserId] = trade
	tradeOffer:FireClient(from, tradeId, target.UserId, target.DisplayName)
	tradeOffer:FireClient(target, tradeId, from.UserId, from.DisplayName)
	send(from, "Обмен начался. Выбери карточку и количество в окне обмена.")
	send(target, "Обмен начался. Выбери карточку и количество в окне обмена.")
	task.delay(120, function()
		if activeTrades[from.UserId] == trade then
			activeTrades[from.UserId], activeTrades[target.UserId] = nil, nil
			send(from, "Обмен отменён: время вышло.", "error")
			send(target, "Обмен отменён: время вышло.", "error")
		end
	end)
end)

tradeOffer.OnServerEvent:Connect(function(player, tradeId, cardName, amount)
	local trade = activeTrades[player.UserId]
	if not trade or trade.id ~= tradeId or trade.submitted[player.UserId] then
		return
	end
	if typeof(cardName) ~= "string" or #cardName > 40 or typeof(amount) ~= "number" or amount % 1 ~= 0 or amount < 0 or amount > 99 then
		return
	end
	local inventory = inventoryFor(player)
	if amount > 0 and (inventory[cardName] or 0) < amount then
		send(player, "У тебя нет столько таких карточек.", "error")
		return
	end
	local offeredCardName = cardName
	if amount == 0 then
		offeredCardName = ""
	end
	trade.offers[player.UserId] = { cardName = offeredCardName, amount = amount }
	trade.submitted[player.UserId] = true
	local partner
	if trade.a == player then
		partner = trade.b
	else
		partner = trade.a
	end
	tradeResult:FireClient(partner, player.DisplayName .. " подготовил предложение. Ждём твоё предложение.")
	send(player, "Предложение записано. Ждём второго игрока.")
	if trade.submitted[trade.a.UserId] and trade.submitted[trade.b.UserId] then
		local offerA, offerB = trade.offers[trade.a.UserId], trade.offers[trade.b.UserId]
		local invA, invB = inventoryFor(trade.a), inventoryFor(trade.b)
		local invalidOfferA = offerA.amount > 0 and (invA[offerA.cardName] or 0) < offerA.amount
		local invalidOfferB = offerB.amount > 0 and (invB[offerB.cardName] or 0) < offerB.amount
		if invalidOfferA or invalidOfferB then
			send(trade.a, "Обмен отменён: количество карточек изменилось.", "error")
			send(trade.b, "Обмен отменён: количество карточек изменилось.", "error")
		else
			if offerA.amount > 0 then
				invA[offerA.cardName] = invA[offerA.cardName] - offerA.amount
				if invA[offerA.cardName] == 0 then invA[offerA.cardName] = nil end
			end
			if offerB.amount > 0 then
				invB[offerB.cardName] = invB[offerB.cardName] - offerB.amount
				if invB[offerB.cardName] == 0 then invB[offerB.cardName] = nil end
			end
			if offerA.amount > 0 then
				invB[offerA.cardName] = (invB[offerA.cardName] or 0) + offerA.amount
			end
			if offerB.amount > 0 then
				invA[offerB.cardName] = (invA[offerB.cardName] or 0) + offerB.amount
			end
			send(trade.a, "Обмен завершён.", "success")
			send(trade.b, "Обмен завершён.", "success")
			sendInventory(trade.a)
			sendInventory(trade.b)
		end
		activeTrades[trade.a.UserId], activeTrades[trade.b.UserId] = nil, nil
	end
end)

local function addCasePrompt()
	local world = workspace:WaitForChild("BrawlWorld", 30)
	if not world then warn("CardSystems: BrawlWorld wasn't found"); return end
	local bases = world:WaitForChild("PersonalBases", 30)
	if not bases then warn("CardSystems: PersonalBases wasn't found"); return end
	for _, base in ipairs(bases:GetChildren()) do
		local conveyor = base:FindFirstChild("CaseConveyor")
		if conveyor then
			for index, caseType in ipairs({ "Starter", "Brawl", "Mega" }) do
				local config = caseTypes[caseType]
				local casePart = base:FindFirstChild("ConveyorCase_" .. index)
				if casePart and casePart:IsA("BasePart") then
					casePart.Color = config.color
					casePart.Material = Enum.Material.Metal
					casePart:SetAttribute("CaseType", caseType)
					casePart:SetAttribute("BaseSlotNumber", base:GetAttribute("SlotNumber"))
					local details = Instance.new("Folder")
					details.Name = caseType .. "CaseDetails"
					details.Parent = base
					local function detail(name, size, offset, color, shape, material)
						local part = Instance.new("Part")
						part.Name, part.Size = name, size
						part.Position = casePart.Position + offset
						part.Anchored, part.CanCollide = true, false
						part.Material, part.Color = material or Enum.Material.Metal, color
						if shape then part.Shape = shape end
						part.Parent = details
						return part
					end
					detail("TopPlate", Vector3.new(5.8, 0.35, 5.8), Vector3.new(0, 2.75, 0), Color3.fromRGB(255, 220, 70), nil, Enum.Material.Neon)
					if caseType == "Starter" then
						detail("SignalAntenna", Vector3.new(0.35, 1.8, 0.35), Vector3.new(0, 3.7, 0), Color3.fromRGB(225, 235, 255))
						detail("SignalOrb", Vector3.new(1.1, 1.1, 1.1), Vector3.new(0, 4.8, 0), config.color, Enum.PartType.Ball, Enum.Material.Neon)
					elseif caseType == "Brawl" then
						detail("LeftWing", Vector3.new(0.6, 4, 2.8), Vector3.new(-3.1, 0.5, 0), Color3.fromRGB(255, 220, 70))
						detail("RightWing", Vector3.new(0.6, 4, 2.8), Vector3.new(3.1, 0.5, 0), Color3.fromRGB(255, 220, 70))
					else
						detail("TopOrb", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 4.1, 0), Color3.fromRGB(255, 225, 80), Enum.PartType.Ball, Enum.Material.Neon)
						detail("SideCoreLeft", Vector3.new(0.35, 3.4, 3.4), Vector3.new(-2.9, 0.1, 0), config.color, nil, Enum.Material.Neon)
						detail("SideCoreRight", Vector3.new(0.35, 3.4, 3.4), Vector3.new(2.9, 0.1, 0), config.color, nil, Enum.Material.Neon)
					end
					local stripe = base:FindFirstChild("ConveyorCaseStripe_" .. index)
					if stripe and stripe:IsA("BasePart") then
						stripe.Color = Color3.fromRGB(255, 225, 80)
						stripe.Material = Enum.Material.Neon
					end
					local light = Instance.new("PointLight")
					light.Name = "CaseGlow"
					light.Color = config.color
					light.Brightness = 1.2
					light.Range = 14
					light.Parent = casePart
					local prompt = Instance.new("ProximityPrompt")
					prompt.Name = "Open" .. caseType .. "Case"
					prompt.ActionText = "Купить • " .. config.cost .. " монет"
					prompt.ObjectText = config.name
					prompt.HoldDuration = 0.35
					prompt.MaxActivationDistance = 12
					prompt.RequiresLineOfSight = false
					prompt.Parent = casePart
					prompt.Triggered:Connect(function(player)
						handleOpenCase(player, caseType, base)
					end)
					local labelGui = Instance.new("BillboardGui")
					labelGui.Name = "CaseNameLabel"
					labelGui.Size = UDim2.fromOffset(210, 56)
					local labelHeight = if caseIndex == 2 then 6.3 else 4.8
					labelGui.StudsOffset = Vector3.new(0, labelHeight, 0)
					labelGui.MaxDistance = 120
					labelGui.AlwaysOnTop = true
					labelGui.Adornee = casePart
					labelGui.Parent = casePart
					local label = Instance.new("TextLabel")
					label.Size = UDim2.fromScale(1, 1)
					label.BackgroundColor3 = Color3.fromRGB(34, 27, 62)
					label.BackgroundTransparency = 0.15
					label.Text = config.name .. "\n" .. config.cost .. " монет"
					label.TextColor3 = config.color
					label.TextStrokeColor3 = Color3.new(0, 0, 0)
					label.TextStrokeTransparency = 0.25
					label.TextScaled = false
					label.TextWrapped = true
					label.TextSize = 16
					label.Font = Enum.Font.GothamBlack
					label.Parent = labelGui
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(sendInventory)
Players.PlayerRemoving:Connect(function(player)
	local trade = activeTrades[player.UserId]
	if trade then
		local partner = if trade.a == player then trade.b else trade.a
		activeTrades[trade.a.UserId], activeTrades[trade.b.UserId] = nil, nil
		send(partner, "Обмен отменён: игрок вышел.", "error")
	end
	local request = pendingRequests[player.UserId]
	if request then send(request.from, "Запрос отменён: игрок вышел.", "error"); pendingRequests[player.UserId] = nil end
	for targetId, pending in pairs(pendingRequests) do
		if pending.from == player then pendingRequests[targetId] = nil end
	end
	inventories[player.UserId], lastCaseAt[player.UserId], openingCase[player.UserId], hotbars[player.UserId], firstCaseAwarded[player.UserId] = nil, nil, nil, nil, nil
end)

task.spawn(addCasePrompt)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(sendInventory, player) end
print("Brawl Card case and trading prototype ready")

```

## 3. CardSystemsClient

Создай `LocalScript` в `StarterPlayer > StarterPlayerScripts` и назови его `CardSystemsClient`. Замени его содержимое разделом ниже.

```lua
-- LocalScript in StarterPlayer > StarterPlayerScripts.
-- Collection/trading UI and the 3D case-opening scene. Cases are opened at the base conveyor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("CardGameRemotes")
local tradeRequest = remotes:WaitForChild("TradeRequest")
local tradeReply = remotes:WaitForChild("TradeReply")
local tradeOffer = remotes:WaitForChild("TradeOffer")
local tradeResult = remotes:WaitForChild("TradeResult")
local inventoryUpdate = remotes:WaitForChild("InventoryUpdate")
local caseReveal = remotes:WaitForChild("CaseReveal")
local setHotbar = remotes:WaitForChild("SetHotbar")
local placeFighter = remotes:WaitForChild("PlaceFighter")

local gui = Instance.new("ScreenGui")
gui.Name = "CardGameGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function make(className, properties, parent)
	local object = Instance.new(className)
	for key, value in pairs(properties) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local panel = make("Frame", {
	Name = "InventoryPanel",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.new(0.34, 0, 0, 310),
	BackgroundColor3 = Color3.fromRGB(34, 27, 62),
	BackgroundTransparency = 0.08,
}, gui)
panel.Visible = false
make("UISizeConstraint", { MinSize = Vector2.new(250, 260), MaxSize = Vector2.new(350, 330) }, panel)
make("UICorner", { CornerRadius = UDim.new(0, 14) }, panel)
make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, panel)

make("TextLabel", {
	Size = UDim2.new(1, -20, 0, 42), Position = UDim2.fromOffset(10, 8),
	BackgroundTransparency = 1, Text = "ИНВЕНТАРЬ БОЙЦОВ",
	TextColor3 = Color3.fromRGB(255, 220, 70), TextScaled = true,
	Font = Enum.Font.GothamBlack,
}, panel)

local inventoryList = make("ScrollingFrame", {
	Name = "InventoryList", Size = UDim2.new(1, -24, 0, 150),
	Position = UDim2.fromOffset(12, 56), BackgroundColor3 = Color3.fromRGB(21, 20, 38),
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 6, ScrollingDirection = Enum.ScrollingDirection.Y,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, inventoryList)
make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, inventoryList)
make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, inventoryList)

local status = make("TextLabel", {
	Name = "Status", Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 212),
	BackgroundTransparency = 1, Text = "Кейсы покупаются у конвейера на твоей базе.",
	TextColor3 = Color3.fromRGB(225, 225, 235), TextSize = 14,
	Font = Enum.Font.Gotham, TextWrapped = true,
}, panel)

local tradeButton = make("TextButton", {
	Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 260),
	BackgroundColor3 = Color3.fromRGB(130, 45, 220),
	Text = "ОБМЕН С ИГРОКОМ РЯДОМ", TextColor3 = Color3.new(1, 1, 1),
	TextSize = 16, TextWrapped = true, Font = Enum.Font.GothamBold,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, tradeButton)

local inventoryToggle = make("TextButton", {
	Name = "InventoryButton", Size = UDim2.fromOffset(150, 42), Position = UDim2.fromOffset(16, 72),
	BackgroundColor3 = Color3.fromRGB(34, 27, 62), Text = "ИНВЕНТАРЬ",
	TextColor3 = Color3.fromRGB(255, 220, 70), TextSize = 17, Font = Enum.Font.GothamBlack,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, inventoryToggle)
make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, inventoryToggle)

local quickbar = {}
local selectedFighter
local renderHotbar
local quickbarFrame = make("Frame", {
	Name = "Quickbar", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(0.76, 0, 0, 66), BackgroundTransparency = 1,
}, gui)
local quickStatus = make("TextLabel", {
	Name = "QuickStatus", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -4),
	Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "",
	TextColor3 = Color3.new(1, 1, 1), TextSize = 16, Font = Enum.Font.GothamBold,
}, quickbarFrame)
local quickbarButtons = {}
for slotIndex = 1, 5 do
	local slotButton = make("TextButton", {
		Name = "Slot" .. slotIndex, Size = UDim2.new(0.19, 0, 1, 0),
		Position = UDim2.new((slotIndex - 1) * 0.202, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), Text = tostring(slotIndex) .. "\n—",
		TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true, Font = Enum.Font.GothamBold,
	}, quickbarFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 9) }, slotButton)
	make("UIStroke", { Color = Color3.fromRGB(95, 85, 130), Thickness = 1 }, slotButton)
	quickbarButtons[slotIndex] = slotButton
end

local inventory = {}
local activeTrade
local tradeForm

local function renderInventory()
	for _, child in ipairs(inventoryList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	local cardNames = {}
	for cardName, amount in pairs(inventory) do
		if amount > 0 then table.insert(cardNames, cardName) end
	end
	table.sort(cardNames)
	if #cardNames == 0 then
		make("TextLabel", {
			Size = UDim2.new(1, -8, 0, 54), BackgroundTransparency = 1,
			Text = "Пока нет бойцов.\nОткрой кейс у конвейера!", TextColor3 = Color3.new(1, 1, 1),
			TextSize = 16, TextWrapped = true, Font = Enum.Font.GothamMedium,
		}, inventoryList)
		return
	end
	for order, cardName in ipairs(cardNames) do
		local row = make("TextButton", {
			Name = "Card_" .. cardName, Size = UDim2.new(1, -8, 0, 38),
			LayoutOrder = order, BackgroundColor3 = Color3.fromRGB(60, 48, 98),
			Text = cardName .. " × " .. inventory[cardName] .. "     + В быстрый доступ",
			TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true,
			Font = Enum.Font.GothamBold,
		}, inventoryList)
		make("UICorner", { CornerRadius = UDim.new(0, 7) }, row)
		row.Activated:Connect(function()
			local exists = false
			for _, equipped in pairs(quickbar) do
				if equipped == cardName then exists = true; break end
			end
			if exists then
				quickStatus.Text = cardName .. " уже в быстром доступе."
				return
			end
			local slotIndex
			for index = 1, 5 do
				if not quickbar[index] then slotIndex = index; break end
			end
			if not slotIndex then slotIndex = 1 end
			quickbar[slotIndex] = cardName
			setHotbar:FireServer(quickbar)
			quickStatus.Text = cardName .. " добавлен в слот " .. slotIndex .. ". Нажми его снизу, затем кликни свою базу."
			renderHotbar()
		end)
	end
end

renderHotbar = function()
	for index, slotButton in ipairs(quickbarButtons) do
		local cardName = quickbar[index]
		if cardName then
			slotButton.Text = tostring(index) .. "\n" .. cardName
		else
			slotButton.Text = tostring(index) .. "\n—"
		end
		if selectedFighter and selectedFighter == cardName then
			slotButton.BackgroundColor3 = Color3.fromRGB(80, 58, 145)
		else
			slotButton.BackgroundColor3 = Color3.fromRGB(34, 27, 62)
		end
	end
end

for index, slotButton in ipairs(quickbarButtons) do
	slotButton.Activated:Connect(function()
		local cardName = quickbar[index]
		if not cardName then
			quickStatus.Text = "Открой кейс и добавь бойца в быстрый доступ через инвентарь."
			return
		end
		if selectedFighter == cardName then
			selectedFighter = nil
			quickStatus.Text = "Размещение отменено."
		else
			selectedFighter = cardName
			quickStatus.Text = "Выбран " .. cardName .. ": кликни по свободному месту своей базы."
		end
		renderHotbar()
	end)
end

inventoryToggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then renderInventory() end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not selectedFighter then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local mouse = player:GetMouse()
	local target = mouse.Target
	local world = workspace:FindFirstChild("BrawlWorld")
	local bases = world and world:FindFirstChild("PersonalBases")
	local ownBase
	if bases then
		for _, base in ipairs(bases:GetChildren()) do
			if base:GetAttribute("OwnerUserId") == player.UserId then ownBase = base; break end
		end
	end
	if target and ownBase and target.Name == "BaseColorInset" and target:IsDescendantOf(ownBase) then
		placeFighter:FireServer(selectedFighter, mouse.Hit.Position)
		quickStatus.Text = "Ставлю " .. selectedFighter .. " на базу..."
		selectedFighter = nil
		renderHotbar()
	else
		quickStatus.Text = "Кликни по полу внутри своей базы, чтобы поставить бойца."
	end
end)

local function scenePart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Material = material or Enum.Material.SmoothPlastic
	part.Color = color
	part.Parent = parent
	return part
end

local function createFighter(worldModel, fighterName, accent, rarity)
	-- Use the detailed imported mesh for Edgar when it is available.
	if fighterName == "Эдгар" then
		local template = ReplicatedStorage:FindFirstChild("EdgarModel")
		if template and template:IsA("Model") then
			local imported = template:Clone()
			imported.Name = fighterName
			for _, item in ipairs(imported:GetDescendants()) do
				if item:IsA("BasePart") then
					item.Anchored = true
					item.CanCollide = false
					item.CastShadow = true
					local partName = string.lower(item.Name)
					if string.find(partName, "scarf") then
						item.Color = Color3.fromRGB(142, 62, 220)
					elseif string.find(partName, "jacket_red") or string.find(partName, "trouser_stripe") then
						item.Color = Color3.fromRGB(205, 45, 60)
					elseif string.find(partName, "hair") then
						item.Color = Color3.fromRGB(28, 33, 58)
					elseif string.find(partName, "head") or string.find(partName, "neck") or string.find(partName, "forearm") then
						item.Color = Color3.fromRGB(242, 204, 184)
					elseif string.find(partName, "visible_eye_white") or string.find(partName, "shoe") or string.find(partName, "tongue") then
						item.Color = Color3.fromRGB(235, 235, 250)
					elseif string.find(partName, "eye") then
						item.Color = Color3.fromRGB(18, 16, 28)
					elseif string.find(partName, "gold") or string.find(partName, "buckle") then
						item.Color = Color3.fromRGB(255, 194, 55)
					elseif string.find(partName, "sole") then
						item.Color = Color3.fromRGB(60, 42, 100)
					elseif string.find(partName, "glove") or string.find(partName, "belt") then
						item.Color = Color3.fromRGB(112, 54, 180)
					elseif string.find(partName, "jacket") or string.find(partName, "trouser") or string.find(partName, "torso") or string.find(partName, "shirt") or string.find(partName, "sleeve") or string.find(partName, "arm") then
						item.Color = Color3.fromRGB(31, 29, 55)
					end
				end
			end
			imported.Parent = worldModel
			local _, originalSize = imported:GetBoundingBox()
			if originalSize.Y > 0 then
				imported:ScaleTo(math.clamp(6.4 / originalSize.Y, 0.2, 3))
			end
			local boundsCFrame, boundsSize = imported:GetBoundingBox()
			local pivotToBounds = imported:GetPivot():ToObjectSpace(boundsCFrame)
			local targetBounds = CFrame.new(0, -2.3 + boundsSize.Y / 2, 0) * CFrame.Angles(0, math.rad(180), 0)
			imported:PivotTo(targetBounds * pivotToBounds:Inverse())

			local effectPart = imported:FindFirstChild("Torso_base", true)
			if not (effectPart and effectPart:IsA("BasePart")) then
				effectPart = imported:FindFirstChildWhichIsA("BasePart", true)
			end
			if effectPart then
				local light = Instance.new("PointLight")
				light.Color = accent
				light.Brightness = rarity == "Легендарная" and 5 or 3
				light.Range = rarity == "Легендарная" and 22 or 16
				light.Parent = effectPart
				local attachment = Instance.new("Attachment")
				attachment.Parent = effectPart
				local sparks = Instance.new("ParticleEmitter")
				sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				sparks.Color = ColorSequence.new(accent)
				sparks.Lifetime = NumberRange.new(0.7, 1.4)
				sparks.Speed = NumberRange.new(2, 5)
				sparks.SpreadAngle = Vector2.new(180, 180)
				sparks.Rate = rarity == "Легендарная" and 40 or 18
				sparks.Parent = attachment
			end
			local aura = scenePart(imported, "EdgarAura", Vector3.new(math.max(boundsSize.X, 3.5), 0.14, math.max(boundsSize.Z, 3.5)), Vector3.new(0, -2.22, 0), accent, Enum.Material.Neon)
			aura.Shape = Enum.PartType.Cylinder
			aura.Orientation = Vector3.new(0, 0, 90)
			aura.Transparency = 0.28
			return imported
		end
	end

	local model = Instance.new("Model")
	model.Name = fighterName
	model.Parent = worldModel
	local bodyColor = Color3.fromRGB(45, 43, 70)
	scenePart(model, "Body", Vector3.new(2.1, 2.5, 1.1), Vector3.new(0, 0.2, 0), bodyColor)
	scenePart(model, "Head", Vector3.new(1.65, 1.65, 1.4), Vector3.new(0, 2.25, 0), Color3.fromRGB(255, 190, 125))
	scenePart(model, "Hair", Vector3.new(1.8, 0.6, 1.55), Vector3.new(0, 3.1, 0), accent)
	scenePart(model, "LeftLeg", Vector3.new(0.75, 1.25, 0.9), Vector3.new(-0.55, -1.65, 0), accent)
	scenePart(model, "RightLeg", Vector3.new(0.75, 1.25, 0.9), Vector3.new(0.55, -1.65, 0), accent)
	scenePart(model, "LeftArm", Vector3.new(0.7, 1.8, 0.8), Vector3.new(-1.35, 0.35, 0), bodyColor)
	scenePart(model, "RightArm", Vector3.new(0.7, 1.8, 0.8), Vector3.new(1.35, 0.35, 0), bodyColor)
	local badge = scenePart(model, "ChestBadge", Vector3.new(0.7, 0.7, 0.16), Vector3.new(0, 0.45, 0.62), accent, Enum.Material.Neon)
	if fighterName == "Эдгар" then
		scenePart(model, "Scarf", Vector3.new(2.2, 0.35, 0.45), Vector3.new(0, 0.95, 0.8), Color3.fromRGB(185, 55, 235))
		scenePart(model, "ScarfTail", Vector3.new(0.5, 1.8, 0.35), Vector3.new(0.75, -0.15, 1), Color3.fromRGB(185, 55, 235))
	end
	local light = Instance.new("PointLight")
	light.Color = accent
	light.Brightness = 2
	light.Range = 16
	light.Parent = badge
	local sparkAttachment = Instance.new("Attachment")
	sparkAttachment.Parent = badge
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(accent)
	sparks.Lifetime = NumberRange.new(0.7, 1.4)
	sparks.Speed = NumberRange.new(2, 5)
	sparks.SpreadAngle = Vector2.new(180, 180)
	if rarity == "Легендарная" then
		sparks.Rate = 45
	elseif rarity == "Эпическая" then
		sparks.Rate = 25
	elseif rarity == "Редкая" then
		sparks.Rate = 14
	else
		sparks.Rate = 7
	end
	sparks.Parent = sparkAttachment
	local aura = scenePart(model, "Aura", Vector3.new(3.8, 0.18, 3.8), Vector3.new(0, -2.3, 0), accent, Enum.Material.Neon)
	aura.Shape = Enum.PartType.Cylinder
	aura.Orientation = Vector3.new(0, 0, 90)
	aura.Transparency = 0.25
	return model
end

local openingFrame
local animationId = 0

local function playOpening(caseType, caseName, fighterName, rarity, accent)
	animationId += 1
	local thisAnimation = animationId
	if openingFrame then openingFrame:Destroy() end
	openingFrame = make("Frame", {
		Name = "CaseOpening", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 7, 18), BackgroundTransparency = 0.08,
		ZIndex = 20,
	}, gui)
	make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 55), Position = UDim2.new(0, 12, 0.08, 0),
		BackgroundTransparency = 1, Text = caseName, TextColor3 = accent,
		TextScaled = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local viewport = make("ViewportFrame", {
		Size = UDim2.new(0.78, 0, 0.56, 0), Position = UDim2.new(0.11, 0, 0.22, 0),
		BackgroundColor3 = Color3.fromRGB(24, 19, 48), Ambient = Color3.fromRGB(180, 180, 205),
		LightColor = Color3.new(1, 1, 1), ZIndex = 21,
	}, openingFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 18) }, viewport)
	make("UIStroke", { Color = accent, Thickness = 3 }, viewport)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 2, 13), Vector3.new(0, 0.5, 0))
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	scenePart(worldModel, "Pedestal", Vector3.new(8, 0.5, 5), Vector3.new(0, -3, 0), Color3.fromRGB(38, 31, 70), Enum.Material.Metal)
	local caseColor
	if caseType == "Starter" then
		caseColor = Color3.fromRGB(45, 130, 255)
	elseif caseType == "Brawl" then
		caseColor = Color3.fromRGB(170, 60, 255)
	else
		caseColor = Color3.fromRGB(255, 185, 35)
	end
	local crate = Instance.new("Model")
	crate.Name = "SpinningCase"
	crate.Parent = worldModel
	scenePart(crate, "Box", Vector3.new(4.5, 3.5, 3.5), Vector3.new(0, 0.3, 0), caseColor, Enum.Material.Metal)
	scenePart(crate, "Lid", Vector3.new(4.9, 0.55, 3.9), Vector3.new(0, 2.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
	local frontCore = scenePart(crate, "FrontCore", Vector3.new(1.8, 1.4, 0.18), Vector3.new(0, 0.35, 1.85), Color3.fromRGB(255, 245, 175), Enum.Material.Neon)
	local caseLight = Instance.new("PointLight")
	caseLight.Color = caseColor
	caseLight.Brightness = 3
	caseLight.Range = 18
	caseLight.Parent = frontCore
	if caseType == "Starter" then
		local orb = scenePart(crate, "SignalOrb", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 3.25, 0), caseColor, Enum.Material.Neon)
		orb.Shape = Enum.PartType.Ball
	elseif caseType == "Brawl" then
		scenePart(crate, "LeftWing", Vector3.new(0.6, 4, 3.5), Vector3.new(-2.5, 0.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
		scenePart(crate, "RightWing", Vector3.new(0.6, 4, 3.5), Vector3.new(2.5, 0.3, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
	else
		local orb = scenePart(crate, "MegaCore", Vector3.new(2.1, 2.1, 2.1), Vector3.new(0, 3.2, 0), Color3.fromRGB(255, 220, 70), Enum.Material.Neon)
		orb.Shape = Enum.PartType.Ball
		scenePart(crate, "LeftReactor", Vector3.new(0.35, 3.8, 3.2), Vector3.new(-2.4, 0.3, 0), caseColor, Enum.Material.Neon)
		scenePart(crate, "RightReactor", Vector3.new(0.35, 3.8, 3.2), Vector3.new(2.4, 0.3, 0), caseColor, Enum.Material.Neon)
	end
	local caption = make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 66), Position = UDim2.new(0, 12, 0.82, 0),
		BackgroundTransparency = 1, Text = "КЕЙС ОТКРЫВАЕТСЯ...", TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local startTime = os.clock()
	while os.clock() - startTime < 2.2 and thisAnimation == animationId do
		local angle = (os.clock() - startTime) * 5
		crate:PivotTo(CFrame.new(0, 0.4 + math.sin(angle * 1.5) * 0.25, 0) * CFrame.Angles(0, angle, 0))
		RunService.RenderStepped:Wait()
	end
	if thisAnimation ~= animationId then return end
	crate:Destroy()
	local fighter = createFighter(worldModel, fighterName, accent, rarity)
	local flash = make("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent,
		BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 24,
	}, openingFrame)
	TweenService:Create(flash, TweenInfo.new(0.65), { BackgroundTransparency = 1 }):Play()
	task.delay(0.7, function()
		if flash.Parent then flash:Destroy() end
	end)
	for ringIndex = 1, 3 do
		local ring = scenePart(worldModel, "RevealPulse" .. ringIndex, Vector3.new(0.6, 0.12, 0.6), Vector3.new(0, -2.35 + ringIndex * 0.18, 0), accent, Enum.Material.Neon)
		ring.Shape = Enum.PartType.Cylinder
		ring.Orientation = Vector3.new(0, 0, 90)
		local delayTime = (ringIndex - 1) * 0.18
		task.delay(delayTime, function()
			if ring.Parent then
				TweenService:Create(ring, TweenInfo.new(0.85), { Size = Vector3.new(7 + ringIndex, 0.12, 7 + ringIndex), Transparency = 1 }):Play()
			end
		end)
	end
	local revealStart = os.clock()
	while os.clock() - revealStart < 1.8 and thisAnimation == animationId do
		local angle = (os.clock() - revealStart) * 1.4
		fighter:PivotTo(CFrame.new(0, math.sin(angle * 2) * 0.15, 0) * CFrame.Angles(0, angle, 0))
		RunService.RenderStepped:Wait()
	end
	if thisAnimation ~= animationId then return end
	caption.Text = fighterName .. " • " .. rarity
	caption.TextColor3 = accent
	task.wait(1.4)
	if thisAnimation == animationId and openingFrame then
		openingFrame:Destroy()
		openingFrame = nil
	end
end

local function playOpeningCinematic(caseType, caseName, fighterName, rarity, accent)
	animationId += 1
	local thisAnimation = animationId
	if openingFrame then openingFrame:Destroy() end
	openingFrame = make("Frame", {
		Name = "CaseOpeningCinematic", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(10, 7, 24), BackgroundTransparency = 0.02, ZIndex = 20,
	}, gui)
	make("TextLabel", {
		Size = UDim2.new(0.92, 0, 0, 58), Position = UDim2.new(0.04, 0, 0.035, 0),
		BackgroundColor3 = Color3.fromRGB(31, 22, 62), BackgroundTransparency = 0.05,
		Text = caseName .. "  •  КЕЙС НА КОНВЕЙЕРЕ", TextColor3 = Color3.fromRGB(255, 221, 85),
		TextSize = 24, TextWrapped = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)
	local viewport = make("ViewportFrame", {
		Size = UDim2.new(0.94, 0, 0.68, 0), Position = UDim2.new(0.03, 0, 0.16, 0),
		BackgroundColor3 = Color3.fromRGB(18, 14, 40), Ambient = Color3.fromRGB(155, 145, 195),
		LightColor = Color3.fromRGB(255, 235, 195), ZIndex = 21,
	}, openingFrame)
	make("UICorner", { CornerRadius = UDim.new(0, 20) }, viewport)
	make("UIStroke", { Color = accent, Thickness = 3 }, viewport)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 2.1, 18), Vector3.new(0, -0.4, 0))
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local caption = make("TextLabel", {
		Size = UDim2.new(0.92, 0, 0, 64), Position = UDim2.new(0.04, 0, 0.86, 0),
		BackgroundColor3 = Color3.fromRGB(31, 22, 62), BackgroundTransparency = 0.05,
		Text = "КОНВЕЙЕР ЗАПУСКАЕТСЯ...", TextColor3 = Color3.new(1, 1, 1),
		TextSize = 26, TextWrapped = true, Font = Enum.Font.GothamBlack, ZIndex = 22,
	}, openingFrame)

	local caseColor
	if caseType == "Starter" then
		caseColor = Color3.fromRGB(40, 125, 255)
	elseif caseType == "Brawl" then
		caseColor = Color3.fromRGB(165, 55, 245)
	else
		caseColor = Color3.fromRGB(255, 185, 30)
	end
	scenePart(worldModel, "ConveyorFrame", Vector3.new(17, 0.8, 8), Vector3.new(0, -3.1, 0), Color3.fromRGB(28, 25, 55), Enum.Material.Metal)
	scenePart(worldModel, "MovingBelt", Vector3.new(15.8, 0.18, 6.4), Vector3.new(0, -2.58, 0), Color3.fromRGB(48, 52, 78), Enum.Material.Metal)
	scenePart(worldModel, "RailLeft", Vector3.new(17, 0.75, 0.45), Vector3.new(0, -2.05, -3.7), caseColor, Enum.Material.Neon)
	scenePart(worldModel, "RailRight", Vector3.new(17, 0.75, 0.45), Vector3.new(0, -2.05, 3.7), caseColor, Enum.Material.Neon)
	local rollers = {}
	for index = 1, 11 do
		local x = -7.2 + (index - 1) * 1.44
		local roller = scenePart(worldModel, "Roller" .. index, Vector3.new(0.55, 6.3, 0.55), Vector3.new(x, -2.77, 0), Color3.fromRGB(118, 130, 165), Enum.Material.Metal)
		roller.Shape = Enum.PartType.Cylinder
		table.insert(rollers, { part = roller, position = roller.Position })
	end
	local beltAngle = 0
	local function animate(duration, speed, update)
		local start = os.clock()
		local previous = start
		while os.clock() - start < duration and thisAnimation == animationId do
			local now = os.clock()
			local dt = now - previous
			previous = now
			beltAngle += dt * speed
			for _, rollerData in ipairs(rollers) do
				rollerData.part.CFrame = CFrame.new(rollerData.position) * CFrame.Angles(0, 0, beltAngle) * CFrame.Angles(math.rad(90), 0, 0)
			end
			if update then update(math.clamp((now - start) / duration, 0, 1), now) end
			RunService.RenderStepped:Wait()
		end
	end

	local crate = Instance.new("Model")
	crate.Name = "RidingCase"
	crate.Parent = worldModel
	local body = scenePart(crate, "CaseBody", Vector3.new(3.8, 3.1, 3.4), Vector3.zero, caseColor, Enum.Material.Metal)
	crate.PrimaryPart = body
	local lid = scenePart(crate, "CaseLid", Vector3.new(4.05, 0.48, 3.65), Vector3.new(0, 1.78, 0), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	scenePart(crate, "FrontPanel", Vector3.new(2, 1.35, 0.18), Vector3.new(0, 0.15, 1.78), Color3.fromRGB(245, 250, 255), Enum.Material.Neon)
	scenePart(crate, "SideTrimL", Vector3.new(0.35, 2.6, 0.25), Vector3.new(-1.95, 0, 1.75), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	scenePart(crate, "SideTrimR", Vector3.new(0.35, 2.6, 0.25), Vector3.new(1.95, 0, 1.75), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
	local core = Instance.new("Attachment")
	core.Position = Vector3.new(0, 0, 1)
	core.Parent = body
	local crateSparks = Instance.new("ParticleEmitter")
	crateSparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	crateSparks.Color = ColorSequence.new(caseColor, Color3.fromRGB(255, 235, 150))
	crateSparks.Lifetime = NumberRange.new(0.45, 0.9)
	crateSparks.Speed = NumberRange.new(3, 7)
	crateSparks.SpreadAngle = Vector2.new(180, 180)
	crateSparks.Rate = 0
	crateSparks.Parent = core
	local crateLight = Instance.new("PointLight")
	crateLight.Color = caseColor
	crateLight.Brightness = 3
	crateLight.Range = 18
	crateLight.Parent = body
	crate:PivotTo(CFrame.new(-8, -0.9, 0) * CFrame.Angles(0, 0, math.rad(-12)))
	caption.Text = "КОНВЕЙЕР НАБИРАЕТ СКОРОСТЬ"
	animate(1.35, 18, function(alpha, now)
		local eased = 1 - (1 - alpha) * (1 - alpha)
		local x = -8 + eased * 8
		crate:PivotTo(CFrame.new(x, -0.9 + math.sin(now * 15) * 0.12, 0) * CFrame.Angles(0, now * 1.2, math.rad(-12 + math.sin(now * 19) * 3)))
	end)
	if thisAnimation ~= animationId then return end
	crate:PivotTo(CFrame.new(0, -0.9, 0))
	caption.Text = "КЕЙС ОСТАНАВЛИВАЕТСЯ..."
	animate(0.55, 25, function(alpha, now)
		crate:PivotTo(CFrame.new(math.sin(now * 38) * (1 - alpha) * 0.17, -0.9, 0) * CFrame.Angles(0, 0, math.sin(now * 35) * (1 - alpha) * 0.04))
		crateLight.Brightness = 2.5 + math.abs(math.sin(now * 24)) * 4
	end)
	local lidStart = lid.CFrame
	caption.Text = "ЗАРЯДКА КЕЙСА..."
	crateSparks:Emit(42)
	animate(0.65, 8, function(alpha)
		local eased = alpha * alpha
		lid.CFrame = lidStart * CFrame.new(0, eased * 2.6, 0) * CFrame.Angles(math.rad(-105 * eased), 0, 0)
		crateLight.Brightness = 4 + eased * 10
	end)
	if thisAnimation ~= animationId then return end
	crate:Destroy()

	local previews = {
		{ "Шелли", "Обычная", Color3.fromRGB(70, 145, 255) },
		{ "Кольт", "Редкая", Color3.fromRGB(155, 80, 255) },
		{ "Нита", "Обычная", Color3.fromRGB(70, 145, 255) },
		{ "Ворон", "Легендарная", Color3.fromRGB(255, 215, 55) },
		{ "Спайк", "Эпическая", Color3.fromRGB(255, 150, 45) },
	}
	caption.Text = "РУЛЕТКА БОЙЦОВ"
	for index, entry in ipairs(previews) do
		local preview = createFighter(worldModel, entry[1], entry[3], entry[2])
		local duration = 0.16 + index * 0.085
		caption.Text = entry[1] .. "  •  " .. entry[2]
		caption.TextColor3 = entry[3]
		animate(duration, 22 - index * 2, function(alpha, now)
			preview:PivotTo(CFrame.new(0, math.sin(now * 9) * 0.22, 0) * CFrame.Angles(0, now * (8 - index * 0.45), 0))
		end)
		preview:Destroy()
	end
	if thisAnimation ~= animationId then return end
	caption.Text = "ПОСЛЕДНИЙ БРОСОК..."
	caption.TextColor3 = accent
	local winner = createFighter(worldModel, fighterName, accent, rarity)
	local winnerLight = Instance.new("PointLight")
	winnerLight.Color = accent
	winnerLight.Brightness = 0
	winnerLight.Range = 24
	winnerLight.Parent = winner:FindFirstChild("ChestBadge")
	local revealFlash = make("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent,
		BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 24,
	}, openingFrame)
	TweenService:Create(revealFlash, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	task.delay(0.85, function()
		if revealFlash.Parent then revealFlash:Destroy() end
	end)
	local winnerBadge = winner:FindFirstChild("ChestBadge")
	local winnerSparks = winnerBadge and winnerBadge:FindFirstChildOfClass("Attachment")
	if winnerSparks then
		local emitter = winnerSparks:FindFirstChildOfClass("ParticleEmitter")
		if emitter then
			local burst = 55
			if rarity == "Эпическая" then burst = 80 end
			if rarity == "Легендарная" then burst = 120 end
			emitter:Emit(burst)
		end
	end
	caption.Text = "ВЫПАЛ " .. string.upper(fighterName) .. "  •  " .. string.upper(rarity)
	caption.TextColor3 = accent
	animate(1.7, 7, function(alpha, now)
		local rise = -2.8 + alpha * 2.8
		winner:PivotTo(CFrame.new(0, rise + math.sin(now * 4) * 0.1, 0) * CFrame.Angles(0, now * 1.25, 0))
		winnerLight.Brightness = 2 + alpha * 5
	end)
	if thisAnimation ~= animationId then return end
	task.wait(1.4)
	if thisAnimation == animationId and openingFrame then
		openingFrame:Destroy()
		openingFrame = nil
	end
end

local function showTradeForm()
	if tradeForm then tradeForm:Destroy() end
	tradeForm = make("Frame", {
		Size = UDim2.new(0.86, 0, 0, 230), Position = UDim2.new(0.07, 0, 0.5, -115),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), ZIndex = 30,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, tradeForm)
	make("UIStroke", { Color = Color3.fromRGB(255, 205, 45), Thickness = 2 }, tradeForm)
	make("TextLabel", {
		Size = UDim2.new(1, -16, 0, 42), Position = UDim2.fromOffset(8, 6),
		BackgroundTransparency = 1, Text = "ОБМЕН КАРТОЧКАМИ",
		TextColor3 = Color3.fromRGB(255, 220, 70), TextSize = 21, Font = Enum.Font.GothamBlack, ZIndex = 31,
	}, tradeForm)
	local cardNames = {}
	for name, amount in pairs(inventory) do
		if amount > 0 then table.insert(cardNames, name) end
	end
	table.sort(cardNames)
	if #cardNames == 0 then table.insert(cardNames, "НЕТ КАРТОЧЕК") end
	local cardIndex = 1
	local selectedCard = cardNames[1]
	local selectedAmount = 1
	local cardLabel = make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 38), Position = UDim2.fromOffset(10, 52),
		BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), TextSize = 17,
		Font = Enum.Font.GothamBold, ZIndex = 31,
	}, tradeForm)
	local amountLabel = make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromOffset(10, 91),
		BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(225, 225, 235),
		TextSize = 15, Font = Enum.Font.Gotham, ZIndex = 31,
	}, tradeForm)
	local function refreshTradeForm()
		selectedCard = cardNames[cardIndex]
		local owned = inventory[selectedCard] or 0
		selectedAmount = math.clamp(selectedAmount, 1, math.max(owned, 1))
		cardLabel.Text = "Карточка: " .. selectedCard
		amountLabel.Text = "Количество: " .. (owned > 0 and tostring(selectedAmount) or "0") .. " из " .. owned
	end
	local previous = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.fromOffset(12, 130), Text = "◀", ZIndex = 31 }, tradeForm)
	local nextCard = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(1, -54, 0, 130), Text = "▶", ZIndex = 31 }, tradeForm)
	local less = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(0.5, -48, 0, 130), Text = "−", ZIndex = 31 }, tradeForm)
	local more = make("TextButton", { Size = UDim2.fromOffset(42, 36), Position = UDim2.new(0.5, 6, 0, 130), Text = "+", ZIndex = 31 }, tradeForm)
	local submit = make("TextButton", {
		Size = UDim2.new(1, -20, 0, 42), Position = UDim2.fromOffset(10, 178),
		BackgroundColor3 = Color3.fromRGB(55, 170, 85), Text = "ПРЕДЛОЖИТЬ",
		TextColor3 = Color3.new(1, 1, 1), TextSize = 17, Font = Enum.Font.GothamBold, ZIndex = 31,
	}, tradeForm)
	previous.Activated:Connect(function()
		cardIndex = (cardIndex - 2) % #cardNames + 1
		refreshTradeForm()
	end)
	nextCard.Activated:Connect(function()
		cardIndex = cardIndex % #cardNames + 1
		refreshTradeForm()
	end)
	less.Activated:Connect(function()
		selectedAmount = math.max(1, selectedAmount - 1)
		refreshTradeForm()
	end)
	more.Activated:Connect(function()
		selectedAmount += 1
		refreshTradeForm()
	end)
	submit.Activated:Connect(function()
		if not activeTrade then
			status.Text = "Обмен уже закончился."
			tradeForm:Destroy()
			return
		end
		local amount = inventory[selectedCard] and inventory[selectedCard] > 0 and selectedAmount or 0
		tradeOffer:FireServer(activeTrade.id, selectedCard, amount)
		activeTrade = nil
		tradeForm:Destroy()
	end)
	refreshTradeForm()
end

tradeButton.Activated:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then status.Text = "Персонаж ещё загружается."; return end
	local nearestPlayer
	local nearestDistance = 25
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot then
				local distance = (otherRoot.Position - root.Position).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestPlayer = other
				end
			end
		end
	end
	if not nearestPlayer then status.Text = "Подойди ближе к игроку для обмена."; return end
	tradeRequest:FireServer(nearestPlayer.UserId)
	status.Text = "Запрос отправлен: " .. nearestPlayer.DisplayName
end)

inventoryUpdate.OnClientEvent:Connect(function(newInventory, newHotbar)
	inventory = newInventory or {}
	local oldHotbar = quickbar
	quickbar = newHotbar or quickbar
	for index = 1, 5 do
		if quickbar[index] and quickbar[index] ~= oldHotbar[index] then
			quickStatus.Text = quickbar[index] .. " сразу добавлен в быстрый доступ — нажми слот " .. index .. "."
			break
		end
	end
	renderInventory()
	renderHotbar()
end)

caseReveal.OnClientEvent:Connect(function(stage, caseType, caseName, fighterName, rarity, color)
	if stage == "Start" then
		task.spawn(playOpeningCinematic, caseType, caseName, fighterName, rarity, color)
	end
end)

tradeRequest.OnClientEvent:Connect(function(fromUserId, fromName)
	local dialog = make("Frame", {
		Size = UDim2.new(0.86, 0, 0, 150), Position = UDim2.new(0.07, 0, 0.5, -75),
		BackgroundColor3 = Color3.fromRGB(34, 27, 62), ZIndex = 40,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 12) }, dialog)
	make("TextLabel", {
		Size = UDim2.new(1, -20, 0, 65), Position = UDim2.fromOffset(10, 8),
		BackgroundTransparency = 1, Text = fromName .. " предлагает обмен.",
		TextColor3 = Color3.new(1, 1, 1), TextWrapped = true, TextSize = 19,
		Font = Enum.Font.GothamBold, ZIndex = 41,
	}, dialog)
	local accept = make("TextButton", {
		Size = UDim2.new(0.48, -8, 0, 48), Position = UDim2.new(0, 8, 1, -56),
		BackgroundColor3 = Color3.fromRGB(50, 165, 80), Text = "ПРИНЯТЬ", TextColor3 = Color3.new(1, 1, 1), ZIndex = 41,
	}, dialog)
	local decline = make("TextButton", {
		Size = UDim2.new(0.48, -8, 0, 48), Position = UDim2.new(0.52, 0, 1, -56),
		BackgroundColor3 = Color3.fromRGB(180, 60, 65), Text = "ОТКЛОНИТЬ", TextColor3 = Color3.new(1, 1, 1), ZIndex = 41,
	}, dialog)
	accept.Activated:Connect(function()
		tradeReply:FireServer(true)
		dialog:Destroy()
	end)
	decline.Activated:Connect(function()
		tradeReply:FireServer(false)
		dialog:Destroy()
	end)
end)

tradeOffer.OnClientEvent:Connect(function(tradeId, partnerId, partnerName)
	activeTrade = { id = tradeId, partnerId = partnerId, partnerName = partnerName }
	status.Text = "Обмен с " .. partnerName .. ". Выбери свою карточку."
	showTradeForm()
end)

tradeResult.OnClientEvent:Connect(function(message, kind)
	status.Text = tostring(message)
	if kind == "error" then
		status.TextColor3 = Color3.fromRGB(255, 125, 125)
	elseif kind == "success" then
		status.TextColor3 = Color3.fromRGB(140, 255, 155)
	else
		status.TextColor3 = Color3.fromRGB(225, 225, 235)
	end
end)

renderInventory()

```

## 4. BaseSignClient

Создай `LocalScript` в `StarterPlayer > StarterPlayerScripts` и назови его `BaseSignClient`. Замени его содержимое разделом ниже.

```lua
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts.
-- It shows the player's name only on their own personal base.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local world = Workspace:WaitForChild("BrawlWorld")
local personalBases = world:WaitForChild("PersonalBases")

local function refreshBase(base)
	local sign = base:FindFirstChild("OwnerSign")
	if not sign then
		return
	end

	local privateGui = sign:FindFirstChild("OwnerOnlyDisplay")
	if not privateGui then
		return
	end

	local isMyBase = base:GetAttribute("OwnerUserId") == localPlayer.UserId
	privateGui.Enabled = isMyBase
	if isMyBase then
		local label = privateGui:FindFirstChild("OwnerName")
		if label then
			label.Text = localPlayer.DisplayName .. "'S BASE"
		end
	end
end

local function watchBase(base)
	refreshBase(base)
	base:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		refreshBase(base)
	end)
end

for _, base in ipairs(personalBases:GetChildren()) do
	watchBase(base)
end

personalBases.ChildAdded:Connect(watchBase)

```

## Нужная модель

Для показа импортированного Эдгара положи модель с именем `EdgarModel` в `ReplicatedStorage`.

## Что уже сделано

- Центральный хаб и шесть личных баз создаются скриптом `WorldSetup`.
- `CardSystems` отвечает за кейсы, монеты, карточки, инвентарь, быстрый доступ, размещение бойцов и обмен.
- `CardSystemsClient` показывает интерфейс и анимацию открытия кейса.
- Первый открытый кейс в текущей сессии гарантирует Эдгара.
- Для тестов стартовый баланс выставлен в 10 000 монет.
