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

	self.events:subscribe ("BuildModeStartEvent", self)

	self.build_question = {
		msg = "BUILD?!",
		x = 500, y = 700
	}
	self.abort_question = {
		msg = "ABORT?!",
		x = 600, y = 700
	}

	self.question_font = love.graphics.newFont (21)
end

function BuildModeProcessor:onUpdate (dt)
	if not self.active then
		return
	end

	for y = 1, PlanetData.MapSize.Height do
		for x = 1, PlanetData.MapSize.Width do
			self.tileanimations[y][x].color.g = 255
		end
	end

	if self.hoveredTilePosition then
		self.tileanimations[self.hoveredTilePosition.y][self.hoveredTilePosition.x]
			.color.g = 0
	end

	self.total = 0
	for y = 1, PlanetData.MapSize.Height do
		for x = 1, PlanetData.MapSize.Width do
			if self.currentPlanet.map[y][x] ~= self.buildmap[y][x] then
				self.total = self.total + self.buildmap[y][x].price
			end
		end
	end

	self.rating = self:calculateRating(self.currentPlanet)
end

function BuildModeProcessor:onRender ()
	if not self.active then
		return
	end

	local fontbuffer = love.graphics.getFont ()
	love.graphics.setFont (self.question_font)

	love.graphics.print ("total: " .. self.total.." rating: "..self.rating, self.mapOffset.x, 680)

	love.graphics.print (self.build_question.msg, self.build_question.x, self.build_question.y)
	love.graphics.print (self.abort_question.msg, self.abort_question.x, self.abort_question.y)
	love.graphics.setFont (fontbuffer)
end

function BuildModeProcessor:handle (event)
	local name = event:getClass ()

	if "BuildModeStartEvent" == name then
		print ("starting")
		self:startBuildMode (event)
		return
	end

	if "BuildModeEndEvent" == name then
		self:endBuildMode (event)
		return
	end

	if "MouseMovedEvent" == name then
		self:checkHover (event)
		return
	end

	if "MouseButtonDownEvent" == name then
		self:onMousedown (event)
		return
	end

	if "MouseButtonUpEvent" == name then
		self:onMouseup (event)
		return
	end
end

function BuildModeProcessor:startBuildMode (event)
	self.active = true

	self.currentPlanet = nil
	self.currentTileToBuild = nil
	self.hoveredTilePosition = nil
	self.buildmap = {}

	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	self.currentPlanet = gd.planets[event.planetName]
	assert (self.currentPlanet, "no planet called " .. event.planetName)

	for y = 1, PlanetData.MapSize.Height do
		self.buildmap[y] = {}
		for x = 1, PlanetData.MapSize.Width do
			self.buildmap[y][x] = self.currentPlanet.map[y][x]
		end
	end

	-- add map tiles
	local bg = self.entities:createEntity ({"build-menu"})

	self.entities:addData (bg, TransformData (self.mapOffset.x, self.mapOffset.y))
	local bganimation =
		self.entities:addData (bg, AnimationData ("gfx/tile/Empty"))
	bganimation.color.a = 64

	self.tileanimations = {}
	for y = 1, PlanetData.MapSize.Height do
		self.tileanimations[y] = {}
		for x = 1, PlanetData.MapSize.Width do
			local tile = self.currentPlanet.map[y][x]
			local key = "gfx/tile/" .. tile.name
			local ani = bganimation:addChild (AnimationData (key))
			ani.offset.x = x - 1
			ani.offset.y = y - 1

			self.tileanimations[y][x] = ani
		end
	end

	-- add tile menu
	self.tilemenu = {}
	for _, tile in pairs (PlanetData.TileType) do
		local ani =
			bganimation:addChild (AnimationData ("gfx/tile/"..tile.name))
		ani.offset.x = PlanetData.MapSize.Width + 1
		ani.offset.y = #self.tilemenu
		ani.buttonname = tile.name

		table.insert (self.tilemenu, ani)
	end

	self.events:subscribe ("MouseMovedEvent", self)
	self.events:subscribe ("MouseButtonDownEvent", self)
	self.events:subscribe ("MouseButtonUpEvent", self)
end

function BuildModeProcessor:endBuildMode (event)
	self.active = false

	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- get all map tiles and delete them
	local tiles = self.entities:findEntitiesWithTag ({"build-menu"})
	for _, eid in pairs (tiles) do
		self.entities:deleteEntity (eid)
	end
	-- free shortcut lists
	self.tileanimations = nil
	self.tilemenu = nil

	self.events:unsubscribe ("MouseMovedEvent", self)
	self.events:unsubscribe ("MouseButtonDownEvent", self)
	self.events:unsubscribe ("MouseButtonUpEvent", self)

	self.events:push (PlanetOverviewStartEvent ())
end

function BuildModeProcessor:calculateRating (planet)
	local difficulty = 0
	local attractiveness = 0
	for y = 1, PlanetData.MapSize.Height do
		for x = 1, PlanetData.MapSize.Width do
			difficulty = difficulty + planet.map[y][x].difficulty
			attractiveness = attractiveness + planet.map[y][x].attractiveness
		end
	end
	local mapSize = PlanetData.MapSize.Width * PlanetData.MapSize.Height
	local maxDif = 0
	for _, tile in pairs (PlanetData.TileType) do
		if maxDif < tile.difficulty then maxDif = tile.difficulty end
	end
	local maximumDifficulty = maxDif * mapSize
	return attractiveness
		* (1 - (difficulty / maximumDifficulty))
		* planet.biome.attractiveness
end

function BuildModeProcessor:checkHover (event)
	local parts = {
		x = math.ceil ((event.position.x - self.mapOffset.x) / PlanetData.TileSize),
		y = math.ceil ((event.position.y - self.mapOffset.y) / PlanetData.TileSize)
	}

	local hoversovermap = 0 < parts.x and parts.x <= PlanetData.MapSize.Width
		and 0 < parts.y and parts.y <= PlanetData.MapSize.Height

	self.hoveredTilePosition = nil
	if hoversovermap then
		self.hoveredTilePosition = {
			x = parts.x,
			y = parts.y
		}
	end
end

function BuildModeProcessor:isMenuButton (event)
	local menupos = {
		x = (PlanetData.TileSize * (PlanetData.MapSize.Width + 1)) + self.mapOffset.x,
		y = PlanetData.TileSize
	}
	local ypart =
		math.ceil ((event.position.y - self.mapOffset.y) / PlanetData.TileSize)

	if
		menupos.x < event.position.x
		and event.position.x < (menupos.x + PlanetData.TileSize)
		and 0 < ypart and ypart <= #self.tilemenu
	then
		return self.tilemenu[ypart].buttonname
	end

	return false
end

function BuildModeProcessor:isMapTile (event)
	if not self.hoveredTilePosition then
		return false
	end

	return self.hoveredTilePosition
end

function BuildModeProcessor:checkIfTextIsClicked (event)
	local font = self.question_font

	if
		self.abort_question.x < event.position.x
		and event.position.x < (self.abort_question.x + font:getWidth (self.abort_question.msg))
		and self.abort_question.y < event.position.y
		and event.position.y < (self.abort_question.y + font:getHeight ())
	then
		return self.abort_question.msg
	end

	if
		self.build_question.x < event.position.x
		and event.position.x < (self.build_question.x + font:getWidth (self.build_question.msg))
		and self.build_question.y < event.position.y
		and event.position.y < (self.build_question.y + font:getHeight ())
	then
		return self.build_question.msg
	end

	return false
end

function BuildModeProcessor:onMousedown (event)
	-- check if abort or build is clicked
	local gd = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	local arrrrghButton = self:checkIfTextIsClicked (event)
	if arrrrghButton then
		if arrrrghButton == self.abort_question.msg then
			gd.lastmsg = "Abort is better then ..."
			self:endBuildMode (nil)
			return
		end
		if arrrrghButton == self.build_question.msg then
			-- update shit

			if self.total <= gd.money then
				gd.money = gd.money - self.total
				self.currentPlanet.map = self.buildmap
				gd.lastmsg = "You bought a lot of fancy shizzle!"
			else
				gd.lastmsg = "Y U NOT HAZ ENOUGH MONEYZ"
			end
			self:endBuildMode (nil)
			return
		end
	end

	-- check if menu is clicked
	local tileButton = self:isMenuButton (event)
	if tileButton then
		print ("menu botton " .. tileButton .. " clicked")
		self.currentTileToBuild = tileButton
		return
	end

	-- check if map is clicked
	local tilePos = self:isMapTile (event)
	if tilePos then
		if not self.currentTileToBuild then
			print ("no tile selected!")
			return
		end
		-- set tile type to selected type
		self.buildmap[tilePos.y][tilePos.x] = PlanetData.TileType[self.currentTileToBuild]
		-- set visual type
		self.tileanimations[tilePos.y][tilePos.x].key =
			"gfx/tile/" .. self.buildmap[tilePos.y][tilePos.x].name
		return
	end
end

function BuildModeProcessor:onMouseup (event)
end
