require ("lib.lclass")
require ("lib.yagl.AssetManager")
require ("lib.yanecos.EntityManager")

require ("src.EventManager")

require ("src.events.FocusGainedEvent")
require ("src.events.FocusLostEvent")
require ("src.events.KeyboardKeyDownEvent")
require ("src.events.KeyboardKeyUpEvent")
require ("src.events.MouseButtonDownEvent")
require ("src.events.MouseButtonUpEvent")
require ("src.events.ResizeEvent")
require ("src.events.MouseMovedEvent")
require ("src.events.TileSelectedEvent")
require ("src.events.TileHoveredEvent")

require ("src.processors.TileProcessor")
require ("src.processors.AnimationProcessor")
require ("src.processors.PlayerInputProcessor")

require ("src.data.TileData")
require ("src.data.TransformData")
require ("src.data.AnimationData")
require ("src.data.BuildScreenData")

class "Game"

-- Constructs a new game
function Game:Game ()
	self.eventManager = EventManager ()
	self.assetManager = AssetManager ()
	self.entityManager = EntityManager ()

	self.eventManager:subscribe ("FocusGainedEvent", self)
	self.eventManager:subscribe ("FocusLostEvent", self)
	self.eventManager:subscribe ("KeyboardKeyDownEvent", self)
	self.eventManager:subscribe ("KeyboardKeyUpEvent", self)
	self.eventManager:subscribe ("MouseButtonDownEvent", self)
	self.eventManager:subscribe ("MouseButtonUpEvent", self)
	self.eventManager:subscribe ("ResizeEvent", self)
	self.eventManager:subscribe ("TileSelectedEvent", self)

	self.assetManager:loadImage ("gfx/empty_tile.png", "gfx/tile")
	self.assetManager:loadImage ("gfx/start_tile.png", "gfx/Start")
	self.assetManager:loadImage ("gfx/end_tile.png", "gfx/End")
	self.assetManager:loadImage ("gfx/grass_tile.png", "gfx/Grass")
	self.assetManager:loadImage ("gfx/sand_tile.png", "gfx/Sand")
	self.assetManager:loadImage ("gfx/lake_tile.png", "gfx/Lake")

	self.processors = {
		Tile = TileProcessor (self.entityManager),
		Animation = AnimationProcessor (self.entityManager, self.assetManager),
		Input = PlayerInputProcessor (self.entityManager, self.eventManager),
	}

	self.eventManager:subscribe ("ResizeEvent", self.processors.TileMenu)

	local mapHeight = 10
	local mapWidth = 13
	for y = 0, mapHeight -1 , 1 do
		for x = 0, mapWidth - 1, 1 do
			local eid = self.entityManager:createEntity ({"tile"})
			self.entityManager
				:addData (eid, TransformData ())
			self.entityManager
				:addData (eid, TileData (x, y, TileData.Type.Grass))
			self.entityManager
				:addData (eid, AnimationData ("gfx/Grass"))
		end
	end

	--local xoff = mapWidth * TileData.Size.w
	local yoff = 0
	for tileName, tileTyp in pairs (TileData.Type) do
		local eid = self.entityManager:createEntity ({"tilemenu"})
		self.entityManager
			:addData (eid, TransformData (xoff, yoff))
		self.entityManager
				:addData (eid, TileData (mapWidth, yoff, tileTyp))
		self.entityManager
			:addData (eid, AnimationData ("gfx/"..tileName))
		yoff = yoff + 1
	end


	local eid = self.entityManager:createEntity ({"buildscreen"})
	self.entityManager:addData (eid, BuildScreenData ())
end

-- Raises (queues) a new event
function Game:raise (event)
	self.eventManager:push (event)
end

-- Callback used by EventManager
function Game:handle (event)
end

-- Updates game logic
function Game:onUpdate (dt)
	self.eventManager:update (dt)

	self.processors.Tile:onUpdate (dt)
	self.processors.Animation:onUpdate (dt)
end

-- Renders stuff onto the screen
function Game:onRender ()
	self.processors.Animation:onRender (dt)
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
