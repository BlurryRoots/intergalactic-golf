require ("lib.lclass")
require ("lib.yanecos.Processor")

class "BuildModeProcessor" ("Processor")

function BuildModeProcessor:BuildModeProcessor (entities, events, assets)
	self.entities = entities
	self.events = events
	self.assets = assets

	self.mapOffset = {
		x = PlanetData.TileSize / 2,
		y = PlanetData.TileSize / 2
	}

	self.currentPlanet = nil
end

function BuildModeProcessor:onUpdate (dt)
end

function BuildModeProcessor:onRender ()
end

function BuildModeProcessor:handle (event)
	local name = event:getClass ()
	if "StartBuildModeEvent" == name then
		self:startBuildMode (event)
		return
	end

	if "EndBuildModeEvent" == name then
		self:endBuildMode (event)
		return
	end

	if "MouseMovedEvent" == name then
		self:checkHover (event)
	end
end

function BuildModeProcessor:startBuildMode (event)
	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- add map tiles
	self.currentPlanet = event.planetName
	local planet = gd.planets[self.currentPlanet]
	assert (planet, "no planet called " .. event.planetName)

	-- add tile menu
	local bg = self.entities:createEntity ({"build-menu"})

	self.entities:addData (bg, TransformData (self.mapOffset.x, self.mapOffset.y))
	local bganimation =
		self.entities:addData (bg, AnimationData ("gfx/tile/Empty"))
	bganimation.color.a = 64

	self.tileanimatios = {}
	for y = 1, PlanetData.MapSize.Height do
		self.tileanimatios[y] = {}
		for x = 1, PlanetData.MapSize.Width do
			local tile = planet.map[y][x]
			local key = "gfx/tile/" .. tile.name
			local ani = bganimation:addChild (AnimationData (key))
			ani.offset.x = x - 1
			ani.offset.y = y - 1

			self.tileanimatios[y][x] = ani
		end
	end

	self.events:subscribe ("MouseMovedEvent", self)
end

function BuildModeProcessor:endBuildMode (event)
	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- get all map tiles and delete them
	local tiles = self.entities:findEntitiesWithTag ({"build-menu"})
	for _, eid in pairs (tiles) do
		self.entities:deleteEntity (eid)
	end
	self.tileanimatios = nil

	self.events:unsubscribe ("MouseMovedEvent", self)
end

function BuildModeProcessor:checkHover (event)
	local parts = {
		x = math.ceil ((event.position.x - self.mapOffset.x) / PlanetData.TileSize),
		y = math.ceil ((event.position.y - self.mapOffset.y) / PlanetData.TileSize)
	}

	local hoversovermap =
		0 < parts.x and parts.x <= PlanetData.MapSize.Width
		and
		0 < parts.y and parts.y <= PlanetData.MapSize.Height

	if hoversovermap then
		self.tileanimatios[parts.y][parts.x].color.g = 0
	end
end
