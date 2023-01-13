--Azur Lane - Enterprise
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
	c:AddSetcodesRule(id,true,0x298)--Azur Lane Arch
	Card.Alias(c,id)
	--(1)Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
--XYZ Materials
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:HasLevel() and c:IsSetCard(0x298)
end
function s.xyzcheck(g,tp,xyz)
    local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
    return #mg==2 and math.abs(mg:GetFirst():GetLevel()-mg:GetNext():GetLevel())==6
end
--(1)Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        local tc=eg:GetFirst()
        local seq=tc:GetSequence()
        local zone=0
        if tc:IsLocation(LOCATION_MZONE) then
            zone=0x10000
            while seq>0 do
                zone=zone*2
                seq=seq-1
            end
        elseif tc:IsLocation(LOCATION_SZONE) or tc:GetLocation()==0x0 then
            if seq<5 then--and (not tc:IsType(TYPE_PENDULUM) or not (seq==0 or seq==4)) then
                zone=0x1000000
                while seq>0 do
                    zone=zone*2
                    seq=seq-1
                end
            end
        end
		if Duel.Destroy(eg,REASON_EFFECT) and zone>0 then
            e:SetLabel(zone)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_DISABLE_FIELD)
            e1:SetOperation(s.disop)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetLabel(e:GetLabel())
            Duel.RegisterEffect(e1,tp)
        end
	end
end
function s.disop(e,tp)
    return e:GetLabel()
end