class_name DamageEffectData
extends EffectData

@export var amount: int = 1
@export var damage_type: StringName = &"physical"
@export var target_selector: TargetSelector

func resolve(event: BattleEvent, context: BattleContext, source: Card) -> void:
	if target_selector == null:
		return
	var target := target_selector.pick_target(event, context, source)
	context.deal_damage(target, amount)
