local networkManager = {
	turtleManager = {},
	rednetOpen = false,
	uiManager = {}
}
networkManager.__index = networkManager

function networkManager.init(turtleManager, uiManager)
	local self = setmetatable(networkManager, {})
	self.turtleManager = turtleManager
	self.uiManager = uiManager
	uiManager:setNetworkManager(self)
	
	for i,v in pairs(peripheral.getNames()) do
		if peripheral.getType(v) == "modem" then
			rednet.open(v)
			self.rednetOpen = true
		end
	end

	if not self.rednetOpen then
		uiManager:displayNoRednetMessage()
	end

	return self
end

function networkManager:receiveMessage(stringMessage, id)
	local message = textutils.unserialise(stringMessage)

	local protocol = message.protocol
	local command = message.command

	local fullCommand = protocol .. "." .. command
	local turtle = message.turtle

	if turtle ~= nil and turtle.id ~= id then
		return
	end

	if fullCommand == "general.register" then
		self.turtleManager:receiveTurtleHandshake(textutils.serialise(turtle))
	elseif fullCommand == "general.update" then
		self.turtleManager:update(turtle)
	elseif fullCommand == "general.error" then
		self.turtleManager:displayErrorMessage(turtle.id, message.message)
	elseif fullCommand == "general.message" then
		self.turtleManager:messageRecieved(turtle, message.message)
	end
end

function networkManager:togglePause(id)
	local command = {
		protocol = "turtle",
		command = "toggle_pause"
	}
	rednet.send(id, textutils.serialise(command))
end

function networkManager:setProtocolAction(id, action, params)
	local command = {
		protocol = "protocol",
		command = action,
		params = params
	}
	rednet.send(id, textutils.serialise(command))
end

function networkManager:pingTurtles()
	local command = {
		protocol = "general",
		command = "ping"
	}

	for i,turtle in pairs(self.turtleManager.turtles) do
		rednet.send(turtle.id, textutils.serialise(command))
		self.turtleManager:pingTurtle(turtle)
	end
end

return networkManager
