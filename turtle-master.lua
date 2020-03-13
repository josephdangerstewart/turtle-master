function string.split(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function string.startsWith(inputstr, sub)
	return string.sub(inputstr, 1, #sub) == sub
end

function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.join(tbl, joiner)
	local joined = ""
	for i,v in pairs(tbl) do
		if i == 1 then
			joined = v
		else
			joined = joined .. " " .. v
		end
	end
	return joined
end

local colbalt = dofile("cobalt")
cobalt.ui = dofile("cobalt-ui/init.lua")
local TurtleManager = dofile("tm-helpers/turtle-manager.lua")
local UIManager = dofile("tm-helpers/ui-manager.lua")
local ModalManager = dofile("tm-helpers/modal-manager.lua")
local NetworkManager = dofile("tm-helpers/network-manager.lua")
local ConfigManager = dofile("tm-helpers/config-manager.lua")

local modalManager = ModalManager.init()
local configManager = ConfigManager.init(modalManager)
local uiManager = UIManager.init(modalManager, configManager)
local turtleManager = TurtleManager.init(uiManager)
local networkManager = NetworkManager.init(turtleManager, uiManager)
local pingTimer = 0

local dummyTurtle = {
	name = "Farmy",
	id = 20,
	fuel = 100,
	protocol = "farming",
	fuelLimit = 200,
	online = true,
	inventory = {
		{},
		{
			[3] = {
				name = "minecraft:coal",
				count = 4
			}
		},
		{
			[1] = {
				name = "minecraft:grass",
				count = 20
			}
		},
		{
			[4] = {
				name = "minecraft:grass",
				count = 64
			}
		}
	},
	peripherals = {
		"modem"
	}
}

function cobalt.draw()
	cobalt.ui.draw()
end

function cobalt.update(dt)
	cobalt.ui.update(dt)
end

function cobalt.mousepressed(x, y, button)
	cobalt.ui.mousepressed(x, y, button)
end

function cobalt.mousereleased(x, y, button)
	cobalt.ui.mousereleased(x, y, button) 
end

function cobalt.keypressed(keycode, key)
	if keycode == 203 then
		uiManager:scrollLeft()
	elseif keycode == 205 then
		uiManager:scrollRight()
	end
	cobalt.ui.keypressed(keycode, key)
end

function cobalt.textinput(t)
	cobalt.ui.textinput(t)
end

function cobalt.rednetreceive(id, message, c)
	networkManager:receiveMessage(message, id)
end

function cobalt.timer_event(timer_id)
	if timer_id == pingTimer then
		networkManager:pingTurtles()
		pingTimer = os.startTimer(configManager:getValue("pingTime"))
	end
end

pingTimer = os.startTimer(configManager:getValue("pingTime"))

cobalt.initLoop()
