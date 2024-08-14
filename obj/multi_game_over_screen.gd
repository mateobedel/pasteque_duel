extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Event.current_player != 1:
		$HBoxContainer/rejouer.visible = false
	if Event.player_looser == 1:
		$HBoxContainer2/gagnat/VBoxContainer/P.text = "P2"
	else:
		$HBoxContainer2/gagnat/VBoxContainer/P.text = "P1"
	$HBoxContainer2/score/VBoxContainer/S.text = "P1 : "+str(Event.first_player_score)+"\n"+"P2 : "+str(Event.second_player_score)

@rpc("any_peer", "call_local", "reliable")
func change_scene():
	Event.already_loose = false
	get_tree().change_scene_to_file("res://duel/duel.tscn")

func _on_menu_pressed():
	Event.emit_signal("peer_disconnect")

func _on_rejouer_pressed():
	change_scene.rpc()
