class_name BattleContext
extends RefCounted


var event_queue: BattleEventQueue
var combatants: Array[Combatant] = []
var battle_manager: BattleManager

func _init(
	_event_queue: BattleEventQueue,
	_combatants: Array[Combatant],
	_battle_manager: BattleManager
) -> void:
	event_queue = _event_queue
	combatants = _combatants
	battle_manager = _battle_manager


func spend_mana(combatant: Combatant, amount: int) -> bool:
	if combatant.stats.current_mana < amount:
		return false
	combatant.stats.use_mana(amount)
	return true


func deal_damage(target: Combatant, amount: int) -> void:
	if target == null:
		return
	target.stats.refresh_health(target.stats.current_health - amount)
