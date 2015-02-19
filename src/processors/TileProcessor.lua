require ("lib.lclass")
require ("lib.yanecos.Processor")

require ("src.data.TileData")
require ("src.data.AnimationData")

class "TileProcessor" ("Processor")

function TileProcessor:TileProcessor (entityManager)
	self.em = entityManager
	self.intrests = {
		TileData:getClass (),
	}

	self.mapOffset = {
		x = 0,
		y = 0
	}

	self.tileSize = {
		w = 32,
		h = 32
	}
end

function TileProcessor:onUpdate (dt)
	local tiles = self.em:findEntitiesWithData (self.intrests)

	for _, eid in pairs (tiles) do
		local tile = self.em:getData (eid, TileData:getClass ())
		local transform = self.em:getData (eid, TransformData:getClass ())

		transform.x = self.tileSize * tile.x
		transform.y = self.tileSize * tile.y
	end
end

function TileProcessor:onRender ()
end
