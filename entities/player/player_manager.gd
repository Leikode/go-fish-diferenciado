class_name PlayerManager
extends Node2D

var player_id: int = -1
var player_name: String = ""

@onready var render_hand_component: RenderHandComponent = %RenderHandComponent
@onready var inspect_hand_component: InspectHandComponent = %InspectHandComponent
@onready var player_hand: PlayerHand = %PlayerHand


func _ready() -> void:
	render_hand_component.setup(self)
	inspect_hand_component.setup(self)
	player_hand.setup(self)


func receive_cards(cards: Array[CardData], deck_manager: DeckManager) -> void:
	render_hand_component.receive_cards(cards, deck_manager)
	player_hand.reset_signals()


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
