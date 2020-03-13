local percentBar = {
	x = 0,
	y = 1,
	h = 1,
	value = 50,
	state = ""
}
percentBar.__index = percentBar

function percentBar.new( data, parent )
	data = data or { }
	if data.style then
		local t = data.style
		for k, v in pairs( t ) do
			if not data[k] then
				data[k] = v
			end
		end
		data.style = nil
	end
	local self = setmetatable(data, percentBar)

	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function percentBar:draw()
	-- Draw first line
	self.parent.surf:drawLine(self.x, self.y, self.x, self.h + self.y - 1, " ", colors.lightGray, colors.lightGray)

	-- Draw value line
	local valueOffset = self.h - math.floor(self.h * (self.value/100))
	
	if self.y + valueOffset <= self.h + self.y - 1 then
		self.parent.surf:drawLine(self.x, self.h + self.y - 1, self.x, self.y + valueOffset, " ", colors.green, colors.green)
	end
end

function percentBar:update()
	if self.value > 100 then
		self.value = 100
	elseif self.value < 0 then
		self.value = 0
	end
end

function percentBar:resize()
	-- Empty method
end

return percentBar
