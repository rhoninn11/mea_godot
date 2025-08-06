extends Node2D

@export var steps: Array[Texture2D] = []
@export var look_at: Vector2
@export var curve: Curve


var sprites: Array[Sprite2D] = []

func _ready() -> void:
	for step in steps:
		var new = Sprite2D.new()
		new.texture = step
		self.add_child(new)
		sprites.append(new)
		
		print("created new sprite ", new)
	
func _process(delta: float) -> void:
	
	var step_num = len(steps)
	for i in range(step_num):
		var w = float(i)/float(step_num - 1)
		var final = look_at - self.position
		var pos = lerp(Vector2.ZERO, final, w)
		var scale = curve.sample(w)
		sprites[i].position = pos
		sprites[i].scale = Vector2(scale, 1)
