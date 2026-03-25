class_name RenderSelectionComponent
extends Node2D

func render_selection() -> void:
	var parent: Selection = get_parent()
	parent.visible = true

	for child in get_parent().get_children():
		var child_name: String = child.name
		if child_name.contains("Number"):
			child.visible = true


func fade_others(selected: String) -> void:
	var is_number: bool = true if selected.contains("Number") else false

	var affected_nodes: Array[SelectionSpriteHandler] = []

	var selected_node: SelectionSpriteHandler
	for child in get_parent().get_children():
		var child_name: String = child.name

		if child_name == selected:
			selected_node = child
		if child_name != selected:
			if (
				(child_name.contains("Number") and is_number)
				or (child_name.contains("Suit") and !is_number)
			):
				affected_nodes.append(child)

	var tween: Tween = create_tween()
	tween.set_parallel()
	for selection_card in affected_nodes:
		selection_card.burn_card(tween)
		selection_card.set_process_input(false)

	get_parent().get_node(selected).highlight_card(is_number, tween)

	selected_node.set_process_input(false)

	for child in get_parent().get_children():
		var child_name: String = child.name
		if child_name.contains("Suit") and !child.visible:
			child.visible = true
			child.set_process_input(true)
