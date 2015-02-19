require ("lib.lclass")
require ("lib.yanecos.Processor")
require ("lib.yanecos.EntityManager")

require ("src.events.MouseMovedEvent")
require ("src.events.TileSelectedEvent")

class "PlayerInputProcessor" ("Processor")

function PlayerInputProcessor:PlayerInputProcessor (entityManager, eventManager)
	self.em = entityManager
	self.eventManager = eventManager

	self.keyReactions = {
		KeyboardKeyUpEvent =  {
			escape = function ()
				love.event.quit()
			end,
		},
	}

	self.mouseMoveReactions = {
		MouseMovedEvent = function (event)
			self:handleMouseMoved (event)
		end
	}

	self.mouseButtonReactions = {
		MouseButtonUpEvent = function (event)
			if self.hoveredTile then
				self.eventManager:push (TileSelectedEvent (self.hoveredTile))
			end
		end
	}

	self.hoveredTile = nil
end

function PlayerInputProcessor:containsPosition (transform, size, event)
	return transform.x < event.position.x
		and transform.y < event.position.y
		and event.position.x < (transform.x + size.w)
		and event.position.y < (transform.y + size.h)
end

function PlayerInputProcessor:onUpdate (dt)
end

function PlayerInputProcessor:handleMouseMoved (event)
	local tiles = self.em:findEntitiesWithTag ({"tile"})
	self.hoveredTile = nil

	for _, eid in pairs (tiles) do
		local transform = self.em:getData (eid, TransformData:getClass ())
		local animation = self.em:getData (eid, AnimationData:getClass ())

		animation.color.g = 255
		animation.color.r = 0

		if (self:containsPosition (transform, TileData.Size, event)) then
			animation.color.g = 0
			animation.color.r = 255
			self.hoveredTile = eid
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
end
