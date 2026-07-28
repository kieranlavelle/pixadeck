class_name BattleManager
extends Control

@onready var TurnManagerNode: TurnManager = $TurnManager as TurnManager
@onready var BattleOverlay: Overlay = $BattleOverlay as Overlay
@onready var Battlefield: BoardUI = $BattleLayout/Battlefield/CardDropZone as BoardUI

var combatants: Array[Combatant] = []
var event_queue: BattleEventQueue
var board: Board
var battle_context: BattleContext
var presentation_controller: BattlePresentationController

func _ready():

	# setup the event queue for the battle.
	event_queue = BattleEventQueue.new()
	add_child(event_queue)

	# setup the board
	board = Board.new()

	# discover combatants in this battle
	combatants.assign(get_tree().get_nodes_in_group("Combatants"))
	for combatant in combatants:
		combatant.combatant_id = combatant.get_instance_id()
		combatant.apply_layout()

		# Allow AI end turn?
		if combatant.ai_controller.can_process():
			combatant.ai_controller.ai_turn_ended.connect(_on_request_end_turn)
			combatant.ai_controller._manager = self

		TurnManagerNode.turn_started.connect(combatant._on_turn_start)
		combatant.emit_command.connect(_on_command)

	# If A player skips their turn emit turn finished
	BattleOverlay.request_end_turn.connect(_on_request_end_turn)
	TurnManagerNode.turn_started.connect(_ui_on_turn_start)
	TurnManagerNode.turn_started.connect(BattleOverlay._on_turn_start)

	# setup battle context
	battle_context = BattleContext.new(event_queue, combatants, self, board, TurnManagerNode)
	for combatant in combatants:
		combatant.battle_context = battle_context
	# give the battle event queue context
	event_queue.battle_context = battle_context

	presentation_controller = BattlePresentationController.new(
		Battlefield,
		BattleOverlay,
		board,
		TurnManagerNode,
		combatants
	)
	presentation_controller.setup()

	TurnManagerNode.start(combatants)

func _ui_on_turn_start(combatant: Combatant) -> void:

	# we don't need to check it's there turn as it must be inside this
	# as the signal fired.
	if combatant.is_local_player:
		BattleOverlay.show_end_turn_button()
	else:
		BattleOverlay.hide_end_turn_button()


# Signals do not await connected async methods, so this adapter owns the
# fire-and-forget boundary for UI and AI end-turn requests.
func _on_request_end_turn() -> void:
	await battle_context.execute(EndTurnCommand.new())


# It might be better to have a generic command handler in future
func _on_command(command: Command, callback: Variant) -> void:
	var command_response: Command = await battle_context.execute(command)
	if callback != null:
		callback.call(command_response)
