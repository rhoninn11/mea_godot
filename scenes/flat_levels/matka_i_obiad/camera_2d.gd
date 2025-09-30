extends Camera2D

var time_elapsed: float = 0

func _ready() -> void:
	self.offset = Vector2(256, 256)
	pass
	
func _process(delta: float) -> void:
	time_elapsed += delta
	
	var zoom = sin(time_elapsed) + 1
	zoom = 1
	self.zoom = Vector2(zoom, zoom)
