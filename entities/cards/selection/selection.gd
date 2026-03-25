class_name Selection
extends Node2D

@onready var render_selection_component: RenderSelectionComponent = %RenderSelectionComponent

signal activate_input_for_selection(only_numbers: bool)
signal fade_others(selected: String)


func _ready() -> void:
	fade_others.connect(_on_fade_others)


func handle_selection():
	render_selection_component.render_selection()
	activate_input_for_selection.emit(true)


func _on_fade_others(selected: String) -> void:
	render_selection_component.fade_others(selected)
