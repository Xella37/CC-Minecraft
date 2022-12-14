
local path = "/"..shell.dir()

local Pine3D = require("Pine3D")
local betterblittle = require("betterblittle")
local noise = require("noise")
os.loadAPI(path.."/blittle")

if not fs.exists("worlds") then
	fs.makeDir("worlds")
end

local worldId = ""
local pauseMenu = false
local drawHotbar = true
local viewFPS = false
local f3MenuOpen = false

local speed = 6
local turnSpeed = 180

local camera = {
	x = 0,
	y = 0,
	z = 0,
	rotX = 0,
	rotY = 0,
	rotZ = 0,
}

local keysDown = {}

local screenWidth, screenHeight = term.getSize()

local ThreeDFrame = Pine3D.newFrame()
local blittleOn = true
local menusWindow = window.create(term.current(), 1+math.max(0, screenWidth*0.5-20), 2+math.max(0, screenHeight*0.5-7), screenWidth-math.max(0, screenWidth*0.5 - 20)*2, screenHeight-1-math.max(0, screenHeight*0.5-6)*2)

local bigMenuWindow = window.create(term.current(), 1, 1, screenWidth, screenHeight)
local oldTerm = term.redirect(bigMenuWindow)

local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
local worldListWindow = window.create(term.current(), x1+1, 5, x2 - (x1+1), screenHeight-5 - 5)

local logo = paintutils.loadImage("logo.nfp")
for y = 1, math.ceil(#logo / 3)*3 do
	if not logo[y] then
		logo[y] = {}
	end
	for x = 1, math.ceil(#logo[7] / 2)*2 do
		if not logo[y][x] or logo[y][x] == 0 then
			logo[y][x] = colors.brown
		end
	end
end
local logoWindow = window.create(term.current(), math.floor(screenWidth*0.5 - 18 + 0.5), 1, #logo[1]/2, #logo/3, false)
betterblittle.drawBuffer(logo, logoWindow)
local function runLogoAnimation()
	local randomMap = {}
	for x = 1, #logo[1] do
		local sx = math.floor((x-1)/2)
		randomMap[sx] = math.random(0, 4)
	end

	local startT = os.clock()
	local t = 100
	while t >= 0 do
		local newBuffer = {}
		for y = 1, #logo do
			newBuffer[y] = {}
			for x = 1, #logo[1] do
				newBuffer[y][x] = colors.brown
			end
		end

		for y = 1, #logo do
			for x = 1, #logo[1] do
				local px = logo[y][x]

				local sx = math.floor((x-1)/2)
				local sy = math.floor((y-1)/2)

				local ran = randomMap[sx]

				local yOffset = 2*math.max(0, t*0.2 - ran - sy*2)

				local newY = math.floor(y - yOffset)
				if newY >= 1 then
					newBuffer[newY][x] = px
				end
			end
		end
		betterblittle.drawBuffer(newBuffer, logoWindow)
		while os.clock() < startT + (100-t)/100 do
			os.queueEvent("logoAnimation")
			os.pullEvent("logoAnimation")
		end
		t = t - 1
	end
end

local function termResize()
	screenWidth, screenHeight = oldTerm.getSize()

	term.setBackgroundColor(colors.lightBlue)
	term.clear()

	if viewFPS then
		ThreeDFrame:setSize(1, 2, screenWidth, screenHeight)
	else
		ThreeDFrame:setSize(1, 1, screenWidth, screenHeight)
	end
	menusWindow.reposition(1+math.max(0, screenWidth*0.5-20), 2+math.max(0, screenHeight*0.5-7), screenWidth-math.max(0, screenWidth*0.5 - 20)*2, screenHeight-1-math.max(0, screenHeight*0.5-6)*2)
	bigMenuWindow.reposition(1, 1, screenWidth, screenHeight)
	local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
	local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
	worldListWindow.reposition(x1+1, 5, x2 - (x1+1), screenHeight-5 - 5)
	logoWindow.reposition(math.floor(screenWidth*0.5 - 18 + 0.5), 1, #logo[1]/2, #logo/3)
end

local objects = {}
local grid = {}

local idEncode = {air = "a"}
local idDecode = {a = "air"}
local models = {}
local i = 2
local letters = "abcdefghijklmnopqrstuvwxyz"
local blockIds = {"grass", "dirt", "wood", "leaves", "stone", "sand", "water"}
for _, name in pairs(blockIds) do
	models[name] = Pine3D.loadModel("models/" .. name)
	local letter = letters:sub(i, i)
	idEncode[name] = letter
	idDecode[letter] = name
	i = i + 1
end


local seed = 0
local size = 2
local maxHeightTerrain = 5
local maxHeightChunk = maxHeightTerrain+7
local chunkSize = 16
local terrainSmoothness = 2
local renderDistance = 1
local selectedBlock = "dirt"

local gameState = "mainMenu"

local loadedChunks = {}

local function updateBlockMesh(x, y, z)
	local gridX = grid[x]
	local block = gridX and gridX[y] and gridX[y][z]
	if block then
		local object = block.object

		local originalModel = models[block.originalModel]

		local copyIndex = {}

		local x_new = x-1
		local x_neg = grid[x_new] and grid[x_new][y] and grid[x_new][y][z]
		if not x_neg then
			copyIndex[#copyIndex+1] = 5
			copyIndex[#copyIndex+1] = 6
		end

		local x_new = x+1
		local x_pos = grid[x_new] and grid[x_new][y] and grid[x_new][y][z]
		if not x_pos then
			copyIndex[#copyIndex+1] = 7
			copyIndex[#copyIndex+1] = 8
		end

		local z_neg = gridX[y] and gridX[y][z-1]
		if not z_neg then
			copyIndex[#copyIndex+1] = 9
			copyIndex[#copyIndex+1] = 10
		end

		local z_pos = gridX[y] and gridX[y][z+1]
		if not z_pos then
			copyIndex[#copyIndex+1] = 11
			copyIndex[#copyIndex+1] = 12
		end

		local y_new = y+1
		local y_pos = gridX[y_new] and gridX[y_new][z]
		if not y_pos then
			copyIndex[#copyIndex+1] = 3
			copyIndex[#copyIndex+1] = 4
		end

		local y_new = y-1
		local y_neg = gridX[y_new] and gridX[y_new][z]
		if not y_neg and y ~= 0 then
			copyIndex[#copyIndex+1] = 1
			copyIndex[#copyIndex+1] = 2
		end

		local newModel = {}
		for _, i in pairs(copyIndex) do
			newModel[#newModel+1] = originalModel[i]
		end

		object:setModel(newModel)
	end
end

local function updateChunkMesh(chunkX, chunkZ, unloading)
	for x = chunkX*chunkSize+1-1, chunkX*chunkSize + chunkSize + 1 do
		for z = chunkZ*chunkSize+1-1, chunkZ*chunkSize + chunkSize + 1 do
			for y = 0, maxHeightChunk do
				local grid = grid
				local gridX = grid[x]
				local block = gridX and gridX[y] and gridX[y][z]
				if block then
					local object = block.object

					local originalModel = models[block.originalModel]

					local copyIndex = {}

					local x_new = x-1
					local x_neg = grid[x_new] and grid[x_new][y] and grid[x_new][y][z]
					if not x_neg then
						if x ~= chunkX*chunkSize+1 or loadedChunks[chunkX-1] and loadedChunks[chunkX-1][chunkZ] then
							if x ~= chunkX*chunkSize+chunkSize+1 or not unloading then
								copyIndex[#copyIndex+1] = 5
								copyIndex[#copyIndex+1] = 6
							end
						end
					end

					local x_new = x+1
					local x_pos = grid[x_new] and grid[x_new][y] and grid[x_new][y][z]
					if not x_pos then
						if x ~= chunkX*chunkSize+chunkSize or loadedChunks[chunkX+1] and loadedChunks[chunkX+1][chunkZ] then
							if x ~= chunkX*chunkSize+1-1 or not unloading then
								copyIndex[#copyIndex+1] = 7
								copyIndex[#copyIndex+1] = 8
							end
						end
					end

					local z_neg = gridX[y] and gridX[y][z-1]
					if not z_neg then
						if z ~= chunkZ*chunkSize+1 or loadedChunks[chunkX] and loadedChunks[chunkX][chunkZ-1] then
							if z ~= chunkZ*chunkSize+chunkSize+1 or not unloading then
								copyIndex[#copyIndex+1] = 9
								copyIndex[#copyIndex+1] = 10
							end
						end
					end

					local z_pos = gridX[y] and gridX[y][z+1]
					if not z_pos then
						if z ~= chunkZ*chunkSize+chunkSize or loadedChunks[chunkX] and loadedChunks[chunkX][chunkZ+1] then
							if z ~= chunkZ*chunkSize+1-1 or not unloading then
								copyIndex[#copyIndex+1] = 11
								copyIndex[#copyIndex+1] = 12
							end
						end
					end

					local y_new = y+1
					local y_pos = gridX[y_new] and gridX[y_new][z]
					if not y_pos then
						copyIndex[#copyIndex+1] = 3
						copyIndex[#copyIndex+1] = 4
					end

					local y_new = y-1
					local y_neg = gridX[y_new] and gridX[y_new][z]
					if not y_neg and y ~= 0 then
						copyIndex[#copyIndex+1] = 1
						copyIndex[#copyIndex+1] = 2
					end

					local newModel = {}
					for _, i in pairs(copyIndex) do
						newModel[#newModel+1] = originalModel[i]
					end

					object:setModel(newModel)
				end
			end
		end
	end
end

function setBlock(x, y, z, id, updateConnectedMeshes)
	if not grid[x] then grid[x] = {} end
	if not grid[x][y] then grid[x][y] = {} end

	local block = grid[x][y][z]
	if block then
		return
	end

	local id = id or "dirt"

	local model = models[id]
	local object = ThreeDFrame:newObject(model, x, y, z)

	grid[x][y][z] = {
		object = object,
		originalModel = id,
	}
	objects[#objects+1] = object

	if updateConnectedMeshes then
		updateBlockMesh(x, y, z)
		updateBlockMesh(x-1, y, z)
		updateBlockMesh(x+1, y, z)
		updateBlockMesh(x, y-1, z)
		updateBlockMesh(x, y+1, z)
		updateBlockMesh(x, y, z-1)
		updateBlockMesh(x, y, z+1)
	end
end

function getBlock(x, y, z)
	return grid[x] and grid[x][y] and grid[x][y][z] or nil
end

function removeBlock(x, y, z)
	local block = getBlock(x, y, z)
	if block then
		for i = 1, #objects do
			if objects[i] == block.object then
				table.remove(objects, i)
				break
			end
		end
		grid[x][y][z] = nil
	end
end

local function generateChunk(seed, chunkX, chunkZ, maxHeightTerrain, chunkSize, terrainSmoothness)
	math.randomseed(seed)
	local mapNoise = noise.createNoise(chunkSize, chunkX, chunkZ, seed, terrainSmoothness)

	local waterHeight = 0.3 * maxHeightTerrain
	for a = 1, chunkSize do
		for b = 1, chunkSize do
			local heightRaw = mapNoise[a][b]*maxHeightTerrain
			local height = math.floor(heightRaw)

			if heightRaw < waterHeight then
				for y = 0, height-2 do
					setBlock(chunkX*chunkSize + a, y, chunkZ*chunkSize + b, "dirt")
				end
				if height-1 >= 0 then
					setBlock(chunkX*chunkSize + a, height-1, chunkZ*chunkSize + b, "sand")
				end
				for y = height, waterHeight do
					setBlock(chunkX*chunkSize + a, y, chunkZ*chunkSize + b, "water")
				end
			else
				for y = 0, height-1 do
					setBlock(chunkX*chunkSize + a, y, chunkZ*chunkSize + b, "dirt")
				end
				if height == math.floor(waterHeight) then
					setBlock(chunkX*chunkSize + a, height, chunkZ*chunkSize + b, "sand")
				else
					setBlock(chunkX*chunkSize + a, height, chunkZ*chunkSize + b, "grass")
				end
			end
		end
	end

	local treeCount = math.max(1, math.random(1, chunkSize*chunkSize*0.005))
	for i = 1, treeCount do
		local a = math.random(3, chunkSize-2)
		local b = math.random(3, chunkSize-2)
		local x = chunkX*chunkSize + a
		local z = chunkZ*chunkSize + b

		local plantY = maxHeightTerrain+1
		while not getBlock(x, plantY-1, z) do
			plantY = plantY - 1
		end

		if getBlock(x, plantY-1, z).originalModel == "grass" then
			local height = math.random(1, 3)
			for y = plantY, plantY + height+1 do
				setBlock(x, y, z, "wood")
			end
			for tx = x-2, x+2 do
				for tz = z-2, z+2 do
					for ty = plantY + height, plantY + height + 1 do
						if not getBlock(tx, ty, tz) then
							if not (tx == x-2 and tz == z-2 or tx == x+2 and tz == z-2 or tx == x+2 and tz == z+2 or tx == x-2 and tz == z+2) or math.random(1, 2) == 1 then
								setBlock(tx, ty, tz, "leaves")
							end
						end
					end
				end
			end

			for tx = x-1, x+1 do
				for tz = z-1, z+1 do
					for ty = plantY + height+2, plantY + height + 3 do
						if not getBlock(tx, ty, tz) then
							if not (tx ~= x and tz ~= z and ty == plantY + height + 3) or math.random(1, 3) == 1 then
								setBlock(tx, ty, tz, "leaves")
							end
						end
					end
				end
			end
		end
	end
end

local function unloadChunk(x, z)
	if loadedChunks[x] and loadedChunks[x][z] then
		local encodedBlocks = {}
		local removeObject = {}

		local lastChar = ""
		local charCount = 0
		for a = 1, chunkSize do
			local gridX = grid[x*chunkSize + a]
			if gridX then
				for y = 0, maxHeightChunk do
					local gridXY = gridX[y]
					if gridXY then
						for b = 1, chunkSize do
							local block = gridXY[z*chunkSize + b]

							local char = "a"
							if block then
								removeObject[block.object] = true
								gridXY[z*chunkSize + b] = nil
								char = idEncode[block.originalModel]
							end

							if char == lastChar then
								charCount = charCount + 1
							else
								if charCount == 1 then
									encodedBlocks[#encodedBlocks+1] = lastChar
								else
									encodedBlocks[#encodedBlocks+1] = charCount .. lastChar
								end
								lastChar = char
								charCount = 1
							end
						end
					else
						if lastChar == "a" then
							charCount = charCount + chunkSize
						elseif charCount > 0 then
							if charCount == 1 then
								encodedBlocks[#encodedBlocks+1] = lastChar
							else
								encodedBlocks[#encodedBlocks+1] = charCount .. lastChar
							end
							lastChar = "a"
							charCount = chunkSize
						end
					end
				end
			else
				if lastChar == "a" then
					charCount = charCount + maxHeightChunk*chunkSize
				elseif charCount > 0 then
					if charCount == 1 then
						encodedBlocks[#encodedBlocks+1] = lastChar
					else
						encodedBlocks[#encodedBlocks+1] = charCount .. lastChar
					end
					lastChar = "a"
					charCount = maxHeightChunk*chunkSize
				end
			end
		end
		if charCount > 0 then
			if charCount == 1 then
				encodedBlocks[#encodedBlocks+1] = lastChar
			else
				encodedBlocks[#encodedBlocks+1] = charCount .. lastChar
			end
		end

		local blockEncoded = table.concat(encodedBlocks)
		local file = fs.open("worlds/" .. worldId .. "/chunk_" .. x .. "," .. z .. ".txt", "w")
		file.write(chunkSize .. "\n" .. maxHeightChunk.. "\n" .. blockEncoded)
		file.close()

		local newObjects = {}
		for i = 1, #objects do
			local object = objects[i]
			if not removeObject[object] then
				newObjects[#newObjects+1] = object
			end
		end
		objects = newObjects

		loadedChunks[x][z] = nil
		updateChunkMesh(x, z, true)
		return true
	end
end

local function loadChunkFromRaw(raw, chunkX, chunkZ)
	local parts = {}
	for part in raw:gmatch("[^\n]+") do
		parts[#parts+1] = part
	end
	local chunkSize = tonumber(parts[1])
	local chunkHeight = tonumber(parts[2])

	local blockIds = {}
	local i = 1
	local numberChars = ""
	while i <= #raw do
		local char = raw:sub(i, i)
		local num = tonumber(char)
		if num then
			numberChars = numberChars .. num
		else
			local dec = idDecode[char]
			local count = 1
			if #numberChars > 0 then
				count = tonumber(numberChars)
				numberChars = ""
			end
			for j = 1, count do
				blockIds[#blockIds+1] = dec
			end
		end
		i = i + 1
	end

	i = 1
	for a = 1, chunkSize do
		for y = 0, chunkHeight do
			for b = 1, chunkSize do
				local id = blockIds[i]
				if id ~= "air" then
					setBlock(chunkX*chunkSize + a, y, chunkZ*chunkSize + b, id)
				end
				i = i + 1
			end
		end
	end
end

local function loadChunk(x, z)
	if not loadedChunks[x] or not loadedChunks[x][z] then
		local playerChunkX = math.floor(camera.x / chunkSize)
		local playerChunkZ = math.floor(camera.z / chunkSize)

		if x >= playerChunkX-renderDistance and x <= playerChunkX+renderDistance then
			if z >= playerChunkZ-renderDistance and z <= playerChunkZ+renderDistance then
				local file = fs.open("worlds/" .. worldId .. "/chunk_" .. x .. "," .. z .. ".txt", "r")
				if not file then
					generateChunk(seed, x, z, maxHeightTerrain, chunkSize, terrainSmoothness)
				else
					local raw = file.readAll()
					file.close()
					loadChunkFromRaw(raw, x, z)
				end
				updateChunkMesh(x, z, false)

				if not loadedChunks[x] then
					loadedChunks[x] = {}
				end
				loadedChunks[x][z] = true

				return true
			end
		end
	end
end

local chunkLoadQueue = {}
local chunkUnloadQueue = {}
local function queueChunk(x, z, t)
	if t == "load" then
		for i = #chunkUnloadQueue, 1, -1 do
			if chunkUnloadQueue[1] == x and chunkUnloadQueue[2] == z then
				table.remove(chunkUnloadQueue, i)
			end
		end
		for i = #chunkLoadQueue, 1, -1 do
			if chunkLoadQueue[1] == x and chunkLoadQueue[2] == z then
				return
			end
		end

		chunkLoadQueue[#chunkLoadQueue+1] = {x, z}
	elseif t == "unload" then
		for i = #chunkLoadQueue, 1, -1 do
			if chunkLoadQueue[1] == x and chunkLoadQueue[2] == z then
				table.remove(chunkLoadQueue, i)
				loadedChunks[x][z] = nil
				return
			end
		end
		for i = #chunkUnloadQueue, 1, -1 do
			if chunkUnloadQueue[1] == x and chunkUnloadQueue[2] == z then
				return
			end
		end
		chunkUnloadQueue[#chunkUnloadQueue+1] = {x, z}
	end
end

local function stepChunkQueue()
	if #chunkUnloadQueue > 0 then
		local task = table.remove(chunkUnloadQueue, 1)
		if not unloadChunk(task[1], task[2]) then
			return stepChunkQueue()
		end
		return true
	elseif #chunkLoadQueue > 0 then
		local task = table.remove(chunkLoadQueue, 1)
		if not loadChunk(task[1], task[2]) then
			return stepChunkQueue()
		end
		return true
	end
end

local function udpdateWorld()
	local playerChunkX = math.floor(camera.x / chunkSize)
	local playerChunkZ = math.floor(camera.z / chunkSize)

	for x = playerChunkX-renderDistance, playerChunkX+renderDistance do
		for z = playerChunkZ-renderDistance, playerChunkZ+renderDistance do
			if not loadedChunks[x] or not loadedChunks[x][z] then
				queueChunk(x, z, "load")
			end
		end
	end

	for x = playerChunkX-renderDistance-2, playerChunkX+renderDistance+2 do
		for z = playerChunkZ-renderDistance-2, playerChunkZ+renderDistance+2 do
			if x < playerChunkX-renderDistance or x > playerChunkX+renderDistance or z < playerChunkZ-renderDistance or z > playerChunkZ+renderDistance then
				if loadedChunks[x] and loadedChunks[x][z] then
					queueChunk(x, z, "unload")
				end
			end
		end
	end
end

udpdateWorld()

function drawNiceBorder(win, x1, y1, x2, y2, bg, fg)
	local s = string.rep(" ", x2-x1+1-2)
	win.setBackgroundColor(bg)
	for y = y1+1, y2-1 do
		win.setCursorPos(x1+1, y)
		win.write(s)
	end

	for i = x1 + 1, x2 - 1 do
		win.setBackgroundColor(bg)
		win.setTextColor(fg)
		win.setCursorPos(i, y1)
		win.write(string.char(131))
	end
	for i = x1 + 1, x2 - 1 do
		win.setBackgroundColor(fg)
		win.setTextColor(bg)
		win.setCursorPos(i, y2)
		win.write(string.char(143))
	end
	for i = y1 + 1, y2 - 1 do
		win.setBackgroundColor(bg)
		win.setTextColor(fg)
		win.setCursorPos(x1, i)
		win.write(string.char(149))
	end
	for i = y1 + 1, y2 - 1 do
		win.setBackgroundColor(fg)
		win.setTextColor(bg)
		win.setCursorPos(x2, i)
		win.write(string.char(149))
	end

	win.setCursorPos(x1, y1)
	win.setBackgroundColor(bg)
	win.setTextColor(fg)
	win.write(string.char(151))

	win.setCursorPos(x1, y2)
	win.setBackgroundColor(fg)
	win.setTextColor(bg)
	win.write(string.char(138))

	win.setCursorPos(x2, y1)
	win.setBackgroundColor(fg)
	win.setTextColor(bg)
	win.write(string.char(148))

	win.setCursorPos(x2, y2)
	win.setBackgroundColor(fg)
	win.setTextColor(bg)
	win.write(string.char(133))
end

function drawButton(win, x1, y1, x2, y2, text, bg, fg, tc)
	drawNiceBorder(win, x1, y1, x2, y2, bg, fg)
	win.setTextColor(tc)
	win.setBackgroundColor(bg)
	win.setCursorPos(math.floor((x1+x2)*0.5 - #text*0.5 + 0.5), (y1+y2)*0.5)
	win.write(text)
end

local hotbar = paintutils.loadImage("hotbar.nfp")
local hotbarb = paintutils.loadImage("hotbarb.nfp")

function renderPauseMenu()
	menusWindow.setVisible(false)
	local w, h = menusWindow.getSize()
	drawNiceBorder(menusWindow, 1, 1, w, h, colors.brown, colors.green)
	local pattern = {131, 135, 139, 135, 139, 143}
	local s = ""
	math.randomseed(0)
	for x = 2, w-1 do
		s = s .. string.char(pattern[math.random(6)])
	end
	menusWindow.setBackgroundColor(colors.brown)
	menusWindow.setTextColor(colors.green)
	menusWindow.setCursorPos(2, 1)
	menusWindow.write(s)

	menusWindow.setBackgroundColor(colors.brown)
	menusWindow.setTextColor(colors.white)
	menusWindow.setCursorPos(math.floor(w*0.5 - #("Game Paused")*0.5 + 0.5), 2)
	menusWindow.write("Game Paused")

	drawButton(menusWindow, 3, 4, w-2, 6, "Back to Game", colors.gray, colors.lightGray, colors.white)
	drawButton(menusWindow, 3, 4+4, w-2, 6+4, "Save and Quit", colors.gray, colors.lightGray, colors.white)

	menusWindow.setVisible(true)
end

local frameTimes = {}
local lastFrameTime = os.clock()
function render3DGraphics()
	ThreeDFrame:drawObjects(objects)

	local buff = ThreeDFrame.buffer
	local width, height = buff.width, buff.height
	if f3MenuOpen then
		for i = 1, #frameTimes do
			local time = frameTimes[#frameTimes-i + 1]
			for y = 1, time*200 do
				local c = colors.yellow
				if time > 1/20 then
					c = colors.red
				elseif time > 1/30 then
					c = colors.orange
				end
				buff:setPixel(i, y, c)
			end
		end
	end

	if drawHotbar then
		if blittleOn then
			local hotX = math.floor((width*0.5 - #hotbarb[1]*0.5) * 0.5 + 0.5)
			local hotY = height/3 - 2
			buff:image(hotX, hotY, hotbarb)

			for i = 1, #blockIds do
				local col = colors.gray
				local dy = 0
				if blockIds[i] == selectedBlock then
					col = colors.lightGray
					dy = 1
				end
				for x = hotX*2 + (i-1)*4*2-1, hotX*2 + (i-1)*4*2+4 do
					for y = hotY*3+4, hotY*3+5+dy do
						buff:setPixel(x, y, col)
					end
				end
			end
		else
			local hotX = math.floor(width*0.5 - #hotbar[1]*0.5 + 0.5)
			local hotY = height - 2
			buff:image(hotX, hotY, hotbar)

			for i = 1, #blockIds do
				local col = colors.gray
				if blockIds[i] == selectedBlock then
					col = colors.lightGray
				end
				buff:setPixel(hotX + (i-1)*3, hotY+2, col)
				buff:setPixel(hotX + (i-1)*3+1, hotY+2, col)
			end
		end
	end

	ThreeDFrame:drawBuffer()
end

function renderFPS(frames, lastFPSTime)
	local currentTime = os.clock()

	local frames = frames + 1
	if currentTime > lastFPSTime + 1 then
		lastFPSTime = os.clock()
		if viewFPS then
			term.setBackgroundColor(colors.black)
			term.setCursorPos(1, 1)
			term.clearLine()
			term.setCursorPos(1, 1)
			term.setTextColor(colors.white)
			term.write("Average FPS: " .. frames)
		end
		frames = 0
	end

	frameTimes[#frameTimes+1] = currentTime - lastFrameTime
	lastFrameTime = currentTime
	if #frameTimes > 30 then
		table.remove(frameTimes, 1)
	end

	return frames, lastFPSTime
end

local function rendering()
	local frames = 0
	local lastFPSTime = 0
	while true do
		if pauseMenu then
			renderPauseMenu()
			sleep(0.05)
		else
			render3DGraphics()
		end

		frames, lastFPSTime = renderFPS(frames, lastFPSTime)

		os.queueEvent("FakeEvent")
		os.pullEvent("FakeEvent")
	end
end

local function handleCameraMovement(dt)
	local dx, dy, dz = 0, 0, 0 -- will represent the movement per second

	-- handle arrow keys for camera rotation
	if keysDown[keys.left] then
		camera.rotY = (camera.rotY - turnSpeed * dt) % 360
	end
	if keysDown[keys.right] then
		camera.rotY = (camera.rotY + turnSpeed * dt) % 360
	end
	if keysDown[keys.down] then
		camera.rotZ = math.max(-80, camera.rotZ - turnSpeed * dt)
	end
	if keysDown[keys.up] then
		camera.rotZ = math.min(80, camera.rotZ + turnSpeed * dt)
	end

	-- handle wasd keys for camera movement
	if keysDown[keys.w] then
		dx = speed * math.cos(math.rad(camera.rotY)) + dx
		dz = speed * math.sin(math.rad(camera.rotY)) + dz
	end
	if keysDown[keys.s] then
		dx = -speed * math.cos(math.rad(camera.rotY)) + dx
		dz = -speed * math.sin(math.rad(camera.rotY)) + dz
	end
	if keysDown[keys.a] then
		dx = speed * math.cos(math.rad(camera.rotY - 90)) + dx
		dz = speed * math.sin(math.rad(camera.rotY - 90)) + dz
	end
	if keysDown[keys.d] then
		dx = speed * math.cos(math.rad(camera.rotY + 90)) + dx
		dz = speed * math.sin(math.rad(camera.rotY + 90)) + dz
	end

	-- space and left shift key for moving the camera up and down
	if keysDown[keys.space] then
		dy = speed + dy
	end
	if keysDown[keys.leftShift] then
		dy = -speed + dy
	end

	-- update the camera position by adding the offset
	camera.x = camera.x + dx * dt
	camera.y = camera.y + dy * dt
	camera.z = camera.z + dz * dt

	ThreeDFrame:setCamera(camera)

	udpdateWorld()
end


local function saveWorld()
	for chunkX, a in pairs(loadedChunks) do
		for chunkZ, b in pairs(a) do
			queueChunk(chunkX, chunkZ, "unload")
		end
	end
	chunkLoadQueue = {}
	while stepChunkQueue() do end

	local playerFile = fs.open("worlds/" .. worldId .. "/player.txt", "w")
	playerFile.write(textutils.serialise({
		x = camera.x,
		y = camera.y,
		z = camera.z,
		camHor = camera.rotY,
		camVer = camera.rotZ,
		lastActive = os.time(os.date("!*t")),
	}))
	playerFile.close()
end

local function keyInput()
	while true do
		local event, key, x, y = os.pullEventRaw()

		if event == "key" then
			keysDown[key] = true
			if key == keys.g then
				blittleOn = not blittleOn
				ThreeDFrame:highResMode(blittleOn)
			elseif key == keys.h then
				udpdateWorld()
			elseif key == keys.j then
				stepChunkQueue()
			elseif key == keys.minus then
				renderDistance = math.max(0, renderDistance - 1)
			elseif key == keys.equals then
				renderDistance = renderDistance + 1
			elseif key == keys.z then
				f3MenuOpen = not f3MenuOpen
			elseif key == keys.x then
				drawHotbar = not drawHotbar
			elseif key == keys.c then
				viewFPS = not viewFPS
				if viewFPS then
					ThreeDFrame:setSize(1, 2, screenWidth, screenHeight)
					term.setCursorPos(1, 1)
					term.setBackgroundColor(colors.black)
					term.clearLine()
				else
					ThreeDFrame:setSize(1, 1, screenWidth, screenHeight)
				end
			elseif key >= keys.one and key <= keys.nine then
				local id = blockIds[key - keys.one+1]
				if id then
					selectedBlock = id
				end
			elseif key == keys.grave then
				pauseMenu = not pauseMenu
			end
		elseif event == "mouse_scroll" then
			local selectedNr = 0
			while blockIds[selectedNr] ~= selectedBlock do
				selectedNr = selectedNr + 1
			end

			selectedBlock = blockIds[(selectedNr + key - 1) % #blockIds + 1]
		elseif event == "key_up" then
			keysDown[key] = nil
		elseif event == "mouse_click" then
			if pauseMenu then
				local dx, dy = menusWindow.getPosition()
				dx = dx - 1
				dy = dy - 1
				local w, h = menusWindow.getSize()
				if x >= 3 + dx and y >= 4 + dy and x <= w-2 + dx and y <= 6 + dy then
					pauseMenu = false
				elseif x >= 3 + dx and y >= 4+4 + dy and x <= w-2 + dx and y <= 6+4 + dy then
					break
				end
			else
				local clickedHotbar = false
				local width, height = ThreeDFrame.buffer.width, ThreeDFrame.buffer.height
				if blittleOn then
					local hotX = math.floor((width*0.5 - #hotbarb[1]*0.5) * 0.5 + 0.5)
					local hotY = height/3 - 2

					local clickX = (x-1) * 2 + 1
					local clickY = (y-1) * 3 + 1

					for i = 1, #blockIds do
						if clickX >= hotX*2 + (i-1)*4*2-1 and clickX <= hotX*2 + (i-1)*4*2+4 then
							if clickY >= hotY*3 then
								clickedHotbar = true
								selectedBlock = blockIds[i]
								break
							end
						end
					end
				else
					local hotX = math.floor(width*0.5 - #hotbar[1]*0.5 + 0.5)
					local hotY = height - 2
					for i = 1, #blockIds do
						if (x == hotX + (i-1)*3 or x == hotX + (i-1)*3+1) and (y == hotY+1 or y == hotY+2) then
							selectedBlock = blockIds[i]
							clickedHotbar = true
							break
						end
					end
				end

				if not clickedHotbar then
					local objectIndex, polyIndex = ThreeDFrame:getObjectIndexTrace(objects, x, y) -- detect on what and object the player clicked
					if objectIndex then -- if the player clicked on an object (not void)
						if key == 1 then
							local object = objects[objectIndex]
							local x, y, z = object[1], object[2], object[3]
							removeBlock(x, y, z) -- remove the object the player clicked on
							updateBlockMesh(x-1, y, z)
							updateBlockMesh(x+1, y, z)
							updateBlockMesh(x, y-1, z)
							updateBlockMesh(x, y+1, z)
							updateBlockMesh(x, y, z-1)
							updateBlockMesh(x, y, z+1)
						elseif key == 2 then
							local object = objects[objectIndex]

							local copyIndex = {}
							local x, y, z = object[1], object[2], object[3]

							local x_neg = getBlock(x-1, y, z)
							if not x_neg then
								copyIndex[#copyIndex+1] = 5
								copyIndex[#copyIndex+1] = 6
							end

							local x_pos = getBlock(x+1, y, z)
							if not x_pos then
								copyIndex[#copyIndex+1] = 7
								copyIndex[#copyIndex+1] = 8
							end

							local z_neg = getBlock(x, y, z-1)
							if not z_neg then
								copyIndex[#copyIndex+1] = 9
								copyIndex[#copyIndex+1] = 10
							end

							local z_pos = getBlock(x, y, z+1)
							if not z_pos then
								copyIndex[#copyIndex+1] = 11
								copyIndex[#copyIndex+1] = 12
							end

							local y_pos = getBlock(x, y+1, z)
							if not y_pos then
								copyIndex[#copyIndex+1] = 3
								copyIndex[#copyIndex+1] = 4
							end

							local y_neg = getBlock(x, y-1, z)
							if not y_neg and y ~= 0 then
								copyIndex[#copyIndex+1] = 1
								copyIndex[#copyIndex+1] = 2
							end

							local polyIndexOriginal = copyIndex[polyIndex]

							if polyIndexOriginal == 1 or polyIndexOriginal == 2 then
								setBlock(x, y-1, z, selectedBlock, true)
							elseif polyIndexOriginal == 3 or polyIndexOriginal == 4 then
								if y < maxHeightChunk then
									setBlock(x, y+1, z, selectedBlock, true)
								end
							elseif polyIndexOriginal == 5 or polyIndexOriginal == 6 then
								setBlock(x-1, y, z, selectedBlock, true)
							elseif polyIndexOriginal == 7 or polyIndexOriginal == 8 then
								setBlock(x+1, y, z, selectedBlock, true)
							elseif polyIndexOriginal == 9 or polyIndexOriginal == 10 then
								setBlock(x, y, z-1, selectedBlock, true)
							elseif polyIndexOriginal == 11 or polyIndexOriginal == 12 then
								setBlock(x, y, z+1, selectedBlock, true)
							end
						elseif key == 3 then
							local object = objects[objectIndex]
							local block = getBlock(object[1], object[2], object[3])
							selectedBlock = block.originalModel
						end
					end
				end
			end
		elseif event == "term_resize" then
			screenWidth, screenHeight = oldTerm.getSize()

			termResize()
		end
	end
end

local function gameUpdate()
	local timeFromLastUpdate = os.clock()

	while true do
		local currentTime = os.clock()
		local dt = currentTime - timeFromLastUpdate
		if pauseMenu then
			sleep(0.05)
		else
			handleCameraMovement(dt)
		end
		timeFromLastUpdate = currentTime

	    os.queueEvent("test")
	    os.pullEventRaw("test")
	end
end

local function chunkLoading()
	while true do
		stepChunkQueue()
		sleep(0.1)
	end
end

function openWorld(id)
	worldId = id
	pauseMenu = false

	local defaultValues = true

	local playerPath = "worlds/" .. worldId .. "/player.txt"
	if fs.exists(playerPath) then
		local playerFile = fs.open(playerPath, "r")
		local raw = playerFile.readAll()
		playerFile.close()
		local data = textutils.unserialise(raw)
		if data then
			camera.x = data.x
			camera.y = data.y
			camera.z = data.z
			camera.rotY = data.camHor
			camera.rotZ = data.camVer
			defaultValues = false
		end
	end

	if defaultValues then
		camera.x = 0
		camera.y = 0
		camera.z = 0
		camera.rotY = 0
		camera.rotZ = 0
	end

	local playerFile = fs.open(playerPath, "w")
	playerFile.write(textutils.serialise({
		x = camera.x,
		y = camera.y,
		z = camera.z,
		camHor = camera.rotY,
		camVer = camera.rotZ,
		lastActive = os.time(os.date("!*t")),
	}))
	playerFile.close()

	local worldFile = fs.open("worlds/" .. worldId .. "/world.txt", "r")
	local worldInfoRaw = worldFile.readAll()
	worldFile.close()
	local worldData = textutils.unserialise(worldInfoRaw)
	seed = worldData.seed
	chunkSize = worldData.chunkSize
	maxHeightTerrain = worldData.maxHeightTerrain
	maxHeightChunk = worldData.maxHeightChunk
	terrainSmoothness = worldData.terrainSmoothness

	parallel.waitForAny(keyInput, gameUpdate, rendering, chunkLoading)
end

local newWorldName = ""
function renderCreateWorld(fields, fieldsDefault, fieldsValues, selectedField, errMessage)
	screenWidth, screenHeight = term.getSize()
	bigMenuWindow.setVisible(false)

	local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
	local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
	local cx = math.floor(screenWidth*0.5+0.5)

	term.setBackgroundColor(colors.brown)
	term.setTextColor(colors.white)
	term.clear()

	term.setCursorPos(math.floor(cx - #("World Selection")*0.5 + 0.5), 2)
	term.write("World Creation")

	drawButton(term, x1, screenHeight-3, cx-1, screenHeight-1, "Create World", colors.gray, colors.lightGray, colors.white)
	drawButton(term, cx+1, screenHeight-3, x2, screenHeight-1, "Back to Worlds", colors.gray, colors.lightGray, colors.white)

	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.brown)
	term.setCursorPos(x1+1, 5)
	term.write("Name:")
	drawNiceBorder(term, x1+7, 4, x2, 6, colors.black, colors.green)

	local largestWidth = 0
	for i = 1, #fields do
		if #fields[i] > largestWidth then
			largestWidth = #fields[i]
		end
	end

	term.setBackgroundColor(colors.brown)
	term.setTextColor(colors.white)
	for j = 1, #fields do
		local i = (j - 1) % 2 + 1
		local k = math.floor((j-1) / 2)

		local x = x1+1
		local length = cx - x
		if k == 1 then
			x = x + 1 + length
		end

		term.setCursorPos(x, 8+i*2-1)
		term.write(fields[j] .. ":")
	end

	for j = 1, #fields do
		local i = (j - 1) % 2 + 1
		local k = math.floor((j-1) / 2)

		local x = (x1+largestWidth)+2
		local length = cx - x
		if k == 1 then
			x = x + largestWidth + length + 2 + 1
			length = x2 - x + 1
		end

		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.setCursorPos(x, 8+i*2-1)
		term.write((" "):rep(length))
		term.setCursorPos(x, 8+i*2-1)
		if #fieldsValues[j] > 0 then
			term.write(fieldsValues[j]:sub(-(length-1)))
		else
			term.setTextColor(colors.gray)
			term.write(fieldsDefault[j])
		end

		term.setBackgroundColor(colors.brown)
		term.setTextColor(colors.green)
		term.setCursorPos(x, 8+i*2)
		term.write(string.char(131):rep(length))
	end

	if #errMessage > 0 then
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.setCursorPos(math.floor(cx - (#errMessage + 2)*0.5 + 0.5), screenHeight-5)
		term.write(" " .. errMessage .. " ")
	end

	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.setCursorPos(x1+8, 5)
	term.write(newWorldName)
	if selectedField == 0 then
		term.setCursorBlink(true)
	elseif selectedField >= 1 and selectedField <= #fields then
		local j = selectedField

		local i = (j - 1) % 2 + 1
		local k = math.floor((j-1) / 2)

		local x = (x1+largestWidth)+2
		local length = cx - x
		if k == 1 then
			x = x + largestWidth + length + 2 + 1
		end

		local dx = 0
		if #fieldsValues[j] > 0 then
			dx = #fieldsValues[j]:sub(-(length-1))
		end
		term.setCursorPos(x + dx, 8+i*2-1)
		term.setCursorBlink(true)
	end

	bigMenuWindow.setVisible(true)
end

function createWorld()
	newWorldName = ""

	local fields = {"Seed", "Chunk Size", "Terr Height", "Smoothness"}
	local fieldsDefault = {"random", 16, 5, 2}
	local fieldsValues = {"", "", "", ""}
	local selectedField = 0

	local errMessage = ""

	local largestWidth = 0
	for i = 1, #fields do
		if #fields[i] > largestWidth then
			largestWidth = #fields[i]
		end
	end

	while true do
		renderCreateWorld(fields, fieldsDefault, fieldsValues, selectedField, errMessage)

		local event, key, x, y = os.pullEvent()

		if event == "key" then
			if key == keys.backspace then
				if selectedField == 0 then
					newWorldName = newWorldName:sub(1, #newWorldName-1)
				elseif selectedField >= 1 and selectedField <= #fields then
					fieldsValues[selectedField] = fieldsValues[selectedField]:sub(1, #fieldsValues[selectedField]-1)
				end
			elseif key == keys.grave then
				term.setCursorBlink(false)
				return false
			elseif key == keys.tab then
				selectedField = (selectedField + 1) % (#fields + 1)
			end
		elseif event == "char" then
			if selectedField == 0 then
				newWorldName = (newWorldName .. key):sub(1, 20)
			elseif selectedField >= 1 and selectedField <= #fields then
				fieldsValues[selectedField] = (fieldsValues[selectedField] .. key):sub(1, 20)
			end
		elseif event == "key_up" then
		elseif event == "mouse_click" then
			local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
			local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
			local cx = math.floor(screenWidth*0.5+0.5)

			if x >= x1 and y >= screenHeight-3 and x <= cx-1 and y <= screenHeight-1 then
				local val1 = #fieldsValues[1] > 0 and fieldsValues[1] or fieldsDefault[1]
				local val2 = #fieldsValues[2] > 0 and fieldsValues[2] or fieldsDefault[2]
				local val3 = #fieldsValues[3] > 0 and fieldsValues[3] or fieldsDefault[3]
				local val4 = #fieldsValues[4] > 0 and fieldsValues[4] or fieldsDefault[4]

				if val1 ~= "random" and not tonumber(val1) then
					errMessage = "Seed must be a number"
				elseif not tonumber(val2) then
					errMessage = "Chunk size must be a number"
				elseif tonumber(val2) <= 1 then
					errMessage = "Chunk size must be at least 2"
				elseif not tonumber(val3) then
					errMessage = "Terrain height must be a number"
				elseif tonumber(val3) <= 0 then
					errMessage = "Terrain height must be larger than 0"
				elseif not tonumber(val4) then
					errMessage = "Terrain smoothness must be a number"
				elseif tonumber(val3) < 0 then
					errMessage = "Terrain smoothness cannot be negative"
				elseif tonumber(val2) / 2^(tonumber(val4)+1) % 1 > 0 then
					errMessage = "Chunk size must be divisible by 2^(smooth. + 1)"
				elseif fs.exists("worlds/" .. newWorldName) then
					errMessage = "World with that name already exists"
				else
					-- New world
					math.randomseed(os.clock())
					term.setCursorBlink(false)
					return true, newWorldName,
						val1 == "random" and math.random(0, 999999) or tonumber(val1),
						tonumber(val2),
						tonumber(val3),
						tonumber(val4)
				end
			elseif x >= cx+1 and y >= screenHeight-3 and x <= x2 and y <= screenHeight-1 then
				-- Back to main menu
				term.setCursorBlink(false)
				return false
			else
				if x >= x1+7 and y >= 4 and x <= x2 and y <= 6 then
					selectedField = 0
				else
					for j = 1, #fields do
						local i = (j - 1) % 2 + 1
						local k = math.floor((j-1) / 2)

						local fx = (x1+largestWidth)+2
						local length = cx - fx
						if k == 1 then
							fx = fx + largestWidth + length + 2 + 1
							length = x2 - fx + 1
						end

						if x >= fx and x <= fx + length - 1 and (y == 8+i*2 or y == 8+i*2-1) then
							selectedField = j
							break
						end
					end
				end
			end
		elseif event == "mouse_scroll" then
		elseif event == "term_resize" then
			termResize()
		end
	end
end

local worldSelectionScroll = 0
function renderWorldSelection()
	screenWidth, screenHeight = term.getSize()
	bigMenuWindow.setVisible(false)

	term.setBackgroundColor(colors.brown)
	term.setTextColor(colors.white)
	term.clear()

	term.setCursorPos(math.floor(screenWidth*0.5 - #("World Selection")*0.5 + 0.5), 2)
	term.write("World Selection")

	local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
	local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
	local cx = math.floor(screenWidth*0.5+0.5)

	drawNiceBorder(term, x1, 4, x2, screenHeight-5, colors.black, colors.orange)

	drawButton(term, x1, screenHeight-3, cx-1, screenHeight-1, "New World", colors.gray, colors.lightGray, colors.white)
	drawButton(term, cx+1, screenHeight-3, x2, screenHeight-1, "Back to Main Menu", colors.gray, colors.lightGray, colors.white)

	local worldGradient = paintutils.loadImage("worldGradient.nfp")
	if #worldGradient[#worldGradient] == 0 then
		worldGradient[#worldGradient] = nil
	end
	local bWorldGradient = blittle.shrink(worldGradient, colors.brown)

	local oldTerm = term.redirect(worldListWindow)
		local width, height = term.getSize()
		term.setBackgroundColor(colors.black)
		term.clear()

		local timestamps = {}
		local function getWorldTimestamp(worldId)
			local playerPath = "worlds/" .. worldId .. "/player.txt"
			local timestamp = 0
			if fs.exists(playerPath) then
				local playerFile = fs.open(playerPath, "r")
				local raw = playerFile.readAll()
				playerFile.close()
				local data = textutils.unserialise(raw)
				if data and data.lastActive then
					timestamp = data.lastActive
				end
			end
			timestamps[worldId] = timestamp
			return timestamp
		end
		local worlds = fs.list("worlds")
		table.sort(worlds, function(worldA, worldB)
			local tA = timestamps[worldA] or getWorldTimestamp(worldA)
			local tB = timestamps[worldB] or getWorldTimestamp(worldB)
			return tA > tB
		end)

		for i, worldId in pairs(worlds) do
			local worldY = 1 + (i-1)*4 - worldSelectionScroll
			drawNiceBorder(term, 1, worldY, width, worldY + 2, colors.gray, colors.brown)

			blittle.draw(bWorldGradient, width-11, worldY)

			term.setBackgroundColor(colors.gray)
			term.setTextColor(colors.white)
			term.setCursorPos(2, worldY + 1)
			term.write(worldId)

			term.setBackgroundColor(colors.brown)
			term.setTextColor(colors.lime)
			term.setCursorPos(width - 4, worldY + 1)
			term.write("Play")
		end
	term.redirect(oldTerm)

	worldListWindow.setVisible(true)
	bigMenuWindow.setVisible(true)
	worldListWindow.setVisible(false)
end

function worldSelection()
	worldSelectionScroll = 0

	while true do
		renderWorldSelection()

		local event, key, x, y = os.pullEvent()

		if event == "key" then
			if key == keys.grave then
				return
			end
		elseif event == "key_up" then
		elseif event == "mouse_click" then
			local x1 = math.floor(4 +             math.max(0, screenWidth - 51)*0.5)
			local x2 = math.floor(screenWidth-3 - math.max(0, screenWidth - 51)*0.5)
			local cx = math.floor(screenWidth*0.5+0.5)

			if x >= x1 and y >= screenHeight-3 and x <= cx-1 and y <= screenHeight-1 then
				-- New world
				worldSelectionScroll = 0
				local success, worldId, seedW, chunkSizeW, maxHeightTerrainW, terrainSmoothnessW = createWorld()
				if success and #worldId > 0 then
					seed = seedW
					chunkSize = chunkSizeW
					maxHeightTerrain = maxHeightTerrainW
					maxHeightChunk = maxHeightTerrain+7
					terrainSmoothness = terrainSmoothnessW

					local file = fs.open("worlds/" .. worldId .. "/world.txt", "w")
					file.write(textutils.serialise({
						seed = seed,
						chunkSize = chunkSize,
						maxHeightTerrain = maxHeightTerrain,
						maxHeightChunk = maxHeightChunk,
						terrainSmoothness = terrainSmoothness,
					}))
					file.close()
					sleep(0)

					openWorld(worldId)
					saveWorld()
				end
			elseif x >= cx+1 and y >= screenHeight-3 and x <= x2 and y <= screenHeight-1 then
				-- Back to main menu
				return
			elseif x >= x1+1 and y >= 5 and x <= x2 and y <= screenHeight-5 then
				local dx = x1+1-1
				local dy = 5-1
				local width, height = worldListWindow.getSize()

				local timestamps = {}
				local function getWorldTimestamp(worldId)
					local playerPath = "worlds/" .. worldId .. "/player.txt"
					local timestamp = 0
					if fs.exists(playerPath) then
						local playerFile = fs.open(playerPath, "r")
						local raw = playerFile.readAll()
						playerFile.close()
						local data = textutils.unserialise(raw)
						if data and data.lastActive then
							timestamp = data.lastActive
						end
					end
					timestamps[worldId] = timestamp
					return timestamp
				end
				local worlds = fs.list("worlds")
				table.sort(worlds, function(worldA, worldB)
					local tA = timestamps[worldA] or getWorldTimestamp(worldA)
					local tB = timestamps[worldB] or getWorldTimestamp(worldB)
					return tA > tB
				end)

				for i, worldId in pairs(worlds) do
					local worldY = 1 + (i-1)*4 - worldSelectionScroll + dy
					drawNiceBorder(term, 1, worldY, width, worldY + 2, colors.gray, colors.brown)
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.white)
					term.setCursorPos(2, worldY + 1)
					term.write(worldId)

					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.lime)
					if x >= dx + width - 4 - 1 and x <= dx + width and math.abs(worldY + 1 - y) <= 1 then
						worldSelectionScroll = 0
						openWorld(worldId)
						saveWorld()
					end
				end
			end
		elseif event == "mouse_scroll" then
			worldSelectionScroll = math.max(0, worldSelectionScroll + key)
		elseif event == "term_resize" then
			termResize()
		end
	end
end

function renderMainMenu()
	screenWidth, screenHeight = term.getSize()

	term.setBackgroundColor(colors.brown)
	term.clear()

	drawButton(term, 4 + math.max(0, screenWidth - 51)*0.5, 8,   screenWidth-3 - math.max(0, screenWidth - 51)*0.5, 8+2,     "Singleplayer", colors.gray, colors.lightGray, colors.white)
	drawButton(term, 4 + math.max(0, screenWidth - 51)*0.5, 8+4, screenWidth-3 - math.max(0, screenWidth - 51)*0.5, 8+2 + 4, "Quit",         colors.gray, colors.lightGray, colors.white)

	term.setBackgroundColor(colors.brown)
	term.setTextColor(colors.white)
	term.setCursorPos(1, screenHeight)
	term.write("v1.0 by Xella")

	bigMenuWindow.setVisible(false)
	bigMenuWindow.setVisible(true)
	logoWindow.setVisible(false)
	logoWindow.setVisible(true)
end

function mainMenu()
	while true do
		renderMainMenu()

		local event, key, x, y = nil, nil, nil, nil
		parallel.waitForAny(runLogoAnimation, function()
			while true do
				local sevent, skey, sx, sy = os.pullEvent()
				if sevent == "mouse_click" then
					if sx >= 4 + math.max(0, screenWidth - 51)*0.5 and sy >= 8 and sx <= screenWidth-3 - math.max(0, screenWidth - 51)*0.5 and sy <= 8+2 then
						event, key, x, y = sevent, skey, sx, sy
						break
					elseif sx >= 4 + math.max(0, screenWidth - 51)*0.5 and sy >= 8+4 and sx <= screenWidth-3 - math.max(0, screenWidth - 51)*0.5 and sy <= 8+2 + 4 then
						event, key, x, y = sevent, skey, sx, sy
						break
					end
				elseif sevent == "term_resize" then
					betterblittle.drawBuffer(logo, logoWindow)
					event, key, x, y = sevent, skey, sx, sy
					break
				end
			end
		end)

		renderMainMenu()
		local i = 0
		while true do
			if not event or i > 0 then
				event, key, x, y = os.pullEvent()
			end

			if event == "key" then
			elseif event == "key_up" then
			elseif event == "mouse_click" then
				if x >= 4 + math.max(0, screenWidth - 51)*0.5 and y >= 8 and x <= screenWidth-3 - math.max(0, screenWidth - 51)*0.5 and y <= 8+2 then
					logoWindow.setVisible(false)
					worldSelection()
					break
				elseif x >= 4 + math.max(0, screenWidth - 51)*0.5 and y >= 8+4 and x <= screenWidth-3 - math.max(0, screenWidth - 51)*0.5 and y <= 8+2 + 4 then
					term.redirect(oldTerm)
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.white)
					term.clear()
					term.setCursorPos(1, 1)
					print("Thanks for playing Xella's CC:Minecraft!")
					return
				end
			elseif event == "term_resize" then
				termResize()
			end
			i = i + 1
		end
	end
end

mainMenu()
