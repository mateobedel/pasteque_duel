extends RigidBody2D

var shock_wave_force = 300
var shock_wave_radius = 300
var max_top = 235
var can_loose = false
var can_merge = true
var loose = false
var size_factor = .6

enum {MIRTILLE, BAIE, CITRON, BANNANE, ORANGE, POMME, PECHE, COCO, MELON, ANANAS, PASTEQUE}
#@export_enum("mirtille", "baie", "citron", "bannane", "orange", "pomme", "peche", "coco", "melon", "ananas", "pasteque") var fruit_id: int
var fruit_id = 2
var radius_list = [37, 41, 70, 77, 91, 121, 139, 172, 188, 243, 279]
var DECALAGE = 890
var sprite_list = ["res://fruits/mirtille.png","res://fruits/baie.png","res://fruits/citron.png","res://fruits/bannane.png","res://fruits/orange.png","res://fruits/pomme.png","res://fruits/peche.png","res://fruits/coco.png","res://fruits/melon.png","res://fruits/ananas.png","res://fruits/pasteque.png"]

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
@export var auth : int

func _ready():
	$can_loose.start(1)
	update_fruit_id()
	Event.a_player_loose.connect(on_multi_loose)
	Event.fruit_merge.connect(on_fruit_merge)
	Event.fruit_can_merge.connect(on_fruit_can_merge)
	if not is_multiplayer_authority():
		visible = false
	
func _enter_tree():
	set_multiplayer_authority(auth)
	if not is_multiplayer_authority():
		freeze = true

func _process(delta):
	if is_multiplayer_authority():
		
		update_pos.rpc(global_position, rotation, fruit_id)
	
		#PERDU
		if position.y < max_top - size_factor*radius_list[fruit_id] && can_loose && not loose:
			
			var player = Event.current_player
			Event.emit_signal("a_player_loose", player)
			$Sprite2D.modulate = Color(1, 0, 0)
			loose = true
			
		if linear_velocity.length()>2 || abs(angular_velocity) > 1:
			check_collision()

func check_collision():
	if not can_merge:
		return
	for fruit in get_tree().get_nodes_in_group("Groupe_fruit"):
		if fruit == self:
			continue
		if position.distance_to(fruit.position) <= 2*size_factor*radius_list[fruit_id]  && fruit_id == fruit.fruit_id:
			Event.emit_signal("fruit_merge",fruit_id)
			Event.start_merge_timer()
			merge(fruit)

func merge(body):
	var pos = position.lerp(body.position, 0.5);
	$CPUParticles2D.emitting = true
	$pop.play()
	fruit_evolution(body, pos)
	
	

@rpc("any_peer", "call_local", "unreliable")
func update_pos(pos, rot, idd):
	if is_multiplayer_authority():
		return
	visible = true
	global_position = pos - Vector2(DECALAGE,0)
	rotation = rot
	fruit_id = idd
	update_fruit_id()
	

func update_fruit_id():
	$CPUParticles2D.amount = remap(size_factor*radius_list[fruit_id],size_factor*37,size_factor*279,5,50)
	$CPUParticles2D.initial_velocity_min = remap(size_factor*radius_list[fruit_id],size_factor*37,size_factor*279,200,250)
	$CPUParticles2D.initial_velocity_max = remap(size_factor*radius_list[fruit_id],size_factor*37,size_factor*279,400,700)
	sprite.texture = load(sprite_list[fruit_id])
	collision.shape.radius = size_factor*radius_list[fruit_id]

func fruit_evolution(body, pos):
	body.queue_free()
	position = pos
	fruit_id= (fruit_id+1)%11
	update_fruit_id()
	apply_shock_wave(pos, body)

func apply_shock_wave(pos, body):
	for fruit in get_tree().get_nodes_in_group("Groupe_fruit"):
		if fruit == self || fruit == body: 
			continue
		if fruit.position.distance_to(pos) < + size_factor*shock_wave_radius + size_factor*radius_list[fruit_id]:
			var impulse_vector = (fruit.position - pos).normalized()*shock_wave_force
			fruit.apply_central_impulse(impulse_vector)

func on_multi_loose(_plyr):
	freeze = true

func _on_can_loose_timeout():
	can_loose = true

func _on_can_merge_timeout():
	can_merge = true

func on_fruit_merge(_id):
	can_merge = false

func on_fruit_can_merge():
	can_merge = true
	
