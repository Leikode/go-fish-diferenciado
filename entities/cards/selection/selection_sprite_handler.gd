extends Sprite2D

var texture_size: Vector2 = Vector2()


func _ready():
	if texture:
		texture_size = Vector2(64., 96.)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var world_pos: Vector2 = get_global_mouse_position()
		var selection_rect: Rect2 = Rect2(position - (texture_size / 2.), texture_size)
		if selection_rect.has_point(world_pos):
			var uv: Vector2 = get_uv_from_click(world_pos)
			burn_card(uv)


func get_uv_from_click(world_click_pos: Vector2) -> Vector2:
	var top_left: Vector2 = position - (texture_size / 2.)
	var uv: Vector2 = (world_click_pos - top_left) / texture_size
	return uv


func burn_card(uv):
	if material and material is ShaderMaterial:
		var tween: Tween = create_tween()
		material.set_shader_parameter("position", uv)
		tween.tween_method(update_radius, 0.0, 2.0, 1.5)


func update_radius(value: float):
	if material:
		material.set_shader_parameter("radius", value)
