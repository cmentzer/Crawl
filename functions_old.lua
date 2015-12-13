
{
local function attack()
	crawl.sendkeys("\9")
end

local function explore()
	crawl.sendkeys("o")
end
	
local function wait()
	crawl.sendkeys("5")
end

local function position_to_direction(x, y)
	if x < 0 then
		if y < 0 then
			output = 'y'
		elseif y == 0 or y == -0 then
			output = 'h'
		else
			output = 'b'
		end
	elseif x == 0 then
		if y < 0 then
			output = 'k'
		elseif y == 0 or y == -0 then
			output = '.'
		else
			output = 'j'
		end
	else
		if y < 0 then
			output = 'u'
		elseif y == 0 or y == -0 then
			output = 'l'
		else
			output = 'n'
		end
	end
	return output
end

local function try_move(dx, dy)
  local m = monster.get_monster_at(dx, dy)
  -- attitude > ATT_NEUTRAL should mean you can push past the monster
  if view.is_safe_square(dx/dx, dy/dy) and (not m or m:attitude() > ATT_NEUTRAL) then
    return position_to_direction(dx, dy)
  else
    return nil
  end
end

local function move_towards(dx, dy)
	local move = try_move(dx, dy)
	if move then
		--the tile we want is not obstructed, move to it
		crawl.mpr("moving to " .. move)
		crawl.process_keys(move)
	else
		crawl.mpr("destination obstructed")
		--for some reason, the tile we want to move to is obstructed, so 
		--we want to move to a tile adjacent to that tile instead
	end 
end

local function flee(array)
	local avg_x = 0
	local avg_y = 0
	for key,val in pairs(array) do
		avg_x = avg_x + val[2]
		avg_y = avg_y + val[3]
	end
	avg_x = math.floor(avg_x / #array)
	avg_y = math.floor(avg_y / #array)
	crawl.mpr("Avg x is " .. avg_x)
	crawl.mpr("Avg y is " .. avg_y)
	crawl.mpr("We want to move to (" .. avg_x*-1 .. ", " .. avg_y*-1 .. ")")
	move_towards(avg_x*-1, avg_y*-1)
end
	

function do_moves()
	local monster_list = {}
	monster_count = 0
	for x = -8,8 do
		for y = -8,8 do
			local m = monster.get_monster_at(x,y)
			if m and not m:is_safe() then
				monster_count = monster_count + 1
				local a = {m,x,y}
				table.insert(monster_list, a)
			end
		end
	end
	if monster_count > 1 then
		flee(monster_list)
	elseif monster_count > 0 then
		attack()
	else
		local current_hp,max_hp = you.hp()
		crawl.mpr(current_hp)
		crawl.mpr(max_hp)
		if current_hp < 0.3*max_hp then
			try_emergency()
		elseif current_hp < max_hp then
			wait()
		else 
			explore()
		end
	end
end

function get_inventory()
	local i 
	local t = {}
	for i = 0,51 do 
		it = items.inslot(i)
		if it then
			local name = it.name()
			t[i] = name
		end
		i = i + 1
	end
	return t
end

function try_emergency()
	for key, val in pairs(t) do
		if val == "Potion of Heal Wounds" then
			crawl.sendkeys('q')
			crawl.sendkeys(key)
		end
	end
end

function test_hit_closest()
	local t = get_inventory()
	--for key, val in pairs(t) do
	--	crawl.mpr(key)
	--	crawl.mpr(val)
	--end
	get_inventory()
	do_moves()
end
}

