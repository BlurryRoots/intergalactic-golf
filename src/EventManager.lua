require ("lib.lclass")

class "EventManager"

function EventManager:EventManager ()
	self.events = {}
	self.subscriber = {}
end

function EventManager:push (event)
	table.insert (self.events, event)
end

function EventManager:subscribe (typeName, handler)
	self.subscriber[typeName] = self.subscriber[typeName] or {}
	table.insert (self.subscriber[typeName], handler)
end

function EventManager:unsubscribe (typeName, handler)
	if not self.subscriber[typeName] then
		error ("No one had previously been subscribed to " .. typeName)
	end

	local index = 0
	for i, h in pairs (self.subscriber[typeName]) do
		if handler == h then
			index = i
			break
		end
	end

	if 0 < index then
		table.remove (self.subscriber[typeName], index)
	end
end

function EventManager:update (dt)
	while table.getn (self.events) > 0 do
		local event = table.remove (self.events)
		local handlers = self.subscriber[event:getClass ()]
		if handlers and table.getn (handlers) > 0 then
			for _,handler in pairs (self.subscriber[event:getClass ()]) do
				handler:handle (event)
			end
		end
	end
end
