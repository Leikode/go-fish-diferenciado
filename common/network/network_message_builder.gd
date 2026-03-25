class_name NetworkMessageBuilder
extends RefCounted

static func join(player_name: String) -> Dictionary:
	return { "action": "join", "name": player_name }


static func start_game() -> Dictionary:
	return { "action": "start_game" }


static func play_card(card_key: String) -> Dictionary:
	return { "action": "card_played", "card": card_key, "to": "others" }


static func buy_card_request(from_player_id: int, to_opponent_id: int, card_key: String) -> Dictionary:
	return { "action": "buy_card_request", "card": card_key, "from": from_player_id, "to": to_opponent_id }


static func buy_card_response(player_in_turn: int, affected_player_id: int, card_key: String, accepted: bool) -> Dictionary:
	return { "action": "buy_card_response", "card": card_key, "accepted": accepted, "to": "others", "from": affected_player_id, "player_in_turn": player_in_turn }


static func game_state(hand: Array[String]) -> Dictionary:
	return { "action": "game_state", "hand": hand, "to": "others" }


static func report_number_of_cards(from: int, number_of_cards: int) -> Dictionary:
	return { "action": "number_of_cards", "from": from, "value": number_of_cards, "to": "others" }
