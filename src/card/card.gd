class_name Card
extends TextureRect


signal played_card(card: Card, parent: CardDropZone)
signal request_transition(card: Card, from: String, to: String, callback: Callable)


@export var card_data: CardData

@onready var card_state: CardStateMachine = $CardStateMachine
@onready var hover_panel: Panel = $Assets/HoverPanel
@onready var clicked_panel: Panel = $Assets/ClickedPanel
@onready var dragging_panel: Panel = $Assets/DraggingPanel
@onready var playable_panel: Panel = $Assets/PlayablePanel
@onready var tooltip_stack: VBoxContainer = $TooltipStack

@onready var assets: Control = $Assets
@onready var description: RichTextLabel = $Assets/Description
@onready var image_asset: TextureRect = $Assets/ImageAsset
@onready var inner_border: TextureRect = $Assets/InnerBorder
@onready var card_type: TextureRect = $Assets/Type
@onready var outer_border: TextureRect = $Assets/OuterBorder
@onready var card_flag: TextureRect = $Assets/Flag
@onready var card_mana_cost: TextureRect = $Assets/Mana
@onready var background: TextureRect = $Assets/Background

var TOOLTIP_SCENE = preload("res://src/scenes/tooltip.tscn")
var tooltip_offset_y: float = 0.0

# used to block certain state transitions during the other players turn
var opponents_turn: bool = true
var is_locally_owned: bool = false

func _ready():
	if card_data == null:
		print("Error: card data was null")
	
	description.text = card_data.description
	inner_border.texture = card_data.inner_border_asset
	outer_border.texture = card_data.border_asset
	card_type.texture = card_data.type_asset
	card_flag.texture = card_data.flag_asset
	card_mana_cost.texture = card_data.mana_asset
	background.texture = card_data.background_asset
	image_asset.texture = card_data.image_asset


func _process(_delta: float) -> void:
	# if tooltip is visible recalc it's position each frame.
	if tooltip_stack.visible:
		_update_tooltip_position()


func _input(event: InputEvent) -> void:
	# _input sees mouse events anywhere in the viewport. We only use it after a
	# state has captured the interaction, so dragging still receives motion and
	# button-release events once the cursor leaves the card's Control rect.
	if card_state.wants_captured_input(event):
		card_state.handle_input(event)
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	# _gui_input is for starting card-local interactions: hover-to-click begins
	# only when Godot delivered the mouse event to this specific card Control.
	# Ongoing click/drag handling moves to _input through wants_captured_input().
	if card_state.current_state:
		card_state.handle_input(event)


func show_tooltip() -> void:
	# 1. Clear old tooltips
	for child in tooltip_stack.get_children():
		child.queue_free()
	
	# 2. Instantiate new tooltips
	var main_tooltip = TOOLTIP_SCENE.instantiate()
	tooltip_stack.add_child(main_tooltip)
	main_tooltip.setup(card_data.card_name, card_data.description, card_data.card_cost)
	
	for effect in card_data.effects:
		var effect_tooltip = TOOLTIP_SCENE.instantiate()
		tooltip_stack.add_child(effect_tooltip)
		effect_tooltip.setup(effect.name, effect.description)
	
	# 3. Start invisible (opacity = 0)
	tooltip_stack.modulate.a = 0.0
	tooltip_stack.visible = true
	tooltip_stack.reset_size()
	
	# 4. Wait 1 frame for Godot to measure text label dimensions
	await get_tree().process_frame
	
	if not tooltip_stack.visible:
		return
		
	tooltip_stack.reset_size()
	
	# 5. Start offset lower for animation
	tooltip_offset_y = 6.0
	_update_tooltip_position()
	
	# 6. Smoothly tween opacity to 1.0 and offset to 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tooltip_stack, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "tooltip_offset_y", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func hide_tooltip() -> void:
	tooltip_stack.visible = false


func _update_tooltip_position() -> void:
	var gap = 8
	var viewport = get_viewport_rect()
	var margin = 8
	
	# To the right of the card
	var x = global_position.x + size.x + gap
	
	# If the tooltip goes off the right edge of the screen, place it on the left instead
	if x + tooltip_stack.size.x > viewport.size.x - margin:
		x = global_position.x - tooltip_stack.size.x - gap
		
	# Above the card's visual asset so it doesn't overlap adjacent cards in the hand
	var y = assets.global_position.y - tooltip_stack.size.y - gap
	
	# Keep within vertical bounds so it doesn't go off the top of the screen
	y = clamp(y, margin, viewport.size.y - tooltip_stack.size.y - margin)
	
	# Apply the position + the offset animated by the tween
	tooltip_stack.global_position = Vector2(x, y + tooltip_offset_y)


func play(zone: CardDropZone) -> void:
	played_card.emit(self, zone)
