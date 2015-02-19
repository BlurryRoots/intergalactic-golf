require ("lib.lclass")
require ("lib.yanecos.Processor")
require ("lib.yanecos.EntityManager")

require ("src.events.MouseMovedEvent")

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

end

function PlayerInputProcessor:containsPosition (transform, size, event)
	return transform.x < event.position.x
		and transform.y < event.position.y
		and event.position.x < (transform.x + size.w)
		and event.position.y < (transform.y + size.h)
end

function PlayerInputProcessor:onUpdate (dt)
end

local inspect = require ("lib.inspect")
function PlayerInputProcessor:handleMouseMoved (event)
	local tiles = self.em:findEntitiesWithTag ({"tile"})

	for _, eid in pairs (tiles) do
		local transform = self.em:getData (eid, TransformData:getClass ())
		local animation = self.em:getData (eid, AnimationData:getClass ())

		animation.color.g = 255
		animation.color.r = 0

		if (self:containsPosition (transform, TileData.Size, event)) then
			animation.color.g = 0
			animation.color.r = 255
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
end
