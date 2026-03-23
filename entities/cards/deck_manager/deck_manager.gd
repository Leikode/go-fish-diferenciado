class_name DeckManager
extends Node

@export var card_scene: PackedScene

@onready var deck_component: DeckComponent = %DeckComponent

var card_owner: Dictionary[String, int] = { }

signal cards_distributed()


func distribute_to(player_ids: Array[int]) -> void:
	assert(player_ids.size() >= 3 and player_ids.size() <= 4, "Precisa de 3 a 4 jogadores")

	card_owner.clear()

	var all_keys: Array[String] = deck_component.get_all_keys(player_ids.size())
	all_keys.shuffle()

	for i in range(all_keys.size()):
		var player_id := player_ids[i % player_ids.size()]
		card_owner[all_keys[i]] = player_id

	cards_distributed.emit()


func get_hand_for(player_id: int) -> Array[CardData]:
	var hand: Array[CardData] = []
	for key in card_owner:
		if card_owner[key] == player_id:
			hand.append(CardData.from_key(key))
	return hand


func get_hand_keys_for(player_id: int) -> Array[String]:
	var keys: Array[String] = []
	for key in card_owner:
		if card_owner[key] == player_id:
			keys.append(key)
	return keys


func transfer_card(card: CardData, to_player_id: int) -> void:
	var key := card.to_key()
	if card_owner.has(key):
		card_owner[key] = to_player_id


func remove_card(card: CardData) -> void:
	card_owner.erase(card.to_key())


func get_rect_for(card: CardData) -> Vector2i:
	return deck_component.get_rect(card.number, card.suit)


func get_card_size() -> Vector2i:
	return DeckComponent.CARD_SIZE
