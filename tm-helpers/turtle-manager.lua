turtleManager = {
	turtles = { },
	pingCounts = { },
	allMessages = { },
}
turtleManager.__index = turtleManager

local maxPingCount = 1;

function turtleManager.init(uiManager)
	local self = setmetatable(
		{
			uiManager = uiManager,
			turtles = { },
			pingCounts = { }
		},
		turtleManager
	)

	self:loadSavedTurtles()

	for i,v in pairs(self.turtles) do
		uiManager:createTurtlePreview(v)
		self:setUpUiLogic(v)
	end

	return self
end

function turtleManager:loadSavedTurtles()
	if not fs.exists("turtles.data") then
		local fileInit = fs.open("turtles.data", "w")
		fileInit.close()
	end

	local file = fs.open("turtles.data", "r")
	local contents = file.readAll()
	file.close()

	self.turtles = textutils.unserialise(contents)

	for i,v in pairs(self.turtles) do
		v.online = false;
		v.messages = {};
	end;
end

function turtleManager:saveTurtles()
	local deepTurtlesCopy = {}
	for i,v in ipairs(self.turtles) do
		deepTurtlesCopy[i] = {}
		for label, data in pairs(v) do
			if label ~= "uiController" then
				deepTurtlesCopy[i][label] = data
			end
		end
	end

	local file = fs.open("turtles.data", "w")
	file.write(textutils.serialise(deepTurtlesCopy))
	file.close()
end

function turtleManager:receiveTurtleHandshake(rawTurtleData)
	local newTurtle = textutils.unserialise(rawTurtleData)

	newTurtle.messages = {}

	self.uiManager:createTurtlePreview(newTurtle)
	self:setUpUiLogic(newTurtle)
	table.insert(self.turtles, newTurtle)
	self:saveTurtles()
end

function turtleManager:messageRecieved(turtle, message)
	for i,v in pairs(self.turtles) do
		if v.id == turtle.id then
			table.insert(v.messages, message)
			table.insert(self.allMessages, v.name .. ": " .. message)

			if self.uiManager.currentTurtle == v then
				self.uiManager:updateSingleTurtlePanel()
			end
		end
	end
	self.uiManager:updateMessages(self.allMessages)
end

function turtleManager:removeTurtle(turtle)
	for i,v in ipairs(self.turtles) do
		if v == turtle then
			table.remove(self.turtles, i)
			break
		end
	end
	self.uiManager:removeTurtlePanel(turtle)
	self:saveTurtles()
end

function turtleManager:setUpUiLogic(turtle)
	if turtle.uiController == nil then
		return
	end

	-- Set up logic for remove button
	turtle.uiController.removeButton.onclick = function()
		self.uiManager:confirm(
			function()
				self:removeTurtle(turtle)
			end
		)
	end

	-- Set up logic for goto button

	-- Set up logic for protocol buttons
end

function turtleManager:update(turtlePacket)
	for i,v in pairs(self.turtles) do
		if v.id == turtlePacket.id then
			v.name = turtlePacket.name
			v.fuel = turtlePacket.fuel
			v.fuelLimit = turtlePacket.fuelLimit
			v.protocol = turtlePacket.protocol
			v.inventory = turtlePacket.inventory
			v.peripherals = turtlePacket.peripherals
			v.protocolActions = turtlePacket.protocolActions
			v.currentCommand = turtlePacket.currentCommand
			v.online = true;
			
			self.pingCounts[turtlePacket.id] = 0;

			self.uiManager:updateTurtlePreview(v)
			if self.uiManager.currentTurtle == v then
				self.uiManager:updateSingleTurtlePanel()
			end

			break;
		end
	end

	self:saveTurtles()
end

function turtleManager:pingTurtle(turtle)
	if self.pingCounts[turtle.id] == nil then
		self.pingCounts[turtle.id] = 0;
	end

	self.pingCounts[turtle.id] = self.pingCounts[turtle.id] + 1;

	if self.pingCounts[turtle.id] > maxPingCount then
		for i,v in pairs(self.turtles) do
			if v.id == turtle.id then
				v.online = false;

				self.uiManager:updateTurtlePreview(v);
				if self.uiManager.currentTurtle == v then
					self.uiManager:updateSingleTurtlePanel()
				end

				break;
			end
		end
	end
end

function turtleManager:displayErrorMessage(id, message)
	for i,v in pairs(self.turtles) do
		if v.id == id then
			self.uiManager:displayErrorMessage(v.name, message)
		end
	end
end

return turtleManager
