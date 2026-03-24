class_name OpponentManager
extends Control

@onready var opponent_hand: RenderOpponentHandComponent = %RenderOpponentHandComponent
@onready var opponent_hand_area: OpponentHandArea = %OpponentHandArea

var opponent_id: int = -1
var opponent_name: String = "Silva e Silva"
var number_of_cards: int = -1
var points: int = 0


func display_number_of_cards(direction: Vector2) -> void:
	opponent_hand.render_hand(opponent_name, direction, number_of_cards)
