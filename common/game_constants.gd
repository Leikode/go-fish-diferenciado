extends Node

const START_NUMBER_OF_CARDS: int = 8
const CARD_SUITS: Array[String] = ["Spade", "Diamond", "Club", "Hearts"]

const SCALE_MULTIPLIER: float = 3.
const CARD_Y_OFFSET: float = 920.
const CARD_ANIMATION_TIMER_WAIT_TIME: float = 1.5

const SERVER_URL := "ws://186.202.209.213:8080/ws"
