class_name PlayCardCommand
extends RootCommand


var owner: Combatant
var card: Card


func _init(_owner: Combatant, _card: Card):
	owner = _owner
	card = _card


func execute(context: BattleContext) -> PlayCardCommand:

	if not owner.hand.has_card(card):
		reason = "Does not have card in hand"
		is_success = false
		return self

	#1. Request board room
	if not context.board.can_add_card(owner.seat):
		reason = "No room on board"
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
		context.board,
		card,
		{}
	)
	await context.event_queue.resolve_child(event)

	if event.cancelled:
		reason = event.cancelled_reason
		is_success = false
		return self

	#4. Spend Mana & Move
	if not owner.hand.has_card(card):
		reason = "Does not have card in hand"
		is_success = false
		return self

	# second_check: Request board room
	if not context.board.can_add_card(owner.seat):
		reason = "No room on board"
		is_success = false
		return self

	# second_check: Request spend mana
	if not context.has_mana_for_card(owner, card):
		reason = "Not enough mana"
		is_success = false
		return self

	# SPEND, SPEND, SPEND!
	if not context.spend_mana(owner, card.card_data.card_cost):
		reason = "Mana amount must be positive and affordable"
		is_success = false
		return self
	owner.hand.play_card(card, context.board)

	#5. PlayedCard BattleEvent
	var played_card_event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_PLAYED,
		owner,
		owner,
		context.board,
		card,
		{}
	)
	await context.event_queue.resolve_child(played_card_event)

	# if this card is a one shot, discard it.
	# this works, but it looks bad as things aren't animated, i.e we dont
	# see this card apply it's affect to other cards, and we dont then animate to discard pile
	if card.card_data.lifetime == CardData.Lifetime.ONE_SHOT:
		var discard_cmd := DiscardCardCommand.new(
			owner, card, DiscardCardCommand.Zone.BATTLEFIELD
		)
		await context.execute(discard_cmd)

		if not discard_cmd.is_success:
			is_success = false
			reason = discard_cmd.reason
			return self

	is_success = true
	return self
