extends RigidBody2D

var anim_count = 0
@onready var timer = $Timer
@onready var animation_player =$AnimationPlayer
var shock_wave_radius = 600
var shock_wave_force = 2000
var DECALAGE = 890
var auth = 0

func _enter_tree():
	set_multiplayer_authority(auth)
	if !is_multiplayer_authority():
		freeze = true
	

@rpc("any_peer", "call_local", "unreliable")
func update_pos(pos, rot):
	if is_multiplayer_authority():
		return
	global_position = pos - Vector2(DECALAGE,0)
	rotation = rot

func _process(delta):
	if is_multiplayer_authority():
		update_pos.rpc(global_position,rotation)

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start(5)
	animation_player.speed_scale = .8

func _on_timer_timeout():
	animation_player.play("flash")

func shock_wave():
	for fruit in get_tree().get_nodes_in_group("Groupe_fruit"):
		if fruit.position.distance_to(position) < shock_wave_radius + fruit.radius_list[fruit.fruit_id]:
			var impulse_vector = (fruit.position - position).normalized()*shock_wave_force
			fruit.apply_central_impulse(impulse_vector)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "flash":
		if anim_count < 2:
			animation_player.speed_scale*=1.5
			animation_player.play("flash")
			anim_count+=1
		else:
			$CollisionShape2D.disabled = true
			animation_player.play("explosion")
			$explosion2.play()
			if is_multiplayer_authority():
				shock_wave()
			$sparks.emitting = false
			$explosion.emitting = true
			$death.start(3)
			

func _on_death_timeout():
	queue_free()
