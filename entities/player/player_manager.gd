class_name PlayerManager
extends Node2D

var player_id: int = -1
var player_name: String = ""

@export var hand_component: HandComponent


func _ready() -> void:
	hand_component.setup(player_id)


func receive_cards(cards: Array[CardData], deck_manager: DeckManager) -> void:
	hand_component.receive_cards(cards, deck_manager)


func add_card(card: CardData, deck_manager: DeckManager) -> void:
	hand_component.add_card(card, deck_manager)


func remove_card(card: CardData, deck_manager: DeckManager) -> void:
	hand_component.remove_card(card, deck_manager)


func get_hand() -> Array[CardData]:
	return hand_component.get_cards()


func get_hand_keys() -> Array[String]:
	return hand_component.get_card_keys()
