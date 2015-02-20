require ("lib.lclass")
require ("lib.yanecos.EntityManager")
require ("lib.yagl.AssetManager")

require ("src.EventManager")

require ("src.events.BuildModeEndEvent")
require ("src.events.BuildModeStartEvent")
require ("src.events.PlanetOverviewStartEvent")
require ("src.events.PlanetOverviewEndEvent")

require ("src.data.AnimationData")
require ("src.data.GameData")
require ("src.data.HitboxData")
require ("src.data.PlanetData")
require ("src.data.TransformData")

require ("src.processors.AnimationProcessor")
require ("src.processors.BuildModeProcessor")
require ("src.processors.MovementProcessor")
require ("src.processors.PlanetOverviewProcessor")
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
	self.assets:loadImage ("gfx/bush_tile.png", "gfx/tile/Bush")
	self.assets:loadImage ("gfx/plain_tile.png", "gfx/tile/Plain")
	self.assets:loadImage ("gfx/barren_tile.png", "gfx/tile/Barren")

	self.assets:loadImage ("gfx/empty_tile.png", "gfx/tile/Empty")
	self.assets:loadImage ("gfx/end_tile.png", "gfx/tile/End")
	self.assets:loadImage ("gfx/grass_tile.png", "gfx/tile/Lawn")
	self.assets:loadImage ("gfx/lake_tile.png", "gfx/tile/Lake")
	self.assets:loadImage ("gfx/sand_tile.png", "gfx/tile/Sand")
	self.assets:loadImage ("gfx/start_tile.png", "gfx/tile/Start")

	self.assets:loadImage ("gfx/planet.png", "gfx/Planet")
	self.assets:loadImage ("gfx/bg.png", "gfx/Background")

	self.entities = EntityManager ()
	self.gd =
		self.entities
			:addData (self.entities:createEntity ({"gamedata"}), GameData ())
	self.gd.resolution = {w = 1280, h = 920}
	self.gd.population = 100000
	self.gd.money = 0
	self.gd.planets["Knurpsel1"] = PlanetData (PlanetData.Biomes.Tundra)
	self.gd.planets["Knurpsel2"] = PlanetData (PlanetData.Biomes.Tropical)
	self.gd.planets["Knurpsel3"] = PlanetData (PlanetData.Biomes.Grassland)
	self.gd.planets["Knurpsel4"] = PlanetData (PlanetData.Biomes.Temperate)

	self.buildModeProcessor =
		BuildModeProcessor (self.entities, self.events, self.assets)
	--self.buildModeProcessor:handle (BuildModeStartEvent ("Knurpsel4"))

	self.planetOverviewProcessor =
		PlanetOverviewProcessor (self.entities, self.events, self.assets)
	local e = PlanetOverviewStartEvent ()
	print (inspect (e.getClass))
	self.planetOverviewProcessor:handle (e)

	self.animationProcessor = AnimationProcessor (self.entities, self.assets)

	self.inputProcessor = PlayerInputProcessor (self.entities, self.events)
	self.events:subscribe ("KeyboardKeyDownEvent", self.inputProcessor)
	self.events:subscribe ("KeyboardKeyUpEvent", self.inputProcessor)
	self.events:subscribe ("MouseButtonDownEvent", self.inputProcessor)
	self.events:subscribe ("MouseButtonUpEvent", self.inputProcessor)
	self.events:subscribe ("MouseMovedEvent", self.inputProcessor)
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

	local moneyfactor = 10
	for _,planet in pairs(self.gd.planets) do
		if planet.bought then
			local rating = self.buildModeProcessor:calculateRating (planet.map)
			self.gd.money = self.gd.money + rating * dt * moneyfactor
		end
	end
end

-- Renders stuff onto the screen
function Game:onRender ()
	self.buildModeProcessor:onRender ()
	self.animationProcessor:onRender ()
	self.inputProcessor:onRender ()

	love.graphics.print ("money: " .. self.gd.money, 32, 720)
end

-- Gets called when game exits. May be used to do some clean up.
function Game:onExit ()
	--
end
