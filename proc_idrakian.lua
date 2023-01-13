REASON_IDRAKIAN		 = 0x80000000
SUMMON_TYPE_IDRAKIAN = 0x20
HINTMSG_IMATERIAL	 = 601
IDRAKIAN_IMPORTED=true
if not aux.IdrakianProcedure then
	aux.IdrakianProcedure = {}
	Idrakian = aux.IdrakianProcedure
end
if not Idrakian then
	Idrakian = aux.IdrakianProcedure
end
--[[
add at the start of the script to add Ingition procedure
if not REVERSE_XYZ_IMPORTED then Duel.LoadScript("proc_idrakian.lua") end
]]
--Idrakian Summon
--Parameters:
-- c: card
-- lv: level of the first material (the second is two times the level)
-- f1: optional, filter for the first material
-- f2: optional, filter for the second material
-- alterf: optional, filter for the alternative summon method (using 1 monster as material)
-- alterop: optional, operation for the alternative summon method
-- desc: optional, description for the alternative summon method
function Idrakian.AddProcedure(c,lv,f1,f2,alterf,alterop,desc)
	if c.rxyz_filter==nil then
		local mt=c:GetMetatable()
		mt.rxyz_type=1
		mt.rxyz_filter=function(mc,ignoretoken) return mc and (not f or f(mc)) and (mc:IsXyzLevel(c,lv) or mc:IsXyzLevel(c,lv*2)) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.rxyz_parameters={mt.rxyz_filter,c,lv,f1,f2,alterf,alterop,desc}
	end
	--remove xyz type
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_REMOVE_TYPE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(TYPE_XYZ)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1180)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Idrakian.Condition(lv,f1,f2))
	e1:SetTarget(Idrakian.Target(lv,f1,f2))
	e1:SetOperation(Idrakian.Operation)
	e1:SetValue(SUMMON_TYPE_IDRAKIAN)
	c:RegisterEffect(e1)
	if alterf then
		local e2=e1:Clone()
		e2:SetDescription(desc)
		e2:SetCondition(Idrakian.Condition2(alterf,alterop))
		e2:SetTarget(Idrakian.Target2(alterf,alterop))
		e2:SetOperation(Idrakian.Operation2(alterf,alterop))
		c:RegisterEffect(e2)
	end
end
function Idrakian.FilterEx(c,f,sc,tp,lv,mg)
    local g
	if mg then
		g=mg
	else
		g=Group.CreateGroup()
	end
    g:AddCard(c)
	return (not lv or c:IsXyzLevel(sc,lv)) and (not f or f(c,sc,SUMMON_TYPE_IDRAKIAN,tp))
        and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function Idrakian.Filter(c,f1,sc,tp,lv)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and (not lv or c:IsXyzLevel(sc,lv))
        and (not f1 or f1(c,sc,SUMMON_TYPE_IDRAKIAN,tp)) 
end
function Idrakian.Check(tp,sg,sc,lv,f1,f2)
	if lv then
		return sg:IsExists(Idrakian.FilterEx,1,nil,f1,sc,tp,lv,sg)
			and sg:IsExists(Idrakian.FilterEx,1,nil,f2,sc,tp,lv*2,sg)
	else
		return sg:IsExists(Idrakian.FilterEx,2,nil,f1,sc,tp,lv,sg)
	end
end
function Idrakian.Condition(lv,f1,f2)
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
                
				if lv then
					local mg1=Duel.GetMatchingGroup(Idrakian.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
					local mg2=Duel.GetMatchingGroup(Idrakian.Filter,tp,LOCATION_MZONE,0,nil,f2,c,tp,lv*2)					
					if #mg1<1 or #mg2<1 then return false end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_IDRAKIAN)
					if must then mustg:Merge(must) end
					if not (mg1+mg2):Includes(mustg) then return false end
					
					return mg1:IsExists(Idrakian.FilterEx,1,nil,f1,c,tp,lv,mg2)
						and mg2:IsExists(Idrakian.FilterEx,1,nil,f2,c,tp,lv*2,mg1)
				else
					local mg1=Duel.GetMatchingGroup(Idrakian.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
					if #mg1<2 then return false end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_IDRAKIAN)
					if must then mustg:Merge(must) end
					if not mg1:Includes(mustg) then return false end
					
					return mg1:IsExists(Idrakian.FilterEx,2,nil,f1,c,tp,lv,nil)
				end
            end
end
function Idrakian.Target(lv,f1,f2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,mg1,mg2)
                if not mg1 then
                    mg1=Duel.GetMatchingGroup(Idrakian.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
                end
				if lv then
					if not mg2 then
						mg2=Duel.GetMatchingGroup(Idrakian.Filter,tp,LOCATION_MZONE,0,nil,f2,c,tp,lv*2)
					end
				else
					if not mg2 then
						mg2=Group.CreateGroup()
					end
				end

				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,mg1+mg2,tp,c,mg1+mg2,REASON_IDRAKIAN)
				if must then mustg:Merge(must) end
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<2 do                    
					local cg=Group.CreateGroup()
					if lv then
						if not sg:IsExists(Idrakian.FilterEx,1,nil,f1,c,tp,lv,mg2) then
							cg:Merge(mg1:Filter(Idrakian.FilterEx,nil,f1,c,tp,lv,mg2))
						end
						if not sg:IsExists(Idrakian.FilterEx,1,nil,f2,c,tp,lv*2,mg1) then
							cg:Merge(mg2:Filter(Idrakian.FilterEx,nil,f2,c,tp,lv*2,mg1))
						end
					else
						if not sg:IsExists(Idrakian.FilterEx,2,nil,f1,c,tp,lv,mg2) then
							cg:Merge(mg1:Filter(Idrakian.FilterEx,nil,f1,c,tp,lv,mg2))
						end
					end
					cg:Remove(function(c,g) return g:IsContains(c) end,nil,sg)
					if #cg==0 then break end
					finish=#sg==max and Idrakian.Check(tp,sg,c,lv,f1,f2)
					cancel=Duel.GetCurrentChain()<=0 and #sg==0
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_IMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
					if not tc then break end
					if not sg:IsContains(tc) then
						sg:AddCard(tc)
					else
						sg:RemoveCard(tc)
					end
				end
				
				if #sg>0 then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					return false
				end
            end
end
function Idrakian.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)				
    local c=e:GetHandler()
	local g=e:GetLabelObject()
	local sg=Group.CreateGroup()
	for tc in aux.Next(g) do
		sg:Merge(tc:GetOverlayGroup())
	end
	Duel.SendtoGrave(sg,REASON_IDRAKIAN+REASON_RULE)
	c:SetMaterial(g)
    Duel.SendtoGrave(g,REASON_IDRAKIAN+REASON_RULE,g)
	g:DeleteGroup()
end