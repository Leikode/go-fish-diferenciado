class_name Card
extends Node2D

@onready var card_area: Area2D = %CardArea

var card: CardData

signal hovered_on(card: Card)
signal hovered_off(card: Card)


func _ready() -> void:
	card_area.mouse_entered.connect(_on_card_area_mouse_entered)
	card_area.mouse_exited.connect(_on_card_area_mouse_exited)


func _on_card_area_mouse_entered() -> void:
	hovered_on.emit(self)


func _on_card_area_mouse_exited() -> void:
	hovered_off.emit(self)
