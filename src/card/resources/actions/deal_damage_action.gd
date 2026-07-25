class_name DealDamageAction
extends EffectAction

@export var amount: int = 1
@export var damage_type: StringName = &"physical"

func apply(_event: BattleEvent, context: BattleContext, _source: Card, targets: Array[Variant]) -> void:
	# for now we only support combatant damage
	for target in targets:
		if target is not Combatant:
			continue
		context.deal_damage(target, amount)
