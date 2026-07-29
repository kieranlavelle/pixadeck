class_name Deck
extends TextureRect

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var hand: Hand = %Hand as Hand
@onready var empty_texture: ColorRect = $EmptyTexture

@export var draw_sound: AudioStream
@export var starting_deck: Array[CardData]

var draw_pile: Array[CardData] = []
var hovered: bool = false

signal card_discarded(card: Card)


func _ready():
	audio.stream = draw_sound
	draw_pile = starting_deck.duplicate()
	draw_pile.shuffle()


func is_deck_empty() -> bool:
	return draw_pile.is_empty()


func draw_card() -> CardData:
	if is_deck_empty():
		return null

	if audio.stream:
		audio.play()

	var drawn_card = draw_pile.pop_back()

	if draw_pile.is_empty():
		empty_texture.show()

	return drawn_card


func discard_card(card_data: CardData, owner: Combatant) -> Card:
	var index := draw_pile.find(card_data)
	if index == -1:
		return null

	draw_pile.remove_at(index)
	if draw_pile.is_empty():
		empty_texture.show()

	# Deck entries are data, unlike hand and board entries. Promote the data to a
	# runtime Card while it is still parented here so presentation can handle the
	# discard transition without ever observing an orphaned Card node.
	var runtime_card := Hand.CARD_SCENE.instantiate() as Card
	runtime_card.card_data = card_data
	runtime_card.owner_combatant = owner
	add_child(runtime_card)
	card_discarded.emit(runtime_card)
	return runtime_card


func animate_card_to_hand(card_in_hand: Card) -> void:
	# start this card as invisible, seems like it should
	# be a hand or card responsibility
	card_in_hand.modulate.a = 0.0
	card_in_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# wait for the next frame to assure the the card has a layout
	# so we can use it's global positions.
	await get_tree().process_frame

	# need to create a temp flyer to move from deck -> hand
	var flyer := TextureRect.new()
	flyer.texture = texture
	flyer.size = card_in_hand.size
	flyer.global_position = global_position
	flyer.top_level = true # this prevents layout disturbing this flyer
	flyer.z_index = 100

	# in future we could move this to a dedicated overlay for animations
	get_tree().current_scene.add_child(flyer)

	var tween := create_tween()
	tween.tween_property(
		flyer,
		"global_position",
		card_in_hand.global_position,
		0.4
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished
	flyer.queue_free()

	card_in_hand.modulate.a = 1.0
	card_in_hand.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false
