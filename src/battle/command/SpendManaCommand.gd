class_name SpendManaCommand
extends Command

var owner: Combatant
var amount: int
var source: Variant


func _init(_owner: Combatant, _amount: int, _source: Variant = null):
	owner = _owner
	amount = _amount
	source = _source if _source != null else _owner


func execute(context: BattleContext) -> SpendManaCommand:
	if owner == null:
		reason = "No combatant to spend mana"
		return self

	if not context.spend_mana(owner, amount):
		reason = "Mana amount must be positive and affordable"
		return self

	await context.event_queue.resolve_child(BattleEvent.new(
		BattleEventType.MANA_SPENT,
		owner,
		source,
		owner,
		null,
		{"amount": amount}
	))
	is_success = true
	return self
