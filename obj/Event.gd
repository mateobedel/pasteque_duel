extends Node2D

signal fruit_merge(fruit_id)
signal fruit_can_merge()
signal fruit_loose
signal peer_disconnect()

signal a_player_loose(looser)
signal update_other_score(nm,scr)

signal s_launch_object(sender_id, type)
signal score_updated(scr)
signal object_button_pressed(rdm_id)

var last_score = 0
var last_capture = null
var already_loose = false

var player_looser

var first_player_score = 0
var second_player_score = 0

var first_player = 1
var second_player = 0
var current_player = 0
var current_peer

# Called when the node enters the scene tree for the first time.
func _ready():
	fruit_loose.connect(on_loose)
	a_player_loose.connect(on_a_player_loose)
	peer_disconnect.connect(on_peer_disconnect)
	multiplayer.peer_disconnected.connect(on_peer_just_disconnected)

func on_loose():
	last_capture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())


@rpc("any_peer", "call_local", "reliable")
func update_loose(looser):
	player_looser = looser
	if looser != current_player && not already_loose:
		emit_signal("a_player_loose",looser)


func on_a_player_loose(looser):
	already_loose = true
	update_loose.rpc(looser)

func start_merge_timer():
	$can_fruit_merge.start(0.1)

func on_peer_disconnect():
	current_peer.close() #yesssss
	multiplayer.set_multiplayer_peer(null)
	get_tree().change_scene_to_file("res://obj/menu.tscn")

func on_peer_just_disconnected(id):
	current_peer.close() #yesssss
	multiplayer.set_multiplayer_peer(null)
	get_tree().change_scene_to_file("res://obj/menu.tscn")
	



func _on_can_fruit_merge_timeout():
	emit_signal("fruit_can_merge")

