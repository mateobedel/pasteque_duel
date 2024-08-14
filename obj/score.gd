extends Node2D

var score = 0
var score_list = [1,5,10,20,50,100,200,500,1000,2000,5000]

# Called when the node enters the scene tree for the first time.
func _ready():
	Event.fruit_merge.connect(on_fruit_merge)
	Event.fruit_loose.connect(on_loose)


func on_fruit_merge(fruit_id):
	score += score_list[fruit_id]
	$AnimationPlayer.play("bump")
	$CenterContainer/Label.text = str(score)
	
func on_loose():
	Event.last_score = score
