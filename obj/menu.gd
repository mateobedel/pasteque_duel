extends Node2D

@onready var titre = $titre

var t = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS 
	get_tree().root.content_scale_size = Vector2(1080,1920)
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	titre.scale.x = .8 + .05*sin(t)
	titre.scale.y = .8 + .05*cos(t)
	titre.rotation_degrees = sin(t)*2.5
	
	t+=delta*7
	if t > 2*PI: t = 0



func _on_solo_pressed():
	get_tree().change_scene_to_file("res://obj/solo.tscn")


func _on_duel_pressed():
	get_tree().change_scene_to_file("res://obj/lobby.tscn")


func _on_test_pressed():
	get_tree().change_scene_to_file("res://duel/duel.tscn")
