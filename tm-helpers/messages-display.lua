local messagesDisplay = {
	rootPanel = {},
	titleText = {},
	collapseButton = nil,
	messagesPanel = {},
	messageElements = {},
	x = 14,
	y = 6,
	w = 0,
	h = 0,
	actualState = "",
	monitor = nil,
}
messagesDisplay.__index = messagesDisplay

function messagesDisplay.init(panel)
	local self = setmetatable(messagesDisplay, {})
	local termW, termH = term.getSize()

	self.w = termW - 15 - self.x
	self.h = termH - 2 - self.y

	self.rootPanel = panel:add(
		"panel",
		{
			x = self.x,
			y = self.y,
			w = self.w,
			h = self.h,
			backColour = colors.white,
		}
	)

	self.titleText = self.rootPanel:add(
		"text",
		{
			x = 1,
			y = 1,
			text = "Messages",
		}
	)

	self.collapseButton = self.rootPanel:add(
		"button",
		{
			x = self.w,
			w = 1,
			h = 1,
			text = "-",
			foreColour = colors.black,
			backColour = colors.white,
		}
	)

	self.collapseButton.onclick = function()
		self:toggleVisible()
	end

	self.messagesPanel = self.rootPanel:add(
		"panel",
		{
			x = 1,
			y = 2,
			w = self.w,
			h = self.h - 1
		}
	)

	self.actualState = self.messagesPanel.state

	return self
end

function messagesDisplay:clearMonitor()
	local monW, monH = term.getSize()
	self.monitor.setBackgroundColor(colors.white)
	self.monitor.setTextColor(colors.black)
	local str = ""
	for x = 1, monW do
		str = str .. " "
	end
	for y = 1, monH do
		self.monitor.setCursorPos(1, y)
		self.monitor.write(str)
	end

	self.monitor.setCursorPos(1, 1)
	self.monitor.write("Messages for turtle master")
end

function messagesDisplay:initExternalMonitor(monitorName)
	self.monitor = peripheral.wrap(monitorName)
	self:clearMonitor()
end

function messagesDisplay:toggleVisible()
	if self.messagesPanel.state == self.actualState then
		self.messagesPanel.state = "NONE"
		self.collapseButton.text = "+"
	else
		self.messagesPanel.state = self.actualState
		self.collapseButton.text = "-"
	end
end

function messagesDisplay:updateDisplay(messages)
	for i,v in pairs(self.messageElements) do
		self.messagesPanel:removeChild(v)
	end

	local y = 1
	for i = #messages, 1, -1 do
		local message = messages[i]
		if y > self.h - 1 then
			break
		end

		local messageElement = self.messagesPanel:add(
			"text",
			{
				text = message,
				x = 1,
				y = y,
				foreColour = colors.lightGray,
			}
		)

		table.insert(self.messageElements, messageElement)

		y = y + 1
	end
end

function messagesDisplay:updateMonitorDisplay(messages)
	if self.monitor ~= nil then
		self:clearMonitor()
		local monW, monH = self.monitor.getSize()
		self.monitor.setTextColor(colors.lightGray)

		local y = 3
		for i = #messages, 1, -1 do
			local message = messages[i]
			if y < monH then
				self.monitor.setCursorPos(1, y)
				self.monitor.write(message)
			else
				break
			end

			y = y + 1
		end
	end
end

return messagesDisplay
