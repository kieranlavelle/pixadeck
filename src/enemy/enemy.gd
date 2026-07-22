class_name Enemy
extends BasePlayer


func _on_turn_start(player: BasePlayer) -> void:
	# call base class on turn start func
	await super(player)
	if player.player_id == player_id:
		play_turn()
	

func play_turn() -> void:
	# look at the cards in hand, pick one, play it.
	var dropzone: CardDropZone = get_tree().get_first_node_in_group("CardDropZone")
	if len(hand.cards) > 0:
		
		var cards: Array[Card] = hand.cards.duplicate()
		for card in cards:
			_request_to_play_card(card, dropzone)
			
	# if we got here, the AI has tried to play every card in hand
	player_turn_ended.emit()
