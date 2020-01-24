local component = require("component")
local fs = require("filesystem")
local computer = require("computer")
local unicode = require("unicode")
local shell2 = require("shell")
local GPUProxy = component.proxy(component.list("gpu")())
local internetProxy = component.proxy(component.list("internet")())

local screenWidth, screenHeight = GPUProxy.getResolution()

----------------------------------------------------------------------------------------------------

local function download(url, file)
	local handle, data, chunk = internetProxy.request(url), ""
    
	while true do
		chunk = handle.read(math.huge)
		if chunk then
			data = data .. chunk
		else
			break
		end
	end
 
	handle.close()
	
	local file = io.open(file, "w")
	file:write(data)
	file:close()
end

local function centrize(width)
	return math.floor(screenWidth / 2 - width / 2)
end

local function centrizedText(y, color, text)
	GPUProxy.fill(1, y, screenWidth, 1, " ")
	GPUProxy.setForeground(color)
	GPUProxy.set(centrize(#text), y, text)
end

local function title()
	local y = math.floor(screenHeight / 2 - 1)
	centrizedText(y, 0x000000, "Установка SuperOs")
	return y + 2
end

local function progress(value)
	local width = 26
	local x, y, part = centrize(width), title(), math.ceil(width * value)
	
	GPUProxy.setForeground(0x000000)
	GPUProxy.set(x, y, string.rep("-", part))
	GPUProxy.setForeground(0x7F7F7F)
	GPUProxy.set(x + part, y, string.rep("-", width - part))
end

---------------------------------------------------------------------------------------------------

GPUProxy.setBackground(0xFFFFFF)
GPUProxy.fill(1, 1, screenWidth, screenHeight, " ")

progress(0.1)
download("https://raw.githubusercontent.com/KKosty4ka/OpenComputers-SuperOS/master/superos/settings.lua", "/superos/settings.lua")
