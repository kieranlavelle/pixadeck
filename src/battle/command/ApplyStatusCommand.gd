class_name ApplyStatusCommand
extends Command

var owner: Combatant
var target: Card
var instance: CardStatusInstance
var source: Variant

func _init(_owner: Combatant, _target: Card, _source: Variant, _instance: CardStatusInstance):
	owner = _owner
	target = _target
	instance = _instance
	source = _source


func execute(context: BattleContext) -> ApplyStatusCommand:

	if target == null:
		reason = "No target"
		is_success = false
		return self
	
	if instance == null:
		reason = "no status instance provided to apply"
		is_success = false
		return self
	
	if target is not Card:
		reason = "can only apply a status to a card"
		is_success = false
		return self
	
	if instance.data == null:
		reason = "instance has no status defined in instance.data"
		is_success = false
		return self

	var apply_status_request := BattleEvent.new(
		BattleEventType.APPLY_STATUS_REQUESTED,
		owner,
		source,
		target,
		source,
		{
			"status": instance
		}
	)
	await context.event_queue.enqueue(apply_status_request)

	if apply_status_request.cancelled:
		reason = apply_status_request.cancelled_reason
		is_success = false
		return self
	
	# context call to apply status to a card
	# this context call combines stacks of the same StatusInstanceType
	context.apply_status(target, instance)

	var status_applied := BattleEvent.new(
		BattleEventType.STATUS_APPLIED,
		owner,
		source,
		target,
		source,
		{
			"status": instance
		}
	)
	await context.event_queue.enqueue(status_applied)

	is_success = true
	return self
