class_name SelectionSpriteHandler
extends Sprite2D

var texture_size: Vector2 = Vector2()
var selection_rect: Rect2


func _ready():
	set_process_input(false)
	set_process(false)
	get_parent().activate_input_for_selection.connect(_on_activate_input_for_selection)
	if texture:
		texture_size = Vector2(64., 96.)
	selection_rect = Rect2(position - (texture_size / 2.), texture_size)


func _on_activate_input_for_selection(only_numbers: bool):
	if only_numbers and name.contains("Number"):
		set_process_input(true)
		set_process(true)
	if only_numbers and name.contains("Suit"):
		visible = false


func _process(_delta: float) -> void:
	var world_pos: Vector2 = get_global_mouse_position()

	if selection_rect.has_point(world_pos):
		material.set_shader_parameter("mouse_uv", get_uv_from_world_pos(world_pos))
	else:
		material.set_shader_parameter("mouse_uv", Vector2(-1., -1.))


func get_uv_from_world_pos(world_pos: Vector2) -> Vector2:
	var top_left: Vector2 = position - (texture_size / 2.)
	var uv: Vector2 = (world_pos - top_left) / texture_size
	return uv


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var world_pos: Vector2 = get_global_mouse_position()

		if selection_rect.has_point(world_pos):
			var parent: Selection = get_parent()
			if name.contains("Number"):
				parent.selected_number = int(str(name).trim_prefix("Number"))
			else:
				parent.selected_suit = str(name).trim_prefix("Suit")
			parent.fade_others.emit(name)


func burn_card(tween: Tween):
	if material and material is ShaderMaterial:
		material.set_shader_parameter("position", Vector2(.5, .5))
		tween.tween_method(update_radius, 0.0, 2.0, 1.)
		material.set_shader_parameter("mouse_uv", Vector2(-1., -1.))


func update_radius(value: float):
	if material:
		material.set_shader_parameter("radius", value)


func highlight_card(is_number: bool, tween: Tween):
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if is_number:
		tween.tween_property(self, "position", Vector2((viewport_size.x / 2.) - texture_size.x - 4. + (texture_size.x / 2.), viewport_size.y / 2.), .08)
	else:
		tween.tween_property(self, "position", Vector2((viewport_size.x / 2.) + (texture_size.x / 2.), viewport_size.y / 2.), .08)
