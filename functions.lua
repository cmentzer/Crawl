function get_game_state()
	-- function to get the list of items that we can see
	function populate_item_list(x, y)
	  floor_items = items.get_items_at(x, y)
	  if not floor_items then
	    return false
	  end
	  for key, item in ipairs(floor_items) do
	  	table.insert(item_list, {item.class(), item.name(), x, y})
	  end
	end
	-- function to get the list of walls that we can see
	function find_wall(x, y)
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

	-- function to get the list of lava we can see
	function find_lava(x, y)
		local l = view.feature_at(x, y)
		if l == "lava" then
			return 1
		else
			return 0
		end
	end

	-- function to get the list of monsters 
	function find_monster(x, y)
		local m = monster.get_monster_at(x, y)
		return m
	end

	-- function to get the list of water
	function find_water(x,y)
		local w = view.feature_at(x,y)
		if w == "shallow_water" then
			return 2
		elseif w == "deep_water" then
			return 1
		else
			return 0
		end
	end

	-- function to populate inventory
	function populate_inventory(inventory)
		local i = 0
		for i = 0, 51 do
			if items.inslot(i) then
				table.insert(inventory, items.inslot(i))
			end
		end
		return inventory
	end

	-- start getting the game state:

	--crawl.mpr("getting game state ...")
	-- list of visible walls
	local wall_list = {}
	-- list of visible monsters
	local monster_list = {}
	-- list of visible water
	local water_list = {}
	-- list of visible lava
	local lava_list = {}
	-- list of items
	local agents_list = {}
	-- inventory 
	local inventory = {}
	item_list = {}


	-- player is a variable that holds information about the player
	local player = {{0, 0}, {you.xl(), you.hp(), you.hunger()}}
	table.insert(agents_list, player)

	-- inventory is our inventory
	inventory = populate_inventory({})

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
	--				crawl.mpr(m:name())
					table.insert(monster_list, {m:name(), x, y})
					table.insert(agents_list, {{x, y}, (m:name())})
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
		--crawl.mpr("there is a wall at " .. value[1] .. value[2])
	end

	for key, value in pairs(monster_list) do 
		crawl.mpr("There is a(n) " .. value [1] .. " at " .. value[2] .. ", " .. value[3])
	end 
	for key, value in pairs(water_list) do
	--	crawl.mpr("there is " .. value[1] .. " water at " .. value[2] .. value[3])
	end
	for key, value in pairs(lava_list) do
	--	crawl.mpr("there is lava at " .. value[1] .. value[2])
	end
	for key, value in pairs(item_list) do
	--	 crawl.mpr("there is an item of class " .. value[1] .. " and name \"" .. value[2] .. "\" at position " .. value[3] .. ", " .. value[4])
	end

	--crawl.mpr("with " .. table.getn(wall_list) .. " walls ... \n")
	--crawl.mpr(table.getn(monster_list) .. " monsters ... \n")
	--crawl.mpr(table.getn(lava_list) .. " tiles of lava ... \n")
	--crawl.mpr(table.getn(water_list) .. " tiles of water ... \n")
	--crawl.mpr("and " .. table.getn(item_list) .. " items on the floor ... \n")
	--crawl.mpr(" ... the current value attributed to this game state is: " .. "10 \n")

	local gameState = {wall_list, monster_list, water_list, lava_list, item_list, agents_list, inventory}
	return gameState

end

function getAction(agentIndex, gameState)
	local actionScores = {}
	local currentScore = 0
	local legalActions = getLegalActions(agentIndex, gameState)
	for key, action in pairs(legalActions) do
		crawl.mpr("getting score for action " .. action[1])
		currentScore = getScoreForAction(action, gameState)
		-- penalize the "do nothing" action when we are adjacent to monsters
		if action[1] == "." then
			for key, action2 in pairs(legalActions) do
				if action2[2] == "monster" then
					currentScore = currentScore - 20
				end
			end
		end
			

		crawl.mpr("that score is " .. currentScore)

		table.insert(actionScores, {action, currentScore})
	end

	-- crawl.mpr("score table is " )
	for k,v in pairs(actionScores) do
	--	crawl.mpr(v[1])
--		crawl.mpr(v[2])
	end
	local maxScore = -100
	local action = ""
	for k,v in pairs(actionScores) do
--		crawl.mpr(v[2])
--		crawl.mpr(maxScore)
		if v[2] > maxScore then
			maxScore = v[2]
			action = v[1]
		end
	end
	crawl.mpr("returning action " .. action[1] .. " with value " .. maxScore)
	return action[1]
end

function getScoreForAction(action, gameState) 
	globalDepth = 0 -- can mess with this
	return maxValue(generateSuccessor(gameState, 1, action), 0, 1, action)
end

function maxValue(gameState, depth, agentIndex, action)
	--if isWinState(gameState) or isLoseState(gameState) or depth == globalDepth then
	if depth == globalDepth then
		toreturn = scoreGameState(gameState, action)
		--crawl.mpr("maxValue returning " .. toreturn .. " at max depth of " .. depth)
		return toreturn --return scoreGameState(gameState)
	end

	local v = -10000
	local potential = 0
	for key, action2 in pairs(getLegalActions(agentIndex, gameState)) do
		--crawl.mpr("action2 200 is " .. action2)
		potential = minValue(generateSuccessor(gameState, agentIndex, action2), depth + 1, agentIndex + 1, action2)
		--crawl.mpr("that action returned value " .. potential)
		if potential > v then
			v = potential
		end
	end
		--crawl.mpr("maxvalue returning " .. v)
	return v
end

function minValue(gameState, depth, agentIndex, action)
	--if isWinState(gameState) or isLoseState(gameState) or depth == globalDepth then
	if depth == globalDepth then
		toreturn = scoreGameState(gameState, action)
		--crawl.mpr("maxValue returning " .. toreturn .. " at max depth of " .. depth)
		return toreturn --return scoreGameState(gameState)
	end

	local v = 10000
	local potential = 0
	for key, action2 in pairs(getLegalActions(agentIndex, gameState)) do
		--crawl.mpr("action2 222 is " .. action2)
		if agentIndex == gameStateMaxAgent then
			potential = maxValue(generateSuccessor(gameState, agentIndex, action2), depth + 1, 1, action2)
			--crawl.mpr("that action returned value " .. potential)
		else
			potential = maxValue(generateSuccessor(gameState, agentIndex, action2), depth, agentIndex + 1, action2)
			--crawl.mpr("that action returned value " .. potential)
		end
		if potential < v then
			v = potential
		end
	end
--	crawl.mpr("minvalue returning " .. v)
	return v
end

function scoreGameState(gameState, action)
	-- first, lets get the score from the number of adjacent walls
	local function numAdjWalls(wall_list)
	local adjWalls = 0
		for key, value in pairs(wall_list) do 
			if ((value[1] == -1 or value[1] == 0 or value[1] == 1) and
				(value[2] == -1 or value[2] == 0 or value[2] == 1)) then
				-- this wall is adjacent to us, +1
				adjWalls = adjWalls + 1
			end
		end 
		return adjWalls
	end

	-- then, compute the score we get from the locations of monsters on the screen
	local function getMonsterScore(monster_list)
		-- undefined, for now just return number of monsters in the list
		playerPos = gameState[6][1][1]
		playerX = playerPos[1]
		playerY = playerPos[2]
		local score = 0
		for key, monster in pairs(monster_list) do
			local monsterX = monster[2]
			local monsterY = monster[3]
			score = score + 8 - manhattanDistance(playerX, playerY, monsterX, monsterY)
		end
		return score
	end

	-- then, computer score from water. Like walls and lava, standing NEXT TO water is good, 
	-- because mosnters standing in water get a debuff to hit chance. However we want to avoid 
	-- STANDING in water, to avoid the debuff ourselves. Also like lava, standing IN DEEP water
	-- kills you, so we dont want that
	local function getWaterScore(water_list)
		local adjWater = 0
		local standingInSWater = false
		local standingInDWater = false
		for key, value in pairs(water_list) do
			if ((value[2] == -1 or value[2] == 0 or value[2] == 1) and
				(value[3] == -1 or value[3] == 0 or value[3] == 1)) then
				-- this water is adjacent to us, +1
				-- check if the adjacent water is shallow or deep, 
				-- standing next to deep water is better
				if value[1] == "shallow" then
					adjWater = adjWater + 1
				else 
					adjWater = adjWater + 2
				end
			end
			if value[2] == 0 and value[3] == 0 then
				if value[1] == "shallow" then
					standingInSWater = true
				else 
					standingInDWater = true
				end
			end
		end 
		if standingInSWater then
			-- sometimes standing in shallow water is unavoidable, so we want to make sure
			-- that the value we attribute to it is not TOO low. 
			return -15
		elseif standingInDWater then
			return -100000
		else
			return adjWater
		end
	end 

	-- then, computer score from lava. For most purposes, we can consider lava to be the same
	-- as walls (if we stand next to lava, there can't be a monster there). However, we need to
	-- make sure we assign an extremely negative value to STANDING in lava. 
	local function getLavaScore(lava_list)
		local adjLava = 0
		local standingInLava = false
		for key, value in pairs(lava_list) do 
			if ((value[1] == -1 or value[1] == 0 or value[1] == 1) and
				(value[2] == -1 or value[2] == 0 or value[2] == 1)) then
				-- this lava is adjacent to us, +1
				adjLava = adjLava + 1
			end
			if value[1] == 0 and value[2] == 0 then
				standingInLava = true
			end
		end 
		if standingInLava then
			return -100000
		else
			return adjLava
		end
	end
	-- now computer the total score of the given gamestate
	local wallScore = numAdjWalls(gameState[1])
	local monsterScore = getMonsterScore(gameState[2])
	local waterScore = getWaterScore(gameState[3])
	local lavaScore = getLavaScore(gameState[4])
	local attackScoreBonus = 0
	if action[2] == "monster" then
		attackScoreBonus = 10
		crawl.mpr("ATTACK BONUS ACTIVE!!")
	end
	-- TODO: consider health, player and monster if possible
	local toreturn = wallScore * 2 + monsterScore + lavaScore + waterScore + attackScoreBonus
	--crawl.mpr("scoreGameState returning ... " .. toreturn)
	return toreturn
end

function isWinState(gameState)
	-- undefined, probably forever
end

function isLoseState(gameState)
	-- undefined, probably forever
end

function getLegalActions(agentIndex, gameState)
	-- movement: 
	function getLegalMovementActions(agentIndex, gameState)
		-- get the agent from the game state that we are 
		-- finding the legal actions for
		agentLen = table.getn(gameState[6])
		local agent = gameState[6][agentIndex]
		local agentX = agent[1][1]
		local agentY = agent[1][2]

		-- possible movement actions are one of: 
		-- y, u, h, j, k, l, b, n. 
		local adjTiles = {}
		for x = agentX - 1, agentX + 1 do
			--crawl.mpr("x is " .. x)
			for y = agentY - 1, agentY + 1 do
			--	crawl.mpr("y is " .. y)
				-- if we can see that cell ...
				if you.see_cell(x, y) then
				-- check if that cell is a wall
					local w = find_wall(x, y)
					local m = find_monster(x, y)
					local w2 = find_water(x, y)
					local l = find_lava(x, y)

					if w == 1 then -- cell has wall
						table.insert(adjTiles, {"wall", x, y})
					elseif m and not m:is_safe() then -- cell has monster
						table.insert(adjTiles, {"monster", x, y})
					elseif w2 == 2 then -- cell has shallow water
						table.insert(adjTiles, {"shallow", x, y})
					elseif w2 == 1 then -- cell has deep water
						table.insert(adjTiles, {"deep", x, y})
					elseif l == 1 then -- cell has lava
						table.insert(adjTiles, {"lava", x, y})
					else 
						table.insert(adjTiles, {"floor", x, y})
					end -- end if
				else 
					table.insert(adjTiles, {"hidden", x, y})
				end -- end can see
			end -- end y loop
		end -- end x loop


		-- y = -1, -1  (up and left)
		-- h = -1, 0  (left) 
		-- b = -1, 1 (down and left)

		-- j = 0, 1  (down)
		-- k = 0, -1 (up)

		-- u = 1, 1 (up and right)
		-- l = 1, 0 (right)
		-- n = 1, -1 (down and right)

		local y = adjTiles[1][1]
		local h = adjTiles[2][1]
		local b = adjTiles[3][1]

		local k = adjTiles[4][1]

		--crawl.mpr("working with agent number " .. agentIndex)
		--crawl.mpr("that agent's WAIT move is " .. adjTiles[5][1])
		local wait = adjTiles[5][1]
		local j = adjTiles[6][1]

		local u = adjTiles[7][1]
		local l = adjTiles[8][1]
		local n = adjTiles[9][1]

		local moves = {{"y", y}, {"h", h}, {"b", b}, {"k", k}, {".", wait}, {"j", j}, {"u", u}, {"l", l}, {"n", n}}
		return moves
	end

	-- for the given agentIndex and gameState, get a list of the legal
	-- actions of that agent.
	local moves = getLegalMovementActions(agentIndex, gameState)
	local legalMoves = {}
	--crawl.mpr("working with agent number " .. agentIndex .. " that agent's moves are .. ")
	for key, value in pairs(moves) do
	--	crawl.mpr(value[2])
		if value[2] == "floor" or 
			value[2] == "shallow" or 
			value[2] == "monster" then
			table.insert(legalMoves, value)
		end
	end
	return legalMoves
end

function generateSuccessor(gameState, agentIndex, action)
	local agent = gameState[6][agentIndex]
	local player = gameState[6][1]
	local agentX = agent[1][1]
	local agentY  = agent[1][2]
	local newX = 0
	local newY = 0

	if action[1] == "y" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX - 1 == player[1][1] and agentY - 1 == player [1][2]) then
			newX = agentX
			newY = agentY
		else
			newX = agentX - 1
			newY = agentY - 1
		end
	elseif action[1] == "h" then 
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX - 1 == player[1][1] and agentY == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX - 1
			newY = agentY
		end
	elseif action[1] == "b" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX - 1 == player[1][1] and agentY + 1 == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX - 1
			newY = agentY + 1
		end
	elseif action[1] == "j" then 
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX == player[1][1] and agentY + 1 == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX
			newY = agentY + 1
		end
	elseif action[1] == "k" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX == player[1][1] and agentY - 1 == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX
			newY = agentY - 1
		end
	elseif action[1] == "u" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX + 1 == player[1][1] and agentY + 1 == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX + 1
			newY = agentY + 1
		end
	elseif action[1] == "l" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX + 1 == player[1][1] and agentY == player [1][2]) then
			newX = agentX
			newY = agentY
		else 
			newX = agentX + 1
			newY = agentY
		end
	elseif action[1] == "n" then
		if action[2] == "monster" then
			newX = agentX
			newY = agentY
		elseif(agentX + 1 == player[1][1] and agentY - 1 == player [1][2]) then
			newX = agentX
			newY = agentY	
		else 
			newX = agentX + 1
			newY = agentY - 1
		end
	elseif action[1] == "." then
		newX = agentX
		newY = agentY
	else
		crawl.mpr("Invalid key passed in as action to generateSuccessor")
		return "invalid key"
	end

	local newAgentList = gameState[6]
	newAgentList[agentIndex] = {{newX, newY}, gameState[6][agentIndex][2]}

	local newGameState = {gameState[1], gameState[2], gameState[3], gameState[4], gameState[5], newAgentList}
	return newGameState

end

function manhattanDistance(x1, y1, x2, y2)
	dX = x1 - x2
	dY = y1 - y2
	return math.abs(dX) + math.abs(dY)
end

function main()
	-- Essentially we want to split the game state into two categories:
	-- one is "combat", for which we score our gamestates based on things like
		-- location of monsters, our location relative to monsters and environmental 
		-- features, how much health we have, etc. 
	-- the other is "non-combat", during which we handle exploration, hunger, 
	-- equipment, managing skills, etc.

	local inCombat = false
	local gameState = get_game_state()
	local inventory = gameState[7]
	-- if there are monsters on the screen, we are in combat, and need to switch to 
	-- our "combat" logic
	if table.getn(gameState[2]) > 0 then
		inCombat = true
		agents = 1 + table.getn(gameState[2])
	else 
		inCombat = false
		agents = 1
	end
	-- if we are in combat, this code will determine our actions:
	if inCombat then
		crawl.mpr("in combat !!!")
--		currentScore = scoreGameState(gameState)
--		crawl.mpr("IN MAIN the game state is equal to " .. currentScore)
		-- list the actions available to the player:
--		crawl.mpr("the actions available to the player are: ")
--		local moves = getLegalActions(1, gameState)
--		for key, value in pairs(moves) do 
--			crawl.mpr(value)
--		end
		gameStateMaxAgent = table.getn(gameState[6])
		crawl.mpr("number of agents is" .. gameStateMaxAgent)
		local toTake = getAction(1, gameState)
		crawl.sendkeys(toTake)
	-- if we are not in combat, this code will determine our actions:
	else
		crawl.mpr("not in combat")
		local hunger = gameState[6][1][2][3]
		crawl.mpr("your hunger level is ".. hunger)
		if hunger < 4 then
			-- eat some food
			crawl.mpr("we should eat some food!")

			-- the position of an item in our inventory LIST is 1 greater than 
			-- that item's position in our actual inventory. That is, if there is 
			-- food at slot 4 in our inventory LIST, we need to get the key for the item
			-- in slot 3 in the game's inventory TABLE.
			local toEat = nil
			for key, item in pairs(inventory) do 
				if item.class() == "Comestibles" then
					crawl.mpr("EATING ONE OF MY " .. item.name())
					--crawl.mpr(items.inslot(key - 1).name())
					toEat = items.index_to_letter(key - 1)
					break 
				end
			end
			if toEat then
				crawl.sendkeys('e')
				crawl.sendkeys(toEat)
			end
		else
			crawl.sendkeys('o')
		end
	end
end