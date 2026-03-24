class_name Selection
extends Node2D

@onready var render_selection_component: RenderSelectionComponent = %RenderSelectionComponent


func handle_selection():
	render_selection_component.render_selection()
