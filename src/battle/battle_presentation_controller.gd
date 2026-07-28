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
	board.card_removed.connect(board_ui._on_card_removed)

	# let hands know about their drop-zone target so they can pass to card
	for combatant in combatants:
		combatant.hand.can_drop_at = board_ui.can_accept_drop_at
