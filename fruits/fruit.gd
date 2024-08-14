extends RigidBody2D
class_name Fruit

var shock_wave_force = 300
var shock_wave_radius = 300
var max_top = 512
var can_loose = false
var can_merge = true
var loose = false

enum {MIRTILLE, BAIE, CITRON, BANNANE, ORANGE, POMME, PECHE, COCO, MELON, ANANAS, PASTEQUE}
#@export_enum("mirtille", "baie", "citron", "bannane", "orange", "pomme", "peche", "coco", "melon", "ananas", "pasteque") var fruit_id: int
var fruit_id = 2
var radius_list = [37, 41, 70, 77, 91, 121, 139, 172, 188, 243, 279]

var sprite_list = ["res://fruits/mirtille.png","res://fruits/baie.png","res://fruits/citron.png","res://fruits/bannane.png","res://fruits/orange.png","res://fruits/pomme.png","res://fruits/peche.png","res://fruits/coco.png","res://fruits/melon.png","res://fruits/ananas.png","res://fruits/pasteque.png"]

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D


func _ready():
	$can_loose.start(1)
	update_fruit_id()
	Event.fruit_loose.connect(on_loose)
	Event.fruit_merge.connect(on_fruit_merge)
	Event.fruit_can_merge.connect(on_fruit_can_merge)
	pass
	

func _process(delta):
	if position.y < max_top - radius_list[fruit_id] && can_loose && not loose:
		Event.emit_signal("fruit_loose")
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
		if position.distance_to(fruit.position) <= 2*radius_list[fruit_id]  && fruit_id == fruit.fruit_id:
			Event.emit_signal("fruit_merge",fruit_id)
			Event.start_merge_timer()
			merge(fruit)

func merge(body):
	var pos = position.lerp(body.position, 0.5);
	$CPUParticles2D.emitting = true
	$pop.play()
	fruit_evolution(body, pos)
	

func update_fruit_id():
	$CPUParticles2D.amount = remap(radius_list[fruit_id],37,279,5,50)
	$CPUParticles2D.initial_velocity_min = remap(radius_list[fruit_id],37,279,200,250)
	$CPUParticles2D.initial_velocity_max = remap(radius_list[fruit_id],37,279,400,700)
	sprite.texture = load(sprite_list[fruit_id])
	collision.shape.radius = radius_list[fruit_id]

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
		if fruit.position.distance_to(pos) < + shock_wave_radius + radius_list[fruit_id]:
			var impulse_vector = (fruit.position - pos).normalized()*shock_wave_force
			fruit.apply_central_impulse(impulse_vector)

func on_loose():
	freeze = true

func _on_can_loose_timeout():
	can_loose = true

func _on_can_merge_timeout():
	can_merge = true

func on_fruit_merge(id):
	can_merge = false

func on_fruit_can_merge():
	can_merge = true
