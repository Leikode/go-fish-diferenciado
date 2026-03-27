class_name InspectBoardComponent
extends Node2D

const COLLISION_MASK_CARD: int = 3
var screen_size

var current_selected_card: CardData = CardData.new(-1, "")

signal selected_opponent(opponent: OpponentManager, card: CardData)


func _ready() -> void:
	screen_size = get_viewport_rect().size
	set_process_input(false)


func _exit_tree() -> void:
	set_process_input(false)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card: Variant = raycast_check_for_card()
			if card and is_instance_of(card, OpponentHandArea) and current_selected_card.number != -1:
				var opponent: OpponentManager = card.get_parent()
				selected_opponent.emit(opponent, current_selected_card)
				current_selected_card = CardData.new(-1, "")
				set_process_input(false)


func raycast_check_for_card() -> Variant:
	var space_state: PhysicsDirectSpaceState2D = get_viewport().world_2d.direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider
	return null


func on_opponent_selection(number: int, suit: String) -> void:
	var card: CardData = CardData.new(number, suit)
	current_selected_card = card
	set_process_input(true)
