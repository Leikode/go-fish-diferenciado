class_name RenderGameStateManager
extends Control

@export var from_label: Label
@export var to_label: Label
@export var player_turn: Label

@onready var cards_texture: Texture2D = preload("res://entities/cards/art/Pixel_Playing_Card_Set_updated.svg")
@onready var card_shader: Shader = preload("res://entities/cards/art/card.gdshader")

var parent: BoardManager
var deck_manager: DeckManager

var viewport_size: Vector2


func setup(board_manager: BoardManager) -> void:
	from_label.text = ""
	to_label.text = ""
	player_turn.text = ""
	parent = board_manager
	deck_manager = parent.deck_manager
	viewport_size = get_viewport().get_visible_rect().size
#	to_opponent_position = {
#		0: Vector2(
#			center_of_screen.x + (0. * GameConstants.OPPONENT_CARDS_OFFSET.x),
#			center_of_screen.y + (1. * GameConstants.OPPONENT_CARDS_OFFSET.y),
#		),
#		1: Vector2(
#			center_of_screen.x + (1. * GameConstants.OPPONENT_CARDS_OFFSET.x),
#			center_of_screen.y + (0. * GameConstants.OPPONENT_CARDS_OFFSET.y),
#		),
#		2: Vector2(
#			center_of_screen.x + (0. * GameConstants.OPPONENT_CARDS_OFFSET.x),
#			center_of_screen.y + (-1. * GameConstants.OPPONENT_CARDS_OFFSET.y),
#		),
#		3: Vector2(
#			center_of_screen.x + (-1. * GameConstants.OPPONENT_CARDS_OFFSET.x),
#			center_of_screen.y + (0. * GameConstants.OPPONENT_CARDS_OFFSET.y),
#		),
#	}


func show_buyed_card(card: CardData, name_from: String, name_to: String, player_in_turn: int) -> void:
	_animate_buy_card(card, name_from, name_to, player_in_turn)


func show_negated_card(card: CardData, name_from: String, name_to: String) -> void:
	_animate_negate_card(card, name_from, name_to)


func show_player_turn() -> void:
	pass


func _animate_buy_card(card: CardData, name_from: String, name_to: String, player_in_turn: int) -> void:
	var sprite_size: Vector2i = deck_manager.get_card_size()
	var rect_origin: Vector2i = deck_manager.get_rect_for(card)
	var region: Rect2 = Rect2(rect_origin, sprite_size)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _create_card_texture(region)
	sprite.region_rect = region
	sprite.name = "AddingCardSprite"

	sprite.scale *= 2.

	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = card_shader
	mat.set_shader_parameter("outline_color", Vector3(0., 0., 0.89))
	mat.set_shader_parameter("angle", 0.)
	sprite.material = mat

	sprite.position = Vector2((viewport_size.x / 2.), 382.)

	add_child(sprite)

	from_label.text = "%s\nCompra a carta:" % name_to
	to_label.text = "De:\n%s" % name_from

	await get_tree().create_timer(1.5).timeout

	from_label.text = ""
	to_label.text = ""

	sprite.queue_free()

	if player_in_turn == GameState.local_player_id:
		parent.activate_selection.emit()


func _animate_negate_card(card: CardData, name_from: String, name_to: String) -> void:
	var sprite_size: Vector2i = deck_manager.get_card_size()
	var rect_origin: Vector2i = deck_manager.get_rect_for(card)
	var region: Rect2 = Rect2(rect_origin, sprite_size)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _create_card_texture(region)
	sprite.region_rect = region
	sprite.name = "SubtractingCardSprite"

	sprite.scale *= 2.

	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = card_shader
	mat.set_shader_parameter("outline_color", Vector3(0.98, 0.184, 0.39))
	mat.set_shader_parameter("angle", 0.)
	sprite.material = mat

	sprite.position = Vector2((viewport_size.x / 2.), 382.)

	add_child(sprite)

	from_label.text = "%s\nPassa a vez ao comprar:" % name_to
	from_label.add_theme_font_size_override("font_size", 15)
	to_label.text = "De:\n%s" % name_from

	await get_tree().create_timer(1.5).timeout

	from_label.text = ""
	to_label.text = ""

	sprite.queue_free()


func _create_card_texture(region: Rect2, padding: int = 4) -> Texture2D:
	var atlas: Texture2D = cards_texture
	var atlas_img: Image = atlas.get_image()

	var width: int = int(region.size.x) + padding * 2
	var height: int = int(region.size.y) + padding * 2

	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	img.blit_rect(
		atlas_img,
		region,
		Vector2i(padding, padding),
	)

	var tex := ImageTexture.create_from_image(img)
	return tex
