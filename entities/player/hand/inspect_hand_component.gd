class_name InspectHandComponent
extends Node

var _parent: PlayerManager

const MAGNIFY_CARD_SCALE_FACTOR: float = 4.

var tween_shader: Tween


func setup(parent_player: PlayerManager) -> void:
	_parent = parent_player


func card_highlight_on(card: Card) -> void:
	var sprite: Sprite2D = card.get_node("CardSprite")
	sprite.scale = Vector2(1., 1.)
	sprite.scale *= MAGNIFY_CARD_SCALE_FACTOR
	sprite.z_index = 2


func card_highlight_off(card: Card) -> void:
	var sprite: Sprite2D = card.get_node("CardSprite")
	sprite.scale = Vector2(1., 1.)
	sprite.scale *= GameConstants.SCALE_MULTIPLIER
	sprite.z_index = 1
