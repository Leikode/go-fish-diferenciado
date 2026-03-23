class_name Login
extends Control

@onready var name_input: LineEdit = %NameInput
@onready var connect_button: Button = %ConnectButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	NetworkManager.connected.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.joined.connect(_on_joined)
	NetworkManager.server_error.connect(_on_server_error)

	connect_button.pressed.connect(_on_connect_pressed)


func _on_connect_pressed() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name.is_empty():
		status_label.text = "Digite um nome!"
		return

	connect_button.disabled = true
	status_label.text = "Conectando..."
	GameState.local_name = player_name
	NetworkManager.connect_to_server(player_name)


func _on_connected() -> void:
	status_label.text = "Conectado! Entrando na sala..."


func _on_connection_failed() -> void:
	connect_button.disabled = false
	status_label.text = "Falha na conexão. Tente novamente."


func _on_joined(player_id: int, _players: Array) -> void:
	GameState.local_player_id = player_id
	get_tree().change_scene_to_file("res://ui/lobby/lobby.tscn")


func _on_server_error(reason: String) -> void:
	connect_button.disabled = false
	status_label.text = "Erro: %s" % reason
