extends Node

var _socket := WebSocketPeer.new()
var _connected := false
var _pending_name := ""

# conexão
signal connected()
signal disconnected()
signal connection_failed()

# lobby
signal joined(player_id: int, players: Array)
signal player_joined(player_id: int, name: String)
signal player_left(player_id: int, name: String)
signal lobby_updated(players: Array, host_id: int)

# jogo
signal game_started(players: Array, host_id: int)

# relay — qualquer mensagem de jogo vinda de outro jogador
signal message_received(msg: Dictionary)

# erro
signal server_error(reason: String)


func _ready() -> void:
	set_process(true)


func connect_to_server(player_name: String) -> void:
	_pending_name = player_name
	var err := _socket.connect_to_url(GameConstants.SERVER_URL)
	if err != OK:
		connection_failed.emit()


func _process(_delta: float) -> void:
	_socket.poll()

	match _socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				_connected = true
				connected.emit()
				send(NetworkMessageBuilder.join(_pending_name))

			while _socket.get_available_packet_count() > 0:
				var raw := _socket.get_packet().get_string_from_utf8()
				var msg: Dictionary = JSON.parse_string(raw)
				if msg:
					NetworkMessageParser.parse(msg)
		WebSocketPeer.STATE_CLOSED:
			if _connected:
				_connected = false
				disconnected.emit()
		WebSocketPeer.STATE_CONNECTING:
			pass


func send(payload: Dictionary) -> void:
	if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("NetworkManager: socket não está aberto")
		return
	_socket.send_text(JSON.stringify(payload))


func disconnect_from_server() -> void:
	_socket.close()
	_connected = false
