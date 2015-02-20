require ("lib.lclass")
require ("lib.yanecos.Data")

class "PlanetData" ("Data")

local function addBiome (t, p, a, name, def)
	t[name] = {
		price = p,
		attractiveness = a,
		name = name,
		defaultTileName = def,
	}
end

local function addTileType (t, p, a, d, name)
	t[name] = {
		attractiveness = a,
		price = p,
		difficulty = d,
		name = name,
	}
end

PlanetData.Biomes = {}
addBiome (PlanetData.Biomes, 100000, 1.0, "Grassland", "Grass")
addBiome (PlanetData.Biomes, 150000, 1.5, "Tropical", "Bush")
addBiome (PlanetData.Biomes, 120000, 1.2, "Temperate", "Plane")
addBiome (PlanetData.Biomes,  90000, 0.9, "Tundra", "Barren")

PlanetData.TileType = {}
-- defaults for biomes
addTileType (PlanetData.TileType, 1500, 0.5, 1, "Grass")
addTileType (PlanetData.TileType, 1500, 0.5, 1, "Bush")
addTileType (PlanetData.TileType, 1500, 0.5, 1, "Plane")
addTileType (PlanetData.TileType, 1000, 0.3, 1, "Barren")
-- additional tiles to build
addTileType (PlanetData.TileType,  250, 1.0, 1, "Start")
addTileType (PlanetData.TileType,  250, 1.0, 1, "End")
addTileType (PlanetData.TileType, 1500, 0.5, 1, "Lawn")
addTileType (PlanetData.TileType, 1000, 0.3, 1, "Sand")
addTileType (PlanetData.TileType, 5000, 0.9, 1, "Lake")

PlanetData.MapSize = {
	Width = 13,
	Height = 10
}

PlanetData.TileSize = 64

function PlanetData:PlanetData (biome)
	self.bought = false
	self.biome = biome or PlanetData.Biomes.Grassland
	self.map = {}

	local defaultType = PlanetData.TileType[self.biome.defaultTileName]
	if not defaultType then
		error ("No default found for " .. self.biome.defaultTileName)
	end
	for y = 1, PlanetData.MapSize.Height do
		self.map[y] = {}
		for x = 1, PlanetData.MapSize.Width do
			self.map[y][x] = defaultType
		end
	end
end
