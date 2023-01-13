--Super Star Vesperbell
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Place 2 Vesperbell members on PZONE
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)Increase or reduce Pendulum Scales
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))	
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.cpstarget)
	e2:SetOperation(s.cpsoperation)
	c:RegisterEffect(e2)
	--(3)Allow direct attacks
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
--(1)Place 2 Vesperbell members on PZONE
function s.pcfilter(c)
	return c:IsSetCard(0x315) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and (c:IsCode(777003070) or c:IsCode(777003080))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2 and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc1=g:Select(tp,1,1,nil):GetFirst()
		g:Remove(Card.IsCode,nil,tc1:GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g2=g:Select(tp,1,1,nil)
		Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		Duel.MoveToField(g2:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--(2)Increase or reduce Pendulum Scales
function s.cpstarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_PZONE,0,2,nil) end
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_PZONE,0,2,2,nil)
end
function s.getscale(c)
	if c == Duel.GetFieldCard(0,LOCATION_PZONE,0) or c == Duel.GetFieldCard(1,LOCATION_PZONE,0) then
		return c:GetLeftScale()
	else
		return c:GetRightScale()
	end
end
function s.cpsoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	tg=tg:Filter(Card.IsRelateToEffect,nil,e)
	for tc in aux.Next(tg) do
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
		local scale = s.getscale(tc)
		local opt = (scale <= 1) and 1 or 2
		if opt == 2 then
			opt = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		else
			opt = Duel.SelectOption(tp,aux.Stringid(id,2))
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		if opt == 0 then
			e1:SetValue(2)
		else
			e1:SetValue(-2)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
--(3)Allow direct attacks
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRitualMonster()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end