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

require ("src.processors.TileProcessor")
require ("src.processors.AnimationProcessor")
require ("src.processors.PlayerInputProcessor")
require ("src.processors.TileMenuProcessor")

require ("src.data.TileData")
require ("src.data.TransformData")
require ("src.data.AnimationData")

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

	self.processors = {
		Tile = TileProcessor (self.entityManager),
		Animation = AnimationProcessor (self.entityManager, self.assetManager),
		Input = PlayerInputProcessor (self.entityManager, self.eventManager),
		TileMenu = TileMenuProcessor (self.entityManager, self.assetManager)
	}

	self.eventManager:subscribe ("KeyboardKeyUpEvent", self.processors.Input)
	self.eventManager:subscribe ("KeyboardKeyDownEvent", self.processors.Input)
	self.eventManager:subscribe ("MouseButtonDownEvent", self.processors.Input)
	self.eventManager:subscribe ("MouseButtonUpEvent", self.processors.Input)
	self.eventManager:subscribe ("MouseMovedEvent", self.processors.Input)

	self.eventManager:subscribe ("ResizeEvent", self.processors.TileMenu)

	for y = 0, 9, 1 do
		for x = 0, 9, 1 do
			local eid = self.entityManager:createEntity ({"tile"})
			self.entityManager
				:addData (eid, TransformData ())
			self.entityManager
				:addData (eid, TileData (x, y, TileData.Type.Grass))
			self.entityManager
				:addData (eid, AnimationData ("gfx/tile"))
				.color = {r = 0, g = 255, b = 0, a = 255}
		end
	end

	--local menuEid = self.entityManager:createEntity ({"tilemenu"})
	--self.entityManager
	--	:addData (menuEid, TransformData ())
	--self.entityManager
	--	:addData (menuEid, TileSelectionMenuData (TileData.Type, {width = 256, height = 512}))

	--local yoff = 0
	--for _, tileTyp in pairs (TileData.Type) do
	--	local eid = self.entityManager:createEntity ({"tile"})
	--	self.entityManager:addData (eid, TransformData ())
	--	self.entityManager
	--		:addData (eid, AnimationData ("gfx/tile"))
	--		.color = {r = }
	--end
end

-- Raises (queues) a new event
function Game:raise (event)
	self.eventManager:push (event)
end

-- Callback used by EventManager
function Game:handle (event)
	if event:getClass () == "TileSelectedEvent" then
		print ("jorp")
	end
end

-- Updates game logic
function Game:onUpdate (dt)
	self.eventManager:update (dt)

	self.processors.Tile:onUpdate (dt)
	self.processors.Animation:onUpdate (dt)
	--self.processors.TileMenu:onUpdate (dt)
end

-- Renders stuff onto the screen
function Game:onRender ()
	self.processors.Animation:onRender (dt)
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
