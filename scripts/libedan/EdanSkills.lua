EdanSkills = {}

EdanSkills.CacheDurationSeconds = 1
EdanSkills.LearnedSkillCache = {}
EdanSkills.LastUpdate = {}
EdanSkills.SkillLevels = {}

-- returns the skill id you have learned or 0
function EdanSkills.GetSkill(id)
	local now = os.clock()
	local cache = EdanSkills.LearnedSkillCache[id]
	local cache_age = EdanSkills.LastUpdate[id]

	if cache and now - cache_age < EdanSkills.CacheDurationSeconds then
		return cache
	end

	local selfPlayer = GetSelfPlayer()
	local levels = EdanSkills.SkillLevels[id]
	local output = 0
	if levels ~= nil then
		output = SkillsHelper.GetKnownSkillId(levels)
	end

	EdanSkills.LearnedSkillCache[id] = output
	EdanSkills.LastUpdate[id] = now

	return output
end

-- get the skill level of the skill you have learned. returns 0 if not learned
function EdanSkills.GetSkillLevel(id)
	local learned = EdanSkills.GetSkill(id)
	return EdanSkills.IdLevels[learned] or 0
end

function EdanSkills.SkillUsable(id)
	local learned = EdanSkills.GetSkill(id)
	if learned ~= 0 and SkillsHelper.IsSkillUsable(learned) then
		return true
	end
	return false
end

function EdanSkills.SkillUsableCooldown(id)
	local learned = EdanSkills.GetSkill(id)
	if learned ~= 0 and SkillsHelper.IsSkillUsable(learned) and not GetSelfPlayer():IsSkillOnCooldown(learned) then
		return true
	end
	return false
end

function EdanSkills.ClearCache()
	EdanSkills.LearnedSkillCache = {}
end

function EdanSkills.UseSkill(id, delay)
	local selfPlayer = GetSelfPlayer()
	local learned = EdanSkills.GetSkill(id)
	if learned ~= 0 then
		selfPlayer:UseSkill(learned, delay)
	end
end

function EdanSkills.UseSkillAtPosition(id, position, delay)
	local selfPlayer = GetSelfPlayer()
	local learned = EdanSkills.GetSkill(id)
	if learned ~= 0 then
		selfPlayer:UseSkillAtPosition(learned, position, delay)
	end
end

-- for internal use

function EdanSkills.Range(lo, hi)
	if lo > hi then
		lo,hi = hi,lo
	end
	local output = {}
	for i=hi,lo,-1 do
		table.insert(output, i)
	end
	return output
end

function EdanSkills.RegisterSkills(t)
	for _,v in ipairs(t) do
		local name = v[1]
		if #v == 3 then
			local lo_id = v[2]
			local hi_id = v[3]
			_G[name] = lo_id
			EdanSkills.SkillLevels[lo_id] = EdanSkills.Range(lo_id, hi_id)
		elseif type(v[2]) == 'table' then
			local list = v[2]
			table.sort(list, function(a,b) return a > b end)
			local lo_id = list[1]
			_G[name] = lo_id
			EdanSkills.SkillLevels[lo_id] = list
		else
			local lo_id = v[2]
			_G[name] = lo_id
			EdanSkills.SkillLevels[lo_id] = {lo_id}
		end
	end
end