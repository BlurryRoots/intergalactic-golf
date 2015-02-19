require ("lib.lclass.init")

class "TileSelectedEvent"

function TileSelectedEvent:TileSelectedEvent (eid)
	self.eid = eid or error ("NO NO NO!!!")
end
