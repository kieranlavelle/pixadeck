class_name BattleManager
extends Control

@onready var TurnManagerNode: TurnManager = $TurnManager as TurnManager
@onready var BattleOverlay = $BattleOverlay
@onready var Battlefield: CardDropZone = $BattleLayout/Battlefield/CardDropZone as CardDropZone

var combatants: Array[Combatant] = []
var event_queue: BattleEventQueue
var battle_context: BattleContext

func _ready():

	# setup the event queue for the battle.
	event_queue = BattleEventQueue.new()
	add_child(event_queue)
	
	# discover combatants in this battle
	combatants.assign(get_tree().get_nodes_in_group("Combatants"))
	for combatant in combatants:
		combatant.combatant_id = combatant.get_instance_id()
		combatant.apply_layout()
		
		# Allow AI end turn?
		if combatant.ai_controller.can_process():
			combatant.ai_controller.ai_turn_ended.connect(
				_on_request_end_turn
			)
			combatant.ai_controller._manager = self
		TurnManagerNode.turn_started.connect(combatant._on_turn_start)
		combatant.request_play_card.connect(_on_play_card_request)
	
	# If A player skips their turn emit turn finished
	BattleOverlay.request_end_turn.connect(_on_request_end_turn)
	TurnManagerNode.turn_started.connect(_ui_on_turn_start)
	TurnManagerNode.turn_started.connect(BattleOverlay._on_turn_start)
	
	# setup battle context
	battle_context = BattleContext.new(event_queue, combatants, self, Battlefield)
	for combatant in combatants:
		combatant.battle_context = battle_context
	# give the battle event queue context
	event_queue.battle_context = battle_context


	TurnManagerNode.start(combatants)

func _ui_on_turn_start(combatant: Combatant) -> void:
	
	# we don't need to check it's there turn as it must be inside this
	# as the signal fired.
	if combatant.is_local_player:
		BattleOverlay.show_end_turn_button()
	else:
		BattleOverlay.hide_end_turn_button()


# This is a thin wrapper around _end_current_turn due to signals
# not awaiting async functions but BattleEvents are async and we
# need to emit one on turn end
func _on_request_end_turn() -> void:
	await _end_current_turn()


# Currently this dispatches the turn ending signal onto the 
# BattleEventQueue, may move into turu
func _end_current_turn() -> void:
	var combatant := TurnManagerNode.current_combatant
	if combatant == null:
		return

	await event_queue.enqueue(
		BattleEvent.new(
			BattleEventType.TURN_ENDING, combatant, combatant
		)
	)
	
	TurnManagerNode.advance_turn()
	
	await event_queue.enqueue(
		BattleEvent.new(
			BattleEventType.TURN_ENDED,
			combatant,
			combatant,
			null,
			null,
			{},
			battle_context.expire_card_statuses_for_owner
		)
	)


# It might be better to have a generic command handler in future
func _on_play_card_request(command: PlayCardCommand, callback: Callable) -> void:
	# TODO, the flow of this might be easier if we pass commands into
	# these functions and they modify things like reason and is_success

	#1. Request battlefield room
	if not battle_context.has_room_on_battlefield(command.owner):
		command.reason = "No room on battlefield"
		command.is_success = false
		if callback:
			callback.call(command)
		return
	
	#2. Request spend mana
	if not battle_context.has_mana_for_card(command.owner, command.card):
		command.reason = "Not enough mana"
		command.is_success = false
		if callback:
			callback.call(command)
		return
	
	#3. RequestPlayCard BattleEvent
	var event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_PLAY_REQUESTED,
		command.owner,
		command.owner,
		command.battlefield,
		command.card,
		{},
		null
	)
	await event_queue.enqueue(event)
	
	if event.cancelled:
		command.reason = event.cancelled_reason
		command.is_success = false
		if callback:
			callback.call(command)
		return

	#4. Spend Mana & Move
	# second_check: Request battlefield room
	if not battle_context.has_room_on_battlefield(command.owner):
		command.reason = "No room on battlefield"
		command.is_success = false
		if callback:
			callback.call(command)
		return
	
	# second_check: Request spend mana
	if not battle_context.has_mana_for_card(command.owner, command.card):
		command.reason = "Not enough mana"
		command.is_success = false
		if callback:
			callback.call(command)
		return

	# SPEND, SPEND, SPEND!
	battle_context.spend_mana(command.owner, command.card.card_data.card_cost)
	battle_context.play_card(command.owner, command.card)

	#5. PlayedCard BattleEvent
	var played_card_event: BattleEvent = BattleEvent.new(
		BattleEventType.CARD_PLAYED,
		command.owner,
		command.owner,
		command.battlefield,
		command.card,
		{},
		null
	)
	await event_queue.enqueue(played_card_event)

	command.is_success = true
	callback.call(command)
