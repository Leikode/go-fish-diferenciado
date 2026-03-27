class_name RenderOpponentHandComponent
extends Node2D

@onready var cards_texture: Texture2D = preload("res://entities/cards/art/Pixel_Playing_Card_Set_updated.svg")
@onready var card_shader: Shader = preload("res://entities/cards/art/card.gdshader")

var cards_label: Label = null


func render_hand(name_: String, direction: Vector2, number_of_cards: int) -> void:
	var rect_origin: Vector2i = GameConstants.OPPONENT_CARDS_RECT
	var card_size: Vector2i = GameConstants.OPPONENT_CARDS_SIZE
	var region: Rect2 = Rect2(rect_origin, card_size)

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "OpponentCardsSprite"

	sprite.texture = _create_card_texture(region)

	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = card_shader
	mat.set_shader_parameter("outline_color", Vector3(0.98, 0.184, 0.39))
	mat.set_shader_parameter("angle", 0.)
	sprite.material = mat

	sprite.scale = Vector2(GameConstants.SCALE_MULTIPLIER, GameConstants.SCALE_MULTIPLIER)

	var center_of_screen: Vector2 = get_viewport().get_visible_rect().size / 2.
	get_parent().position = Vector2(
		center_of_screen.x + (direction.x * GameConstants.OPPONENT_CARDS_OFFSET.x),
		center_of_screen.y + (direction.y * GameConstants.OPPONENT_CARDS_OFFSET.y),
	)
	get_parent().add_child(sprite)

	if !cards_label:
		_create_cards_label(name_, number_of_cards)
	else:
		_update_cards_label(name_, number_of_cards)


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


func _create_cards_label(name_: String, number_of_cards: int) -> void:
	cards_label = Label.new()
	cards_label.theme = GameConstants.GAME_FONT
	cards_label.text = "%s\nNumber of Cards: %d\nPoints: %d" % [name_, number_of_cards, get_parent().points]
	cards_label.position = Vector2(
		-((GameConstants.OPPONENT_CARDS_SIZE.x * GameConstants.SCALE_MULTIPLIER) / 2.),
		-((GameConstants.OPPONENT_CARDS_SIZE.y * GameConstants.SCALE_MULTIPLIER) / 2.) - 70.,
	)
	get_parent().add_child(cards_label)


func _update_cards_label(name_: String, number_of_cards: int) -> void:
	cards_label.text = "%s\nNumber of Cards: %d\nPoints: %d" % [name_, number_of_cards, get_parent().points]
