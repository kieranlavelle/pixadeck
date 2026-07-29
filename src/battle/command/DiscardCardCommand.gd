class_name DiscardCardCommand
extends Command

enum Zone { DECK, HAND, BATTLEFIELD }

var owner: Combatant
var card: Variant
var zone: int
var source: Variant


func _init(
	_owner: Combatant,
	_card: Variant,
	_zone: int,
	_source: Variant = null
):
	owner = _owner
	card = _card
	zone = _zone
	source = _source if _source != null else _owner


func execute(context: BattleContext) -> DiscardCardCommand:
	if owner == null:
		reason = "No combatant to discard a card"
		return self

	var discarded_card := context.discard_card(owner, card, zone)
	if discarded_card == null:
		reason = "Card is not in the requested source zone"
		return self

	await context.event_queue.enqueue(BattleEvent.new(
		BattleEventType.CARD_DISCARDED,
		owner,
		source,
		owner.discard_pile,
		discarded_card,
		{"zone": Zone.keys()[zone].to_lower()}
	))
	is_success = true
	return self
