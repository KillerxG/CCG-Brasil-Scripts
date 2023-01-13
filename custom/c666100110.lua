--Cybernova Polymerization
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(aux.IsMaterialListSetCard,0x1093),s.matfilter,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	AshBlossomTable=AshBlossomTable or {}
	table.insert(AshBlossomTable,e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
--Fusion Summon
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE)
end
function s.matfilter(c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsAbleToGrave()) or (c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsMonster() and c:IsAbleToGrave())
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=3
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil),s.fcheck
	if eg and #eg>0 then
			return eg,s.fcheck
		end
end