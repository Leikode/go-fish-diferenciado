class_name Card
extends Node2D

@onready var card_area: Area2D = %CardArea

var card: CardData

var texture_size: Vector2

signal hovered_on(card: Card)
signal hovered_off(card: Card)


func _ready() -> void:
	card_area.mouse_entered.connect(_on_card_area_mouse_entered)
	card_area.mouse_exited.connect(_on_card_area_mouse_exited)
	texture_size = Vector2(96., 144.)


func _process(_delta: float) -> void:
	var sprite: Sprite2D = get_node("CardSprite")
	var world_pos: Vector2 = get_global_mouse_position()
	var selection_rect: Rect2 = Rect2(position - (texture_size / 2.), texture_size)
	if selection_rect.has_point(world_pos):
		sprite.material.set_shader_parameter("mouse_uv", get_uv_from_world_pos(world_pos))


func get_uv_from_world_pos(world_pos: Vector2) -> Vector2:
	var top_left: Vector2 = position - (texture_size / 2.)
	var uv: Vector2 = (world_pos - top_left) / texture_size
	return uv


func _on_card_area_mouse_entered() -> void:
	hovered_on.emit(self)
	set_process(true)


func _on_card_area_mouse_exited() -> void:
	hovered_off.emit(self)
	set_process(false)

	var sprite: Sprite2D = get_node("CardSprite")
	sprite.material.set_shader_parameter("mouse_uv", Vector2(-1., -1.))
