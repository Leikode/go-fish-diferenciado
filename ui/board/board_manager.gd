extends Node2D

@export var deck_manager: DeckManager
@export var selection: Selection
@export var player_scene: PackedScene
@export var opponent_scene: PackedScene

@onready var inspect_board_component: InspectBoardComponent = %InspectBoardComponent

var _local_player: PlayerManager
var _opponents: Dictionary[int, OpponentManager] = { }

var player_id_to_direction: Dictionary = {
	0: Vector2(0., 1.),
	1: Vector2(1., 0.),
	2: Vector2(0., -1.),
	3: Vector2(-1., 0.),
}


func _ready() -> void:
	NetworkManager.message_received.connect(_on_message_received)
	NetworkManager.disconnected.connect(_on_disconnected)
	NetworkManager.player_left.connect(_on_player_left)

	_spawn_players()

	selection.trigger_select_player.connect(
		inspect_board_component.on_opponent_selection,
	)
	inspect_board_component.selected_opponent.connect(_on_player_buy_from_opponent_request)

	if GameState.is_host():
		_host_distribute_cards()


func _exit_tree() -> void:
	NetworkManager.message_received.disconnect(_on_message_received)


func _spawn_players() -> void:
	for player in GameState.players:
		var player_id: int = player["id"]
		var player_name: String = player["name"]

		if player_id == GameState.local_player_id:
			var node: PlayerManager = player_scene.instantiate()
			node.player_id = player_id
			node.player_name = player_name
			node.name = "Player_%d" % player_id
			add_child(node)

			_local_player = node
		else:
			var node: OpponentManager = opponent_scene.instantiate()
			node.opponent_id = player_id
			node.opponent_name = player_name
			node.name = "Opponent_%d" % player_id
			add_child(node)
			_opponents[player_id] = node


func _host_distribute_cards() -> void:
	deck_manager.distribute_to(GameState.player_ids())
	_local_player.receive_cards(deck_manager.get_hand_for(GameState.local_player_id), deck_manager)

	_broadcast_start_hand()
	_handle_player_turn(GameState.local_player_id)


func _broadcast_start_hand() -> void:
	for opponent_id in _opponents:
		if opponent_id == GameState.local_player_id:
			continue

		NetworkManager.send(
			{
				"action": "start_hand",
				"hand": deck_manager.get_hand_keys_for(opponent_id),
				"to": opponent_id,
			},
		)


func _on_message_received(msg: Dictionary) -> void:
	match msg.get("action", ""):
		"start_hand":
			_handle_start_hand(msg.get("hand", []))
		"number_of_cards":
			_display_opponent_number_of_cards(
				int(msg.get("from")),
				int(msg.get("value")),
			)
		"player_turn":
			_handle_player_turn(
				int(msg.get("player_in_turn")),
			)
		"buy_card_request":
			_evaluate_player_buy_request(
				int(msg.get("from")),
				msg.get("card"),
			)
		"buy_card_response":
			_handle_buy_card_response(
				int(msg.get("from")),
				int(msg.get("player_in_turn")),
				msg.get("card"),
				msg.get("accepted"),
			)


func _handle_start_hand(hand_keys: Array) -> void:
	if GameState.is_host():
		return

	var cards: Array[CardData] = []
	for key in hand_keys:
		cards.append(CardData.from_key(key))
		deck_manager.card_owner[key] = GameState.local_player_id

	_local_player.receive_cards(cards, deck_manager)
	_set_board_shader_direction(1)


func _display_opponent_number_of_cards(opponent_id: int, number_of_cards: int) -> void:
	var opponent: OpponentManager = _opponents[opponent_id]
	opponent.number_of_cards = number_of_cards
	opponent.display_number_of_cards(
		player_id_to_direction[(GameState.local_player_id - opponent_id + 4) % 4],
	)


func _set_board_shader_direction(current_player_id: int):
	var local_player_id: int = GameState.local_player_id

	var bg_node: ColorRect = get_node("CanvasLayer/BoardBG")
	if current_player_id == local_player_id:
		var speed: float = (_local_player.points + 1.) * 0.5
		bg_node.material.set_shader_parameter("speed", speed)
	else:
		var speed: float = (_opponents[current_player_id].points + 1.) * 0.5
		bg_node.material.set_shader_parameter("speed", speed)

	bg_node.material.set_shader_parameter(
		"direction",
		player_id_to_direction[(local_player_id - current_player_id + 4) % 4],
	)


func _handle_player_turn(player_in_turn: int) -> void:
	_set_board_shader_direction(player_in_turn)
	if GameState.local_player_id != player_in_turn:
		return

	selection.handle_selection()


func _evaluate_player_buy_request(player_in_turn: int, card: String) -> void:
	var parsed_card: CardData = CardData.from_key(card)
	var player_has_card: bool = _local_player.evaluate_buy_request_from_opponent(
		player_in_turn,
		parsed_card,
		deck_manager,
	)

	NetworkManager.send(
		NetworkMessageBuilder.buy_card_response(
			player_in_turn,
			GameState.local_player_id,
			card,
			player_has_card,
		),
	)


func _on_player_buy_from_opponent_request(opponent: OpponentManager, card: CardData) -> void:
	NetworkManager.send(
		NetworkMessageBuilder.buy_card_request(
			GameState.local_player_id,
			opponent.opponent_id,
			card.to_key(),
		),
	)


func _handle_buy_card_response(
		from: int,
		player_in_turn: int,
		card: String,
		accepted: bool,
) -> void:
	if GameState.local_player_id == player_in_turn:
		if !accepted:
			NetworkManager.send(
				{
					"action": "player_turn",
					"player_in_turn": (GameState.local_player_id % GameState.players.size()) + 1,
				},
			)
		else:
			_local_player.add_card(from, CardData.from_key(card), deck_manager)
	else:
		for opponent in _opponents.values():
			if opponent.opponent_id != player_in_turn and opponent.opponent_id != from:
				opponent.handle_other_players_buy_response(
					from,
					player_in_turn,
					CardData.from_key(card),
					accepted,
				)


func _on_player_left(player_id: int, _name: String) -> void:
	var opponent: OpponentManager = _opponents.get(player_id)
	if opponent:
		opponent.queue_free()
		_opponents.erase(player_id)


func _on_disconnected() -> void:
	get_tree().change_scene_to_file("res://ui/login/login.tscn")
