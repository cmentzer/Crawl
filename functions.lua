function test()
	crawl.mpr("testing")

local function populate_item_list(x, y)
  floor_items = items.get_items_at(x, y)
  if not floor_items then
    return false
  end
  for key, item in ipairs(floor_items) do
  	table.insert(item_list, {item.class(), item.name(), x, y})
  end
end

local function find_wall(x, y)
	local f = view.feature_at(x, y)
	--crawl.mpr("feature at " .. x .. " " .. y .. " is " .. f .. "\n")
	if f == "rock_wall" or
		f == "stone_wall" or
		f == "permarock_wall" then
		return 1
	else 
		return 0
	end
end

local function find_lava(x, y)
	local l = view.feature_at(x, y)
	if l == "lava" then
		return 1
	else
		return 0
	end
end

local function find_monster(x, y)
	local m = monster.get_monster_at(x, y)
	return m
end

local function find_water(x,y)
	local w = view.feature_at(x,y)
	if w == "shallow_water" then
		return 2
	elseif w == "deep_water" then
		return 1
	else
		return 0
	end
end

function get_game_state()
	crawl.mpr("getting game state ...")
	local wall_list = {}
	local monster_list = {}
	local water_list = {}
	local lava_list = {}
	item_list = {}

	-- for every cell inside our max vision range ... 
	for x = -8,8 do
		for y = -8,8 do
			-- if we can see that cell ...
			if you.see_cell(x, y) then
				-- check if that cell is a wall
				local w = find_wall(x, y)
				if w == 1 then
					table.insert(wall_list, {x, y})
				end
				-- check if that cell is a monster
				local m = find_monster(x, y)
				if m and not m:is_safe() then
					crawl.mpr(m:name())
					table.insert(monster_list, {m:name(), x, y})
				end
				-- check if that cell has water
				local w = find_water(x, y)
				if w == 2 then
					table.insert(water_list, {"shallow", x, y})
				elseif w == 1 then
					table.insert(water_list, {"deep", x, y})
				end
				-- check if that cell has lava
				local l = find_lava(x, y)
				if l == 1 then
					table.insert(lava_list, {x, y})
				end
				-- check if that cell has an item or corpse
				populate_item_list(x, y)
			end
		end
	end

	-- loops to print information about the current game state (useful for debugging, but eventually it would be a good idea to move)
	-- these loops to their own functions ("print features", "print items", ... etc). It might even be possible to assign in game macros
	-- to print functions that display the current values in lists at the time of the button press in game. 

	for key, value in pairs(wall_list) do 
		crawl.mpr("there is a wall at " .. value[1] .. value[2])
	end

	for key, value in pairs(monster_list) do 
		crawl.mpr("There is a(n) " .. value [1] .. " at " .. value[2] .. value[3])
	end 
	for key, value in pairs(water_list) do
		crawl.mpr("there is " .. value[1] .. " water at " .. value[2] .. value[3])
	end
	for key, value in pairs(lava_list) do
		crawl.mpr("there is lava at " .. value[1] .. value[2])
	end
	for key, value in pairs(item_list) do
		 crawl.mpr("there is an item of class " .. value[1] .. " and name \"" .. value[2] .. "\" at position " .. value[3] .. ", " .. value[4])
	end

	crawl.mpr("with " .. table.getn(wall_list) .. " walls ... \n")
	crawl.mpr(table.getn(monster_list) .. " monsters ... \n")
	crawl.mpr(table.getn(lava_list) .. " tiles of lava ... \n")
	crawl.mpr(table.getn(water_list) .. " tiles of water ... \n")
	crawl.mpr("and " .. table.getn(item_list) .. " items on the floor ... \n")
	crawl.mpr(" ... the current value attributed to this game state is: " .. "10 \n")

end

function getAction(gameState)
	local actionScores = {}
	local currentScore = 0
	for action in getLegalActions(gameState) do
		currentScore = getScoreForAction(action, gameState)
		table.insert(actionScores, {action, currentScore})
	end

	crawl.mpr("score table is " )
	for k,v in actionScores do
		crawl.mpr(k)
		crawl.mpr(v)

	local maxScore = 0
	local action = ""
	for k,v in actionScores do
		if v > maxScore then
			maxScore = v
			action = k
		end
	end
	crawl.mpr("returning action " .. action .. " with value " .. maxScore)
	return action
end

function maxValue(gameState, depth, agentIndex)
	if isWinState(gameState) or isLoseState(gameState) or depth == globalDepth then
		return scoreGameState(gameState)
	end

	local v = -100000
	local potential = 0
	for action in getLegalActions(gameState) do
		potential = minValue(generateSuccessor(gameState, agentIndex, action), depth, agentIndex + 1)
		if v < potential then
			v = potential
		end
	return v
end

function minValue(gameState, depth, agentIndex)
	if isWinState(gameState) or isLoseState(gameState) or depth == globalDepth then
		return scoreGameState(gameState)
	end

	local v = 100000
	local potential = 0
	for action in getLegalActions(gameState) do
		if agentIndex == gameStateMaxAgent - 1 then
			potential = maxValue(generateSuccessor(gameState, agentIndex, action), depth + 1, 0)
		else
			potential = maxValue(generateSuccessor(gameState, agentIndex, action), depth, agentIndex + 1)
		end
		if v < potential then
			v = potential
		end
	return v
end

function scoreGameState(gameState)
	-- TODO: DEFINE THIS. Cannot run without this being filled out.
end

function isWinState(gameState)
	-- undefined, probably forever
end

function isLoseState(gameState)
	-- undefined, probably forever
end

function getLegalActions(gameState)
	--undefined
end

function getScoreForAction(action, gameState) 
	--undefined
end