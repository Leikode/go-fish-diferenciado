extends Node2D

@export var deck_manager: DeckManager
@export var player_scene: PackedScene
@export var opponent_scene: PackedScene

var _local_player: PlayerManager
var _opponents: Dictionary[int, OpponentManager] = { }


func _ready() -> void:
	NetworkManager.message_received.connect(_on_message_received)
	NetworkManager.disconnected.connect(_on_disconnected)
	NetworkManager.player_left.connect(_on_player_left)

	_spawn_players()

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

	_broadcast_game_state()


func _broadcast_game_state() -> void:
	for opponent_id in _opponents:
		if opponent_id == GameState.local_player_id:
			continue
		NetworkManager.send(
			{
				"action": "game_state",
				"hand": deck_manager.get_hand_keys_for(opponent_id),
				"to": opponent_id,
			},
		)


func play_card_local(card: CardData) -> void:
	_local_player.remove_card(card, deck_manager)
	deck_manager.remove_card(card)

	NetworkManager.send(NetworkMessageBuilder.play_card(card.to_key()))


func _on_message_received(msg: Dictionary) -> void:
	match msg.get("action", ""):
		"game_state":
			_handle_remote_game_state(msg.get("hand", []))


func _on_game_state() -> void:
	pass


func _handle_remote_game_state(hand_keys: Array) -> void:
	if GameState.is_host():
		return

	var cards: Array[CardData] = []
	for key in hand_keys:
		cards.append(CardData.from_key(key))
		deck_manager.card_owner[key] = GameState.local_player_id

	_local_player.receive_cards(cards, deck_manager)


func _on_player_left(player_id: int, _name: String) -> void:
	var opponent: OpponentManager = _opponents.get(player_id)
	if opponent:
		opponent.queue_free()
		_opponents.erase(player_id)


func _on_disconnected() -> void:
	get_tree().change_scene_to_file("res://ui/login/login.tscn")
