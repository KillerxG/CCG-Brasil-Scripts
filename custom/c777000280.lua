--Azur Lane - Akagi
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--(1)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--(2)Zones in the same column cannot be used
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
	--(3)Self Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(s.descon)
	c:RegisterEffect(e3)
end
--(1)Activate
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetColumnGroup():IsExists(Card.IsControler,1,nil,1-tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--(2)Zones in the same column cannot be used
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=c:GetColumnZone(LOCATION_ONFIELD)
	for tc in c:GetColumnGroup():Iter() do
		local ctrl=tc:IsControler(tp)
		local seq=tc:GetSequence()
		zones=zones&~(ctrl and (1<<seq) or (1<<(16+seq)))
		if tc:IsInExtraMZone() then
			zones=zones&~(ctrl and (1<<(27-seq)) or (1<<(11-seq)))
		end
	end
	return zones
end
--(3)Self Destroy
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x298)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE,0,1,nil)
end