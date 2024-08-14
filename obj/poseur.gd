extends Node2D

var next_fruit : int

var can_spawn = true
var loose = false
var TANK_TOP = 400
var sprite_list = ["res://fruits/mirtille.png","res://fruits/baie.png","res://fruits/citron.png","res://fruits/bannane.png","res://fruits/orange.png","res://fruits/pomme.png","res://fruits/peche.png","res://fruits/coco.png","res://fruits/melon.png","res://fruits/ananas.png","res://fruits/pasteque.png"]
var radius_list = [37, 41, 70, 77, 91, 121, 139, 172, 188, 243, 279]


@onready var fruit_viewer = $fruit_viewer


# Called when the node enters the scene tree for the first time.
func _ready():
	fruit_viewer.position.y = TANK_TOP
	viewer_update()

func viewer_update():
	next_fruit = randi_range(0,4)
	fruit_viewer.texture = load(sprite_list[next_fruit])

func pose_fruit():
	var fruit_scene = preload("res://fruits/fruit.tscn")
	var fruit_instance = fruit_scene.instantiate()
	fruit_instance.position.x = get_global_mouse_position().x
	fruit_instance.position.y = TANK_TOP
	fruit_instance.fruit_id = next_fruit
	add_child(fruit_instance)

func _process(delta):
	
	fruit_viewer.position.x = get_global_mouse_position().x
	if can_spawn && Input.is_action_just_released("BUTTON_LEFT") && not loose:
		$Timer.start(.4)
		can_spawn = false
		pose_fruit()
		viewer_update()
	queue_redraw()
		
		
func _draw():
	if not loose:
		draw_line(Vector2(get_global_mouse_position().x,TANK_TOP),Vector2(get_global_mouse_position().x, 1630),"#00ff99",9,false)
	

func on_loose():
	$fruit_viewer.texture = null
	loose = true

func _on_timer_timeout():
	can_spawn = true
