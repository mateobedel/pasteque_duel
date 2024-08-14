extends Control

var on_ico_list = [load("res://ico/icoba.png"), load("res://ico/icoblq.png"), load("res://ico/icopa.png")]
var off_ico_list = [load("res://ico/icobd.png"), load("res://ico/icobld.png"), load("res://ico/icopd.png")]
var rdm_id

@onready var progress_bar = $TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	Event.score_updated.connect(on_score_updated)
	rdm_id = randi_range(0,2)
	$TextureButton.texture_normal = off_ico_list[rdm_id]
	$TextureButton.texture_pressed = off_ico_list[rdm_id]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	if progress_bar.value >= 100:
		Event.emit_signal("object_button_pressed", rdm_id)
		rdm_id = randi_range(0,2)
		$TextureButton.texture_normal = off_ico_list[rdm_id]
		$TextureButton.texture_pressed = off_ico_list[rdm_id]
		progress_bar.value = 0

func on_score_updated(scr):
	progress_bar.value = min(100,progress_bar.value+scr/10)
	if progress_bar.value >= 100:
		$TextureButton.texture_normal = on_ico_list[rdm_id]
		$AnimationPlayer.play("shake")


func _on_animation_player_animation_finished(anim_name):
	if progress_bar.value >= 100:
		$Timer.start(2)
	

func _on_timer_timeout():
	$AnimationPlayer.play("shake")
