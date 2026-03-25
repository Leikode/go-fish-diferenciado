class_name PlayerHand
extends Node2D

var _parent: PlayerManager


func setup(parent_node: PlayerManager) -> void:
	_parent = parent_node


func reset_signals() -> void:
	for child in get_children():
		child.hovered_on.connect(
			_parent.on_hovered_on,
		)
		child.hovered_off.connect(
			_parent.on_hovered_off,
		)
