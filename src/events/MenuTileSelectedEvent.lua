require ("lib.lclass.init")

class "MenuTileSelectedEvent"

function MenuTileSelectedEvent:MenuTileSelectedEvent (eid)
	self.eid = eid or error ("NO NO NO!!!")
end
