extends Node2D

var next_fruit : int

var can_spawn = true
var loose = false
var TANK_TOP = 200
var TANK_BOTTOM = 910
var sprite_list = ["res://fruits/mirtille.png","res://fruits/baie.png","res://fruits/citron.png","res://fruits/bannane.png","res://fruits/orange.png","res://fruits/pomme.png","res://fruits/peche.png","res://fruits/coco.png","res://fruits/melon.png","res://fruits/ananas.png","res://fruits/pasteque.png"]
var radius_list = [37, 41, 70, 77, 91, 121, 139, 172, 188, 243, 279]
var scale_factor = .6
var DECALAGE = 890
var DEBUT_TANK = 1117
var FIN_TANK = 1748
var last_mouse_pos

@onready var fruit_viewer = $fruit_viewer

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	Event.s_launch_object.connect(on_s_launch_object)
	Event.a_player_loose.connect(on_loose)
	Event.object_button_pressed.connect(on_object_button_pressed)
	fruit_viewer.position.y = TANK_TOP
	viewer_update()
	

func viewer_update():
	next_fruit = randi_range(0,4)
	fruit_viewer.texture = load(sprite_list[next_fruit])
	update_fruit.rpc(next_fruit)

func pose_fruit():
	var fruit_scene = preload("res://duel/multi_fruit.tscn")
	var fruit_instance = fruit_scene.instantiate()
	fruit_instance.position.x = $fruit_viewer.position.x
	fruit_instance.position.y = TANK_TOP
	fruit_instance.fruit_id = next_fruit
	fruit_instance.auth = name.to_int()
	add_child(fruit_instance,true)

func _process(delta):
	
	if is_multiplayer_authority():
		

			
		#Update pos
		fruit_viewer.position.x = clamp(get_global_mouse_position().x, DEBUT_TANK+scale_factor*radius_list[next_fruit], FIN_TANK-scale_factor*radius_list[next_fruit])
		update_pos.rpc($fruit_viewer.position)
		
		if Input.is_action_just_pressed("BUTTON_LEFT"):
			last_mouse_pos = get_global_mouse_position()
		
		#Spawn_fruit
		if can_spawn && Input.is_action_just_released("BUTTON_LEFT") && not loose && last_mouse_pos.x <= FIN_TANK && last_mouse_pos.x >= DEBUT_TANK:
			$Timer.start(.4)
			can_spawn = false
			pose_fruit()
			viewer_update()
	queue_redraw()

@rpc("any_peer", "call_local", "reliable")
func launch_object(auth, type):
	var object_scene
	var object_radius
	if type == "bomb":
		object_radius = 80
		object_scene = preload("res://obj/bombe.tscn")
	elif type == "pierre":
		object_radius = 54
		object_scene = preload("res://obj/pierre.tscn")
	elif type == "ballon":
		object_radius = 74
		object_scene = preload("res://obj/ballon.tscn")
	
	var object_instance = object_scene.instantiate()
	if is_multiplayer_authority():
		object_instance.position.x = randi_range(DEBUT_TANK+object_radius,FIN_TANK-object_radius)
	else:
		object_instance.position.x = randi_range(DEBUT_TANK+object_radius-DECALAGE,FIN_TANK-object_radius-DECALAGE)
	object_instance.position.y = TANK_TOP
	object_instance.auth = auth
	add_child(object_instance)

@rpc("any_peer", "call_local", "unreliable")
func update_pos(pos):
	if is_multiplayer_authority():
		return
	$fruit_viewer.position = pos - Vector2(DECALAGE,0)

	

@rpc("any_peer", "call_local", "reliable")
func update_fruit(fid):
	if is_multiplayer_authority(): #peer de l'adversaire
		return
	$fruit_viewer.texture = load(sprite_list[fid])
		
func _draw():
	if not loose:
		if is_multiplayer_authority():
			draw_line(Vector2($fruit_viewer.position.x,TANK_TOP),Vector2($fruit_viewer.position.x, TANK_BOTTOM),"#00ff99",9,false)
		else:
			draw_line(Vector2($fruit_viewer.position.x,TANK_TOP),Vector2($fruit_viewer.position.x, TANK_BOTTOM),"#ffffff",9,false)
		
	

func on_loose(_plry):
	$fruit_viewer.texture = null
	loose = true

func _on_timer_timeout():
	can_spawn = true

func on_s_launch_object(sender_id, type):
	if sender_id == name.to_int():
		return
	if Event.current_player == 1:
		launch_object.rpc(Event.second_player, type)
	else:
		launch_object.rpc(Event.first_player, type)
	
func on_object_button_pressed(rdm_id):
	if is_multiplayer_authority():
		if rdm_id == 0:
			Event.emit_signal("s_launch_object",name.to_int(),"bomb")
		elif rdm_id == 1:
			Event.emit_signal("s_launch_object",name.to_int(),"ballon")
		elif rdm_id == 2:
			Event.emit_signal("s_launch_object",name.to_int(),"pierre")
			
