class_name Lobby
extends Control

@onready var players_list: VBoxContainer = %PlayersList
@onready var start_button: Button = %StartButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.game_started.connect(_on_game_started)
	NetworkManager.server_error.connect(_on_server_error)
	NetworkManager.disconnected.connect(_on_disconnected)

	start_button.pressed.connect(_on_start_pressed)

	start_button.visible = GameState.is_host()
	start_button.disabled = true


func _on_lobby_updated(players: Array, host_id: int) -> void:
	GameState.host_id = host_id
	GameState.players = players

	start_button.visible = GameState.is_host()

	start_button.disabled = players.size() < 2

	status_label.text = "Aguardando jogadores... (%d/4)" % players.size()

	_refresh_player_list(players)


func _refresh_player_list(players: Array) -> void:
	for child in players_list.get_children():
		child.queue_free()

	for p in players:
		var label := Label.new()
		var suffix := " (você)" if p["id"] == GameState.local_player_id else ""
		var host_mark := " ★" if p["id"] == GameState.host_id else ""
		label.text = "%s%s%s" % [p["name"], host_mark, suffix]
		players_list.add_child(label)


func _on_start_pressed() -> void:
	start_button.disabled = true
	NetworkManager.send(NetworkMessageBuilder.start_game())


func _on_game_started(_players: Array, _host_id: int) -> void:
	get_tree().change_scene_to_file("res://ui/board/board_manager.tscn")


func _on_player_left(_player_id: int, name_: String) -> void:
	status_label.text = " %s saiu da sala." % name_


func _on_server_error(reason: String) -> void:
	start_button.disabled = false
	status_label.text = "Erro: %s" % reason


func _on_disconnected() -> void:
	get_tree().change_scene_to_file(
		"res://ui/login/login.tscn",
	)
