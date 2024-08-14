extends Node2D

var score = 0
var score_list = [5,10,15,25,50,95,125,250,500,1000,2000]

func _enter_tree():
	if name == "score_player":
		set_multiplayer_authority(Event.current_player)
	else:
		$CenterContainer/Label.set("theme_override_colors/font_color",Color(1,1,1))
		if Event.current_player == 1:
			set_multiplayer_authority(Event.second_player)
		else:
			set_multiplayer_authority(Event.first_player)

# Called when the node enters the scene tree for the first time.
func _ready():
	Event.a_player_loose.connect(on_a_player_loose)
	if (Event.current_player == 1 && name == "score_player") || (Event.current_player != 1 && name != "score_player"):
		$CenterContainer/Label.text = "J1 : 0"
	else:
		$CenterContainer/Label.text = "J2 : 0"

	Event.fruit_merge.connect(on_fruit_merge)
	Event.update_other_score.connect(on_other_score)
	#Event.multi_fruit_loose.connect(on_loose)


func on_fruit_merge(fruit_id):
	if is_multiplayer_authority():
		score += score_list[fruit_id]
		Event.emit_signal("score_updated",score_list[fruit_id])
		$AnimationPlayer.play("bump")
		if (Event.current_player == 1 && name == "score_player") || (Event.current_player != 1 && name != "score_player"):
			$CenterContainer/Label.text = "J1 : "+str(score)
		else:
			$CenterContainer/Label.text = "J2 : "+str(score)

		update_score.rpc(score,Event.current_player)
	
@rpc("any_peer", "call_local", "reliable")
func update_score(scr, peer):
	if peer != Event.current_player:
		Event.emit_signal("update_other_score",name,scr)

func on_loose():
	Event.last_score = score

func on_other_score(nm,scr):
	if nm != name:
		score = scr
		if (Event.current_player == 1 && name == "score_player") || (Event.current_player != 1 && name != "score_player"):
			$CenterContainer/Label.text = "J1 : "+str(score)
		else:
			$CenterContainer/Label.text = "J2 : "+str(score)
			
func on_a_player_loose(lsr):
	if (Event.current_player == 1 && name == "score_player") || (Event.current_player != 1 && name != "score_player"):
		Event.first_player_score = score
	else:
		Event.second_player_score = score
