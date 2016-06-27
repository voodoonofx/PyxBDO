Maehwa = { }
Maehwa.__index = Maehwa
Maehwa.Version = "1"
Maehwa.Author = "Vitalic for orignal 1.1, Triplany for update"
Maehwa.GrinderVersion = 2
Maehwa.BodyDistance = 190

-------------------------- Spell ID's ------------------------------------

Maehwa.SLICE = { 1512, 1510, 1509, 1508, 1507, 1511, 1506, 1504, 1503, 1502, 414, 412, 411, 410, 409, 413, 408, 1261, 1260, 1259}
Maehwa.ARROW_GRAPPLE = { 1570, 1326, 1569, 1325 }
Maehwa.BACKSTAB = { 1619 }
Maehwa.BACKSTEP_SLASH = { 1596, 1595, 1594, 421, 420, 419}
Maehwa.BLIND_SLASH = { 1580, 1579, 400, 399 }
Maehwa.BLIND_THRUST = { 1563, 1562, 1561, 1321, 1320, 1319 }
Maehwa.BLOOMING = { 1560, 1314 }
Maehwa.BLOOMING_PHANTOM = { 1567, 1323 }
Maehwa.BLUNT_KICK = { 1528, 1272 }
Maehwa.CARVER = { 1537, 1536, 1535, 1277, 1276, 1275 }
Maehwa.CARVER_TYPHOON = { 1538, 1278 }
Maehwa.CHAOS_RED_MOON = { 1574, 1573, 1572 }
Maehwa.CHARGED_STUB_ARROW = { 1543, 1283 }
Maehwa.CHARGED_STUB_ARROW_ENHANCED = { 1544, 1284 }
Maehwa.CHARGED_STUB_ARROW_EVASION = { 1545, 1453 }
Maehwa.CHASE = { 1592, 1591, 1456, 1455 }
Maehwa.CYCLONE_SLASH = { 1578, 1577, 398, 397 }
Maehwa.DEEP_SLICE = { 1514, 1513, 1505, 1461, 1460, 1262 }
Maehwa.DIVIDER = { 1553, 1552, 1551, 1550, 1549, 425, 1288, 1287, 1286, 1285 }
Maehwa.DRAGON_BITE = { 1557, 1556, 1555, 1553, 1298, 1297, 1296 }
Maehwa.DRAGON_CLAW = { 1558, 1299 }
Maehwa.FLOW_EARTHQUAKE = { 424 }
Maehwa.FORCE_OF_THE_SWORD = { 1617, 407 }
Maehwa.FORWARD_ROLL = { 1501, 1258 }
Maehwa.GALE = { 416, 415, 403, 402, 401 }
Maehwa.LEAP = { 422 }
Maehwa.LUNAR_SLASH = { 1568, 1324 }
Maehwa.MAEHWAS_WILL = { 1590, 1589, 1588 }
Maehwa.MAEHWA_ASCENSION_TO_HEAVEN = { 1576 }
Maehwa.MAEHWA_DECAPITATION = { 1586, 1585, 1584, 1583, 1582 }
Maehwa.MUSA_SPIRIT = { 406, 405, 404 }
Maehwa.NEMESIS_SLASH = { 1565, 1564, 1450, 1322 }
Maehwa.RETALIATION = { 1525, 1524, 1523, 159, 1269, 1268 }
Maehwa.RETALIATION_STANCE = { 1522, 1267 }
Maehwa.RETALIATION_DECAPITATION = { 1526, 1270 }
Maehwa.RISING_STORM = { 1447, 1446, 1445 }
Maehwa.RISING_STORM_BLAZE = { 1465 }
Maehwa.ROUNDHOUSE_KICK = { 1530, 1274 }
Maehwa.STUB_ARROW = {1540, 1539, 1280, 1279}
Maehwa.STUB_ARROW_DOUBLE_SHOT = { 1541, 1281 }
Maehwa.STUB_ARROW_EVASIVE_SHOT = { 1548, 1547, 1546, 1464, 1463, 1462 }
Maehwa.STUB_ARROW_TRIPLE_SHOT = { 1542, 1282 }
Maehwa.SWEEP_KICK = { 1529, 1273 }
Maehwa.TIGER_BLADE = { 1554, 1289 }
Maehwa.TIGER_BLADE_DUAL = { 1312 }
Maehwa.TIGER_BLADE_SECOND_BLOOMING = { 1315 }
Maehwa.TIGER_BLADE_THIRD_BLOOMING = { 1316 }
Maehwa.TIGER_BLADE_TRIPLE = { 1313 }
Maehwa.TOPSPIN_KICK = { 1437, 1318, 1317 }
Maehwa.UPPER_KICK = { 1527, 1271 }
Maehwa.WHIRLWIND_CUT = { 1518, 1517, 1516, 1515, 418, 1265, 1264, 1263 }
Maehwa.WHIRLWIND_CUT_CYCLONE = { 1521, 202 }
Maehwa.WHIRLWIND_CUT_GRINDER = { 1519, 1266 }
Maehwa.ULTIMATE_CHAOS_RED_MOON = { 1575 }
Maehwa.ULTIMATE_DECAPITATION = { 1587 }
Maehwa.ULTIMATE_ARROW_GRAPPLE = { 1571, 1454 }
Maehwa.ULTIMATE_BLIND_SLASH = { 1581, 1459 }
Maehwa.ULTIMATE_BLUNT_KICK = { 1532, 393 }
Maehwa.ULTIMATE_CHASE = { 1593, 1457 }
Maehwa.ULTIMATE_DRAGON_CLAW = { 1559, 1300 }
Maehwa.ULTIMATE_GALE = { 423 }
Maehwa.ULTIMATE_NEMESIS_SLASH = { 1566, 1451 }
Maehwa.ULTIMATE_RISING_STORM = { 396 }
Maehwa.ULTIMATE_ROUNDHOUSE_KICK = { 1534, 395 }
Maehwa.ULTIMATE_STUB_ARROW = { 1452 }
Maehwa.ULTIMATE_SWEEP_KICK = { 1533, 394 }
Maehwa.ULTIMATE_UPPER_KICK = { 1531, 392 }
Maehwa.ULTIMATE_WHIRLWIND_CUT = { 1520, 201 }

-------------------------------------------------------------------------------------------------

-----------------------------------------------------

setmetatable(Maehwa, {
	__call = function (cls, ...)
	return cls.new(...)
end,
})

------------------------------------------------------

-----------Set New Blader and constants ----------------

function Maehwa.new()
	local instance = {}
	local self = setmetatable(instance, Maehwa)
	return self
end

------------------------------------------------------------

---------- No Mobs to fuck up? Setup Roaming State -----------

function Maehwa:Roaming()
	local selfPlayer = GetSelfPlayer()
	if not selfPlayer then
		return
	end
end

------------------------------------------------------------------

------------ Main Combat Logic Function ----------------------

function Maehwa:Attack(monsterActor)

------------ Local Spell ID's ---------------------------------------------------------------
	
	local SLICE = SkillsHelper.GetKnownSkillId(Maehwa.SLICE)
	local ARROW_GRAPPLE = SkillsHelper.GetKnownSkillId(Maehwa.ARROW_GRAPPLE)
	local BACKSTAB = SkillsHelper.GetKnownSkillId(Maehwa.BACKSTAB)
	local BACKSTEP_SLASH = SkillsHelper.GetKnownSkillId(Maehwa.BACKSTEP_SLASH)
	local BLIND_SLASH = SkillsHelper.GetKnownSkillId(Maehwa.BLIND_SLASH)
	local BLIND_THRUST = SkillsHelper.GetKnownSkillId(Maehwa.BLIND_THRUST)
	local BLOOMING = SkillsHelper.GetKnownSkillId(Maehwa.BLOOMING)
	local BLOOMING_PHANTOM = SkillsHelper.GetKnownSkillId(Maehwa.BLOOMING_PHANTOM)
	local BLUNT_KICK = SkillsHelper.GetKnownSkillId(Maehwa.BLUNT_KICK)
	local CARVER = SkillsHelper.GetKnownSkillId(Maehwa.CARVER)
	local CARVER_TYPHOON = SkillsHelper.GetKnownSkillId(Maehwa.CARVER_TYPHOON)
	local CHAOS_RED_MOON = SkillsHelper.GetKnownSkillId(Maehwa.CHAOS_RED_MOON)
	local CHARGED_STUB_ARROW = SkillsHelper.GetKnownSkillId(Maehwa.CHARGED_STUB_ARROW)
	local CHARGED_STUB_ARROW_ENHANCED = SkillsHelper.GetKnownSkillId(Maehwa.CHARGED_STUB_ARROW_ENHANCED)
	local CHARGED_STUB_ARROW_EVASION = SkillsHelper.GetKnownSkillId(Maehwa.CHARGED_STUB_ARROW_EVASION)
	local CHASE = SkillsHelper.GetKnownSkillId(Maehwa.CHASE)
	local CYCLONE_SLASH = SkillsHelper.GetKnownSkillId(Maehwa.CYCLONE_SLASH)
	local DEEP_SLICE = SkillsHelper.GetKnownSkillId(Maehwa.DEEP_SLICE)
	local DIVIDER = SkillsHelper.GetKnownSkillId(Maehwa.DIVIDER)
	local DRAGON_BITE = SkillsHelper.GetKnownSkillId(Maehwa.DRAGON_BITE)
	local DRAGON_CLAW = SkillsHelper.GetKnownSkillId(Maehwa.DRAGON_CLAW)
	local FLOW_EARTHQUAKE = SkillsHelper.GetKnownSkillId(Maehwa.FLOW_EARTHQUAKE)
	local FORCE_OF_THE_SWORD = SkillsHelper.GetKnownSkillId(Maehwa.FORCE_OF_THE_SWORD)
	local FORWARD_ROLL = SkillsHelper.GetKnownSkillId(Maehwa.FORWARD_ROLL)
	local GALE = SkillsHelper.GetKnownSkillId(Maehwa.GALE)
	local LEAP = SkillsHelper.GetKnownSkillId(Maehwa.LEAP)
	local LUNAR_SLASH = SkillsHelper.GetKnownSkillId(Maehwa.LUNAR_SLASH)
	local MAEHWAS_WILL = SkillsHelper.GetKnownSkillId(Maehwa.MAEHWAS_WILL)
	local MAEHWA_ASCENSION_TO_HEAVEN = SkillsHelper.GetKnownSkillId(Maehwa.MAEHWA_ASCENSION_TO_HEAVEN)
	local MAEHWA_DECAPITATION = SkillsHelper.GetKnownSkillId(Maehwa.MAEHWA_DECAPITATION)
	local MUSA_SPIRIT = SkillsHelper.GetKnownSkillId(Maehwa.MUSA_SPIRIT)
	local NEMESIS_SLASH = SkillsHelper.GetKnownSkillId(Maehwa.NEMESIS_SLASH)
	local RETALIATION = SkillsHelper.GetKnownSkillId(Maehwa.RETALIATION)
	local RETALIATION_STANCE = SkillsHelper.GetKnownSkillId(Maehwa.RETALIATION_STANCE)
	local RETALIATION_DECAPITATION = SkillsHelper.GetKnownSkillId(Maehwa.RETALIATION_DECAPITATION)
	local RISING_STORM = SkillsHelper.GetKnownSkillId(Maehwa.RISING_STORM)
	local RISING_STORM_BLAZE = SkillsHelper.GetKnownSkillId(Maehwa.RISING_STORM_BLAZE)
	local ROUNDHOUSE_KICK = SkillsHelper.GetKnownSkillId(Maehwa.ROUNDHOUSE_KICK)
	local STUB_ARROW = SkillsHelper.GetKnownSkillId(Maehwa.STUB_ARROW)
	local STUB_ARROW_DOUBLE_SHOT = SkillsHelper.GetKnownSkillId(Maehwa.STUB_ARROW_DOUBLE_SHOT)
	local STUB_ARROW_EVASIVE_SHOT = SkillsHelper.GetKnownSkillId(Maehwa.STUB_ARROW_EVASIVE_SHOT)
	local STUB_ARROW_TRIPLE_SHOT = SkillsHelper.GetKnownSkillId(Maehwa.STUB_ARROW_TRIPLE_SHOT)
	local SWEEP_KICK = SkillsHelper.GetKnownSkillId(Maehwa.SWEEP_KICK)
	local TIGER_BLADE = SkillsHelper.GetKnownSkillId(Maehwa.TIGER_BLADE)
	local TIGER_BLADE_DUAL = SkillsHelper.GetKnownSkillId(Maehwa.TIGER_BLADE_DUAL)
	local TIGER_BLADE_SECOND_BLOOMING = SkillsHelper.GetKnownSkillId(Maehwa.TIGER_BLADE_SECOND_BLOOMING)
	local TIGER_BLADE_THIRD_BLOOMING = SkillsHelper.GetKnownSkillId(Maehwa.TIGER_BLADE_THIRD_BLOOMING)
	local TIGER_BLADE_TRIPLE = SkillsHelper.GetKnownSkillId(Maehwa.TIGER_BLADE_TRIPLE)
	local TOPSPIN_KICK = SkillsHelper.GetKnownSkillId(Maehwa.TOPSPIN_KICK)
	local UPPER_KICK = SkillsHelper.GetKnownSkillId(Maehwa.UPPER_KICK)
	local WHIRLWIND_CUT = SkillsHelper.GetKnownSkillId(Maehwa.WHIRLWIND_CUT)
	local WHIRLWIND_CUT_CYCLONE = SkillsHelper.GetKnownSkillId(Maehwa.WHIRLWIND_CUT_CYCLONE)
	local WHIRLWIND_CUT_GRINDER =SkillsHelper.GetKnownSkillId(Maehwa.WHIRLWIND_CUT_GRINDER)

-------------------------------------------------------------------------------------------------------------------

---------------------- Monster Visable? Then: ------------------------------------------------------------------------

	selfPlayer = GetSelfPlayer()
	actorPosition = monsterActor.Position
	EdanScout.Update()
	selfPlayer:FacePosition(actorPosition)
	
	if monsterActor then
		local monsters = GetMonsters()
    	local monsterCount = 0 

		if actorPosition.Distance3DFromMe > monsterActor.BodySize + self.BodyDistance then
			Bot.Pather:MoveDirectTo(actorPosition)
	----------------------------- Close the Gap! -------------------------------------

				if  not selfPlayer.IsActionPending and DRAGON_BITE ~= 0 and SkillsHelper.IsSkillUsable(DRAGON_BITE) and not selfPlayer:IsSkillOnCooldown(DRAGON_BITE)
				and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600 then
					print("Closing the Gap with Dragon's Bite!")
					selfPlayer:SetActionState(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_MAIN_ATTACK)
					return
				end
		else
			Bot.Pather:Stop()

			for k, v in pairs(monsters) do
				if v.IsAggro then
					monsterCount = monsterCount + 1
				end
			end

			if not selfPlayer.IsActionPending then


	----------------------------------------------------------------------------------

	-------------------------------- Up in their faces? ----------------------------------

				if RISING_STORM ~= 0 and monsterCount >= 3 and not selfPlayer:IsSkillOnCooldown(RISING_STORM) and SkillsHelper.IsSkillUsable(RISING_STORM)
				 then
					print("Rising Storm!")
					selfPlayer:SetActionState(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_1, 3000)
					return
				end

	--------------------------------------------------------------------------------------

				if MUSA_SPIRIT ~= 0 and selfPlayer.ManaPercent <= 10 and not selfPlayer:IsSkillOnCooldown(MUSA_SPIRIT) then
					print("Regenerating WP! Musa Spirit!")
					selfPlayer:SetActionState(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_2, 1500)
					return
				end

				if GALE ~= 0 and not selfPlayer:IsSkillOnCooldown(GALE) and SkillsHelper.IsSkillUsable(GALE) then
					print("Casting Gale!")
					selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 3000)
					return
				end

				if CARVER ~= 0 and selfPlayer.Stamina >= 130 and not selfPlayer:IsSkillOnCooldown(CARVER) then
					print("Casting Carver!")
					selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_EVASION | ACTION_FLAG_MAIN_ATTACK, actorPosition, 1500)
					return
				end

				if DIVIDER ~= 0 and SkillsHelper.IsSkillUsable(DIVIDER) and not selfPlayer:IsSkillOnCooldown(DIVIDER)  then
					print("Casting Divider!")
					selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)

					if selfPlayer.Mana >= 20 and string.match(selfPlayer.CurrentActionName, "GhostSword") then
						print("Downward Slash!")
						selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MAIN_ATTACK, actorPosition, 600)
						return
					end
					return
				end

				if SLICE ~= 0  then
					print("Slice!")
					selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)

					if BLIND_THRUST ~= 0 and selfPlayer.Stamina >= 210 and not selfPlayer:IsSkillOnCooldown(BLIND_THRUST)
					and string.match(selfPlayer.CurrentActionName, "ATTACK") then
						print("Blind Thrust!")
						selfPlayer:SetActionStateAtPosition(ACTION_FLAG_JUMP, actorPosition, 800)

						if NEMESIS_SLASH ~= 0 and SkillsHelper.IsSkillUsable(NEMESIS_SLASH) and not selfPlayer:IsSkillOnCooldown(NEMESIS_SLASH)
						and string.match(selfPlayer.CurrentActionName, "Back_Lunge") then
							print("Nemesis Slash!")
							selfPlayer:SetActionStateAtPosition(ACTION_FLAG_JUMP, actorPosition, 1500)
							return
						end
						return
					end
					return	
				end
				
			end
		end
	end
end

return Maehwa()