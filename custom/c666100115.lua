--Cyber Dragon Nexus
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
   	--Code
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(CARD_CYBER_DRAGON)
	c:RegisterEffect(e0)
	--Fusion Summon
	local params = {aux.FilterBoolFunction(aux.IsMaterialListSetCard,0x1093),nil,nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
	--Treat Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.xyzcost)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
--Fusion Summon
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
--Treat Level
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local alte0=Effect.CreateEffect(c)
	alte0:SetType(EFFECT_TYPE_FIELD)
    alte0:SetCode(EFFECT_XYZ_LEVEL)
    alte0:SetTargetRange(LOCATION_MZONE,0)
    alte0:SetTarget(aux.TargetBoolFunction(s.xyzfilter))
    alte0:SetValue(s.xyzlv)
	alte0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(alte0,tp)
	end
function s.xyzfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and not c:IsType(TYPE_XYZ)
end
function s.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_LIGHT) and rc:IsRace(RACE_MACHINE) then
		return 5,6,e:GetHandler():GetLevel()
	else
		return e:GetHandler():GetLevel()
	end
end