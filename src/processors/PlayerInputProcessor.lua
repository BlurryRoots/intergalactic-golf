require ("lib.lclass")
require ("lib.yanecos.Processor")
require ("lib.yanecos.EntityManager")

require ("src.events.MouseMovedEvent")
require ("src.events.TileSelectedEvent")
require ("src.events.MenuTileSelectedEvent")

require ("src.data.BuildScreenData")
require ("src.data.TileData")

class "PlayerInputProcessor" ("Processor")

function PlayerInputProcessor:PlayerInputProcessor (entityManager, eventManager)
	self.em = entityManager
	self.eventManager = eventManager

	self.eventManager:subscribe ("KeyboardKeyUpEvent", self)
	self.eventManager:subscribe ("KeyboardKeyDownEvent", self)
	self.eventManager:subscribe ("MouseButtonDownEvent", self)
	self.eventManager:subscribe ("MouseButtonUpEvent", self)
	self.eventManager:subscribe ("MouseMovedEvent", self)
	self.eventManager:subscribe ("TileHoveredEvent", self)
	self.eventManager:subscribe ("MenuTileSelectedEvent", self)
	self.eventManager:subscribe ("TileSelectedEvent", self)

	self.keyReactions = {
		KeyboardKeyUpEvent =  {
			escape = function ()
				love.event.quit()
			end,
			r = function ()
				self.eventManager:push(CalculateRatingEvent ())
			end
		},
	}

	self.mouseMoveReactions = {
		MouseMovedEvent = function (event)
			self:handleMouseMoved (event)
		end
	}

	self.mouseButtonReactions = {
		MouseButtonUpEvent = function (event)
			if self.previousHoveredTileId then
				if self.em:hasTag (self.previousHoveredTileId, "tilemenu") then
					self.eventManager:push (MenuTileSelectedEvent (self.previousHoveredTileId))
				else
					self.eventManager:push (TileSelectedEvent (self.previousHoveredTileId))
				end
			end
		end
	}

	self.previousHoveredTileId = nil
end

function PlayerInputProcessor:containsPoint (transform, size, point)
	return transform.x < point.x
		and transform.y < point.y
		and point.x < (transform.x + size.w)
		and point.y < (transform.y + size.h)
end

function PlayerInputProcessor:onUpdate (dt)
end

function PlayerInputProcessor:handleMouseMoved (event)
	-- check if map is being hovered
	local tiles = self.em:findEntitiesWithTag ({"tile"})

	for _, eid in pairs (tiles) do
		local transform = self.em:getData (eid, TransformData:getClass ())
		local animation = self.em:getData (eid, AnimationData:getClass ())

		if (self:containsPoint (transform, TileData.Size, event.position)) then
			self.eventManager:push (TileHoveredEvent (eid))
		end
	end

	-- check if menu
	-- check if map is being hovered
	local tiles = self.em:findEntitiesWithTag ({"tilemenu"})

	for _, eid in pairs (tiles) do
		local transform = self.em:getData (eid, TransformData:getClass ())
		local animation = self.em:getData (eid, AnimationData:getClass ())

		if (self:containsPoint (transform, TileData.Size, event.position)) then
			self.eventManager:push (TileHoveredEvent (eid))
		end
	end
end

function PlayerInputProcessor:handle (event)
	local keymap = self.keyReactions[event:getClass()]
	if keymap and keymap[event:Key ()] then
		keymap[event:Key ()] ()
	end

	local mouseReaction = self.mouseMoveReactions[event:getClass ()]
	if mouseReaction then
		mouseReaction (event)
	end

	local mouseButtonReaction = self.mouseButtonReactions[event:getClass ()]
	if mouseButtonReaction then
		mouseButtonReaction (event)
	end

	if "TileHoveredEvent" == event:getClass () then
		if self.previousHoveredTileId then
			self.em
				:getData (self.previousHoveredTileId, AnimationData:getClass ())
				.color = {r = 255, g = 255, b = 255, a = 255}
		end

		self.em
			:getData (event.hoveredTileId, AnimationData:getClass ())
			.color = {r = 255, g = 64, b = 64, a = 255}
		self.previousHoveredTileId = event.hoveredTileId
	end

	if "MenuTileSelectedEvent" == event:getClass () then
		for _, eid in pairs (self.em:findEntitiesWithTag ({"buildscreen"})) do
			local buildscreendata =
				self.em:getData (eid, BuildScreenData:getClass ())
			local tile = self.em:getData (event.eid, TileData:getClass ())
			buildscreendata.buildTileType = tile.type
		end
	end

	if "TileSelectedEvent" == event:getClass () then
		for _, eid in pairs (self.em:findEntitiesWithTag ({"buildscreen"})) do
			local buildscreendata =
				self.em:getData (eid, BuildScreenData:getClass ())
			if not buildscreendata.buildTileType then
				print ("choose kekse")
			else
				local tile = self.em:getData (event.eid, TileData:getClass ())
				local animation = self.em:getData (event.eid, AnimationData:getClass ())
				tile.type = buildscreendata.buildTileType
				animation.key = "gfx/"..TileData.GetTypeName (tile.type)
				buildscreendata.shoppingList[event.eid] = tile.type.Price

				local total = 0
				for _, price in pairs(buildscreendata.shoppingList) do
					total = total + price
				end

				buildscreendata.sum = total
			end
		end
	end
end
