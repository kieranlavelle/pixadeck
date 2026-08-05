class_name BattlePresentationController
extends RefCounted

# ui-components
var board_ui: BoardUI
var overlay_ui: Overlay

# data-components
var board: Board
var turn_manager: TurnManager

# containers
var combatants: Array[Combatant]

func _init(
	_board_ui: BoardUI,
	_overlay_ui: Overlay,
	_board: Board,
	_turn_manager: TurnManager,
	_combatants: Array[Combatant]
):
	board_ui = _board_ui
	overlay_ui = _overlay_ui
	board = _board
	turn_manager = _turn_manager
	combatants = _combatants


func setup() -> void:
	# connect to static nodes
	board.card_placed.connect(board_ui._on_card_placed)
	board.card_removed.connect(_on_card_discarded.unbind(1))

	# let hands know about their drop-zone target so they can pass to card
	for combatant in combatants:
		combatant.hand.can_drop_at = board_ui.can_accept_drop_at
		combatant.deck.card_discarded.connect(_on_card_discarded)
		combatant.hand.card_discarded.connect(_on_card_discarded)


func _on_card_discarded(card: Card) -> void:
	var battlefield_centre := board_ui.get_battlefield_centre()
	var discard_target := board_ui.get_discard_animation_target(card.owner_combatant.seat)
	var discard_card_cue := DiscardCardCue.new(card, battlefield_centre, discard_target)
	await discard_card_cue.play()
	# Discards do not have a visible destination yet. The card remains parented to
	# its source until this presentation transition owns its lifetime.
	card.queue_free()
