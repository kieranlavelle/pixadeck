class_name TooltipStack
extends VBoxContainer

const TOOLTIP_SCENE = preload("res://src/ui/tooltip/tooltip.tscn")
var tooltip_offset_y: float = 0.0

# values used for calculating tooltip pos
var _assets: CardAssets
var _parent: Card
var _card_data: CardData

func setup(parent: Card) -> void:
	_assets = parent.assets
	_parent = parent
	_card_data = parent.card_data


func _process(_delta: float) -> void:
	# if tooltip is visible recalc it's position each frame.
	if visible:
		_update_tooltip_position()


func show_tooltip() -> void:
	# 1. Clear old tooltips
	for child in get_children():
		child.queue_free()

	# 2. Instantiate new tooltips
	var main_tooltip = TOOLTIP_SCENE.instantiate()
	add_child(main_tooltip)
	main_tooltip.setup(
		_card_data.card_name,
		_card_data.description,
		_card_data.card_cost
	)

	# gather all the keywords
	var keywords: Array[KeywordData] = []

	for effect in _card_data.effects:
		for keyword in effect.get_tooltip_keywords():
			if not keywords.has(keyword):
				keywords.append(keyword)

	for keyword in keywords:
		var effect_tooltip = TOOLTIP_SCENE.instantiate()
		add_child(effect_tooltip)
		effect_tooltip.setup(keyword.display_name, keyword.description)

	# 3. Start invisible (opacity = 0)
	modulate.a = 0.0
	visible = true
	reset_size()

	# 4. Wait 1 frame for Godot to measure text label dimensions
	await get_tree().process_frame

	if not visible:
		return

	reset_size()

	# 5. Start offset lower for animation
	tooltip_offset_y = 6.0
	_update_tooltip_position()

	# 6. Smoothly tween opacity to 1.0 and offset to 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "tooltip_offset_y", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _update_tooltip_position() -> void:
	var gap = 8
	var viewport = _parent.get_viewport_rect()
	var margin = 8

	# To the right of the card
	var x = _parent.global_position.x + size.x + gap

	# If the tooltip goes off the right edge of the screen, place it on the left instead
	if x + size.x > viewport.size.x - margin:
		x = _parent.global_position.x - size.x - gap

	# Above the card's visual asset so it doesn't overlap adjacent cards in the hand
	var y = _assets.global_position.y - size.y - gap

	# Keep within vertical bounds so it doesn't go off the top of the screen
	y = clamp(y, margin, viewport.size.y - size.y - margin)

	# Apply the position + the offset animated by the tween
	global_position = Vector2(x, y + tooltip_offset_y)
