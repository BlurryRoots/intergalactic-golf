require ("lib.lclass")
require ("lib.yanecos.Data")

class "TileData" ("Data")

TileData.Type = {
	Start = 1,
	End = 2,
	Grass = 3,
	Sand = 4,
	Lake = 5,
}

TileData.Size = {
	w = 64,
	h = 64,
}

function TileData:TileData (x, y, type)
	self.x = x or 0
	self.y = y or 0
	self.type = type or error ("I need a type!")
end
