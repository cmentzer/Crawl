local function find_wall(x, y)
	local f = view.feature_at(x, y)
	-- crawl.mpr("feature at " .. x .. " " .. y .. " is " .. f .. "\n")
	if f == "rock_wall" then
		return 1
	else 
		return 0
	end
end

local function find_monster(x, y)
	local m = monster.get_monster_at(x, y)
	return m
end

function get_game_state()
	crawl.mpr("getting game state ...")
	local wall_list = {}
	local monster_list = {}
	local water_list = {}
	local lava_list = {}

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
			end
		end
	end
	for x, y in pairs(wall_list) do
		--crawl.mpr("There is a wall at " .. x)
	end
	for m in monster_list do 
		crawl.mpr("There is a monster at " .. m[0])
	end 
end