class_name PlayCardCommand
extends Command

var battlefield: CardDropZone
var owner: Combatant
var card: Card


func _init(_battlefield: CardDropZone, _owner: Combatant, _card: Card):
	battlefield = _battlefield
	owner = _owner
	card = _card


func execute(context: BattleContext) -> PlayCardCommand:
	#1. Request battlefield room
	if not context.has_room_on_battlefield(owner):
		reason = "No room on battlefield"
		is_success = false
		return self
	
	#2. Request spend mana
	if not context.has_mana_for_card(owner, card):
		reason = "Not enough mana"
		is_success = false
		return self
	
	#3. RequestPlayCard BattleEvent
	var event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_PLAY_REQUESTED,
		owner,
		owner,
		battlefield,
		card,
		{},
		null
	)
	await context.event_queue.enqueue(event)
	
	if event.cancelled:
		reason = event.cancelled_reason
		is_success = false
		return self

	#4. Spend Mana & Move
	# second_check: Request battlefield room
	if not context.has_room_on_battlefield(owner):
		reason = "No room on battlefield"
		is_success = false
		return self
	
	# second_check: Request spend mana
	if not context.has_mana_for_card(owner, card):
		reason = "Not enough mana"
		is_success = false
		return self

	# SPEND, SPEND, SPEND!
	context.spend_mana(owner, card.card_data.card_cost)
	context.play_card(owner, card)

	#5. PlayedCard BattleEvent
	var played_card_event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_PLAYED,
		owner,
		owner,
		battlefield,
		card,
		{},
		null
	)
	await context.event_queue.enqueue(played_card_event)

	is_success = true
	return self