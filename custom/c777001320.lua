--Empress of Silver Fangs - Kyara
--Scripted by KillerxG
local s,id=GetID()
s.IsIdrakian=true
if not IDRAKIAN_IMPORTED then Duel.LoadScript("proc_idrakian.lua") end
function s.initial_effect(c)
	--Enkyo Summon
	Idrakian.AddProcedure(c,3,aux.FilterBoolFunctionEx(Card.IsSetCard,0x307),aux.FilterBoolFunctionEx(Card.IsSetCard,0x307))
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
	c:AddSetcodesRule(id,true,0x307)--Silver Fangs Arch
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Card.Alias(c,id)
	c:SetStatus(STATUS_NO_LEVEL,true)
    --(1)Damage Conversion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.revcon)
	e1:SetValue(s.rev)
	c:RegisterEffect(e1)
	--(2)Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetCondition(s.incon)
	c:RegisterEffect(e2)
	--(3)Send to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--(4)Force opponent's monster to attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e4)	
end
--(1)Damage Conversion
function s.revfilter(c,cc)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x307) and c:GetLinkedGroup():IsContains(cc)
end
function s.revcon(e)
	return Duel.IsExistingMatchingCard(s.revfilter,0,LOCATION_MZONE,0,1,nil,e:GetHandler()) 
end
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)>0 or (r&REASON_BATTLE)>0
end
--(2)Cannot be destroyed by card effects
function s.incon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
--(3)Send to GY
function s.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x307) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,1000)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if Duel.SendtoDeck(td,nil,2,REASON_EFFECT)~=0 then
		if tc and tc:IsRelateToEffect(e) then
			if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
				Duel.BreakEffect()
				Duel.Recover(tp,1000,REASON_EFFECT)
			end
		end
	end
end