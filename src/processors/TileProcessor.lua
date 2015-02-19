require ("lib.lclass")
require ("lib.yanecos.Processor")

require ("src.data.TileData")
require ("src.data.AnimationData")
require ("src.data.TransformData")

class "TileProcessor" ("Processor")

function TileProcessor:TileProcessor (entityManager)
	self.em = entityManager
	self.intrests = {
		TileData:getClass (),
	}

end

function TileProcessor:onUpdate (dt)
	local tiles = self.em:findEntitiesWithData (self.intrests)

	for _, eid in pairs (tiles) do
		local tile = self.em:getData (eid, TileData:getClass ())
		local transform = self.em:getData (eid, TransformData:getClass ())

		transform.x = TileData.Size.w * tile.x
		transform.y = TileData.Size.h * tile.y
	end
end

function TileProcessor:onRender ()
end