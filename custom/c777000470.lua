--Azur Lane - Hakuryuu
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:AddSetcodesRule(id,true,0x314)--Waifu Arch
    --(1)To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
--XYZ Materials
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:HasLevel() and c:IsSetCard(0x298)
end
function s.xyzcheck(g,tp,xyz)
    local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
    return #mg==2 and math.abs(mg:GetFirst():GetLevel()-mg:GetNext():GetLevel())==5
end
--(1)To Deck
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local seq=tc:GetSequence()
        if seq>4 then
            Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
        else
            local zone=0x10000
            if tc:IsLocation(LOCATION_MZONE) then
                while seq>0 do
                    zone=zone*2
                    seq=seq-1
                end
            elseif tc:IsLocation(LOCATION_SZONE) then
                zone=0x1000000
                while seq>0 do
                    zone=zone*2
                    seq=seq-1
                end
            end
            Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
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