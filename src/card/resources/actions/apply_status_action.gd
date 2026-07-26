class_name ApplyStatusAction
extends EffectAction

@export var status: CardStatusData

func apply(_event: BattleEvent, _context: BattleContext, source: Card, targets: Array[Variant]) -> void:
	for target in targets:

		# currently we will only apply status' to cards
		if target is not Card:
			continue
		
		var instance := CardStatusInstance.new()
		instance.data = status
		instance.applier = source
		instance.host = target

		instance.remaining_turns = status.duration

		target.add_status(instance)
