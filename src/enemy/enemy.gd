class_name Enemy
extends BasePlayer


func _on_turn_start(id: int) -> void:
	# call base class on turn start func
	await super(id)
	if id == player_id:
		play_turn()
	

func play_turn() -> void:
	# look at the cards in hand, pick one, play it.
	if len(hand.cards) > 0:
		var card: Card = hand.cards.pick_random()
		var dropzone: CardDropZone = get_tree().get_first_node_in_group("CardDropZone")
		hand.play_card(card, dropzone)
