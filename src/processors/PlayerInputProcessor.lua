require ("lib.lclass")
require ("lib.yanecos.Processor")

class "PlayerInputProcessor" ("Processor")

function PlayerInputProcessor:PlayerInputProcessor (entities, events)
	self.entities = entities
	self.events = events

	self.reactions = {
		KeyboardKeyUpEvent =  {
			escape = function ()
				love.event.quit()
			end,
		},

		KeyboardKeyDownEvent = {
		}
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
