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
