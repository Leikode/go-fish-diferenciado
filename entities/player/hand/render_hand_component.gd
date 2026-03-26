class_name RenderHandComponent
extends Node2D

@onready var cards_texture: Texture2D = preload("res://entities/cards/art/Pixel_Playing_Card_Set_updated.svg")
@onready var card_shader: Shader = preload("res://entities/cards/art/card.gdshader")

var _cards: Array[CardData] = []
var _card_cache := { }

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var side_offset: float = 120.
@export var max_rotation_deg: float = 5.
@export var x_sep: float = -10.
@export var y_min: float = .0
@export var y_max: float = -15.

var hand_width: float
var viewport_size: Vector2

var _parent: PlayerManager

var colors: Dictionary[int, Vector3] = {
	1: Vector3(
		0.2,
		0.5,
		0.9,
	),
	2: Vector3(
		0.1,
		0.7,
		0.8,
	),
	3: Vector3(
		0.3,
		0.8,
		0.7,
	),
	4: Vector3(
		0.15,
		0.4,
		0.75,
	),
	5: Vector3(
		0.4,
		0.65,
		0.95,
	),
	6: Vector3(
		0.1,
		0.55,
		0.6,
	),
	7: Vector3(
		0.5,
		0.3,
		0.9,
	),
	8: Vector3(
		0.2,
		0.75,
		0.55,
	),
}


func setup(player_manager: PlayerManager) -> void:
	_parent = player_manager
	viewport_size = get_viewport().get_visible_rect().size


func receive_cards(cards: Array[CardData], deck_manager: DeckManager) -> void:
	_cards = cards
	_render_hand(deck_manager)


func add_card(from: int, card: CardData, deck_manager: DeckManager) -> Array[CardData]:
	_cards.append(card)
	_cards.sort_custom(func(a, b): return a.number < b.number)
	_render_hand(deck_manager)

	return _cards


func remove_card(from: int, card: CardData, deck_manager: DeckManager) -> Array[CardData]:
	_cards = _cards.filter(func(c): return c.to_key() != card.to_key())
	_cards.sort_custom(func(a, b): return a.number < b.number)
	_render_hand(deck_manager)

	return _cards


func _render_hand(deck_manager: DeckManager) -> void:
	for child in _parent.player_hand.get_children():
		child.queue_free()

	var card_size: Vector2i = deck_manager.get_card_size()
	var count: int = _cards.size()

	hand_width = (count * card_size.x * GameConstants.SCALE_MULTIPLIER) + ((count - 1.) * x_sep)

	var hand_total_width: float = (viewport_size.x - (2. * side_offset))

	var final_x_sep: float = x_sep
	if hand_width > hand_total_width:
		final_x_sep = (hand_total_width - (card_size.x * GameConstants.SCALE_MULTIPLIER * count)) / (count - 1.)
		hand_width = hand_total_width

	var new_side_offset: float = ((viewport_size.x - hand_width + (card_size.x * GameConstants.SCALE_MULTIPLIER)) / 2.)

	for i in count:
		var card: CardData = _cards[i]
		var rect_origin: Vector2i = deck_manager.get_rect_for(card)
		var region: Rect2 = Rect2(rect_origin, card_size)

		var card_node: Card = deck_manager.card_scene.instantiate()

		var sprite := Sprite2D.new()
		sprite.name = "CardSprite"

		sprite.texture = _get_card_texture(card, region)

		var mat: ShaderMaterial = ShaderMaterial.new()
		mat.shader = card_shader
		mat.set_shader_parameter("outline_color", colors[card.number])
		sprite.material = mat

		sprite.scale = Vector2(GameConstants.SCALE_MULTIPLIER, GameConstants.SCALE_MULTIPLIER)

		var pos: float = (1. / (count - 1.)) * i

		var y_multiplier: float = hand_curve.sample(pos)
		var rot_multiplier: float = rotation_curve.sample(pos)

		if count == 1:
			y_multiplier = 0.
			rot_multiplier = 0.

		var final_x: float = new_side_offset + (card_size.x * GameConstants.SCALE_MULTIPLIER * i) + (final_x_sep * i)
		var final_y: float = y_min + (y_max * y_multiplier) + GameConstants.CARD_Y_OFFSET

		card_node.position = Vector2(final_x, final_y)
		card_node.rotation_degrees = max_rotation_deg * rot_multiplier

		card_node.name = card.to_key()
		card_node.card = card
		card_node.add_child(sprite)

		_parent.player_hand.add_child(card_node)


func _get_card_texture(card, region: Rect2) -> Texture2D:
	var key = card.to_key()

	if not _card_cache.has(key):
		_card_cache[key] = _create_card_texture(region, 4)

	return _card_cache[key]


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
