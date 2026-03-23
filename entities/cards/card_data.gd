class_name CardData
extends RefCounted

var number: int
var suit: String


func _init(p_number: int, p_suit: String) -> void:
	number = p_number
	suit = p_suit


func to_key() -> String:
	return "%d%s" % [number, suit]


static func from_key(key: String) -> CardData:
	var n := key.left(1).to_int()
	var s := key.substr(1)
	return CardData.new(n, s)
