class_name ApplyStatusCommand
extends Command

var owner: Combatant
var target: Card
var definition: CardStatusData
var duration: int
var source: Variant

func _init(
	_owner: Combatant,
	_target: Card,
	_source: Variant,
	_definition: CardStatusData,
	_duration: int = CardStatusData.USE_DEFAULT_DURATION
):
	owner = _owner
	target = _target
	source = _source
	definition = _definition
	duration = _duration


func execute(context: BattleContext) -> ApplyStatusCommand:

	if target == null:
		reason = "No target"
		is_success = false
		return self
	
	if definition == null:
		reason = "no status definition provided to apply"
		is_success = false
		return self
	
	if target is not Card:
		reason = "can only apply a status to a card"
		is_success = false
		return self
	
	var apply_status_request := BattleEvent.new(
		BattleEventType.APPLY_STATUS_REQUESTED,
		owner,
		source,
		target,
		source,
		{
			"definition": definition,
			"duration": duration
		}
	)
	await context.event_queue.enqueue(apply_status_request)

	if apply_status_request.cancelled:
		reason = apply_status_request.cancelled_reason
		is_success = false
		return self
	
	await context.apply_card_status(source, target, definition, duration)

	is_success = true
	return self
