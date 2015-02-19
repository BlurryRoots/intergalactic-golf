require ("lib.lclass")
require ("lib.yanecos.Data")

class "BuildScreenData" ("Data")

function BuildScreenData:BuildScreenData ()
	self.buildTileType = nil
	self.sum = 0
	self.shoppingList = {}
end