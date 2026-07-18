extends TextureRect

@onready var hand: HBoxContainer = %Hand
@onready var empty_texture: ColorRect = $EmptyTexture

@export var starting_deck: Array[CardData]

var draw_pile: Array[CardData] = []
var hovered: bool = false

const CARD_SCENE = preload("res://src/card/card.tscn")

func _ready():
	draw_pile = starting_deck.duplicate()
	draw_pile.shuffle()
	

func draw_card():
	if draw_pile.is_empty():
		empty_texture.show()
		return
	
	var drawn_card = draw_pile.pop_back()
	var new_card_ui = CARD_SCENE.instantiate()

	# 3. Inject the data BEFORE adding to the tree 
	# (So the card's _ready() function can set the labels)
	new_card_ui.card_data = drawn_card
	hand.add_child(new_card_ui)


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false


func _input(event):
	if event.is_action_pressed("left_mouse_button"):
		draw_card()
