extends CharacterBody2D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

const SPEED = 300.0


func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			if event.is_pressed():
				velocity.x = SPEED
			else:
				velocity.x = 0
				
func _physics_process(delta):
	# Add the gravity.
	move_and_slide()
