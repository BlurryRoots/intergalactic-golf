require ("lib.lclass")
require ("lib.yanecos.Processor")

class "BuildModeProcessor" ("Processor")

function BuildModeProcessor:BuildModeProcessor (entityManager, assets)
	self.entities = entityManager
	self.assets = assets
end

function BuildModeProcessor:onUpdate (dt)
end

function BuildModeProcessor:onRender ()
end

function BuildModeProcessor:startBuildMode (event)
	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- add map tiles
	local planet = gd.planets[event.planetName]
	assert (planet, "no planet called " .. event.planetName)

	for y = 1, PlanetData.MapSize.Height do
		for x = 1, PlanetData.MapSize.Width do
			local eid = self.entities:createEntity ({"map-tiles"})

			local transform = self.entities:addData (eid, TransformData ())
			local tile = planet.map[y][x]
			transform.x = x * PlanetData.TileSize
			transform.y = y * PlanetData.TileSize

			local key = "gfx/tile/" .. tile.name
			local animation = self.entities:addData (eid, AnimationData (key))
		end
	end
end

function BuildModeProcessor:endBuildMode (event)
	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- get all map tiles and delete them
	local tiles = self.entities:findEntitiesWithTag ({"map-tiles"})
	for _, eid in pairs (tiles) do
		self.entities:deleteEntity (eid)
	end
end

function BuildModeProcessor:handle (event)
	if "StartBuildModeEvent" == event:getClass () then
		self:startBuildMode (event)
		return
	end

	if "EndBuildModeEvent" == event:getClass () then
		self:endBuildMode (event)
		return
	end
end
