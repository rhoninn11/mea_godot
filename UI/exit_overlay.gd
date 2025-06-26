extends Control

@onready var rect = $exit_indicator

@export var after: float = 1
var time: float = 0
var base_size: Vector2 = Vector2(50,50)

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		time += delta
	else:
		time -= delta
		
	if time < 0:
		time = 0
		
	var progress = time/after
	var scale = 1 + progress*3
	rect.set_size(base_size*scale)
	
	if progress >= 1:
		get_tree().quit()
