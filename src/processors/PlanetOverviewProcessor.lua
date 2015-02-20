require ("lib.lclass")
require ("lib.yanecos.Processor")

require ("src.data.TransformData")

class "PlanetOverviewProcessor" ("Processor")

function PlanetOverviewProcessor:PlanetOverviewProcessor (entities, events, assets)
	self.entities = entities
	self.events = events
	self.assets = assets
	self.active = false

	self.events:subscribe ("PlanetOverviewStartEvent", self)
	self.events:subscribe ("PlanetOverviewEndEvent", self)
end

function PlanetOverviewProcessor:onUpdate (dt)
	if not self.active then
		return
	end
end

function PlanetOverviewProcessor:onRender ()
	if not self.active then
		return
	end
end

local inspect = require ("lib.inspect")
function PlanetOverviewProcessor:handle (event)
	local name = event:getClass ()

	if "PlanetOverviewStartEvent" == name then
		self:startOverview (event)
		return
	end

	if "PlanetOverviewEndEvent" == name then
		self:endOverview (event)
		return
	end

	if "MouseButtonDownEvent" == name then
		self:onMousedown (event)
		return
	end
end

function PlanetOverviewProcessor:startOverview (event)
	-- register event handlers
	self.events:subscribe ("MouseButtonDownEvent", self)

	-- create base entity (visual)
	local eid = self.entities:createEntity ({"planet-overview"})
	print ("event is " .. inspect (TransformData))
	self.entities:addData (eid, TransformData (0, 0))

	local bganimation = self.entities:addData (eid, AnimationData ("gfx/Background"))
	local gamedata = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	self.planetanimations = {}
	for _, planets in pairs (gamedata) do
		table.insert (
			self.planetanimations,
			bganimation:addChild (AnimationData ("gfx/Planet"))
		)
	end

	for i, planet in pairs (self.planetanimations) do
		planet.offset.x = 0.0
		planet.offset.y = 0.0
	end
	-- create animation tree
end

function PlanetOverviewProcessor:endOverview (event)
	-- cleanup
	self.planetanimations = {}

	for _, eid in pairs (self.entities:getEntitiesWithTag ({"gamedata"})) do
		self.entities:deleteEntity (eid)
	end

	-- unregister events
	self.events:unsubscribe ("MouseButtonDownEvent", self)
end

function PlanetOverviewProcessor:onMousedown (event)
	-- check if planet has been clicked
		-- populate stats window (price, biome and is bought?)
	-- how to buy a planet?
end
