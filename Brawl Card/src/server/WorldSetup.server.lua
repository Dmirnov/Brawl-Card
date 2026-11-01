--!strict
-- Two open, connected flat areas. No scenery, structures, or template models.
-- Rojo maps this script into ServerScriptService.

local Workspace = game:GetService("Workspace")

local TILE_SIZE = 512
local FLOOR_THICKNESS = 8
local FLOOR_TOP_Y = 0

local function makeFlatWorld(name: string, centerX: number, material: Enum.Material, color: Color3): Part
	local oldFloor = Workspace:FindFirstChild(name)
	if oldFloor then
		oldFloor:Destroy()
	end

	local floor = Instance.new("Part")
	floor.Name = name
	floor.Anchored = true
	floor.Size = Vector3.new(TILE_SIZE, FLOOR_THICKNESS, TILE_SIZE)
	floor.Position = Vector3.new(centerX, FLOOR_TOP_Y - FLOOR_THICKNESS / 2, 0)
	floor.Material = material
	floor.Color = color
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = Workspace
	return floor
end

-- The adjoining edges meet exactly at X = 256, leaving no gap or step.
makeFlatWorld("SpawnWorld", 0, Enum.Material.Grass, Color3.fromRGB(95, 155, 80))
makeFlatWorld("TradeWorld", TILE_SIZE, Enum.Material.Concrete, Color3.fromRGB(105, 125, 150))

-- Invisible spawn marker resting on the spawn world's floor.
local previousSpawn = Workspace:FindFirstChild("PlayerSpawn")
if previousSpawn then
	previousSpawn:Destroy()
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Anchored = true
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, FLOOR_TOP_Y + 0.5, 0)
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.AllowTeamChangeOnTouch = false
spawn.Duration = 0
spawn.Parent = Workspace

-- Remove the former raised trade platform, if this script is rerun in an existing place.
local oldTradeZone = Workspace:FindFirstChild("TradeZone")
if oldTradeZone then
	oldTradeZone:Destroy()
end

print("Brawl Stars RNG Tycoon: connected spawn and trade plains created.")
