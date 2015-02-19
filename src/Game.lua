require ("lib.lclass")

require ("src.EventManager")

require ("src.events.FocusGainedEvent")
require ("src.events.FocusLostEvent")
require ("src.events.KeyboardKeyDownEvent")
require ("src.events.KeyboardKeyUpEvent")
require ("src.events.MouseButtonDownEvent")
require ("src.events.MouseButtonUpEvent")
require ("src.events.ResizeEvent")

class "Game"

-- Constructs a new game
function Game:Game ()
	self.eventManager = EventManager ()

	self.eventManager:subscribe ("FocusGainedEvent", self)
	self.eventManager:subscribe ("FocusLostEvent", self)
	self.eventManager:subscribe ("KeyboardKeyDownEvent", self)
	self.eventManager:subscribe ("KeyboardKeyUpEvent", self)
	self.eventManager:subscribe ("MouseButtonDownEvent", self)
	self.eventManager:subscribe ("MouseButtonUpEvent", self)
	self.eventManager:subscribe ("ResizeEvent", self)
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
end

-- Renders stuff onto the screen
function Game:onRender ()
	--
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
