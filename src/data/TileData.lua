require ("lib.lclass")
require ("lib.yanecos.Data")

class "TileData" ("Data")

local function ct(a, p, d)
	return {Attractiveness = a, Price = p, Difficulty = d}
end

TileData.Type = {
	Start = ct(1, 100, 1),
	End = ct(1, 100, 1),
	Grass = ct(0.9, 1500, 2),
	Sand = ct(0.6, 1000, 4),
	Lake = ct(2, 5000, 8),
}

function TileData.GetTypeName (n)
	for name, typeN in pairs (TileData.Type) do
		if n == typeN then
			return name
		end
	end

	error ("Alter!!!")
end

TileData.Size = {
	w = 64,
	h = 64,
}

function TileData:TileData (x, y, type)
	self.x = x or 0
	self.y = y or 0
	self.type = type or error ("I need a type!")
end
