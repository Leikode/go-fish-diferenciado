class_name Card
extends Node2D

@onready var card_area: Area2D = %CardArea
@onready var card_animation_timer: Timer = %CardAnimationTimer

var card: CardData

signal hovered_on(card: Card)
signal hovered_off(card: Card)
signal hovered_card_animation(card: Card)
signal reset_card_animation(card: Card)


func _ready() -> void:
	card_area.mouse_entered.connect(_on_card_area_mouse_entered)
	card_area.mouse_exited.connect(_on_card_area_mouse_exited)
	card_animation_timer.wait_time = GameConstants.CARD_ANIMATION_TIMER_WAIT_TIME
	card_animation_timer.timeout.connect(_on_card_timeout)


func _on_card_area_mouse_entered() -> void:
	hovered_on.emit(self)
	card_animation_timer.start()


func _on_card_area_mouse_exited() -> void:
	hovered_off.emit(self)
	if !card_animation_timer.is_stopped():
		card_animation_timer.stop()
	reset_card_animation.emit(self)


func _on_card_timeout() -> void:
	hovered_card_animation.emit(self)
