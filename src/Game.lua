require ("lib.lclass")
require ("lib.yanecos.EntityManager")
require ("lib.yagl.AssetManager")

require ("src.EventManager")

require ("src.events.BuildModeEndEvent")
require ("src.events.BuildModeStartEvent")
require ("src.events.FocusGainedEvent")
require ("src.events.FocusLostEvent")
require ("src.events.KeyboardKeyDownEvent")
require ("src.events.KeyboardKeyUpEvent")
require ("src.events.MouseButtonDownEvent")
require ("src.events.MouseButtonUpEvent")
require ("src.events.PlaySoundEvent")
require ("src.events.ResizeEvent")

require ("src.data.AnimationData")
require ("src.data.GameData")
require ("src.data.HitboxData")
require ("src.data.PlanetData")
require ("src.data.TransformData")

require ("src.processors.AnimationProcessor")
require ("src.processors.BuildModeProcessor")
require ("src.processors.MovementProcessor")
require ("src.processors.PlayerInputProcessor")
require ("src.processors.SoundProcessor")

local inspect = require ("lib.inspect")

class "Game"

-- Constructs a new game
function Game:Game ()
	self.events = EventManager ()
	self.events:subscribe ("FocusGainedEvent", self)
	self.events:subscribe ("FocusLostEvent", self)
	self.events:subscribe ("KeyboardKeyDownEvent", self)
	self.events:subscribe ("KeyboardKeyUpEvent", self)
	self.events:subscribe ("MouseButtonDownEvent", self)
	self.events:subscribe ("MouseButtonUpEvent", self)
	self.events:subscribe ("ResizeEvent", self)

	self.assets = AssetManager ()

	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Grass")
	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Bush")
	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Plane")
	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Barren")

	self.assets:loadImage ("gfx/empty_tile.png", "gfx/tile/Empty")
	self.assets:loadImage ("gfx/end_tile.png", "gfx/tile/End")
	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Lawn")
	self.assets:loadImage ("gfx/lake_tile.png", "gfx/tile/Lake")
	self.assets:loadImage ("gfx/sand_tile.png", "gfx/tile/Sand")
	self.assets:loadImage ("gfx/start_tile.png", "gfx/tile/Start")

	self.entities = EntityManager ()
	local gd =
		self.entities
			:addData (self.entities:createEntity ({"gamedata"}), GameData ())
	gd.planets["Knurpsel"] = PlanetData ()

	self.buildModeProcessor = BuildModeProcessor (self.entities, self.assets)
	self.buildModeProcessor:startBuildMode (BuildModeStartEvent ("Knurpsel"))

	self.animationProcessor = AnimationProcessor (self.entities, self.assets)

	self.inputProcessor = PlayerInputProcessor (self.entities, self.events)
	self.events:subscribe ("KeyboardKeyDownEvent", self.inputProcessor)
	self.events:subscribe ("KeyboardKeyUpEvent", self.inputProcessor)
	self.events:subscribe ("MouseButtonDownEvent", self.inputProcessor)
	self.events:subscribe ("MouseButtonUpEvent", self.inputProcessor)
end

-- Raises (queues) a new event
function Game:raise (event)
	self.events:push (event)
end

-- Callback used by EventManager
function Game:handle (event)
end

-- Updates game logic
function Game:onUpdate (dt)
	self.events:update (dt)

	self.buildModeProcessor:onUpdate (dt)
	self.inputProcessor:onUpdate (dt)
end

-- Renders stuff onto the screen
function Game:onRender ()
	self.buildModeProcessor:onRender ()
	self.animationProcessor:onRender ()
	self.inputProcessor:onRender ()
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
