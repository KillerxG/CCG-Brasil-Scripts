--Lancelot Elementaria Tryce of Knowledge
--Scripted by Hellboy
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x888),s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	c:AddSetcodesRule(id,true,0x314a)--Husband Arch
	--Attribute change
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(s.attval)
    c:RegisterEffect(e1)
	--Unaffected by opponent's Spells/Trap effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.extncon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e3:SetCondition(s.ctlcon)
	c:RegisterEffect(e3)
	--rearrange
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.gycon)
	e4:SetTarget(s.sttg)
	e4:SetOperation(s.stop)
	c:RegisterEffect(e4)
	--Mind scan
	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.con1)
    e5:SetOperation(s.op1)
    c:RegisterEffect(e5)
	--Decrease opponent's monster's ATK/DEF by 200
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(s.rmvcon)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
	--return
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,id+1)
	e8:SetCondition(s.extracond)
	e8:SetTarget(s.target)
	e8:SetOperation(s.operation)
	c:RegisterEffect(e8)
end
s.listed_series={0x888}
s.material_setcode=0x888
function s.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,lc,sumtype,tp) 
end
function s.matfil(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,false,true)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--Attribute change
function s.attval(e,c)
	local c=e:GetHandler()
    local att=c:GetMaterial():GetBitwiseOr(Card.GetAttribute)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(att)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE-RESET_TEMP_REMOVE-RESET_REMOVE-RESET_TURN_SET)
    c:RegisterEffect(e1)
end
--Unaffected by opponent's Spells/Trap effects
function s.extncon(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_LIGHT)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--control
function s.ctlcon(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_DARK)
end
--rearrange
function s.gycon(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_EARTH)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SortDecktop(tp,1-tp,3)
end
--Mind scan
function s.con1(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_SZONE,nil)
    if g and #g>0 then
        for tc in aux.Next(g) do
            if tc:GetFlagEffect(id)==0 then
                Duel.ConfirmCards(tp,tc)
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
        end
    end
end
--Decrease opponent's monster's ATK/DEF by 200
function s.rmvcon(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_FIRE)
end
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*(-100)
end
--return
function s.extracond(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_WIND)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x888) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end