class_name HandComponent
extends Node2D

@export var cards_texture: Texture2D

@onready var card_shader: Shader = preload("res://entities/player/hand/art/card.gdshader")

var _cards: Array[CardData] = []
var _card_cache := { }
var _player_id: int = -1

signal card_selected(card: CardData, player_id: int)

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var side_offset: float = 120.
@export var max_rotation_deg: float = 5.
@export var x_sep: float = -10.
@export var y_min: float = .0
@export var y_max: float = -15.

var hand_width: float
const SCALE_MULTIPLIER: float = 3.
var viewport_size: Vector2


func setup(player_id: int) -> void:
	_player_id = player_id
	viewport_size = DisplayServer.window_get_size()


func receive_cards(cards: Array[CardData], deck_manager: DeckManager) -> void:
	_cards = cards
	_render_hand(deck_manager)


func add_card(card: CardData, deck_manager: DeckManager) -> void:
	_cards.append(card)
	_render_hand(deck_manager)


func remove_card(card: CardData, deck_manager: DeckManager) -> void:
	_cards = _cards.filter(func(c): return c.to_key() != card.to_key())
	_render_hand(deck_manager)


func get_cards() -> Array[CardData]:
	return _cards.duplicate()


func get_card_keys() -> Array[String]:
	var keys: Array[String] = []
	for c in _cards:
		keys.append(c.to_key())
	return keys


func has_card(card: CardData) -> bool:
	for c in _cards:
		if c.to_key() == card.to_key():
			return true
	return false


func _render_hand(deck_manager: DeckManager) -> void:
	for child in get_children():
		child.queue_free()

	var card_size: Vector2i = deck_manager.get_card_size()
	var count: int = _cards.size()

	hand_width = (count * card_size.x * SCALE_MULTIPLIER) + ((count - 1.) * x_sep)

	var hand_total_width: float = (viewport_size.x - (2. * side_offset))

	var final_x_sep: float = x_sep
	if hand_width > hand_total_width:
		final_x_sep = (hand_total_width - (card_size.x * SCALE_MULTIPLIER * count)) / (count - 1.)
		hand_width = hand_total_width

	var new_side_offset: float = viewport_size.x - (hand_width + (card_size.x * SCALE_MULTIPLIER))

	for i in count:
		var card: CardData = _cards[i]
		var rect_origin: Vector2i = deck_manager.get_rect_for(card)
		var region: Rect2 = Rect2(rect_origin, card_size)

		var sprite := Sprite2D.new()

		sprite.texture = _get_card_texture(card, region)

		var mat := ShaderMaterial.new()
		mat.shader = card_shader
		sprite.material = mat

		sprite.scale = Vector2(SCALE_MULTIPLIER, SCALE_MULTIPLIER)

		var pos: float = (1. / (count - 1.)) * i

		var y_multiplier: float = hand_curve.sample(pos)
		var rot_multiplier: float = rotation_curve.sample(pos)

		if count == 1:
			y_multiplier = 0.
			rot_multiplier = 0.

		var final_x: float = (new_side_offset * 1.5) + (card_size.x * SCALE_MULTIPLIER * i) + (final_x_sep * i)
		var final_y: float = y_min + (y_max * y_multiplier) + 1000.

		sprite.position = Vector2(final_x, final_y)
		sprite.rotation_degrees = max_rotation_deg * rot_multiplier

		sprite.name = card.to_key()
		sprite.set_meta("card_data", card)

		add_child(sprite)


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
