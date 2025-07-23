extends StaticBody2D

@onready var sprite = $".."
@onready var anim = $"../../AnimationPlayer"
var holded: bool = false
var by: Node2D = null
func hold_start(node: Node2D) -> void:
	print("hallo")
	holded = true
	by = node

func hold_end() -> void:
	print("elo")
	holded = false
	
func _process(delta: float) -> void:
	if holded:
		anim.current_animation = "matka_drepta"
		var diff = sprite.position - by.position
		print(diff.x)
	else:
		anim.current_animation = "RESET"
