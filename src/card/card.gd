class_name Card
extends TextureRect

signal emit_command(command: PlayCardCommand, callback: Variant)

@export var card_data: CardData

@onready var card_state: CardStateMachine = $CardStateMachine
@onready var tooltip_stack: TooltipStack = $TooltipStack
@onready var assets: CardAssets = $Assets


# used to block certain state transitions during the other players turn
var opponents_turn: bool = true
var is_locally_owned: bool = false
var owner_combatant: Combatant
var card_status_holder: CardStatusHolder = CardStatusHolder.new()

# a callable that takes a global position and tells the caller if a
# card can be released at that position.
var can_drop_at: Callable

func _ready():
	if card_data == null:
		print("Error: card data was null")
	assets.setup(card_data)
	tooltip_stack.setup(self)

	# hookup the signal from the state machine so requests can flow up
	# to card
	card_state.emit_command.connect(emit_command.emit)

	# for this holder, this card is the "host"
	card_status_holder.host = self


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


func hide_tooltip() -> void:
	tooltip_stack.visible = false


func show_tooltip() -> void:
	tooltip_stack.show_tooltip()


func add_status(status: CardStatusInstance) -> void:
	card_status_holder.add_status(status)


func remove_status(status: CardStatusInstance) -> void:
	card_status_holder.remove_status(status)


func is_over_drop_target() -> bool:
	return can_drop_at.call(get_global_mouse_position())


func play_effect_anticipation() -> void:
	assets.outer_glow.visible = true

	# this actually needs to be seat aware for the direction
	# the card moves in.
	var raised_position = assets.position + Vector2(0, -10)
	var tween := create_tween().set_parallel(true)

	tween.tween_property(assets, "scale", Vector2(1.05, 1.05), 0.2)
	tween.parallel().tween_property(assets, "position:y", raised_position.y, 0.2)
	tween.parallel().tween_property(assets.outer_glow, "self_modulate:a", 1.0, 0.14)
	await tween.finished


func release_effect_anticipation() -> void:

	# this brings it back to normal, probably need a "release_effect_anticipation"
	var tween := create_tween().set_parallel(true)
	var original_position = assets.position + Vector2(0, 10)

	tween.tween_property(assets, "scale", Vector2(1,1), 0.2)
	tween.parallel().tween_property(assets, "position:y", original_position.y, 0.2)
	tween.parallel().tween_property(assets.outer_glow, "self_modulate:a", 0, 0.2)
	await tween.finished
	assets.outer_glow.visible = false


func play_discard_animation(
	battlefield_centre: Vector2,
	discard_destination: Vector2
) -> void:
	# give us free movement
	top_level = true
	var tween := create_tween()

	# move the center
	tween.tween_property(self, "global_position", battlefield_centre - size * 0.5, 1)

	# move to discard zone
	tween.tween_property(self, "global_position", discard_destination, 0.9)

	await tween.finished
