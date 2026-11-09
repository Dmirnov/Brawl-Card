--!strict
-- Main spawn plaza: a polished, walkable social hub for the first game phase.
-- Kept separate from WorldSetup so this folder can be moved to a newer project.

local Workspace = game:GetService("Workspace")

local oldHub = Workspace:FindFirstChild("HubDesign")
if oldHub then
	oldHub:Destroy()
end

-- Wait for the base world script when it is present; the design also works on a
-- plain Baseplate, where the floor height is zero.
local spawnWorld = Workspace:WaitForChild("SpawnWorld", 30)
local floorY = 0
if spawnWorld and spawnWorld:IsA("BasePart") then
	floorY = spawnWorld.Position.Y + spawnWorld.Size.Y / 2
end

local hub = Instance.new("Folder")
hub.Name = "HubDesign"
hub.Parent = Workspace

-- The decorative paving is raised, so place the existing spawn marker on its top.
local spawn = Workspace:WaitForChild("PlayerSpawn", 10)
if spawn and spawn:IsA("BasePart") then
	spawn.Position = Vector3.new(0, floorY + 4, 0)
end

local COLORS = {
	stone = Color3.fromRGB(218, 224, 232),
	lightStone = Color3.fromRGB(242, 244, 248),
	deep = Color3.fromRGB(30, 42, 68),
	blue = Color3.fromRGB(66, 148, 238),
	teal = Color3.fromRGB(61, 213, 190),
	gold = Color3.fromRGB(255, 195, 74),
	leaf = Color3.fromRGB(56, 166, 119),
	wood = Color3.fromRGB(117, 75, 52),
	water = Color3.fromRGB(82, 202, 238),
}

local function part(
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	shape: Enum.PartType?,
	parent: Instance?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = parent or hub
	return p
end

local function disk(name: string, diameter: number, thickness: number, y: number, color: Color3, material: Enum.Material): Part
	local p = part(name, Vector3.new(thickness, diameter, diameter), Vector3.new(0, y, 0), color, material, Enum.PartType.Cylinder)
	p.CFrame = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2)
	return p
end

local function diskAt(name: string, x: number, z: number, diameter: number, thickness: number, y: number, color: Color3, material: Enum.Material): Part
	local p = part(name, Vector3.new(thickness, diameter, diameter), Vector3.new(x, y, z), color, material, Enum.PartType.Cylinder)
	p.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.pi / 2)
	return p
end

local function uprightCylinder(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	-- Roblox cylinders use local X as their long axis; map the requested Y height to X.
	local p = part(name, Vector3.new(size.Y, size.X, size.Z), position, color, material, Enum.PartType.Cylinder)
	p.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2)
	return p
end

local function neon(name: string, size: Vector3, position: Vector3, color: Color3): Part
	local p = part(name, size, position, color, Enum.Material.Neon)
	p.CanCollide = false
	return p
end

local function makeTree(x: number, z: number, scale: number)
	local trunkH = 9 * scale
	uprightCylinder("Tree trunk", Vector3.new(2.2, trunkH, 2.2) * scale, Vector3.new(x, floorY + trunkH / 2, z), COLORS.wood, Enum.Material.Wood)
	local crown = part("Tree crown", Vector3.new(10, 10, 10) * scale, Vector3.new(x, floorY + trunkH + 4 * scale, z), COLORS.leaf, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	crown.CanCollide = false
	local crown2 = part("Tree crown highlight", Vector3.new(6.5, 6.5, 6.5) * scale, Vector3.new(x + 2 * scale, floorY + trunkH + 7 * scale, z - 1.4 * scale), Color3.fromRGB(85, 196, 145), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	crown2.CanCollide = false
end

local function makeLamp(x: number, z: number)
	local base = part("Path light base", Vector3.new(0.6, 3, 3), Vector3.new(x, floorY + 0.35, z), COLORS.deep, Enum.Material.Slate, Enum.PartType.Cylinder)
	base.CFrame = CFrame.new(x, floorY + 0.35, z) * CFrame.Angles(0, 0, math.pi / 2)
	uprightCylinder("Path light post", Vector3.new(0.8, 8, 0.8), Vector3.new(x, floorY + 4.5, z), COLORS.deep, Enum.Material.Metal)
	local cap = part("Path light cap", Vector3.new(0.8, 2.2, 2.2), Vector3.new(x, floorY + 8.6, z), COLORS.gold, Enum.Material.Metal, Enum.PartType.Cylinder)
	cap.CFrame = CFrame.new(x, floorY + 8.6, z) * CFrame.Angles(0, 0, math.pi / 2)
	local glow = neon("Path light", Vector3.new(1.6, 1.4, 1.6), Vector3.new(x, floorY + 7.6, z), Color3.fromRGB(255, 230, 156))
	glow.Shape = Enum.PartType.Ball
	glow.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 223, 153)
	light.Brightness = 1.1
	light.Range = 20
	light.Parent = glow
end

local function makeSign(name: string, position: Vector3, title: string, subtitle: string)
	local anchor = part(name .. " anchor", Vector3.new(1, 1, 1), position, COLORS.deep, Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	local board = Instance.new("BillboardGui")
	board.Name = name
	board.Adornee = anchor
	board.Size = UDim2.fromOffset(440, 112)
	board.AlwaysOnTop = true
	board.LightInfluence = 0
	board.MaxDistance = 700
	board.Parent = anchor
	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = COLORS.deep
	back.BackgroundTransparency = 0.08
	back.BorderSizePixel = 0
	back.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = back
	local outline = Instance.new("UIStroke")
	outline.Color = COLORS.gold
	outline.Thickness = 3
	outline.Parent = back
	local heading = Instance.new("TextLabel")
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromScale(0.04, 0.08)
	heading.Size = UDim2.fromScale(0.92, 0.52)
	heading.Font = Enum.Font.GothamBlack
	heading.Text = title
	heading.TextColor3 = Color3.new(1, 1, 1)
	heading.TextScaled = true
	heading.Parent = back
	local caption = Instance.new("TextLabel")
	caption.BackgroundTransparency = 1
	caption.Position = UDim2.fromScale(0.04, 0.59)
	caption.Size = UDim2.fromScale(0.92, 0.29)
	caption.Font = Enum.Font.GothamBold
	caption.Text = subtitle
	caption.TextColor3 = COLORS.teal
	caption.TextScaled = true
	caption.Parent = back
end

-- Layered circular paving gives the spawn area a strong, readable center.
disk("Foundation", 154, 2.2, floorY + 0.55, COLORS.deep, Enum.Material.Slate)
disk("Outer paving", 148, 1.2, floorY + 1.7, COLORS.stone, Enum.Material.Concrete)
disk("Blue inlay ring", 124, 0.35, floorY + 2.45, COLORS.blue, Enum.Material.SmoothPlastic)
disk("Inner paving", 118, 0.55, floorY + 2.82, COLORS.lightStone, Enum.Material.Marble)
disk("Center medallion", 44, 0.35, floorY + 3.27, COLORS.deep, Enum.Material.Slate)
disk("Medallion face", 36, 0.25, floorY + 3.58, COLORS.blue, Enum.Material.SmoothPlastic)

-- A gentle S-curve gives the walk a more natural rhythm than a straight corridor.
local promenadePoints = {
	Vector3.new(72, 0, 0),
	Vector3.new(112, 0, -12),
	Vector3.new(154, 0, -10),
	Vector3.new(194, 0, 9),
	Vector3.new(232, 0, 8),
	Vector3.new(267, 0, 0),
	Vector3.new(292, 0, 0),
}

local function ribbonSegment(name: string, from: Vector3, to: Vector3, width: number, height: number, centerY: number, color: Color3, material: Enum.Material, lengthPadding: number)
	local delta = to - from
	local length = Vector2.new(delta.X, delta.Z).Magnitude
	local center = Vector3.new((from.X + to.X) / 2, floorY + centerY, (from.Z + to.Z) / 2)
	local p = part(name, Vector3.new(length + lengthPadding, height, width), center, color, material)
	p.CFrame = CFrame.new(center) * CFrame.Angles(0, math.atan2(-delta.Z, delta.X), 0)
	return p
end

for index = 1, #promenadePoints - 1 do
	local from = promenadePoints[index]
	local to = promenadePoints[index + 1]
	ribbonSegment("Grand promenade", from, to, 24, 0.7, 0.55, COLORS.stone, Enum.Material.Concrete, 1.2)
	ribbonSegment("Promenade center inlay", from, to, 1.2, 0.16, 0.98, COLORS.gold, Enum.Material.SmoothPlastic, -3)
	for _, side in ipairs({ -1, 1 }) do
		local edge = ribbonSegment("Promenade blue edge", from, to, 0.6, 0.22, 0.98, COLORS.blue, Enum.Material.SmoothPlastic, 1.2)
		edge.CFrame = edge.CFrame * CFrame.new(0, 0, side * 11.4)
	end
end

-- Four broad, low steps ease the change from the raised plaza to the promenade.
for index = 1, 4 do
	local stepX = 78 + index * 4
	local stepTop = 2.0 - index * 0.32
	part("Promenade transition step", Vector3.new(5, stepTop, 30), Vector3.new(stepX, floorY + stepTop / 2, 0), index % 2 == 0 and COLORS.lightStone or COLORS.stone, Enum.Material.Marble)
	part("Step edge inlay", Vector3.new(0.22, 0.18, 26), Vector3.new(stepX + 2.25, floorY + stepTop + 0.09, 0), COLORS.gold, Enum.Material.Metal)
end

-- Sculptural fountain landmark, visible from the spawn point.
local fountainX = 30
diskAt("Fountain lower plinth", fountainX, 0, 27, 2.2, floorY + 4.6, COLORS.deep, Enum.Material.Slate)
diskAt("Fountain gold trim", fountainX, 0, 23, 0.45, floorY + 5.92, COLORS.gold, Enum.Material.Metal)
diskAt("Fountain basin", fountainX, 0, 21, 1.5, floorY + 6.85, COLORS.stone, Enum.Material.Marble)
diskAt("Fountain water", fountainX, 0, 17, 0.35, floorY + 7.75, COLORS.water, Enum.Material.Glass)
local water = hub:FindFirstChild("Fountain water")
if water and water:IsA("BasePart") then
	water.Transparency = 0.18
	water.CanCollide = false
end
uprightCylinder("Fountain stem", Vector3.new(2.2, 8, 2.2), Vector3.new(fountainX, floorY + 11.6, 0), COLORS.blue, Enum.Material.Marble)
diskAt("Fountain upper bowl", fountainX, 0, 10, 0.9, floorY + 15.3, COLORS.lightStone, Enum.Material.Marble)
local jewel = part("Fountain jewel", Vector3.new(4, 4, 4), Vector3.new(fountainX, floorY + 18, 0), COLORS.teal, Enum.Material.Neon, Enum.PartType.Ball)
jewel.CanCollide = false

-- Planters and friendly stylized trees frame the open plaza without blocking movement.
for _, angle in ipairs({ 45, 135, 225, 315 }) do
	local radians = math.rad(angle)
	local x = math.cos(radians) * 61
	local z = math.sin(radians) * 61
	local planter = part("Raised planter", Vector3.new(1.2, 18, 18), Vector3.new(x, floorY + 2.15, z), COLORS.deep, Enum.Material.Slate, Enum.PartType.Cylinder)
	planter.CFrame = CFrame.new(x, floorY + 2.15, z) * CFrame.Angles(0, 0, math.pi / 2)
	local soil = part("Planter soil", Vector3.new(0.5, 14, 14), Vector3.new(x, floorY + 3, z), Color3.fromRGB(105, 78, 55), Enum.Material.Ground, Enum.PartType.Cylinder)
	soil.CFrame = CFrame.new(x, floorY + 3, z) * CFrame.Angles(0, 0, math.pi / 2)
	makeTree(x, z, 0.8)
end

-- Benches are placed around the outside edge, leaving broad, clear routes.
for _, z in ipairs({ -48, 48 }) do
	for _, x in ipairs({ -30, 30 }) do
		part("Bench seat", Vector3.new(12, 0.8, 3), Vector3.new(x, floorY + 3.5, z), COLORS.wood, Enum.Material.WoodPlanks)
		part("Bench back", Vector3.new(12, 3.5, 0.7), Vector3.new(x, floorY + 5.4, z + (z > 0 and 1.3 or -1.3)), COLORS.wood, Enum.Material.WoodPlanks)
		for _, legX in ipairs({ x - 4.5, x + 4.5 }) do
			part("Bench leg", Vector3.new(0.7, 2.8, 0.7), Vector3.new(legX, floorY + 2.2, z), COLORS.gold, Enum.Material.Metal)
		end
	end
end

-- Warm pools of light around the circular plaza and along the promenade.
for _, angle in ipairs({ 0, 60, 120, 180, 240, 300 }) do
	local radians = math.rad(angle)
	makeLamp(math.cos(radians) * 72, math.sin(radians) * 72)
end
for _, position in ipairs({
	Vector3.new(125, 0, -31), Vector3.new(125, 0, 9),
	Vector3.new(175, 0, -20), Vector3.new(175, 0, 20),
	Vector3.new(225, 0, -13), Vector3.new(225, 0, 27),
}) do
	makeLamp(position.X, position.Z)
end

-- Sculptural entry arch: round supports and an open, rising double-beam crown.
for _, z in ipairs({ -14, 14 }) do
	uprightCylinder("Welcome arch pillar", Vector3.new(4, 20, 4), Vector3.new(128, floorY + 10, z), COLORS.deep, Enum.Material.Slate)
	uprightCylinder("Welcome arch teal inlay", Vector3.new(0.7, 17, 4.2), Vector3.new(125.7, floorY + 10, z), COLORS.teal, Enum.Material.Neon)
end
for _, sign in ipairs({ -1, 1 }) do
	local z = sign * 7
	local beam = part("Welcome arch rising beam", Vector3.new(3.2, 3.2, 18), Vector3.new(128, floorY + 21.7, z), COLORS.deep, Enum.Material.Slate)
	beam.CFrame = CFrame.new(128, floorY + 21.7, z) * CFrame.Angles(math.rad(sign * 16), 0, 0)
	local trim = part("Welcome arch gold edge", Vector3.new(3.5, 0.7, 17.5), Vector3.new(128, floorY + 23.6, z), COLORS.gold, Enum.Material.Metal)
	trim.CFrame = CFrame.new(128, floorY + 23.6, z) * CFrame.Angles(math.rad(sign * 16), 0, 0)
end
makeSign("Brawl Card welcome sign", Vector3.new(128, floorY + 27, 0), "BRAWL CARD", "SOCIAL PLAZA  •  COLLECT  •  TRADE")

-- A luminous gateway gives the next district a clear destination and a signature silhouette.
local gateX = 267
for _, z in ipairs({ -13, 13 }) do
	uprightCylinder("Exchange gate pillar", Vector3.new(4, 21, 4), Vector3.new(gateX, floorY + 10.5, z), COLORS.deep, Enum.Material.Slate)
	local trim = part("Exchange gate gold trim", Vector3.new(0.65, 17, 4.2), Vector3.new(gateX - 2.2, floorY + 10.5, z), COLORS.gold, Enum.Material.Metal)
	trim.CanCollide = false
end
part("Exchange gate lintel", Vector3.new(4, 3, 30), Vector3.new(gateX, floorY + 21, 0), COLORS.deep, Enum.Material.Slate)
part("Exchange gate crown", Vector3.new(4.3, 0.8, 30), Vector3.new(gateX, floorY + 22.8, 0), COLORS.gold, Enum.Material.Metal)

local portalPane = part("Portal veil", Vector3.new(0.45, 15, 17), Vector3.new(gateX, floorY + 10, 0), COLORS.teal, Enum.Material.ForceField)
portalPane.Transparency = 0.7
portalPane.CanCollide = false

-- Faceted light nodes form a clean card-like portal ring in the gate opening.
for index = 0, 15 do
	local angle = math.rad(index * 22.5)
	local y = floorY + 10 + math.cos(angle) * 8.7
	local z = math.sin(angle) * 10.2
	local color = index % 2 == 0 and COLORS.teal or COLORS.blue
	local node = part("Portal light node", Vector3.new(2.5, 2.5, 2.5), Vector3.new(gateX - 0.65, y, z), color, Enum.Material.Neon, Enum.PartType.Ball)
	node.CanCollide = false
end
local portalCore = part("Portal core", Vector3.new(2, 2, 2), Vector3.new(gateX, floorY + 10, 0), COLORS.teal, Enum.Material.Neon, Enum.PartType.Ball)
portalCore.Transparency = 0.35
portalCore.CanCollide = false
local portalLight = Instance.new("PointLight")
portalLight.Color = COLORS.teal
portalLight.Brightness = 2
portalLight.Range = 30
portalLight.Parent = portalCore
makeSign("Exchange gate sign", Vector3.new(gateX, floorY + 27, 0), "THE EXCHANGE", "TRADE DISTRICT")

print("Design: central social plaza built.")
