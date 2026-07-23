class_name Hand
extends HBoxContainer

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@export var card_played_sound: AudioStream


const DEFAULT_MAX_HAND_SIZE = 5
const CARD_SCENE = preload("res://src/card/card.tscn")

signal request_play_card(card: Card, zone: CardDropZone)
signal request_transition(card: Card, from: String, to: String, callback: Callable)

var cards: Array[Card] = []
var owner_combatant: Combatant

func _ready():
	audio.stream = card_played_sound


func is_hand_full() -> bool:
	return len(cards) >= DEFAULT_MAX_HAND_SIZE


func add_to_hand(card_data: CardData) -> Card:
	if cards.size() < DEFAULT_MAX_HAND_SIZE:
		var card_instance = CARD_SCENE.instantiate()
		card_instance.card_data = card_data
		
		# connect signals
		card_instance.played_card.connect(request_play_card.emit)
		card_instance.request_transition.connect(request_transition.emit)
		
		add_child(card_instance)
		cards.append(card_instance)
		
		return card_instance
	return null


func update_cards_for_turn(is_opponents_turn: bool) -> void:
	for card in cards:
		card.opponents_turn = is_opponents_turn
		card.is_locally_owned = owner_combatant.is_local_player
	


func play_card(card: Card, new_parent: CardDropZone) -> void:
	
	if audio.stream:
		audio.play()
	
	new_parent.play_card(card, owner_combatant)
	var index = cards.find(card)
	
	# find() can return -1
	if index != -1:
		cards.remove_at(index)
