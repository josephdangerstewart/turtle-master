local configManager = {
	uiElements = {},
	config = {},
	rootPanel = {},
	saveFunctions = {},
	modalManager = {},
}
configManager.__index = configManager

-- Valid types: "number", "string", "peripheral:type"
local configSchema = {
	pingTime = {
		default = 10,
		type = "number",
		display = "Update time"
	},
	messagesMonitor = {
		default = nil,
		type = "peripheral:monitor",
		display = "Messages monitor"
	}
}

function configManager.init(modalManager)
	local self = setmetatable(configManager, {})

	local file
	if not fs.exists("tm.config") then
		file = fs.open("tm.config", "w")
		file.write("{}")
		file.close()
	end

	file = fs.open("tm.config", "r")
	self.config = textutils.unserialise(file.readAll())
	file.close()

	self.modalManager = modalManager

	return self
end

function configManager:getValue(key)
	return self.config[key] or configSchema[key].default
end

function configManager:setValue(key, value)
	self.config[key] = value

	local file = fs.open("tm.config", "w")
	file.write(textutils.serialise(self.config))
	file.close()
end

function configManager:showUi()
	cobalt.state = "config"
end

function configManager:initUi()
	local termW, termH = term.getSize()
	self.rootPanel = cobalt.ui.new({ w = termW, h = termH, state = "config" })

	-- Add the back button
	local backButton = self.rootPanel:add(
		"button",
		{
			x = 1,
			y = 1,
			w = 1,
			h = 1,
			backColour = colors.white,
			foreColour = colors.black,
			text = "<",
		}
	)

	backButton.onclick = function()
		cobalt.state = "all-turtles"
	end

	-- Add the title of the screen
	self.rootPanel:add(
		"text",
		{
			x = 2,
			text = "Settings"
		}
	)

	-- Add the save button
	local saveButton = self.rootPanel:add(
		"button",
		{
			x = termW - 6,
			y = termH,
			w = 6,
			h = 1,
			text = "Save"
		}
	)

	saveButton.onclick = function()
		self:save()
	end

	-- Get X value of inputs
	local colX = 1
	for i,v in pairs(configSchema) do
		if #v.display > colX then
			colX = #v.display
		end
	end

	-- Render the inputs
	colX = colX + 4
	rowY = 3
	for i,v in pairs(configSchema) do
		self.rootPanel:add(
			"text",
			{
				x = 2,
				y = rowY,
				text = v.display
			}
		)

		local parts = string.split(v.type, ":")

		if v.type == "number" or v.type == "string" then
			configManager:renderInput(i, colX, rowY, v.type)
		elseif parts[1] == "peripheral" then
			configManager:renderPeripheralInput(i, colX, rowY, parts[2])
		end
		rowY = rowY + 1
	end
end

function configManager:renderInput(configKey, x, y, type)
	local input = self.rootPanel:add(
		"input",
		{
			x = x,
			y = rowY,
			w = 7,
			text = tostring(self:getValue(configKey)),
		}
	)

	local initialValue = self:getValue(configKey)

	local saveFunction = function()
		if input.text ~= initialValue then
			local value = input.text

			if type == "number" then
				value = tonumber(input.text)

				if value == nil then
					input.text = initialValue
					return
				end
			end

			self:setValue(configKey, value)
		end
	end

	table.insert(self.saveFunctions, saveFunction)
end

function configManager:renderPeripheralInput(configKey, x, y, type)
	local curValue = self:getValue(configKey)
	local display = self.rootPanel:add(
		"button",
		{
			x = x,
			y = y,
			w = 6,
			h = 1,
			text = string.sub(curValue or "", 1, 6),
			backColour = colors.lightGray,
			foreColour = colors.gray
		}
	)

	local clearButton = self.rootPanel:add(
		"button",
		{
			x = x + 7,
			y = y,
			w = 0,
			h = 1,
			text = "X",
			backColour = colors.lightGray,
			foreColour = colors.gray
		}
	)

	clearButton.onclick = function()
		display.text = ""
		curValue = ""
	end

	display.onclick = function()
		local options = {}
		for i,v in pairs(peripheral.getNames()) do
			if peripheral.getType(v) == type then
				table.insert(options, v)
			end
		end

		self.modalManager:radio(
			options,
			"Choose " .. type,
			function(value)
				if value ~= curValue then
					curValue = value
					display.text = string.sub(value, 1, 6)
				end
			end
		)
	end

	local saveFunction = function()
		self:setValue(configKey, curValue)
	end

	table.insert(self.saveFunctions, saveFunction)
end

function configManager:save()
	for i,v in pairs(self.saveFunctions) do
		v()
	end
end

return configManager
