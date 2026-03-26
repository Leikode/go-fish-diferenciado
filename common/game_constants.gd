extends Node

const START_NUMBER_OF_CARDS: int = 8
const CARD_SUITS: Array[String] = ["Spade", "Diamond", "Club", "Hearts"]

const SCALE_MULTIPLIER: float = 3.
const CARD_Y_OFFSET: float = 920.
const CARD_ANIMATION_TIMER_WAIT_TIME: float = 1.5

const OPPONENT_CARDS_RECT: Vector2i = Vector2i(364, 99)
const OPPONENT_CARDS_SIZE: Vector2i = Vector2i(32, 48)
const OPPONENT_CARDS_OFFSET: Vector2 = Vector2(640.0, 360.0)

const SERVER_URL: String = "ws://186.202.209.213:8080/ws"
const GAME_FONT: Theme = preload("res://common/fonts/game_font.tres")
