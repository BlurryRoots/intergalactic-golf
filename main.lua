require ("src.events.FocusGainedEvent")
require ("src.events.FocusLostEvent")
require ("src.events.KeyboardKeyDownEvent")
require ("src.events.KeyboardKeyUpEvent")
require ("src.events.MouseButtonDownEvent")
require ("src.events.MouseButtonUpEvent")
require ("src.events.MouseMovedEvent")
require ("src.events.PlaySoundEvent")
require ("src.events.ResizeEvent")

require ("src.Game")

local gameInstance = nil

function love.load ()
	gameInstance = Game ()
end

function love.quit ()
	gameInstance:onExit ()
end

function love.focus (f)
	if f then
		gameInstance:raise (FocusLostEvent ())
	else
		gameInstance:raise (FocusGainedEvent ())
	end
end

function love.resize (w, h)
	gameInstance:raise (ResizeEvent (w, h))
end

function love.update (dt)
	gameInstance:onUpdate (dt)
end

function love.draw ()
	gameInstance:onRender ()
end

function love.mousepressed (x, y, button)
	gameInstance:raise (MouseButtonDownEvent (x, y, button))
end

function love.mousereleased (x, y, button)
	gameInstance:raise (MouseButtonUpEvent (x, y, button))
end

function love.mousemoved(x, y, dx, dy)
	gameInstance:raise (MouseMovedEvent (x, y, dx, dy))
end

function love.keypressed (key)
	gameInstance:raise (KeyboardKeyDownEvent (key))
end

function love.keyreleased (key)
	gameInstance:raise (KeyboardKeyUpEvent (key))
end
