local TurtleInventoryDisplay = dofile("tm-helpers/turtle-inventory-display.lua")
local MessagesDisplay = dofile("tm-helpers/messages-display.lua")
-- Possible states = "all-turtles", "single-turtle", "main-menu", "config"
-- cobalt manages state
--[[
	turtlePanels = {
		{
			turtle = SOME TURTLE OBJECT,
			panel = SOME PANEL OBJECT
		}
	}
]]
uiManager = {
	turtlePanels = {},
	currentTurtle = {},
	scrollOffset = 0,

	mainMenuConstants = {
		appTitle = "Turtle Master by PossieTV",
		buttonText = "Start"
	},
	allTurtleConstants = {
		previewWidth = 15,
		previewSpacing = 2,
		topSpacing = 4,
		scrollAmount = 5
	},

	mainMenuPanel = {},
	allTurtlesPanel = {},
	singleTurtlePanel = {},
	singleTurtleElements = {},
	allTurtleElements = {},
	turtleInventoryDisplay = {},
	modalManager = {},
	networkManager = {},
	configManager = {}
}
uiManager.__index = uiManager

function uiManager.init(modalManager, configManager)
	local termW, termH = term.getSize()
	cobalt.state = "main-menu"

	local self = setmetatable({}, uiManager)
	self.modalManager = modalManager
	self.configManager = configManager
	self.mainMenuPanel = cobalt.ui.new({ w = termW, h = termH, state = "main-menu" })
	self.allTurtlesPanel = cobalt.ui.new({ w = termW, h = termH, state = "all-turtles" })
	self.singleTurtlePanel = cobalt.ui.new({ w = termW, h = termH, state = "single-turtle" })

	self.configManager:initUi()
	self:initMainMenu()
	self:initAllTurtlesPanel()
	self:initSingleTurtlePanel()

	local messagesMonitor = self.configManager:getValue("messagesMonitor")
	if messagesMonitor ~= nil then
		self.messagesDisplay:initExternalMonitor(messagesMonitor)
	end

	return self
end

function uiManager:initMainMenu()
	local termW, termH = term.getSize()

	local title = self.mainMenuPanel:add(
		"text",
		{
			x = math.floor((termW / 2) - (string.len(self.mainMenuConstants.appTitle) / 2)),
			y = math.floor(termH / 2 - 2),
			text = self.mainMenuConstants.appTitle
		}
	)

	local startButton = self.mainMenuPanel:add(
		"button",
		{
			x = math.floor((termW / 2) - (string.len(self.mainMenuConstants.buttonText) / 2)),
			y = math.floor(termH / 2),
			h = 1,
			w = string.len(self.mainMenuConstants.buttonText) + 2,
			wrap = "center",
			text = self.mainMenuConstants.buttonText
		}
	)

	startButton.onclick = function()
		cobalt.state = "all-turtles"
	end
end

function uiManager:setNetworkManager(networkManager)
	self.networkManager = networkManager
end

function uiManager:initSingleTurtlePanel()
	local termW, termH = term.getSize()
	
	local backButton = self.singleTurtlePanel:add(
		"button",
		{
			x = 1,
			y = 1,
			w = 1,
			h = 1,
			text = "<",
			backColour = colors.white,
			foreColour = colors.black
		}
	)

	backButton.onclick = function()
		cobalt.state = "all-turtles"
	end

	self.singleTurtleElements.nameText = self.singleTurtlePanel:add(
		"text",
		{
			x = 2,
			y = 1,
			text = "Turtle Name"
		}
	)

	self.singleTurtleElements.idText = self.singleTurtlePanel:add(
		"text",
		{
			x = termW - 5,
			y = 1,
			text = "#NIL"
		}
	)

	self.singleTurtleElements.fuelBar = self.singleTurtlePanel:add(
		"percentbar",
		{
			x = 2,
			y = 3,
			h = termH - 4,
			value = 0
		}
	)

	self.singleTurtleElements.fuelReadoutText = self.singleTurtlePanel:add(
		"text",
		{
			x = 3,
			y = 3,
			text = "F: 0/0"
		}
	)

	self.singleTurtleElements.protocolText = self.singleTurtlePanel:add(
		"text",
		{
			x = 3,
			y = 4,
			text = "protocol"
		}
	)

	self.singleTurtleElements.statusText = self.singleTurtlePanel:add(
		"text",
		{
			x = 4,
			y = 5,
			text = "offline",
			backColour = colors.red,
			foreColour = colors.white
		}
	)

	self.singleTurtleElements.gotoButton = self.singleTurtlePanel:add(
		"button",
		{
			x = 4,
			y = 7,
			text = "goto",
			w = 8,
			h = 1
		}
	)

	self.singleTurtleElements.pauseButton = self.singleTurtlePanel:add(
		"button",
		{
			x = 4,
			y = 8,
			text = "pause",
			w = 8,
			h = 1
		}
	)

	self.turtleInventoryDisplay = TurtleInventoryDisplay.init(self.singleTurtlePanel, termW - 14, 3, self.modalManager)
	self.messagesDisplay = MessagesDisplay.init(self.singleTurtlePanel)

	self.singleTurtleElements.peripheralTitle = self.singleTurtlePanel:add(
		"text",
		{
			x = termW - 14,
			y = 9,
			text = "Peripherals"
		}
	)

	self.singleTurtleElements.peripherals = {}
	self.singleTurtleElements.protocolActionButtons = {}
end

function uiManager:initAllTurtlesPanel()
	local termW, termH = term.getSize()

	self.allTurtleElements.serverIdText = self.allTurtlesPanel:add(
		"text",
		{
			x = 1,
			y = 1,
			text = "Server: #" .. os.getComputerID()
		}
	)

	local settingsButtonTitle = "Settings"
	local settingsButton = self.allTurtlesPanel:add(
		"button",
		{
			x = termW - #settingsButtonTitle - 3,
			y = 1,
			h = 1,
			w = #settingsButtonTitle + 1,
			text = settingsButtonTitle,
		}
	)

	settingsButton.onclick = function()
		self.configManager:showUi()
	end

	self.allTurtleElements.scrollLeftButton = self.allTurtlesPanel:add(
		"button",
		{
			x = 1,
			y = termH,
			w = 1,
			h = 1,
			text = "<",
			foreColour = colors.white,
			backColour = colors.black
		}
	)

	self.allTurtleElements.scrollLeftButton.onclick = function()
		self:scrollLeft()
	end

	self.allTurtleElements.scrollRightButton = self.allTurtlesPanel:add(
		"button",
		{
			x = termW,
			y = termH,
			w = 1,
			h = 1,
			text = ">",
			foreColour = colors.white,
			backColour = colors.black
		}
	)

	self.allTurtleElements.scrollRightButton.onclick = function()
		self:scrollRight()
	end

	self.allTurtleElements.exitButton = self.allTurtlesPanel:add(
		"button",
		{
			x = termW,
			y = 1,
			w = 1,
			h = 1,
			text = "X",
			foreColour = colors.white,
			backColour = colors.black
		}
	)

	self.allTurtleElements.exitButton.onclick = function()
		self.modalManager:confirm(
			function()
				term.clear()
				term.setCursorPos(1, 1)
				cobalt.exit()
			end
		)
	end
end

function uiManager:displayNoRednetMessage()
	self.allTurtleElements.serverIdText.text = "NO MODEM FOUND"
	self.allTurtleElements.serverIdText.backColour = colors.red
	self.allTurtleElements.serverIdText.foreColour = colors.white
end

function uiManager:updateMessages(messages)
	self.messagesDisplay:updateMonitorDisplay(messages)
end

function uiManager:updateSingleTurtlePanel()
	self.singleTurtleElements.nameText.text = self.currentTurtle.name
	self.singleTurtleElements.idText.text = "#" .. self.currentTurtle.id
	self.singleTurtleElements.fuelBar.value = math.floor((self.currentTurtle.fuel / self.currentTurtle.fuelLimit) * 100)
	self.singleTurtleElements.fuelReadoutText.text = "F: " .. self.currentTurtle.fuel .. "/" .. self.currentTurtle.fuelLimit
	self.singleTurtleElements.protocolText.text = self.currentTurtle.protocol .. (self.currentTurtle.currentCommand and ":" .. self.currentTurtle.currentCommand or "")
	self.singleTurtleElements.statusText.text = self.currentTurtle.online and "online" or "offline"
	self.singleTurtleElements.statusText.backColour = self.currentTurtle.online and colors.green or colors.red
	self.singleTurtleElements.pauseButton.text = "cancel"
	self.turtleInventoryDisplay:updateDisplay(self.currentTurtle.inventory)
	self.messagesDisplay:updateDisplay(self.currentTurtle.messages)

	self.singleTurtleElements.pauseButton.onclick = function()
		self.networkManager:togglePause(self.currentTurtle.id)
	end

	self.singleTurtleElements.gotoButton.onclick = function()
		self.modalManager:withParams(
			{ coords = "string" },
			function(params)
				self.networkManager:goTo(self.currentTurtle.id, params.coords)
			end
		)
	end

	for i,v in pairs(self.singleTurtleElements.peripherals) do
		self.singleTurtlePanel:removeChild(v)
	end

	for i,v in pairs(self.singleTurtleElements.protocolActionButtons) do
		self.singleTurtlePanel:removeChild(v)
	end

	self.singleTurtleElements.peripherals = {}

	local y = 10
	local termW, termH = term.getSize()
	for i,v in pairs(self.currentTurtle.peripherals) do
		table.insert(
			self.singleTurtleElements.peripherals,
			self.singleTurtlePanel:add(
				"text",
				{
					x = termW - 14,
					y = y,
					text = v
				}
			)
		)
	end

	y = 10
	for i,v in pairs(self.currentTurtle.protocolActions) do
		local pActionButton = self.singleTurtlePanel:add(
			"button",
			{
				x = 4,
				y = y,
				text = i,
				w = 8,
				h = 1
			}
		)

		pActionButton.onclick = function()
			self.modalManager:withParams(
				v.params,
				function(params)
					self.networkManager:setProtocolAction(self.currentTurtle.id, i, params)
				end
			)
		end

		table.insert(self.singleTurtleElements.protocolActionButtons, pActionButton)
		y = y + 1
	end
end

function uiManager:removeTurtlePanel(turtle)
	local panelIndex = -1
	-- Loop through and delete the panel
	for i,v in pairs( self.turtlePanels ) do
		-- Look for the turtle we are deleting
		if v.turtle == turtle then
			-- Remove the panel
			self.allTurtlesPanel:removeChild(v.panel)
			panelIndex = i
			table.remove(self.turtlePanels, i)
			break
		end
	end

	-- Reset the ID display on the turtle panels
	for i,v in pairs( self.turtlePanels ) do
		if v.turtle.uiController ~= nil then
			local idText = v.turtle.uiController.idText
			idText.text = i .. ") #" .. v.turtle.id
		end
	end

	-- The scroll method resets the position of all turtle panels with respect to the scroll offset
	self:scroll()
end

function uiManager:createTurtlePreview(turtle)
	if turtle["uiController"] ~= nil then
		return
	end

	local termW, termH = term.getSize()
	local x
	if #self.turtlePanels > 0 then
		x = self.turtlePanels[#self.turtlePanels].panel.x + self.allTurtleConstants.previewWidth + self.allTurtleConstants.previewSpacing
	else 
		x = self.allTurtleConstants.previewSpacing
	end

	local turtleUiController = {}

	local turtlePanel = self.allTurtlesPanel:add(
		"panel",
		{
			x = x,
			y = 3,
			w = self.allTurtleConstants.previewWidth,
			h = termH - (self.allTurtleConstants.topSpacing)
		}
	)

	table.insert(
		self.turtlePanels,
		{
			panel = turtlePanel,
			turtle = turtle
		}
	)

	turtleUiController.fuelBar = turtlePanel:add(
		"percentbar",
		{
			x = 1,
			y = 1,
			h = termH - (self.allTurtleConstants.topSpacing),
			value = math.floor((turtle.fuel / turtle.fuelLimit) * 100)
		}
	)

	turtleUiController.idText = turtlePanel:add(
		"text",
		{
			x = 2,
			y = 1,
			text = #self.turtlePanels .. ") #" .. turtle.id
		}
	)

	turtleUiController.removeButton = turtlePanel:add(
		"button",
		{
			x = self.allTurtleConstants.previewWidth,
			y = 1,
			w = 1,
			h = 1,
			backColour = colors.red,
			foreColour = colors.black,
			text = "X"
		}
	)

	turtleUiController.nameText = turtlePanel:add(
		"text",
		{
			x = 2,
			y = 2,
			text = turtle.name
		}
	)

	turtleUiController.protocolText = turtlePanel:add(
		"text",
		{
			x = 2,
			y = 3,
			text = turtle.protocol
		}
	)

	turtleUiController.statusText = turtlePanel:add(
		"text",
		{
			x = 2,
			y = 4,
			text = turtle.online and "online" or "offline",
			backColour = turtle.online and colors.green or colors.red,
			foreColour = colors.white,
			marginleft = 1,
			w = 7
		}
	)

	turtleUiController.gotoButton = turtlePanel:add(
		"button",
		{
			x = 3,
			y = 6,
			text = "goto",
			h = 1,
			w = 8
		}
	)

	-- # TODO: give functionality to goto button - Do that in turtle manager

	turtleUiController.pauseButton = turtlePanel:add(
		"button",
		{
			x = 3,
			y = 7,
			h = 1,
			w = 8,
			text = "cancel",
			foreColour = colors.white
		}
	)

	turtleUiController.moreButton = turtlePanel:add(
		"button",
		{
			x = 3,
			y = 8,
			h = 1,
			w = 8,
			text = "more"
		}
	)

	turtleUiController.moreButton.onclick = function()
		self.currentTurtle = turtle
		self:updateSingleTurtlePanel()
		cobalt.state = "single-turtle"
	end

	turtleUiController.pauseButton.onclick = function()
		self.networkManager:togglePause(turtle.id)
	end

	turtleUiController.gotoButton.onclick = function()
		self.modalManager:withParams(
			{ coords = "string" },
			function(params)
				self.networkManager:goTo(turtle.id, params.coords)
			end
		)
	end

	local y = 10
	turtleUiController.protocolActionButtons = {}
	for i,v in pairs(turtle.protocolActions) do
		local pActionButton = turtlePanel:add(
			"button",
			{
				x = 3,
				y = y,
				h = 1,
				w = 8,
				text = i
			}
		)

		pActionButton.onclick = function()
			self.modalManager:withParams(
				v.params,
				function(params)
					self.networkManager:setProtocolAction(turtle.id, i, params)
				end
			)
		end

		table.insert(turtleUiController.protocolActionButtons, pActionButton)
		y = y + 1
	end

	-- # TODO: give functionality to pause button - Do that in turtle manager

	-- # TODO: Add protocol specific buttons to preview - Add UI elements here but add logic in turtle manager

	turtle.uiController = turtleUiController
	return turtleUiController
end

function uiManager:updateTurtlePreview(turtle)
	turtle.uiController.fuelBar.value = math.floor((turtle.fuel / turtle.fuelLimit) * 100)
	turtle.uiController.nameText.text = turtle.name
	turtle.uiController.protocolText.text = turtle.protocol
	turtle.uiController.statusText.text = turtle.online and "online" or "offline"
	turtle.uiController.statusText.backColour = turtle.online and colors.green or colors.red
	turtle.uiController.pauseButton.text = "cancel"
end

function uiManager:scrollLeft()
	if self.scrollOffset <= 0 then
		self.scrollOffset = 0
	else
		self.scrollOffset = self.scrollOffset - self.allTurtleConstants.scrollAmount
	end
	
	self:scroll()
end

function uiManager:scrollRight()
	local termW, termH = term.getSize()

	local maxScroll = (#self.turtlePanels * (self.allTurtleConstants.previewWidth + self.allTurtleConstants.previewSpacing)) - termW
	if self.scrollOffset < maxScroll then
		self.scrollOffset = self.scrollOffset + self.allTurtleConstants.scrollAmount
	end

	self:scroll()
end

function uiManager:scroll()
	local x = self.scrollOffset * -1

	for i,v in pairs( self.turtlePanels ) do
		v.panel.x = x + self.allTurtleConstants.previewSpacing
		x = x + self.allTurtleConstants.previewSpacing + self.allTurtleConstants.previewWidth
	end
end

function uiManager:displayErrorMessage(turtleName, errorMessage)
	local termW, termH = term.getSize()

	local x = math.floor(termW * .25)
	local w = termW - x * 2
	local y = math.floor(termH * .25)
	local h = termH - y * 2

	local panel, modal = self.modalManager:new({
		title = "Error from " .. turtleName,
		titleBarColor = colors.red,
		x = x,
		w = w,
		y = y,
		h = h,
	});

	panel:add(
		"text",
		{
			text = errorMessage,
			x = 1,
			y = 2,
			foreColour = colors.white,
		}
	)
end

function uiManager:confirm(onSuccess)
	self.modalManager:confirm(onSuccess)
end

return uiManager
