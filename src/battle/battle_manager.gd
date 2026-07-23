class_name BattleManager
extends Control

@onready var TurnManagerNode = $TurnManager
@onready var BattleOverlay = $BattleOverlay

var combatants: Array[Combatant] = []

func _ready():
	
	# discover combatants in this battle
	combatants.assign(get_tree().get_nodes_in_group("Combatants"))
	for combatant in combatants:
		combatant.combatant_id = combatant.get_instance_id()
		combatant.apply_layout()
		
		# connect their signals
		combatant.player_turn_ended.connect(TurnManagerNode.turn_finished.emit)
		TurnManagerNode.turn_started.connect(combatant._on_turn_start)
	
	# If A player skips their turn emit turn finished
	BattleOverlay.request_end_turn.connect(TurnManagerNode.turn_finished.emit)
	
	
	# UI Updates
	TurnManagerNode.turn_started.connect(_ui_on_turn_start)
		
	# What to do when a turn starts?
	TurnManagerNode.turn_started.connect(BattleOverlay._on_turn_start)
	

	TurnManagerNode.start(combatants)

func _ui_on_turn_start(combatant: Combatant) -> void:
	
	# we don't need to check it's there turn as it must be inside this
	# as the signal fired.
	if combatant.is_local_player:
		BattleOverlay.show_end_turn_button()
	else:
		BattleOverlay.hide_end_turn_button()
