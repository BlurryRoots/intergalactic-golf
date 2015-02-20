require ("lib.lclass")
require ("lib.yanecos.Data")

class "HitboxData" ("Data")

function HitboxData:HitboxData (width, height)
	self.width = width or error ("no width dude!")
	self.height = height or error ("no height dude!")
end
