class_name RenderSelectionComponent
extends Node2D

# TODO: Achar quem está pontuado e tirar da exibição
var out_numbers: Array[String] = []


func render_selection() -> void:
	var parent: SelectionManager = get_parent()
	parent.visible = true

	for child in get_parent().get_children():
		var child_name: String = child.name

		if child_name.contains("Number") or child_name.contains("Suit"):
			child.material.set_shader_parameter("radius", 0.)
			child.material.set_shader_parameter("is_selected", false)

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
		selection_card.set_process(false)

	get_parent().get_node(selected).highlight_card(is_number, tween)

	selected_node.set_process_input(false)
	selected_node.set_process(false)
	selected_node.material.set_shader_parameter("mouse_uv", Vector2(-1., -1.))
	selected_node.material.set_shader_parameter("is_selected", true)

	for child in get_parent().get_children():
		var child_name: String = child.name
		if child_name.contains("Suit") and !child.visible:
			child.visible = true
			child.set_process_input(true)
			child.set_process(true)

	if !is_number:
		var parent: SelectionManager = get_parent()
		parent.trigger_select_player.emit(
			parent.selected_number,
			parent.selected_suit,
		)
