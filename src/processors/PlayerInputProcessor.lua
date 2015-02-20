require ("lib.lclass")
require ("lib.yanecos.Processor")

class "PlayerInputProcessor" ("Processor")

function PlayerInputProcessor:PlayerInputProcessor (entities, events)
	self.entities = entities
	self.events = events
end

function PlayerInputProcessor:onUpdate (dt)
end

function PlayerInputProcessor:handle (event)
	local name = event:getClass ()

	if "KeyboardKeyDownEvent" == name then
		self:onKeydown (event)
		return
	end

	if "KeyboardKeyUpEvent" == name then
		self:onKeyup (event)
		return
	end

	if "MouseButtonDownEvent" == name then
		self:onMousedown (event)
		return
	end

	if "MouseButtonUpEvent" == name then
		self:onMouseup (event)
		return
	end

	if "MouseMovedEvent" == name then
		self:onMousemoved (event)
		return
	end
end

function PlayerInputProcessor:onKeydown (event)
end

function PlayerInputProcessor:onKeyup (event)
	if "escape" == event.key then
		love.event.quit()
	end
end

function PlayerInputProcessor:onMousedown (event)
end

function PlayerInputProcessor:onMouseup (event)
end

function PlayerInputProcessor:onMousemoved (event)
	if event.delta.x > 1 then
	end
end
