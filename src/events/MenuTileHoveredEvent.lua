require ("lib.lclass.init")

class "MenuTileHoveredEvent"

function MenuTileHoveredEvent:MenuTileHoveredEvent (id)
	self.eid = id or error ("NO ID NO SEX!")
end
