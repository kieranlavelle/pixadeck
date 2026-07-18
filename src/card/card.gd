extends TextureRect


@export var card_data: CardData

@onready var card_state: CardStateMachine = $CardStateMachine
@onready var hover_panel: Panel = $HoverPanel
@onready var clicked_panel: Panel = $ClickedPanel
@onready var dragging_panel: Panel = $DraggingPanel
@onready var tooltip_stack: VBoxContainer = $TooltipStack

var TOOLTIP_SCENE = preload("res://src/scenes/tooltip.tscn")

func _ready():
	if card_data == null:
		print("Error: card data was null")
	texture = card_data.card_asset


# proxy inputs to current state handler
func _unhandled_input(event) -> void:
	if card_state.current_state:
		card_state.current_state.handle_input(event)


func show_tooltip() -> void:
	
	# clear old tooltips
	for child in tooltip_stack.get_children():
		child.queue_free()
	
	# add main card tooltip
	var main_tooltip = TOOLTIP_SCENE.instantiate()
	tooltip_stack.add_child(main_tooltip)
	main_tooltip.setup(card_data.card_name, card_data.description, card_data.card_cost)
	
	# setup effect tooltips
	for effect in card_data.effects:
		var effect_tooltip = TOOLTIP_SCENE.instantiate()
		tooltip_stack.add_child(effect_tooltip)
		effect_tooltip.setup(effect.name, effect.description)
	
	# Wait one frame for the engine to finish layout and text size calculations
	tooltip_stack.modulate.a = 0.0
	tooltip_stack.visible = true
	tooltip_stack.reset_size()
	await get_tree().process_frame
	
	if not tooltip_stack.visible:
		return
		
	tooltip_stack.reset_size()
	_update_tooltip_position()
	
	var target_y = tooltip_stack.global_position.y
	tooltip_stack.global_position.y = target_y + 6 # start 6px lower for slide up
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tooltip_stack, "modulate:a", 1.0, 0.15)
	tween.tween_property(tooltip_stack, "global_position:y", target_y, 0.15)


func hide_tooltip() -> void:
	tooltip_stack.visible = false


func _update_tooltip_position() -> void:
	# Center horizontally relative to the card: (card_center_x) - (half_tooltip_width)
	var x = global_position.x + (size.x / 2.0) - (tooltip_stack.size.x / 2.0)
	# Position above the card: (card_top) - (tooltip_height) - gap
	var y = global_position.y - tooltip_stack.size.y - 6
	
	# clamp tooltip so it's within viewport
	var viewport = get_viewport_rect()
	var margin = 8
	x = clamp(x, margin, viewport.size.x - tooltip_stack.size.x - margin)
	y = clamp(y, margin, viewport.size.y - tooltip_stack.size.y - margin)
	
	tooltip_stack.global_position = Vector2(x, y)
