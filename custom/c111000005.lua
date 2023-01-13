--Rias Gremory
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Alloy same Clan only
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--(2)Summon Method
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptarget)
	e2:SetOperation(s.spactivate)
	c:RegisterEffect(e2)
	--(3)Individual Action
	
end
--(1)Alloy same Clan only
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and not (c:IsSetCard(0x206) or c:IsCode(111000000) or c:IsType(TYPE_EQUIP))
end
function s.filter2(c)
	return c:IsFacedown() and c:IsAbleToRemove() and not (c:IsSetCard(0x206) or c:IsCode(111000000) or c:IsType(TYPE_EQUIP))
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ALL,0,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	local conf=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ALL,0,nil)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		Duel.Remove(conf,POS_FACEDOWN,REASON_EFFECT)
	end
end
--(2)Summon Method
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x211,16,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x211,16,REASON_COST)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local c=e:GetHandler()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--(3)Individual Action