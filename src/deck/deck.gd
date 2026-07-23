extends TextureRect

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var hand: Hand = %Hand as Hand
@onready var empty_texture: ColorRect = $EmptyTexture

@export var draw_sound: AudioStream
@export var starting_deck: Array[CardData]

var draw_pile: Array[CardData] = []
var hovered: bool = false


func _ready():
	audio.stream = draw_sound
	draw_pile = starting_deck.duplicate()
	draw_pile.shuffle()
	

func draw_card():
	if !draw_pile.is_empty():
		
		# check there is room in hand:
		if hand.is_hand_full():
			print("Hand is full, handle this event later")
			return
		
		if audio.stream:
			audio.play()
		
		var drawn_card = draw_pile.pop_back()
		
		# start this card as invisible, seems like it should
		# be a hand or card responsibility
		var card_in_hand := hand.add_to_hand(drawn_card)
		await animate_card_to_hand(card_in_hand)
		
		if draw_pile.is_empty():
			empty_texture.show()


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
