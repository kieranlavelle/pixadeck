class_name RequestDrawCardCommand
extends Command

var hand: Hand
var deck: Deck
var owner: Combatant


func _init(_owner: Combatant, _deck: Deck, _hand: Hand):
	owner = _owner
	deck = _deck
	hand = _hand


func execute(context: BattleContext) -> RequestDrawCardCommand:
	#1. Check has cards in deck
	if deck.is_deck_empty():
		reason = "No cards in deck"
		is_success = false
		return self

	#2. Check room in hand
	if hand.is_hand_full():
		reason = "No room in hand"
		is_success = false
		return self

	#3. RequestPlayCard BattleEvent
	var event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_DRAW_REQUESTED,
		owner,
		owner, # could be deck?
		hand,
		null,
		{}
	)
	await context.event_queue.resolve_child(event)

	if event.cancelled:
		reason = event.cancelled_reason
		is_success = false
		return self

	#4.
	# second_check: Check enough cards in deck.
	if deck.is_deck_empty():
		reason = "No cards in deck"
		is_success = false
		return self

	# second_check: Check room in hand.
	if hand.is_hand_full():
		reason = "No room in hand"
		is_success = false
		return self

	#5. CARD_DRAWN BattleEvent
	var card := await context.draw_and_move_card(owner)
	var draw_event := BattleEvent.new(BattleEventType.CARD_DRAWN, owner, deck, hand, card)
	await context.event_queue.resolve_child(draw_event)

	is_success = true
	return self
