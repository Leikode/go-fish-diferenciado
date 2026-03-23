extends Node

var local_player_id: int = -1
var local_name: String = ""
var players: Array = []
var host_id: int = -1


func is_host() -> bool:
	return local_player_id == host_id


func player_ids() -> Array[int]:
	var ids: Array[int] = []
	for p in players:
		ids.append(p["id"])
	return ids


func get_player_name(player_id: int) -> String:
	for p in players:
		if p["id"] == player_id:
			return p["name"]
	return "?"


func reset() -> void:
	local_player_id = -1
	local_name = ""
	players = []
	host_id = -1
