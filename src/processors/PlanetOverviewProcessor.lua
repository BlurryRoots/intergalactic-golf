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

	self.msg = "3=====> --- (.)(.)"
end

function PlanetOverviewProcessor:onUpdate (dt)
	if not self.active then
		return
	end

	for _, p in pairs (self.planetanimations) do
		p.color.b = 255
	end

	self.kooftext = nil
	if self.selectedplanet then
		self.selectedplanet.color.b = 0
		if self.selectedplanet.planet.bought then
			self.kooftext = "Basteln?"
		else
			self.kooftext = "Koofen?"
		end
	end
end

function PlanetOverviewProcessor:onRender ()
	if not self.active then
		return
	end

	love.graphics.print ("Planet Info:\n" .. self.msg, 800, 42)
	if self.kooftext then
		local ax = self.selectedplanet.offset.x * 256 + self.bgtransform.x
		local ay = self.selectedplanet.offset.y * 256 + self.bgtransform.y
		love.graphics.print (self.kooftext, ax, ay)
	end
end

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
	self.active = true
	-- register event handlers
	self.events:subscribe ("MouseButtonDownEvent", self)

	self.gamedata = self.entities:getData (
		self.entities:firstEntityWithTag ({"gamedata"}),
		GameData:getClass ()
	)

	-- create base entity (visual)
	local eid = self.entities:createEntity ({"planet-overview"})
	self.bgtransform = self.entities:addData (eid, TransformData ())

	self.bganimation = self.entities:addData (eid, AnimationData ("gfx/Background"))
	self.bganimation.offset.x = 0
	self.bganimation.offset.y = 0

	self.planetanimations = {}
	for _, planet in pairs (self.gamedata.planets) do
		local a =
			self.bganimation:addChild (AnimationData ("gfx/Planet"))
		a.planet = planet
		table.insert (
			self.planetanimations,
			a
		)
	end

	self.planetanimations[1].offset.x = 0.5
	self.planetanimations[1].offset.y = 0.5

	self.planetanimations[2].offset.x = 1.5
	self.planetanimations[2].offset.y = 1.5

	self.planetanimations[3].offset.x = 2.5
	self.planetanimations[3].offset.y = 1.2

	self.planetanimations[4].offset.x = 3.5
	self.planetanimations[4].offset.y = 2.5
	-- create animation tree
end

local inspect = require ("lib.inspect")
function PlanetOverviewProcessor:endOverview (event)
	self.active = false
	-- cleanup
	self.planetanimations = nil
	self.bgtransform = nil
	self.bganimation = nil
	self.gamedata = nil
	self.kooftext = nil
	self.msg = "3=====> --- (.)(.)"
	self.selectedplanet = nil

	for _, eid in pairs (self.entities:findEntitiesWithTag ({"planet-overview"})) do
		self.entities:deleteEntity (eid)
	end

	-- unregister events
	self.events:unsubscribe ("MouseButtonDownEvent", self)
end

function PlanetOverviewProcessor:onMousedown (event)
	local shit = false

	-- check if planet has been clicked
	for index, planet in pairs (self.planetanimations) do
		local w = self.assets:get (planet.key):getWidth ()
		local h = self.assets:get (planet.key):getHeight ()
		local ax = planet.offset.x * w + self.bgtransform.x
		local ay = planet.offset.y * h + self.bgtransform.y

		if
			ax <= event.position.x and event.position.x <= (ax + w)
			and ay <= event.position.y and event.position.y <= (ay + h)
		then
			if self.selectedplanet == self.planetanimations[index] then
				if
					not self.selectedplanet.planet.bought
				then
					if self.gamedata.money >= self.selectedplanet.planet.biome.price then
						-- koof dat shit
						self.gamedata.money = self.gamedata.money - self.selectedplanet.planet.biome.price
						self.selectedplanet.planet.bought = true
					end
				else
					-- basteln?
					shit = true
					break
				end
			else
				local p = self.planetanimations[index].planet
				self.msg = "Price: " .. p.biome.price
					.. "\nBiome: " .. p.biome.name
					.. "\nPWND?: " .. (p.bought and "yarp" or "narp")
				self.selectedplanet = self.planetanimations[index]
			end
		end
	end

	if shit then
		print ("whyyyy")
		-- basteln?
		local name = self.selectedplanet.planet
		self.events:push (BuildModeStartEvent (name.name))
		self:endOverview (nil)
	end

	-- populate stats window (price, biome and is bought?)
	-- how to buy a planet?
end
