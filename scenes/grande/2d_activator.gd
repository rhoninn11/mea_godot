extends Area3D

@export var node:Node

func _on_area_entered(area: Area3D) -> void:
	if not node:
		print("node not set")
		return
	
	print("i co aktywuje?")
	ControlMng.activate_alt(node)
	
