class_name NetworkMessageParser
extends RefCounted

static func parse(msg: Dictionary) -> void:
	var action: String = msg.get("action", "")

	match action:
		"joined":
			GameState.local_player_id = msg.get("player_id", -1)
			GameState.players = msg.get("players", [])
			NetworkManager.joined.emit(GameState.local_player_id, GameState.players)
		"lobby_update":
			GameState.players = msg.get("players", [])
			GameState.host_id = msg.get("host_id", -1)
			NetworkManager.lobby_updated.emit(GameState.players, GameState.host_id)
		"player_joined":
			NetworkManager.player_joined.emit(
				msg.get("player_id", -1),
				msg.get("name", ""),
			)
		"player_left":
			GameState.players = msg.get("players", [])
			NetworkManager.player_left.emit(
				msg.get("player_id", -1),
				msg.get("name", ""),
			)
		"game_start":
			GameState.players = msg.get("players", [])
			GameState.host_id = msg.get("host_id", -1)
			NetworkManager.game_started.emit(GameState.players, GameState.host_id)
		"error":
			NetworkManager.server_error.emit(msg.get("reason", "Erro desconhecido."))
		_:
			NetworkManager.message_received.emit(msg)
