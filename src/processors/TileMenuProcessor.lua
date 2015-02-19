require ("lib.lclass")
require ("lib.yanecos.Processor")

require ("src.data.TransformData")
require ("src.data.AnimationData")
require ("src.data.TileSelectionMenuData")

class "TileMenuProcessor" ("Processor")

function TileMenuProcessor:TileMenuProcessor (entityManager, assets)
	self.entityManager = entityManager
	self.assets = assets
	self.resizeEvent = nil
end

function TileMenuProcessor:onUpdate (dt)
	if self.resizeEvent then
		local menuEid = self.entityManager:findEntitiesWithTag ({"tilemenu"})
		for _, eid in pairs (menuEid) do
			local transform =
				self.entityManager:getData (eid, TransformData:getClass ())
			local tilemenu =
				self.entityManager
					:getData (eid, TileSelectionMenuData:getClass ())

			transform.x = self.resizeEvent.width - tilemenu.dimensions.width
			transform.y = 0

			local animation =
				self.entityManager:getData (eid, AnimationData:getClass ())
			local pic = self.assets:get ("gfx/tile")
			animation.scale.x = tilemenu.dimensions.width / pic:getWidth ()
			animation.scale.y = tilemenu.dimensions.height / pic:getHeight ()
		end
	end
end

function TileMenuProcessor:handle (event)
	if "ResizeEvent" == event:getClass () then
		self.resizeEvent = event
	end
end
