require ("lib.lclass")
require ("lib.yanecos.Processor")

require ("src.events.FireMissileEvent")

class "PlayerInputProcessor" ("Processor")

function PlayerInputProcessor:PlayerInputProcessor (entityManager, eventManager)
	self.entityManager = entityManager
	self.eventManager = eventManager

	self.reactions = {
		KeyboardKeyUpEvent =  {
			escape = function ()
				love.event.quit()
			end,
		},
	}
end

function PlayerInputProcessor:onUpdate (dt)
end

function PlayerInputProcessor:handle (event)
	local keymap = self.reactions[event:getClass()]
	if keymap and keymap[event:Key ()] then
		keymap[event:Key ()] ()
	end
end
