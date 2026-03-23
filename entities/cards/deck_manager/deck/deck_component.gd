class_name DeckComponent
extends Node

const CARD_SIZE := Vector2i(32, 48)

var number_and_suit_to_rect: Dictionary[String, Vector2i] = {
	"1Spade": Vector2i(1, 1),
	"1Diamond": Vector2i(34, 1),
	"1Club": Vector2i(67, 1),
	"2Spade": Vector2i(1, 50),
	"2Diamond": Vector2i(34, 50),
	"2Club": Vector2i(67, 50),
	"2Hearts": Vector2i(100, 50),
	"3Spade": Vector2i(1, 99),
	"3Diamond": Vector2i(34, 99),
	"3Club": Vector2i(67, 99),
	"3Hearts": Vector2i(100, 99),
	"1Hearts": Vector2i(100, 1),
	"4Spade": Vector2i(133, 1),
	"4Diamond": Vector2i(166, 1),
	"4Club": Vector2i(199, 1),
	"4Hearts": Vector2i(232, 1),
	"5Spade": Vector2i(133, 50),
	"5Diamond": Vector2i(166, 50),
	"5Club": Vector2i(199, 50),
	"5Hearts": Vector2i(232, 50),
	"6Spade": Vector2i(133, 99),
	"6Diamond": Vector2i(166, 99),
	"6Club": Vector2i(199, 99),
	"6Hearts": Vector2i(232, 99),
	"7Spade": Vector2i(265, 1),
	"7Diamond": Vector2i(298, 1),
	"7Club": Vector2i(331, 1),
	"7Hearts": Vector2i(364, 1),
	"8Spade": Vector2i(265, 50),
	"8Diamond": Vector2i(298, 50),
	"8Club": Vector2i(331, 50),
	"8Hearts": Vector2i(364, 50),
}


func get_rect(card_number: int, card_suit: String) -> Vector2i:
	var key := "%d%s" % [card_number, card_suit]
	return number_and_suit_to_rect.get(key, Vector2i(-1, -1))


func get_all_keys(number_of_players: int) -> Array[String]:
	match number_of_players:
		3:
			var keys: Array[String] = []
			for k in number_and_suit_to_rect.keys():
				if int(k[0]) > 6:
					continue
				keys.append(k)
			return keys
		4:
			var keys: Array[String] = []
			for k in number_and_suit_to_rect.keys():
				keys.append(k)
			return keys
		_:
			return []


func is_valid(card_number: int, card_suit: String) -> bool:
	return number_and_suit_to_rect.has("%d%s" % [card_number, card_suit])
