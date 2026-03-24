class_name RenderSelectionComponent
extends Node2D

func render_selection() -> void:
	var parent: Selection = get_parent()
	parent.visible = true
