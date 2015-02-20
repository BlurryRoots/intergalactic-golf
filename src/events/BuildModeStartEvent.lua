require ("lib.lclass.init")

class "BuildModeStartEvent"

function BuildModeStartEvent:BuildModeStartEvent (planetName)
	self.planetName = planetName or error ("No no noooo!")
end
