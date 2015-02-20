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

	self.tileids = {}
	for y = 1, PlanetData.MapSize.Height do
		self.tileids[y] = {}
		for x = 1, PlanetData.MapSize.Width do
			local eid = self.entities:createEntity ({"map-tiles"})
			self.tileids[y][x] = eid

			local transform = self.entities:addData (eid, TransformData ())
			local tile = planet.map[y][x]
			transform.x = (x - 1) * PlanetData.TileSize + self.mapOffset.x
			transform.y = (y - 1) * PlanetData.TileSize + self.mapOffset.y

			local key = "gfx/tile/" .. tile.name
			local animation = self.entities:addData (eid, AnimationData (key))

			local hitbox = self.entities:addData (
				eid,
				HitboxData (PlanetData.TileSize, PlanetData.TileSize)
			)
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
	local tiles = self.entities:findEntitiesWithTag ({"map-tiles"})
	for _, eid in pairs (tiles) do
		self.entities:deleteEntity (eid)
	end

	self.events:unsubscribe ("MouseMovedEvent", self)
end

local inspect = require ("lib.inspect")
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
		print ("hovering over " .. parts.x .. ":" .. parts.y)
		local animation = self.entities:getData (
			self.tileids[parts.y][parts.x],
			AnimationData:getClass ()
		)
		assert (animation, "No no no animation")
		animation.color.g = 0
	end
end
