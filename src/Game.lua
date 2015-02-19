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

require ("src.processors.TileProcessor")
require ("src.processors.AnimationProcessor")

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

	self.processors = {
		Tile = TileProcessor (self.entityManager),
		Animation = AnimationProcessor (self.entityManager, self.assetManager)
	}
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
	self.processors.Animation:onUpdate (dt)
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
