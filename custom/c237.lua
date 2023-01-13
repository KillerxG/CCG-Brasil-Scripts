--
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	Card.Alias(c,237)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
    --(1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	--e1:SetCode(EFFECT_FREE_CHAIN)
	--e1:SetCondition(s.condition)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.CheckLPCost(1-tp,2000) and Duel.SelectYesNo(1-tp,aux.Stringid(id,4)) then
		if Duel.PayLPCost(1-tp,2000)~=0 then return end
	end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
