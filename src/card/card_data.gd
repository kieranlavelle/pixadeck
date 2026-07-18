class_name CardData
extends Resource

@export var id: String = "card_id"
@export var card_asset: Texture2D
@export var card_name: String = "card_name"
@export var card_cost: int = 1

@export_multiline var description: String = "card effect description"

@export_category("Stats")
@export var damage: int = -1
@export var heal: int = -1

@export var effects: Array[EffectData] = []
