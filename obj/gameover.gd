extends Label
@export var multi = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Event.fruit_loose.connect(on_loose)
	Event.a_player_loose.connect(on_multi_loose)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_loose():
	visible = true
	$AnimationPlayer.play("game_over")
	
func on_multi_loose(plyr):
	if plyr == Event.current_player:
		text = "GAME OVER"
	else:
		text = "YOU WON"
	visible = true
	$AnimationPlayer.play("game_over")
		

func _on_animation_player_animation_finished(anim_name):
	visible = false
	
	if not multi :
		get_tree().change_scene_to_file("res://obj/game_over_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://obj/multi_game_over_screen.tscn")
