--Singtress of Elementale - Zel
--Scripted by KillerxG
local s,id=GetID()
s.IsIdrakian=true
if not IDRAKIAN_IMPORTED then Duel.LoadScript("proc_idrakian.lua") end
function s.initial_effect(c)
	--Enkyo Summon
	Idrakian.AddProcedure(c,3,aux.FilterBoolFunctionEx(Card.IsSetCard,0x310),aux.FilterBoolFunctionEx(Card.IsSetCard,0x310))
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
	c:AddSetcodesRule(id,true,0x310)--Elementale Arch
	c:SetSPSummonOnce(id)
	Card.Alias(c,id)
	c:EnableReviveLimit()
	c:SetStatus(STATUS_NO_LEVEL,true)
	--(1)Change die result
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_DICE_NEGATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.diceop)
	c:RegisterEffect(e1)
	--(2)Protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	--(3)Win the Duel
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(s.wincon)
	e4:SetOperation(s.winop)
	c:RegisterEffect(e4)
end
--(1)Change die result
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid  and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local dc={Duel.GetDiceResult()}
			local ac=1
			local ct=(ev&0xff)+(ev>>16)
			Duel.Hint(HINT_CARD,0,id)
			if ct>1 then
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(dc,1,ct))
				ac=idx+1
			end
			if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then	dc[ac]=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
			else dc[ac]=Duel.AnnounceNumber(tp,1,2,3,4,5,6) end
		Duel.SetDiceResult(table.unpack(dc))
		s[0]=cid
	end
end
--(2)Protection
function s.target(e,c)
	return c:IsSetCard(0x310)
end
--(3)Win the Duel
function s.winfilter(c)
	return c:IsSetCard(0x310) and c:IsType(TYPE_MONSTER)
end
function s.winfilter2(c)
	return c:IsCode(777003240)
end
function s.winfilter3(c)
	return c:IsCode(777003230)
end
function s.winfilter4(c)
	return c:IsCode(777003270)
end
function s.wincon(e)
	return Duel.GetMatchingGroup(s.winfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetAttribute)>=5 
		and Duel.GetMatchingGroup(s.winfilter2,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
		and Duel.GetMatchingGroup(s.winfilter3,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
		and Duel.GetMatchingGroup(s.winfilter4,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_ZEL)
end