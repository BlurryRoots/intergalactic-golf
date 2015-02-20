require ("lib.lclass.init")

class "MouseMovedEvent"

function MouseMovedEvent:MouseMovedEvent (x, y, dx, dy)
	self.position = {
		x = x,
		y = y
	}

	self.delta = {
		x = dx,
		y = dy,
	}
end
