require ("lib.lclass")
require ("lib.yanecos.Data")

class "GameData" ("Data")

function GameData:GameData (planets)
	self.planets = planets or {}
end
