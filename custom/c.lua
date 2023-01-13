--
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
--(1)
