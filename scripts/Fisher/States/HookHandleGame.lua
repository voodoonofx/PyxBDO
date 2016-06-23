HookFishHandleGameState = { }
HookFishHandleGameState.__index = HookFishHandleGameState
HookFishHandleGameState.Name = "Hook game"

setmetatable(HookFishHandleGameState, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function HookFishHandleGameState.new()
    local self = setmetatable({}, HookFishHandleGameState)
    self.LastHookFishTickCount = 0
    self.LastGameTick = 0
    self.RandomWaitTime = 0
    self.Settings = {InstantFish = false, AlwaysPerfect = false}
    self.GamePause = nil
    
    return self
end

function HookFishHandleGameState:NeedToRun()

    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end

    return selfPlayer.MiniGameType == 1
end

function HookFishHandleGameState:Run()

    local selfPlayer = GetSelfPlayer()

    if selfPlayer and selfPlayer.MiniGameType == 1 and selfPlayer.MiniGameResult ~= 3 then
        selfPlayer.MiniGameResult = 3
		local lua = 
		[[
			audioPostEvent_SystemUi(11,00)
			audioPostEvent_SystemUi(11,13)
			local _sinGauge_Result_Perfect = UI.getChildControl ( Panel_SinGauge, "Static_Result_Perfect" )
			_sinGauge_Result_Perfect:ResetVertexAni()
			_sinGauge_Result_Perfect:SetVertexAniRun("Perfect_Ani", true)
			_sinGauge_Result_Perfect:SetVertexAniRun("Perfect_ScaleAni", true)
			_sinGauge_Result_Perfect:SetVertexAniRun("Perfect_AniEnd", true)
			_sinGauge_Result_Perfect:SetShow(true)
		]]
		BDOLua.Execute(lua)
        print("Doing gauge mini game !")
    end
    
end


