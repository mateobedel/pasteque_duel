extends RigidBody2D

var DECALAGE = 890
var auth = 0
var ballon_force = 300
var size_factor = .6

func _enter_tree():
	set_multiplayer_authority(auth)
	if !is_multiplayer_authority():
		freeze = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_multiplayer_authority():
		update_pos.rpc(global_position,rotation)


@rpc("any_peer", "call_local", "unreliable")
func update_pos(pos, rot):
	if is_multiplayer_authority():
		return
	global_position = pos - Vector2(DECALAGE,0)
	rotation = rot
