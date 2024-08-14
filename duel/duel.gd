extends Node2D

var poseur_scene = preload("res://duel/multi_poseur.tscn")

var first_player = Event.first_player
var second_player = Event.second_player
var poseur1
var poseur2

# Called when the node enters the scene tree for the first time.
func _ready():
	#ROTATION ECRAN
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS 
	get_tree().root.content_scale_size = Vector2(1920,1080)

	#CREATION JOUEUR
	poseur2 = poseur_scene.instantiate()
	poseur2.name = str(second_player)
	call_deferred("add_child", poseur2)
	
	poseur1 = poseur_scene.instantiate()
	poseur1.name = str(first_player)
	call_deferred("add_child", poseur1)

	
	
	
	
	


