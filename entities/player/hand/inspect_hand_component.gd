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


func card_animate_rotation(card: Card) -> void:
	var sprite: Sprite2D = card.get_node("CardSprite")

	var shader_current_angle: float = sprite.material.get_shader_parameter("angle")
	if shader_current_angle == 0.:
		if tween_shader:
			tween_shader.kill()
		tween_shader = create_tween()
		tween_shader.tween_property(sprite.material, "shader_parameter/angle", card.rotation_degrees, 0.3)


func card_reset_rotation(card: Card) -> void:
	var sprite: Sprite2D = card.get_node("CardSprite")
	var shader_current_angle: float = sprite.material.get_shader_parameter("angle")
	if shader_current_angle != 0.:
		if tween_shader:
			tween_shader.kill()
		tween_shader = create_tween()
		tween_shader.tween_property(sprite.material, "shader_parameter/angle", 0., 0.1)
