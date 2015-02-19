require ("lib.lclass.init")

class "TileHoveredEvent"

function TileHoveredEvent:TileHoveredEvent (id)
	self.hoveredTileId = id or error ("NO ID NO SEX!")
end
