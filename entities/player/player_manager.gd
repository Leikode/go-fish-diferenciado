class_name PlayerManager
extends Node2D

var player_id: int = -1
var player_name: String = ""
var points: int = 0

@onready var render_hand_component: RenderHandComponent = %RenderHandComponent
@onready var inspect_hand_component: InspectHandComponent = %InspectHandComponent
@onready var player_hand: PlayerHand = %PlayerHand


func _ready() -> void:
	render_hand_component.setup(self)
	inspect_hand_component.setup(self)
	player_hand.setup(self)


func receive_cards(cards: Array[CardData], deck_manager: DeckManager) -> void:
	cards = _check_for_points(cards)
	render_hand_component.receive_cards(cards, deck_manager)
	player_hand.reset_signals()
	NetworkManager.send(
		NetworkMessageBuilder.report_number_of_cards(GameState.local_player_id, cards.size()),
	)


func add_card(card: CardData, deck_manager: DeckManager) -> void:
	render_hand_component.add_card(card, deck_manager)
	player_hand.reset_signals()


func remove_card(card: CardData, deck_manager: DeckManager) -> void:
	render_hand_component.remove_card(card, deck_manager)
	player_hand.reset_signals()


func on_hovered_on(card: Card) -> void:
	inspect_hand_component.card_highlight_on(card)


func on_hovered_off(card: Card) -> void:
	inspect_hand_component.card_highlight_off(card)


func _check_for_points(cards: Array[CardData]) -> Array[CardData]:
	cards.sort_custom(func(a, b): return a.number < b.number)

	var number: int = -1
	var count: int = 0
	var numbers_to_remove: Array[int] = []
	for card in cards:
		if number == -1:
			number = card.number
		if card.number != number:
			count = 0
		count += 1

		if count == 4:
			points += 1
			numbers_to_remove.append(number)

	var result: Array[CardData] = []
	for card in cards:
		if card.number not in numbers_to_remove:
			result.append(card)

	return result
