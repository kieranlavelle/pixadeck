extends TextureRect

@onready var hand: HBoxContainer = %Hand
@onready var empty_texture: ColorRect = $EmptyTexture

@export var starting_deck: Array[CardData]

var draw_pile: Array[CardData] = []
var hovered: bool = false


func _ready():
	draw_pile = starting_deck.duplicate()
	draw_pile.shuffle()
	

func draw_card():
	if !draw_pile.is_empty():
		var drawn_card = draw_pile.pop_back()
		hand.add_to_hand(drawn_card)
		
		if draw_pile.is_empty():
			empty_texture.show()
		


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false
