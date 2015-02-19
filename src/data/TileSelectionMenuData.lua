require ("lib.lclass")
require ("lib.yanecos.Data")

class "TileSelectionMenuData" ("Data")

function TileSelectionMenuData:TileSelectionMenuData (typeList, dimensions)
	self.typeList = typeList
	self.dimensions = dimensions
end
