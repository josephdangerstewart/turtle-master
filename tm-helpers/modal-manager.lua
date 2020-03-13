local modalManager = {
	modals = {},
	previousState = "",
	rootPanel = "",
}
modalManager.__index = modalManager

function modalManager:init()
	local self = setmetatable({}, modalManager)
	return self
end

function modalManager:new(data)
	if data == nil then
		data = {}
	end
	local x, y, w, h, title
	x = data.x or 1
	y = data.y or 1
	w = data.w or 10
	h = data.h or 5
	title = data.title or "Modal"

	local rootPanel = cobalt.ui.new(
		{
			x = x,
			y = y,
			w = w,
			h = h + 1,
			alwaysfocus = true,
			freezeBackground = true
		}
	)

	table.insert(self.modals, rootPanel)

	--Create UI for the title bar
	local titlePanel = rootPanel:add(
		"panel",
		{
			x = 1,
			y = 1,
			w = w,
			h = 1,
			backColour = data.titleBarColor or colors.blue
		}
	)

	local closeButton = titlePanel:add(
		"button",
		{
			x = w,
			h = 1,
			w = 1,
			y = 1,
			backColour = data.titleBarColor or colors.blue,
			text = "X"
		}
	)

	closeButton.onclick = function()
		self:closeModal(rootPanel)
	end

	local titleText = titlePanel:add(
		"text",
		{
			y = 1,
			x = 1,
			backColour = data.titleBarColor or colors.blue,
			foreColour = colors.white,
			text = title
		}
	)

	-- Create the content panel
	local contentPanel = rootPanel:add(
		"panel",
		{
			x = 1,
			y = 2,
			w = w,
			h = h,
			backColour = colors.gray,
			foreColour = colors.white
		}
	)

	-- Return the content panel
	return contentPanel, rootPanel
end

function modalManager:closeModal(modal)
	for i,v in ipairs(self.modals) do
		if v == modal then
			table.remove(self.modals, i)
			break
		end
	end
	cobalt.ui.removePanel(modal)
end

function modalManager:radio(options, title, onSubmit)
	local termW, termH = term.getSize()

	local x = math.floor(termW * .25)
	local w = termW - x * 2
	local y = math.floor(termH * .25)
	local h = #options + 4

	local panel, frame = self:new({
		x = x,
		w = w,
		y = y,
		h = h,
		title = title,
	})

	local rowY = 2
	for i,v in pairs(options) do
		panel:add(
			"radio",
			{
				x = 2,
				y = rowY,
				label = v,
				group = "options"
			}
		)
		rowY = rowY + 1
	end

	local submitButton = panel:add(
		"button",
		{
			text = "Submit",
			x = w - 8,
			y = h,
			w = 8,
			h = 1,
		}
	)

	submitButton.onclick = function()
		local results = panel:getRadioResults("options")
		onSubmit(results[1])
		self:closeModal(frame)
	end
end

function modalManager:confirm(onSuccess)
	local termW, termH = term.getSize()

	local x = math.floor(termW * .25)
	local w = termW - x * 2
	local y = math.floor(termH * .25)
	local h = termH - y * 2
	
	local panel, frame = self:new({
		x = x,
		w = w,
		y = y,
		h = h,
		title = "Confirm"
	})

	local textY = math.floor(h / 2) - 1
	local text = panel:add(
		"text",
		{
			wrap = "center",
			y = textY,
			foreColour = colors.white,
			text = "Are you sure?"
		}
	)

	local buttonX = math.floor((w/2) - 5)
	local noButton = panel:add(
		"button",
		{
			text = "no",
			y = textY + 2,
			backColour = colors.red,
			w = 4,
			h = 1,
			x = buttonX
		}
	)

	local yesButton = panel:add(
		"button",
		{
			text = "yes",
			y = textY + 2,
			backColour = colors.green,
			w = 5,
			h = 1,
			x = buttonX + 6
		}
	)

	noButton.onclick = function()
		self:closeModal(frame)
	end

	yesButton.onclick = function()
		self:closeModal(frame)
		if onSuccess ~= nil then
			onSuccess()
		end
	end
end

function modalManager:withParams(params, callback)
	local keys = 0
	for i,v in pairs(params) do
		keys = keys + 1
	end
	if keys == 0 then
		callback({})
		return
	end
	
	local termW, termH = term.getSize()

	local x = math.floor(termW * .25)
	local w = termW - x * 2
	local y = math.floor(termH * .25)
	local h = termH - y * 2
	
	local panel, frame = self:new({
		x = x,
		w = w,
		y = y,
		h = h,
		title = "Params"
	})

	local paramInputY = 2
	local inputs = {}
	for i,v in pairs(params) do
		table.insert(inputs, self:getParamLine(i, v, paramInputY, panel, w))
		paramInputY = paramInputY + 1
	end

	local button = panel:add(
		"button",
		{
			x = w - 7,
			y = paramInputY,
			w = 6,
			h = 1,
			text = "Done"
		}
	)

	button.onclick = function()
		local paramValues = {}
		for i,v in pairs(inputs) do
			paramValues[v.name] = v.getValue()
		end
		self:closeModal(frame)
		callback(paramValues)
	end
end

function modalManager:getParamLine(name, type, y, panel, width)
	input = panel:add(
		"text",
		{
			x = 1,
			y = y,
			text = name .. ":"
		}
	)

	local x = #(name .. ":") + 2

	local getValue
	if type == "number" then
		local input = panel:add(
			"input",
			{
				w = width - x - 2,
				x = x,
				y = y,
				placeholder = "Number",
				state = "_ALL",
				backPassiveColour = colors.lightGrey,
				forePassiveColour = colors.grey,
				backActiveColour = colors.lightGrey,
				placeholderColour = colors.grey,
				marginLeft = "10%"
			}
		)

		getValue = function()
			return tonumber(input.text)
		end
	elseif type == "string" then
		local input = panel:add(
			"input",
			{
				w = width - x - 2,
				x = x,
				y = y,
				placeholder = "String",
				state = "_ALL",
				backPassiveColour = colors.lightGrey,
				forePassiveColour = colors.grey,
				backActiveColour = colors.lightGrey,
				placeholderColour = colors.grey,
				marginLeft = "10%"
			}
		)

		getValue = function()
			return input.text
		end
	elseif type == "boolean" then
		local input = panel:add(
			"checkbox",
			{
				x = x + 1,
				y = y,
				state = "_ALL",
				group = name,
				label = ""
			}
		)

		getValue = function()
			return input.selected
		end
	end

	return {
		getValue = getValue,
		name = name
	}
end

return modalManager
