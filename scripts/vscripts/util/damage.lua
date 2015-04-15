--伤害系统
--没有伤害公式，但是可以用于物品伤害的加成之类的


--返回伤害类型对应的数字
function GetDamageTypeNumber( type_name )
	
	if type_name == "DAMAGE_TYPE_PHYSICAL" then
		return DAMAGE_TYPE_PHYSICAL
	
	elseif type_name == "DAMAGE_TYPE_MAGICAL" then
		return DAMAGE_TYPE_MAGICAL

	elseif type_name == "DAMAGE_TYPE_PURE" then
		return DAMAGE_TYPE_PURE

	elseif type_name == "DAMAGE_TYPE_COMPOSITE" then
		return DAMAGE_TYPE_COMPOSITE

	end

	return DAMAGE_TYPE_PURE
end

--单体伤害
function DamageTarget( keys )

	--获取增加的技能伤害
	local abilityDamage = keys.caster.add_ability_damage or 0

	local damageTable = {victim  = keys.target, --受害者
						attacker = keys.caster, --伤害者
						damage   = keys.damage + abilityDamage, --伤害
						damage_type = GetDamageTypeNumber(keys.damage_type)} --伤害类型
	local damage = ApplyDamage(damageTable)

	return damage
end


--群体伤害
function DamageAOE( keys )

	local targets = keys.target_entities

	--获取增加的技能伤害
	local abilityDamage = keys.caster.add_ability_damage or 0

	for i,v in pairs(targets) do
		local damageTable = {victim  = v, --受害者
							attacker = keys.caster, --伤害者
							damage   = keys.damage + abilityDamage, --伤害
							damage_type = GetDamageTypeNumber(keys.damage_type)} --伤害类型
		ApplyDamage(damageTable)
	end

end

--方便Lua中调用
function CDOTA_BaseNPC:DamageTargetFun( target,damage,damage_type )
	local damageTable = {target = target,
						caster = self,
						damage = damage,
						damage_type = damage_type
	}
	return DamageTarget( damageTable )
end

function CDOTA_BaseNPC:DamageAOEFun( group,damage,damage_type )
	local damageTable = {target_entities = group,
						caster = self,
						damage = damage,
						damage_type = damage_type
	}
	DamageAOE( damageTable )
end

--增加技能伤害
--每个单位所标记的add_ability_damage就是指增加的技能伤害
function AddAbilityDamage( keys )
	local caster = keys.caster
	local add_damage = keys.add_damage

	if add_damage<0 then
		add_damage = 0
	end

	--获取增加的技能伤害
	local abilityDamage = keys.caster.add_ability_damage or 0

	caster.add_ability_damage = abilityDamage + add_damage
end

function LowAbilityDamage( keys )
	local caster = keys.caster
	local low_damage = keys.low_damage

	if low_damage<0 then
		low_damage = 0
	end

	--获取增加的技能伤害
	local abilityDamage = keys.caster.add_ability_damage or 0
	
	caster.add_ability_damage = abilityDamage - low_damage

	--防止出现负数
	if caster.add_ability_damage<0 then
		caster.add_ability_damage = 0
	end
end