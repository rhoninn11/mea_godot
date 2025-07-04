extends Area3D

signal czlonek_rodziny_blisko_domu()

func _process(delta: float) -> void:
	var node: Node3D
	
	if node.is_in_group("czlonek_rodziny"):
		czlonek_rodziny_blisko_domu.emit()
	pass
