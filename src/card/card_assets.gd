class_name CardAssets
extends Control


@onready var outer_glow: Panel = $OuterGlow
@onready var description: RichTextLabel = $Description
@onready var image_asset: TextureRect = $ImageAsset
@onready var inner_border: TextureRect = $InnerBorder
@onready var card_type: TextureRect = $Type
@onready var outer_border: TextureRect = $OuterBorder
@onready var card_flag: TextureRect = $Flag
@onready var card_mana_cost: TextureRect = $Mana
@onready var background: TextureRect = $Background

@onready var hover_panel: Panel = $HoverPanel
@onready var clicked_panel: Panel = $ClickedPanel
@onready var dragging_panel: Panel = $DraggingPanel
@onready var playable_panel: Panel = $PlayablePanel

# Set's the appropriate texture against each
# child for the card specified by CardData
func setup(data: CardData) -> void:
	description.text = data.description
	inner_border.texture = data.inner_border_asset
	outer_border.texture = data.border_asset
	card_type.texture = data.type_asset
	card_flag.texture = data.flag_asset
	card_mana_cost.texture = data.mana_asset
	background.texture = data.background_asset
	image_asset.texture = data.image_asset
