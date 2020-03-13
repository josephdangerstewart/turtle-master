local turtleInventoryDisplay = {
	panel = {},
	colorDictionary = {},
	remainingColors = {
		colors.white,	
		colors.orange,	
		colors.magenta,	
		colors.lightBlue,
		colors.yellow,	
		colors.lime,	
		colors.pink,	
		colors.gray,	
		colors.lightGray,
		colors.cyan,	
		colors.purple,	
		colors.blue,	
		colors.brown,	
		colors.green,	
		colors.red,	
		colors.black
	},
	inventoryDisplayElements = {},
	modalManager = {}
}
turtleInventoryDisplay.__index = turtleInventoryDisplay

function turtleInventoryDisplay.init(panel, x, y, modalManager)
	local self = setmetatable(turtleInventoryDisplay, panel)
	self.modalManager = modalManager

	local title = panel:add(
		"text",
		{
			x = x,
			y = y,
			text = "Inventory"
		}
	)

	for row = 1, 4 do
		self.inventoryDisplayElements[row] = {}
		for col = 1, 4 do
			self.inventoryDisplayElements[row][col] = panel:add(
				"button",
				{
					x = x + ((col - 1) * 3),
					y = y + row,
					text = "00",
					backColour = colors.lightGray,
					foreColour = colors.black,
					w = 2,
					h = 1
				}
			)
		end
	end

	return self
end

function turtleInventoryDisplay:updateDisplay(inventoryData)
	for row = 1, 4 do
		if inventoryData[row] ~= nil then
			for col = 1, 4 do
				if inventoryData[row][col] ~= nil then
					local name = inventoryData[row][col].name
					local count = inventoryData[row][col].count
					local chosenColor = self:getColor(name, inventoryData)
					local foreColor = chosenColor == 1 and colors.black or colors.white

					self.inventoryDisplayElements[row][col].text = count > 9 and tostring(count) or "0"..count
					self.inventoryDisplayElements[row][col].backColour = chosenColor
					self.inventoryDisplayElements[row][col].foreColour = foreColor
					self.inventoryDisplayElements[row][col].onclick = function()
						self:showColorInfo(chosenColor)
					end
				else
					self.inventoryDisplayElements[row][col].backColour = colors.lightGray
					self.inventoryDisplayElements[row][col].text = "00"
					self.inventoryDisplayElements[row][col].onclick = function()

					end
				end
			end
		end
	end	
end

function turtleInventoryDisplay:getColor(name, inventoryData)
	if self.colorDictionary[name] ~= nil then
		return self.colorDictionary[name]
	end

	if #self.remainingColors > 0 then
		local chosenColor = self.remainingColors[1]
		table.remove(self.remainingColors, 1)
		self.colorDictionary[name] = chosenColor
		return chosenColor
	end

	-- Remove stale colors from the used color table
	for name, color in pairs(self.colorDictionary) do
		local colorIsUsed = false
		for j, inventoryRow in pairs(inventoryData) do
			for n, inventoryItem in pairs(inventoryRow) do
				if inventoryItem ~= nil and inventoryItem.name  then
					colorIsUsed = true
				end
			end
		end

		if not colorIsUsed then
			table.insert(self.remainingColors, color)
			self.colorDictionary[name] = nil
		end
	end
end

function turtleInventoryDisplay:showColorInfo(color)
	local termW, termH = term.getSize()

	local item = ""
	for i,v in pairs(self.colorDictionary) do
		if v == color then
			item = i
		end
	end

	local x = math.floor(termW * .25)
	local w = termW - x * 2
	local y = 4
	local h = 4

	local modal = self.modalManager:new({
		x = x,
		w = w,
		y = y,
		h = h,
		title = "Item Color Details"
	})

	modal:add(
		"text",
		{
			x = 1,
			y = 2,
			text = item == "" and "No item" or "This color is " .. item
		}
	)
end

return turtleInventoryDisplay
