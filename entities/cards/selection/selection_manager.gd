class_name SelectionManager
extends Node2D

@onready var render_selection_component: RenderSelectionComponent = %RenderSelectionComponent

signal activate_input_for_selection(only_numbers: bool)
signal fade_others(selected: String)
signal trigger_select_player(number: int, suit: String)

var selected_number: int = -1
var selected_suit: String = ""


func _ready() -> void:
	fade_others.connect(_on_fade_others)


func handle_selection():
	selected_number = -1
	selected_suit = ""
	render_selection_component.render_selection()
	activate_input_for_selection.emit(true)


func _on_fade_others(selected: String) -> void:
	render_selection_component.fade_others(selected)
