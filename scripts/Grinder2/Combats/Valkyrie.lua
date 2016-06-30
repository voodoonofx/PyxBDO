CombatValkyrie = { }
CombatValkyrie.__index = CombatValkyrie
CombatValkyrie.GrinderVersion = 2

CombatValkyrie.ABILITY_CHARGING_SLASH_IDS = { 749, 748, 747 }
CombatValkyrie.ABILITY_FORWARD_SLASH_IDS = { 1478, 1477, 1476 }
CombatValkyrie.ABILITY_SWORD_OF_JUDGEMENT_IDS = { 735, 734, 733, 732 }
CombatValkyrie.ABILITY_VALKYRIE_SLASH_IDS = { 1475, 1474, 1473, 1472, 1471, 1470, 1469, 1468, 1467, 1466 }
CombatValkyrie.ABILITY_SEVERING_LIGHT_IDS = { 1482, 1481, 1480, 1479 }
CombatValkyrie.ABILITY_CELESTIAL_SPEAR_IDS = { 768, 767, 766, 765 }

--[[
CombatValkyrie.CELESTIALSPEAR_IDS = { 768, 767, 766, 765 }
CombatValkyrie.BREATHOFELION_IDS = { 764, 763, 762 }
CombatValkyrie.SHIELDTHROW_IDS = { 1486, 1485 }
CombatValkyrie.HEAVENSECHO_IDS = { 746, 745, 744 }
CombatValkyrie.DIVINEPOWER_IDS = { 742, 741, 740, 739 }
CombatValkyrie.PUNISHMENT_IDS = { 779, 778, 777, 776 }
CombatValkyrie.SHIELD_STRIKE_IDS = { 1499, 1498, 1497 }
CombatValkyrie.GUARD_IDS = { 718 }
--]]
setmetatable(CombatValkyrie, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function CombatValkyrie.new()
    local self = setmetatable( { }, CombatValkyrie)

    self.ABILITY_CHARGING_SLASH_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_CHARGING_SLASH_IDS)
    self.ABILITY_FORWARD_SLASH_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_FORWARD_SLASH_IDS)
    self.ABILITY_SWORD_OF_JUDGEMENT_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_SWORD_OF_JUDGEMENT_IDS)
    self.ABILITY_VALKYRIE_SLASH_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_VALKYRIE_SLASH_IDS)
    self.ABILITY_SEVERING_LIGHT_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_SEVERING_LIGHT_IDS)
    self.ABILITY_CELESTIAL_SPEAR_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_CELESTIAL_SPEAR_IDS)
--[[
    self.CELESTIALSPEAR_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.CELESTIALSPEAR_IDS)
    self.BREATHOFELION_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.BREATHOFELION_IDS)
    self.SHIELDTHROW_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.SHIELDTHROW_IDS)
    self.HEAVENSECHO_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.HEAVENSECHO_IDS)
    self.DIVINEPOWER_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.DIVINEPOWER_IDS)
    self.PUNISHMENT_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.PUNISHMENT_IDS)
    self.SHIELD_STRIKE_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.SHIELD_STRIKE_IDS)
    self.GUARD_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.GUARD_IDS)
    --]]
    self.CombatRange = 200

    self.Rotations = {
        {
            MinMobs = 1,
            Abilities =
            {
                {
                    MinRange = 0,
                    MaxRange = 1000,
                    Id = self.ABILITY_CELESTIAL_SPEAR_ID,
                    Flags = ACTION_FLAG_SPECIAL_ACTION_2 | ACTION_FLAG_MOVE_BACKWARD,
                    Name = "Celestrial Spear",
                    MyMinHealth = nil,
                    MyMaxHealth = nil,
                    Delay = 500,
                    IgnoreActionPending = false,
                    StopMovement = false,
                    Timer = PyxTimer:New(10.1)
                },
                {
                    MinRange = 0,
                    MaxRange = 250,
                    Id = self.ABILITY_FORWARD_SLASH_ID,
                    Flags = ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_MOVE_FORWARD,
                    Name = "Forward Slash",
                    MyMinHealth = 50,
                    MyMaxHealth = 100,
                    Delay = 500,
                    IgnoreActionPending = false,
                    StopMovement = true
                },
                {
                    MinRange = 0,
                    MaxRange = 220,
                    Id = self.ABILITY_SEVERING_LIGHT_ID,
                    Flags = ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_SECONDARY_ATTACK,
                    Name = "Severing Light",
                    MyMinHealth = 0,
                    MyMaxHealth = 80,
                    Delay = 2000,
                    IgnoreActionPending = false,
                    StopMovement = true
                },
                {
                    MinRange = 0,
                    MaxRange = 200,
                    Id = self.ABILITY_VALKYRIE_SLASH_ID,
                    Flags = ACTION_FLAG_MAIN_ATTACK,
                    Name = "Valkyrie Slash",
                    MyMinHealth = nil,
                    MyMaxHealth = nil,
                    Delay = 1000,
                    IgnoreActionPending = false,
                    StopMovement = true
                }
            }
        },
    }

    return self

end

function CombatValkyrie:UseRotation(rotation, monsterActor)

    local monsterDistance = monsterActor.Position.Distance3DFromMe
    local selfPlayer = GetSelfPlayer()


    for key, value in pairs(rotation.Abilities) do
        if monsterDistance >= (monsterActor.BodySize/2) + value.MinRange and monsterDistance <= (monsterActor.BodySize/2) + value.MaxRange then
            if value.Id ~= 0 and SkillsHelper.IsSkillUsable(value.Id) and not selfPlayer:IsSkillOnCooldown(value.Id)
            and value.IgnoreActionPending == true or selfPlayer.IsActionPending == false then
            if (value.MyMinHealth == nil or selfPlayer.HealthPercent >= value.MyMinHealth)
            and (value.MyMaxHealth == nil or selfPlayer.HealthPercent <= value.MyMaxHealth)
            and (value.Timer == nill or value.Timer:IsRunning() == false or value.Timer:Expired() == true)
             then
                print("CombatValkyrie Using : " .. value.Name)
                if value.StopMovement == true then
                    Bot.Pather:Stop()
                end
                if value.Delay == nil then
                    selfPlayer:SetActionStateAtPosition(value.Flags, monsterActor.Position)
                else
                    selfPlayer:SetActionStateAtPosition(value.Flags, monsterActor.Position, value.Delay)
                end
                if value.Timer ~= nil then
                value.Timer:Reset()
                value.Timer:Start()
                end
                return true

            end
            end
        end

    end


    return false
end

function CombatValkyrie:Attack(monsterActor)



    local selfPlayer = GetSelfPlayer()

    if monsterActor == nil or selfPlayer == nil then
        return
    end
    -- Find a Rotation to Use
    local rotation = self.Rotations[1]
    -- check if we can use any
    if self:UseRotation(rotation, monsterActor) == true then
        return true
    end
    -- if not move closer
    if monsterActor.Position.Distance3DFromMe > (monsterActor.BodySize/2) + self.CombatRange or monsterActor.IsLineOfSight == false then
        Bot.Pather:MoveDirectTo(monsterActor.Position)
    else
        Bot.Pather:Stop()
    end
    return true
end

return CombatValkyrie()