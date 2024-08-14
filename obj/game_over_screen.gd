extends Node2D

var score

# Called when the node enters the scene tree for the first time.
func _ready():
	score = Event.last_score
	$Label2.text = "SCORE : "+str(score)
	$PanelContainer/TextureRect2.texture = Event.last_capture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://obj/solo.tscn")


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://obj/menu.tscn")
