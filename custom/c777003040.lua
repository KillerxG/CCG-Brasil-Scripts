--DBS Potara Fusion - Vegetto
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x314a)--Husband Arch
	c:SetUniqueOnField(1,0,id)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,777002500,777002510)
	--(1)ATK Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--(2)Destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	c:RegisterEffect(e2)
	--(3)Special Summon materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--(4)Destroy opponent's monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)	
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
	--(5)Cannot Cpecial Summon
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(function(e,se,sp,st) return se:GetHandler():IsCode(777003030) end)
	c:RegisterEffect(e5)
end
--(1)ATK Up
function s.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x292)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
--(2)Destroy replace
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsFaceup() and c:GetDefense()>=750 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-750)
		c:RegisterEffect(e2)
		return true
	else return false end
end
--(3)Special Summon materials
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()~=tp and c:GetDefense()==0
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and e:GetHandler():IsAbleToExtra() 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,777002500) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,777002510) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)	
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,777002500)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,777002510)
	if #g1>0 and #g2>0 then
		Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.SpecialSummon(sg1,0,tp,tp,true,false,POS_FACEUP)
	end
end
--(4)Destroy opponent's monsters
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end