class_name InspectBoardComponent
extends Node2D

const COLLISION_MASK_CARD: int = 3
var screen_size


func _ready() -> void:
	screen_size = get_viewport_rect().size
	set_process_input(false)


func _exit_tree() -> void:
	set_process_input(false)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				print("CLICOU NO OPONENTE")


func raycast_check_for_card():
	var space_state: PhysicsDirectSpaceState2D = get_viewport().world_2d.direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider
	return null
